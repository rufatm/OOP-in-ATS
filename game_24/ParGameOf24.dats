//
// Title: Object-Oriented Software Principles
// Number: CAS CS 511
// Semester: Spring 2012
// Class Time: MW 1:00-2:30
// Instructor: Hongwei Xi (hwxiATcsDOTbuDOTedu)
//

(* ****** ****** *)

staload _(*anon*) = "prelude/DATS/list.dats"
staload _(*anon*) = "prelude/DATS/list_vt.dats"

(* ****** ****** *)

staload "workshop.sats"
staload "GameOf24.sats"
staload "ParGameOf24.sats"

(* ****** ****** *)

implement
workshop_add_res (ws, xs) = let
  val xs0 = workshop_get_res (ws)
  val xs1 = list_reverse_append (xs, xs0)
in
  workshop_set_res (ws, xs1)
end // end of [workshop_add_res]

(* ****** ****** *)

#define GRANUARITY 4

implement
par_task_solve
  (ws, x, n) = let
in
//
if n >= GRANUARITY then let
  val sub = task2subtask (x)
in
  par_subtask_solve (ws, sub, n, 0, 1)
end else let
  val res = task_solve (x, n)
in
  workshop_add_res (ws, res)
end (* end of [if]*)
//
end // end of [par_task_solve]

(* ****** ****** *)

implement
par_taskset_solve
  {n} (ws, xs, n) = let
  fun loop (
    xs: List (task n)
  ) :<cloref1> void =
    case+ xs of
    | list_cons (x, xs) => let
        val job = job_new_task (x, n)
        val () = workshop_put_job (ws, job)
      in
        loop (xs)
      end
    | list_nil () => ()
  // end of [loop]
  val xs = taskset2lst (xs)
in
  loop (xs)
end // end of [par_taskset_solve]

(* ****** ****** *)

implement
par_subtask_solve
  (ws, sub, n, i, j) = let
  val (xs, sub) = subtask_red1 (sub, n, i, j)
  val () = par_taskset_solve (ws, xs, n-1)
  val j1 = j + 1
in
  if j1 < n then
    par_subtask_solve (ws, sub, n, i, j1)
  else let
    val sub = subtask_red2 (sub) // subtask (n, i+1, i+2)
  in
    if i <= n-3 then
      par_subtask_solve (ws, sub, n, i+1, i+2)
    else let
      val () = subtask_red3 (subtask_red2 (sub)) in ()
    end // end of [if]
  end // end of [if]
end // end of [par_subtask_solve]

(* ****** ****** *)

implement
par_solve24 (
  nworker, n1, n2, n3, n4
) = let
  val c1 = card_make_stamp_int (1, n1)
  val c2 = card_make_stamp_int (2, n2)
  val c3 = card_make_stamp_int (3, n3)
  val c4 = card_make_stamp_int (4, n4)
  val task = task_make_cards ($lst{card}(c1, c2, c3, c4))
//
  val js =
    jobstore_make_nil ()
  
  val ws = workshop_new (js)

  val err = workshop_add_worker(ws)
  val () = assertloc(err = 0)
  val err = workshop_add_worker(ws)
  val () = assertloc(err = 0)
  val () = par_task_solve(ws,task,4)
  val r1 = job_new_quit()
  val r2 = job_new_quit()
  val () = workshop_put_job(ws,r1)
  val () = workshop_put_job(ws,r2)
  val () = workshop_wait_nwisz(ws)
//
in
  workshop_get_res (ws)
end // end of [solve24]

(* ****** ****** *)

(* end of [ParGameOf24.dats] *)