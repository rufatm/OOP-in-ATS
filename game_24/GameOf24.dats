//
// Title: Object-Oriented Software Principles
// Number: CAS CS 511
// Semester: Spring 2012
// Class Time: MW 1:00-2:30
// Instructor: Hongwei Xi (hwxiATcsDOTbuDOTedu)
//

(* ****** ****** *)

(*
** Assignment 6
** Due Time: Wednesday, February 29, 2012
** 40 points in total
*)

(* ****** ****** *)

(*
** Solving Game-of-24
*)

(* ****** ****** *)

staload "prelude/DATS/list.dats"
staload "prelude/DATS/array.dats"

(* ****** ****** *)

staload "GameOf24.sats"

(* ****** ****** *)

extern
fun task_solve_res
  {n:int | n >= 1}
  (x: task (n), n: int n, res: task1lst): task1lst
// end of [task_solve_res]

extern
fun taskset_solve_res
  {n:int | n >= 1}
  (xs: taskset (n), n: int n, res: task1lst): task1lst
// end of [taskset_solve_res]

extern
fun subtask_solve_res
  {n:int}
  {i,j:nat | i < j; j < n} (
  x: subtask (n, i, j)
, n: int n, i: int i, j: int j
, res: task1lst
) : task1lst // end of [subtask_solve_res]

(* ****** ****** *)

#define EPSILON 1E-6

implement
task1_check (x) = let
  val c = task_get_card_at (x, 0)
  val v = card_eval (c)
in
  abs (24.0 - v) < EPSILON
end

(* ****** ****** *)

implement
task_solve (x, n) = task_solve_res (x, n, list_nil)

(* ****** ****** *)

implement
task_solve_res
  (x, n, res) =
  if n >= 2 then let
    val sub = task2subtask (x) in
    subtask_solve_res (sub, n, 0, 1, res)
  end else
    if task1_check (x) then list_cons (x, res) else res
  // end of [if]
// end of [task_solve_res]

(* ****** ****** *)

implement
taskset_solve_res
  {n} (xs, n, res) = let
  val xs = taskset2lst (xs)
  fun loop (
    xs: List (task(n)), n: int n, res: task1lst
  ) : task1lst =
    case+ xs of
    | list_cons (x, xs) => let
        val res = task_solve_res (x, n, res) in loop (xs, n, res)
      end // end of [list_cons]
    | list_nil () => res
  // end of [loop]
in
  loop (xs, n, res)
end // end of [taskset_solve_res]

(* ****** ****** *)

implement
subtask_solve_res
  (sub, n, i, j, res) = let
  val (xs, sub) = subtask_red1 (sub, n, i, j)
  val res = taskset_solve_res (xs, n-1, res)
  val j1 = j + 1
in
  if j1 < n then
    subtask_solve_res (sub, n, i, j1, res)
  else let
    val sub = subtask_red2 (sub) // subtask (n, i+1, i+2)
  in
    if i <= n-3 then
      subtask_solve_res (sub, n, i+1, i+2, res)
    else let
      val () = subtask_red3 (subtask_red2 (sub)) in res
    end // end of [if]
  end // end of [if]
end // end of [subtask_solve_res]

(* ****** ****** *)

implement
solve24
  (n1, n2, n3, n4) = let
  val c1 = card_make_stamp_int (1, n1)
  val c2 = card_make_stamp_int (2, n2)
  val c3 = card_make_stamp_int (3, n3)
  val c4 = card_make_stamp_int (4, n4)
  val task = task_make_cards ($lst{card}(c1, c2, c3, c4))
in
  task_solve (task, 4)
end // end of [solve24]

(* ****** ****** *)

local

datatype card =
  | CARDatm of
      (int(*stamp*), double)
  | CARDadd of (card, card)
  | CARDsub of (card, card)
  | CARDmul of (card, card)
  | CARDdiv of (card, card)
// end of [card]

assume card_type = card

in // in of [local]

fun
fprint_opr_card_card (
  out: FILEref, opr: string, c1: card, c2: card
) : void = {
  macdef prstr (s) = fprint_string (out, ,(s))
  val () = prstr "("
  val () = fprint_card (out, c1)
  val () = prstr (opr)
  val () = fprint_card (out, c2)
  val () = prstr ")"
} // end of [fprint_opr_card_card]

implement
fprint_card (out, c) = let
  macdef prstr (s) = fprint_string (out, ,(s))
in
  case+ c of
  | CARDatm (stamp, v) => let
      val v = int_of_double (v) in fprintf (out, "%i[%i]", @(v, stamp))
    end // end of [val]
  | CARDadd (c1, c2) => fprint_opr_card_card (out, " + ", c1, c2)
  | CARDsub (c1, c2) => fprint_opr_card_card (out, " - ", c1, c2)
  | CARDmul (c1, c2) => fprint_opr_card_card (out, " * ", c1, c2)  
  | CARDdiv (c1, c2) => fprint_opr_card_card (out, " / ", c1, c2)  
end // end of [fprint_card]

implement
card_make_stamp_int
  (stamp, n) = CARDatm (stamp, double_of_int n)
// end of [card_make_stamp_int]

implement add_card_card (c1, c2) = CARDadd (c1, c2)
implement sub_card_card (c1, c2) = CARDsub (c1, c2)
implement mul_card_card (c1, c2) = CARDmul (c1, c2)
implement div_card_card (c1, c2) = CARDdiv (c1, c2)

implement
card_eval (c) =
  case+ c of
  | CARDatm (_, v) => v
  | CARDadd (c1, c2) => card_eval (c1) + card_eval (c2)
  | CARDsub (c1, c2) => card_eval (c1) - card_eval (c2)
  | CARDmul (c1, c2) => card_eval (c1) * card_eval (c2)
  | CARDdiv (c1, c2) => card_eval (c1) / card_eval (c2)
// end of [card_eval]

end // end of [local]

(* ****** ****** *)

local

assume task (n:int) = array (card, n)
assume subtask (n:int, i:int, j:int) = task(n)
assume taskset(n:int) = List (task(n))

in // in of [local]

implement
task_make_cards
  (cs) = let
  val n = list_length (cs)
in
  array_make_lst ((size1_of_int1)n, cs)
end // end of [task_make_cards]

implement task_get_card_at (x, i) = x[i]

implement
task_rem2_add1 {n}
  (x, n, i, j, c) = x1 where {
  val n1 = n - 1
  val asz = size1_of_int1 (n1)
  val x1 = array_make_elt<card> (asz, c)
  fun loop
    {k,k1:nat | k <= n}
    .<n-k>. (
    x1: task (n-1), k: int k, k1: int k1
  ) :<cloref1> void =
    if (k < n) then
      if k = i then loop (x1, k+1, k1)
      else if k = j then loop (x1, k+1, k1)
      else let
        val () =
          if k1 < n1 then x1[k1] := x[k]
        // end of [val]
      in
        loop (x1, k+1, k1+1)
      end
    (* end of [if] *)
  // end of [loop]
  val () = loop (x1, 0, 1)
} // end of [task_rem2_add1]

implement taskset2lst (xs) = xs

implement task2subtask (x) = x

implement
subtask_red1
  {n} (x, n, i, j) = let
  val ci = task_get_card_at (x, i)
  val cj = task_get_card_at (x, j)
//
  val c1 = add_card_card (ci, cj)
  val x1 = task_rem2_add1 (x, n, i, j, c1)
//
  val c21 = sub_card_card (ci, cj)
  val x21 = task_rem2_add1 (x, n, i, j, c21)
  val c22 = sub_card_card (cj, ci)
  val x22 = task_rem2_add1 (x, n, i, j, c22)
//
  val c3 = mul_card_card (ci, cj)
  val x3 = task_rem2_add1 (x, n, i, j, c3)
//
  val c41 = div_card_card (ci, cj)
  val x41 = task_rem2_add1 (x, n, i, j, c41)
  val c42 = div_card_card (cj, ci)
  val x42 = task_rem2_add1 (x, n, i, j, c42)
//
  val xs = $lst{task(n-1)} (x1, x21, x22, x3, x41, x42)
//
in
  (xs, x)
end // end of [subtask_red1]

implement subtask_red2 (x) = x
implement subtask_red3 (x) = ()

end // end of [local]

(* ****** ****** *)

(* end of [Gameof24.dats] *)