(* $Id$ *)

open Easy_format

let format_float x =
  Atom (string_of_float x)

let format_array ~align_closing f a =
  let l = Array.to_list (Array.map f a) in
  List (("[|", ";", "|]", 
	 { spaced_list with align_closing = align_closing }),
	l)

let format_matrix ~align_closing m =
  format_array ~align_closing (format_array ~align_closing format_float) m

let tuple_param = 
  { compact_list with space_after_separator = true }

let format_tuple f l =
  List (("(", ",", ")", tuple_param), List.map f l)

let format_record f l0 =
  let l = 
    List.map (fun (s, x) -> Label ((Atom (s ^ ":"), spaced_label), f x)) l0 in
  List (("{", ";", "}", spaced_list), l)

let format_function_definition name param body =
  Label (
    (
      Label (
	(Atom ("function " ^ name), spaced_label),
	List (("(", ",", ")", tuple_param), List.map (fun s -> Atom s) param)
      ), 
      spaced_label
    ),
    List (("{", ";", "}", spaced_list), List.map (fun s -> Atom s) body)
  )

let print_margin () =
  let margin = Format.get_margin () in
  print_newline ();
  for i = 1 to margin do
    print_char '+'
  done;
  print_newline ()

let print_matrix ~align_closing m =
  print_margin ();
  Pretty.to_stdout (format_matrix ~align_closing m);
  print_newline ()

let print_tuple l =
  print_margin ();
  Pretty.to_stdout (format_tuple format_float l);
  print_newline ()

let print_function_definition ~margin name param body =
  let margin0 = Format.get_margin () in
  Format.set_margin margin;
  print_margin ();
  Pretty.to_stdout (format_function_definition name param body);
  Format.set_margin margin0;
  print_newline ()

let _ =
  (* Triangular array of arrays showing wrapping of lists of atoms *)
  let m = Array.init 30 (fun i -> Array.init i float) in
  print_matrix ~align_closing:true m;
  print_matrix ~align_closing:false m;

  (* A simple tuple that fits on one line *)
  print_tuple [ 1.; 2.; 3.; 4. ];
  print_newline ();

  (* A function definition, showed with different right-margin settings *)
  List.iter (
    fun margin ->
      print_function_definition ~margin
	"hello" ["arg1";"arg2";"arg3"] [
	  "print \"hello\"";
	  "return foo"
	];
      print_newline ()
  ) [ 10; 20; 30; 40; 80 ]
