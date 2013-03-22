open Printf

let set_delim r s =
  match s with
    | "TAB" -> r := '\t'
    | s when String.length s = 1 -> r := s.[0]
    | s ->
        raise
          (Arg.Bad "Delimiter must be a single ascii character or TAB")

let main () =
  let delim_in = ref ',' in
  let delim_out = ref ',' in
  let options = [
    "-din", Arg.String (set_delim delim_in),
    "<delimiter>
          Input field delimiter (byte or the string 'TAB'; default: ',')";
    "-dout", Arg.String (set_delim delim_out),
    "<delimiter>
          Output field delimiter (byte or the string 'TAB'; default: ',')";
  ]
  in
  let anon_fun s = raise (Arg.Bad ("Don't know what to do with " ^ s)) in
  let usage_msg = "Usage: csv2json [options]\nOptions:\n" in
  Arg.parse options anon_fun usage_msg;
  let ic = stdin in
  let oc = stdout in
  let input = Csv.of_channel ~separator: !delim_in ic in
  let output = Csv.to_channel ~separator: !delim_out oc in
  try
    while true do
      Csv.output_record output (Csv.next input)
    done;
    assert false

  with End_of_file ->
    flush oc

let () = main ()
