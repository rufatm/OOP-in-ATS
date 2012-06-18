//
// Title: Object-Oriented Software Principles
// Number: CAS CS 511
// Semester: Spring 2012
// Class Time: MW 1:00-2:30
// Instructor: Hongwei Xi (hwxiATcsDOTbuDOTedu)
//

(* ****** ****** *)

staload "workshop.sats"
staload "GameOf24.sats"

(* ****** ****** *)

fun job_new_task
  {n:int | n >= 1} (x: task n, n: int n): job
// end of [job_new_task]

fun job_new_quit (): job

(* ****** ****** *)

fun workshop_get_res
  (ws: workshop): task1lst = "workshop_get_res"
fun workshop_set_res
  (ws: workshop, xs: task1lst): void = "workshop_set_res"
// end of [workshop_set_res]

fun workshop_add_res (ws: workshop, xs: task1lst): void

(* ****** ****** *)

fun par_task_solve
  {n:int | n >= 1}
  (ws: workshop, x: task (n), n: int n): void
// end of [par_task_solve]

(* ****** ****** *)

fun par_taskset_solve
  {n:int | n >= 1}
  (ws: workshop, xs: taskset (n), n: int n): void
// end of [par_taskset_solve]

(* ****** ****** *)

fun
par_subtask_solve
  {n:int}
  {i,j:nat | i < j; j < n} (
  ws: workshop
, sub: subtask (n, i, j)
, n: int n, i: int i, j: int j
) : void // end of [subtask_solve]

(* ****** ****** *)

(*
** HX-2012-03:
** solving Game-of-24 by using [nworker] threads
*)
fun par_solve24 (
  nworker: uint, n1: int, n2: int, n3: int, n4: int
) : task1lst // end of [par_solve24]

(* ****** ****** *)

(* end of [ParGameOf24.sats] *)