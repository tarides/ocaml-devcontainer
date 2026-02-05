(** A simple library demonstrating inline and expect tests *)

let add x y = x + y

let%test "add positive numbers" =
  add 2 3 = 5

let%test "add with zero" =
  add 0 42 = 42

let greet name =
  Printf.sprintf "Hello, %s!" name

let%expect_test "greet output" =
  print_endline (greet "World");
  [%expect {| Hello, World! |}]

let fibonacci n =
  let rec fib a b count =
    if count <= 0 then a
    else fib b (a + b) (count - 1)
  in
  fib 0 1 n

let%test "fibonacci base cases" =
  fibonacci 0 = 0 && fibonacci 1 = 1

let%test "fibonacci sequence" =
  fibonacci 10 = 55
