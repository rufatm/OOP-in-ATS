//
// Title: Object-Oriented Software Principles
// Number: CAS CS 511
// Semester: Spring 2012
// Class Time: MW 1:00-2:30
// Instructor: Hongwei Xi (hwxiATcsDOTbuDOTedu)
//

(* ****** ****** *)

(*
** Implementing a workshop
*)

(* ****** ****** *)

staload "workshop.sats"
staload "GameOf24.sats"
staload "ParGameOf24.sats"

(* ****** ****** *)

dataviewtype
job_ =
  | {n:int | n >= 1}
    JOBtask of (task n, int n)
  | JOBquit of ()
assume job = job_

(* ****** ****** *)

implement
job_new_task
  (task, n) = JOBtask (task, n)
// end of [job_new_task]

implement job_new_quit () = JOBquit ()

(* ****** ****** *)

implement
job_get_kind (x) =
  case+ x of
  | JOBtask _ => (fold@ (x); 1)
  | JOBquit _ => (fold@ (x); 0)
// end of [job_get_kind]

(* ****** ****** *)

implement
job_get_priority (x) =
  case+ x of
  | JOBtask _ => (fold@ (x); 0)
  | JOBquit _ => (fold@ (x); 1)
// end of [job_get_priority]

(* ****** ****** *)

implement
job_finish (ws, x) = (
  case+ x of
  | ~JOBtask (task, n) => par_task_solve (ws, task, n)
  | ~JOBquit () => ()
) // end of [job_finish]

(* ****** ****** *)

(* end of [workshop_job.dats] *)