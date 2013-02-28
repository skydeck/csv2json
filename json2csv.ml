open Printf

let string_of_json (x : Yojson.Basic.json) =
  match x with
    | `String s -> s
    | `Int i -> string_of_int i
    | `Float f -> sprintf "%f" f
    | `Bool b -> if b then "1" else "0"
    | `Null -> ""
    | `List _
    | `Assoc _ -> Yojson.Basic.to_string x

let get_field k json =
  match json with
      `Assoc l ->
        (try string_of_json (List.assoc k l)
         with Not_found -> "")
    | _ -> ""

let translate_record oc colnames json =
  let row = List.map (fun k -> get_field k json) colnames in
  Csv.output_record oc row

let main () =
  let delim = ref ',' in
  let no_header = ref false in
  let colnames = ref [] in
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

    "-n", Arg.Set no_header,
    "
          Omit header row containing field names."
  ]
  in
  let anon_fun s = colnames := s :: !colnames in
  let usage_msg = "\
Usage: json2csv [options] COLNAME1 [COLNAME2 ...]
Options:
"
  in
  Arg.parse options anon_fun usage_msg;
  let colnames = List.rev !colnames in
  let ic = stdin in
  let oc = stdout in
  let stream = Yojson.Basic.stream_from_channel ic in
  let csv_out = Csv.to_channel ~separator: !delim oc in
  if not !no_header then
    Csv.output_record csv_out colnames;
  Stream.iter (translate_record csv_out colnames) stream;
  flush oc

let () = main ()
