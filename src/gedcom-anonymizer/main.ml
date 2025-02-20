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

let arg_usage =
  Printf.sprintf "gedcom-anonymizer [OPTIONS] FILE\n%s"
    ( String.concat "\n"
        [
          "Anonymize a GEDCOM file '$FILE', creating a file '$FILE.anon.ged'.";
          "All the line values are modified, except the identifiers";
          "The following OPTIONS are available:";
        ])

let () =
  let arg_list = [] in
  Arg.parse
    arg_list
    (fun fname ->
       Gedcom_anonymizer_lib.Main.anon_file fname (fname^".anon.ged")
    )
    arg_usage;
  exit 0
