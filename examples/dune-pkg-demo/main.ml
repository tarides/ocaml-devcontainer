(** Demo application using dune package management *)

open Cmdliner

let name =
  let doc = "Name to greet" in
  Arg.(value & opt string "World" & info ["n"; "name"] ~doc)

let greet name =
  Printf.printf "Hello, %s! (Built with dune pkg)\n" name

let greet_cmd =
  let doc = "A simple greeting program" in
  let info = Cmd.info "dune_pkg_demo" ~doc in
  Cmd.v info Term.(const greet $ name)

let () = exit (Cmd.eval greet_cmd)
