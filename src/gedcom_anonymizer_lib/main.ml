(**************************************************************************)
(*                                                                        *)
(*  Copyright (c) 2022 OCamlPro SAS                                       *)
(*                                                                        *)
(*  All rights reserved.                                                  *)
(*  This file is distributed under the terms of the GNU Lesser General    *)
(*  Public License version 2.1, with the special exception on linking     *)
(*  described in the LICENSE.md file in the root directory.               *)
(*                                                                        *)
(*                                                                        *)
(**************************************************************************)


let anon_file file =
  let lines = EzFile.read_lines file in

  let lines = Array.map Gedcom.parse_line lines in

  let new_table kind =
    let names = Hashtbl.create 1111 in
    let name_counter = ref 0 in
    let add_name name =
      match Hashtbl.find names name with
      | _n -> ()
      | exception Not_found ->
          incr name_counter ;
          Hashtbl.add names name !name_counter
    in
    let get_name name =
      Printf.sprintf "%s%d" kind (Hashtbl.find names name) in
    add_name, get_name
  in

  let add_firstname, get_firstname = new_table "FirstName" in
  let add_surname, get_surname = new_table "SurName" in
  let add_place, get_place = new_table "Address,City" in

  let add_name, get_name =
    let split name =
      match EzString.split name '/' with
        [firstname ; surname ; "" ] -> firstname, surname
      | _ -> name, ""
    in
    let add_name name =
      let firstname, surname = split name in
      add_firstname firstname ;
      add_surname surname
    in
    let get_name name =
      let firstname, surname = split name in
      let firstname = get_firstname firstname in
      let surname = get_surname surname in
      Printf.sprintf "%s /%s/" firstname surname
    in
    add_name, get_name
  in

  let dates = ref [] in
  let add_date date =
    let date = EzString.split date ' ' in
    dates := List.rev date :: !dates
  in

  Array.iter (function (_num, _opt, tag, arg) ->
    match tag, arg with
    | "NAME", Some name -> add_name name
    | "PLAC", Some name -> add_place name
    | "DATE", Some date -> add_date date
    | _ -> ()
    ) lines;

  let dates = Array.of_list !dates in
  Array.sort compare dates;
  let alldates = Hashtbl.create 1111 in
  let months = [|
    "JAN" ; "FEB"; "MAR"; "APR"; "MAY"; "JUN";
    "JUL" ; "AUG"; "SEP"; "OCT"; "NOV"; "DEC";
  |]
  in
  Array.iteri (fun i date ->
      let date = String.concat " " (List.rev date) in
      let day = i mod 10 in
      let mon = (i / 10 ) mod 12 in
      let year = i / 120 in

      Hashtbl.add alldates date
        (Printf.sprintf "%d %s %d" (3 * day+1)
           months.(mon) (1000 + year))
    ) dates;
  let get_date date = Hashtbl.find alldates date in

  let lines = Array.map (function (indent, maybe_s, tag, arg) ->
    let arg =
      match tag, arg with
      | "NAME", Some name -> Some ( get_name name )
      | "PLAC", Some name -> Some ( get_place name )
      | "DATE", Some date -> Some ( get_date date )
      | _ -> arg
    in
    (indent, maybe_s, tag, arg)
    ) lines in

  let lines = Array.map (function (indent, maybe_s, tag, arg) ->
      Printf.sprintf "%s%d%s %s %s"
        (String.make indent ' ') indent
        (match maybe_s with
         | None -> ""
         | Some s -> Printf.sprintf " @%s" s)
        tag
        (match arg with
         | None -> ""
         | Some s -> s)
    ) lines in

  EzFile.write_lines ( file ^ ".anon") lines;
  exit 0

let main () =

  let arg_usage =
    Printf.sprintf "gedcom-anonymizer [OPTIONS] FILE\n%s"
      ( String.concat "\n"
          [
        "Anonymize a GEDCOM file '$FILE', creating a file '$FILE.anon'. The following fields are modified:";
        " * NAME: replaced by 'FirstNameNUM1 /SurNameNUM2/'";
        " * PLAC: replaced by 'Address,CityNUM'";
        " * DATE: replaced by another date starting at year 1000, maintaining the same order between all date";
        "where NUM are counters";
        "";
        "The following OPTIONS are available:";
      ])
  in
  let arg_list = [] in
  let arg_anon = anon_file in
  Arg.parse arg_list arg_anon arg_usage;
  Arg.usage arg_list arg_usage;
  exit 2
