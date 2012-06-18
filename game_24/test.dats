(*
** Solving Game-of-24
*)

(* ****** ****** *)

staload "prelude/DATS/list.dats"

(* ****** ****** *)

staload "GameOf24.sats"
staload "ParGameOf24.sats"

(* ****** ****** *)
//
dynload "workshop.dats"
dynload "workshop_job.dats"
dynload "workshop_jobstore_hp.dats"
//
dynload "GameOf24.dats"
dynload "ParGameOf24.dats"
//
(* ****** ****** *)

fun solve24_and_show (
  n1: int, n2: int, n3: int, n4: int
) : void = let
  val xs = par_solve24 (2u, n1, n2, n3, n4)
in
  if list_is_cons (xs) then {
   val  () = println!
      ("Here is the list of all the solutions:")
    val () = loop (xs) where {
      fun loop (xs: task1lst): void =
        case+ xs of
        | list_cons (x, xs) => let
            val c = task_get_card_at (x, 0)
            val () = fprint_card (stdout_ref, c)
            val () = print_newline ()
          in
            loop (xs)
          end // end of [list_cons]
        | list_nil () => ()
      // end of [loop]
    } // end of [val]
  } else
    println! ("There is no solution found:")
  // end of [if]
end // end of [solve24_and_show]

(* ****** ****** *)

implement
main () = () where {
  val () = solve24_and_show (2, 3, 5, 12)
  val () = solve24_and_show (3, 5, 7, 13)
  val () = solve24_and_show (4, 4, 10, 10)
  val () = solve24_and_show (5, 5, 7, 11)
  val () = solve24_and_show (5, 7, 7, 11)
} // end of [main]

(* ****** ****** *)

(* end of [test.dats] *)