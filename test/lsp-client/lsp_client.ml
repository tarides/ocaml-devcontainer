let request_id = ref 0

(* JSON-RPC 2.0 with Content-Length framing *)

let send oc (msg : Yojson.Safe.t) =
  let content = Yojson.Safe.to_string msg in
  let header = Printf.sprintf "Content-Length: %d\r\n\r\n" (String.length content) in
  output_string oc header;
  output_string oc content;
  flush oc

let read_headers ic =
  let headers = Hashtbl.create 4 in
  let rec loop () =
    let line = input_line ic in
    let line = String.trim line in
    if line = "" then headers
    else begin
      (match String.split_on_char ':' line with
       | key :: rest ->
         let value = String.trim (String.concat ":" rest) in
         Hashtbl.replace headers key value
       | _ -> ());
      loop ()
    end
  in
  loop ()

let receive ic =
  let headers = read_headers ic in
  let content_length =
    int_of_string (Hashtbl.find headers "Content-Length")
  in
  let buf = Bytes.create content_length in
  really_input ic buf 0 content_length;
  Yojson.Safe.from_string (Bytes.to_string buf)

(* Skip server-initiated notifications (no "id" field) and return the
   next response that carries an "id". This prevents flaky tests when
   ocamllsp sends unsolicited notifications such as publishDiagnostics
   before replying to our request. *)
let receive_response ic =
  let rec loop () =
    let msg = receive ic in
    match Yojson.Safe.Util.member "id" msg with
    | `Null -> loop ()
    | _ -> msg
  in
  loop ()

let request oc ic method_ params =
  incr request_id;
  let msg =
    `Assoc
      ([ ("jsonrpc", `String "2.0");
         ("id", `Int !request_id);
         ("method", `String method_) ]
       @ (match params with
          | Some p -> [ ("params", p) ]
          | None -> []))
  in
  send oc msg;
  receive_response ic

let notify oc method_ params =
  let msg =
    `Assoc
      ([ ("jsonrpc", `String "2.0");
         ("method", `String method_) ]
       @ (match params with
          | Some p -> [ ("params", p) ]
          | None -> []))
  in
  send oc msg

(* URI helpers *)

let file_uri path =
  let abs =
    if Filename.is_relative path then Filename.concat (Sys.getcwd ()) path
    else path
  in
  "file://" ^ abs

(* LSP commands *)

let initialize oc ic root_path =
  let root_uri = file_uri root_path in
  let params =
    `Assoc
      [ ("processId", `Null);
        ("rootUri", `String root_uri);
        ("capabilities",
         `Assoc
           [ ("textDocument",
              `Assoc
                [ ("hover",
                   `Assoc
                     [ ("contentFormat",
                        `List [ `String "markdown"; `String "plaintext" ]) ]);
                  ("completion",
                   `Assoc
                     [ ("completionItem",
                        `Assoc [ ("snippetSupport", `Bool false) ]) ]);
                  ("formatting", `Assoc []) ]) ]) ]
  in
  let result = request oc ic "initialize" (Some params) in
  notify oc "initialized" (Some (`Assoc []));
  result

let did_open oc file_path =
  let uri = file_uri file_path in
  let content =
    let ch = open_in file_path in
    Fun.protect
      ~finally:(fun () -> close_in ch)
      (fun () ->
        let len = in_channel_length ch in
        really_input_string ch len)
  in
  notify oc "textDocument/didOpen"
    (Some
       (`Assoc
          [ ("textDocument",
             `Assoc
               [ ("uri", `String uri);
                 ("languageId", `String "ocaml");
                 ("version", `Int 1);
                 ("text", `String content) ]) ]))

let hover oc ic file_path line col =
  let uri = file_uri file_path in
  request oc ic "textDocument/hover"
    (Some
       (`Assoc
          [ ("textDocument", `Assoc [ ("uri", `String uri) ]);
            ("position",
             `Assoc [ ("line", `Int line); ("character", `Int col) ]) ]))

let completion oc ic file_path line col =
  let uri = file_uri file_path in
  request oc ic "textDocument/completion"
    (Some
       (`Assoc
          [ ("textDocument", `Assoc [ ("uri", `String uri) ]);
            ("position",
             `Assoc [ ("line", `Int line); ("character", `Int col) ]) ]))

let formatting oc ic file_path =
  let uri = file_uri file_path in
  request oc ic "textDocument/formatting"
    (Some
       (`Assoc
          [ ("textDocument", `Assoc [ ("uri", `String uri) ]);
            ("options",
             `Assoc
               [ ("tabSize", `Int 2); ("insertSpaces", `Bool true) ]) ]))

let shutdown oc ic =
  let result = request oc ic "shutdown" None in
  notify oc "exit" None;
  result

(* Subprocess management *)

let with_lsp_server f =
  let in_r, in_w = Unix.pipe () in
  let out_r, out_w = Unix.pipe () in
  let pid =
    Unix.create_process "ocamllsp" [| "ocamllsp" |] in_r out_w Unix.stderr
  in
  Unix.close in_r;
  Unix.close out_w;
  let oc = Unix.out_channel_of_descr in_w in
  let ic = Unix.in_channel_of_descr out_r in
  Fun.protect
    ~finally:(fun () ->
      (try close_out oc with _ -> ());
      (try close_in ic with _ -> ());
      (try Unix.kill pid Sys.sigterm with _ -> ());
      ignore (Unix.waitpid [] pid))
    (fun () -> f oc ic)

let () =
  if Array.length Sys.argv < 2 then begin
    Printf.eprintf
      "Usage: lsp_client <command> [args...]\n\
       Commands:\n\
      \  initialize [root]           Initialize LSP server\n\
      \  hover <file> <line> <col>   Request hover info\n\
      \  completion <file> <line> <col>  Request completions\n\
      \  format <file>               Request formatting\n\
      \  shutdown                    Send shutdown request\n";
    exit 1
  end;
  let command = Sys.argv.(1) in
  with_lsp_server (fun oc ic ->
    match command with
    | "initialize" ->
      let root = if Array.length Sys.argv > 2 then Sys.argv.(2) else "." in
      let result = initialize oc ic root in
      print_endline (Yojson.Safe.pretty_to_string result)
    | "hover" ->
      if Array.length Sys.argv < 5 then begin
        Printf.eprintf "Usage: lsp_client hover <file> <line> <col>\n";
        exit 1
      end;
      ignore (initialize oc ic ".");
      let file_path = Sys.argv.(2) in
      let line = int_of_string Sys.argv.(3) in
      let col = int_of_string Sys.argv.(4) in
      did_open oc file_path;
      let result = hover oc ic file_path line col in
      print_endline (Yojson.Safe.pretty_to_string result)
    | "completion" ->
      if Array.length Sys.argv < 5 then begin
        Printf.eprintf "Usage: lsp_client completion <file> <line> <col>\n";
        exit 1
      end;
      ignore (initialize oc ic ".");
      let file_path = Sys.argv.(2) in
      let line = int_of_string Sys.argv.(3) in
      let col = int_of_string Sys.argv.(4) in
      did_open oc file_path;
      let result = completion oc ic file_path line col in
      print_endline (Yojson.Safe.pretty_to_string result)
    | "format" ->
      if Array.length Sys.argv < 3 then begin
        Printf.eprintf "Usage: lsp_client format <file>\n";
        exit 1
      end;
      ignore (initialize oc ic ".");
      let file_path = Sys.argv.(2) in
      did_open oc file_path;
      let result = formatting oc ic file_path in
      print_endline (Yojson.Safe.pretty_to_string result)
    | "shutdown" ->
      ignore (initialize oc ic ".");
      let result = shutdown oc ic in
      print_endline (Yojson.Safe.pretty_to_string result)
    | _ ->
      Printf.eprintf "Unknown command: %s\n" command;
      exit 1)
