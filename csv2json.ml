open Printf

let main () =
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
  ]
  in
  let anon_fun s = raise (Arg.Bad ("Don't know what to do with " ^ s)) in
  let usage_msg = "Usage: csv2json [options]\nOptions:\n" in
  Arg.parse options anon_fun usage_msg;
  let ic = stdin in
  let oc = stdout in
  let stream = Csv.of_channel ~separator: !delim ic in
  let errors = ref 0 in
  try
    let head = Csv.next stream in
    while true do
      try
        let pairs =
          let x = Csv.next stream in
          try List.combine head x
          with _ -> incr errors; raise Exit
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
