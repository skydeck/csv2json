open Printf

type header_kind = First_line | Numbered of int

let make_numbered_labels first l =
  let _, acc =
    List.fold_left
      (fun (i, acc) x -> (i+1, (string_of_int i, x) :: acc))
      (first, []) l
  in
  List.rev acc

let main () =
  let header_kind = ref First_line in
  let delim = ref ',' in
  let options = [
    "-d", Arg.String (
      function
        | "TAB" -> delim := '\t'
        | s when String.length s = 1 -> delim := s.[0]
        | s ->
            raise
              (Arg.Bad "Delimiter must be a single ascii character or TAB")
    ),
    "<delimiter>
          Field delimiter (single byte or the string 'TAB'; default: ',')";

    "-n", Arg.Unit (fun () -> header_kind := Numbered 1),
    "
          Use numbers for field labels, treat first row as data";

    "-n0", Arg.Unit (fun () -> header_kind := Numbered 0),
    "
          Use numbers for field labels starting from 0,
          treat first row as data";

    "-n1", Arg.Unit (fun () -> header_kind := Numbered 0),
    "
          Use numbers for field labels starting from 1,
          treat first row as data (same as -n)";
  ]
  in
  let anon_fun s = raise (Arg.Bad ("Don't know what to do with " ^ s)) in
  let usage_msg = "Usage: csv2json [options]\nOptions:\n" in
  Arg.parse options anon_fun usage_msg;
  let ic = stdin in
  let oc = stdout in
  let stream = Csv.of_channel ~separator: !delim ic in
  let errors = ref 0 in
  let header_kind = !header_kind in
  try
    let head =
      match header_kind with
          First_line -> Csv.next stream
        | Numbered first -> []
    in
    while true do
      try
        let pairs =
          let row = Csv.next stream in
          match header_kind with
              First_line ->
                (try List.combine head row
                 with _ -> incr errors; raise Exit)
            | Numbered first ->
                make_numbered_labels first row
        in
        let fields =
          List.fold_right (
            fun (k, v) acc ->
              match v with
                  "" -> acc
                | v -> (k, `String v) :: acc
          ) pairs []
        in
        fprintf oc "%s\n" (Yojson.Basic.to_string (`Assoc fields))
      with Exit -> ()
    done;
    assert false

  with End_of_file ->
    flush oc;
    if !errors <> 0 then (
      eprintf "%i errors\n%!" !errors;
      false
    )
    else
      true

let () =
  if main () then exit 0
  else exit 1
