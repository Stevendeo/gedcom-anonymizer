(*
Copyright (c) 2014 Julien Sagot

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*)

(** {1 GEDCOM 5.5.1 handling in OCaml.} *)
(* extracted from Gedcom OPAM package of Julien Sagot to remove
   recursive types *)

(** {2 Parsing function.} *)

(** [(LVL, XREF_ID, TAG, VALUE)] *)
type gedcom_line = int * string option * string * string option

(** You will need to use [-rectypes] compiler flag with this type. *)
type gedcom_node = Node of gedcom_line * gedcom_node list

(** Parse a GEDCOM line. *)
val parse_line : string -> gedcom_line

(** Read a list of lines from an [in_channel] and return the
    [gedcom_line list] corresponding. *)
val parse_lines : in_channel -> gedcom_line list

(** Turn a list of [gedcom_line] into a tree using tags level. *)
val mk_tree : gedcom_line list -> gedcom_node list

(** {2 [gedcom_line] getters.} *)

(** Get the level of a [gedcom_line] *)
val lvl : gedcom_line -> int

(** Get the xref of a [gedcom_line].
    Raise [Not_found] if no such information is present. *)
val xref : gedcom_line -> string

(** Get the tag of a [gedcom_line]. *)
val tag : gedcom_line -> string

(** Get the value of a [gedcom_line].
    Raise [Not_found] if no such information is present. *)
val value : gedcom_line -> string

(** {2 [gedcom_node] getters.} *)

(** Get node value, i.e. the current [gedcom_line]. *)
val node : gedcom_node -> gedcom_line

(** Get node children. *)
val children : gedcom_node -> gedcom_node list

(** {2 Helpers module.} *)

module GedcomHelpers : sig

    (** Concatenation of CONT / CONC lines groups. *)
    val concat : gedcom_line list -> gedcom_line list

    (** Trim characters which are not part of the [xref]
        (i.e. leading and trailing ' ' and '@') *)
    val trim_xref : string -> string

    (** Split name in first name / last name / title. *)
    val parse_name :
      string -> (string option * string option * string option)

    (** Extract first name part of a gedcom name or raise
        [Not_found]. *)
    val name_first :
      (string option * string option * string option) -> string

    (** Extract last name part of a gedcom name or raise
        [Not_found]. *)
    val name_last :
      (string option * string option * string option) -> string

    (** Extract title part of a gedcom name or raise
        [Not_found]. *)
    val name_title :
      (string option * string option * string option) -> string

  end

(** {2 Printing module (on stdout).} *)

module GedcomPrint : sig

    (** Print a [gedcom_line], without new line at the end. *)
    val print_gedcom_line : gedcom_line -> unit

    (** Print a [gedcom_nocde], without new line at the end. *)
    val print_gedcom_node : gedcom_node -> unit

  end
