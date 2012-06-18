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

staload HP = "libats/SATS/linheap_binomial.sats"
staload _(*anon*) = "libats/DATS/linheap_binomial.dats"

(* ****** ****** *)

staload "workshop.sats"

(* ****** ****** *)

absviewtype myjob = $extype"myjob"

extern castfn job2myjob (x: job): myjob
extern castfn myjob2job (x: myjob): job

(* ****** ****** *)

extern
fun myjob_get_priority (x: !myjob):<> int
implement
myjob_get_priority (x) = let
  val x = __copy (x) where {
  extern
    castfn __copy (x: !myjob):<> job 
  }
  val pri = job_get_priority (x)
  val _ = __free (x) where {
    extern castfn __free (x: job):<> ptr
  }
in
  pri
end // end of [myjob_get_priority]

(* ****** ****** *)

val cmp = lam (
  x1: &myjob, x2: &myjob
) : int =<cloref>
  compare (myjob_get_priority x1, myjob_get_priority x2)
// end of [val]

implement
$HP.compare_elt_elt<myjob>
  (x1, x2, cmp) = 
  compare (myjob_get_priority x1, myjob_get_priority x2)
// end of [$HP.compare_elt_elt]

(* ****** ****** *)

assume jobstore = $HP.heap (myjob)

(* ****** ****** *)

implement
jobstore_make_nil () = $HP.linheap_make_nil ()

(* ****** ****** *)

implement
jobstore_isemp (js) = $HP.linheap_is_empty (js)
implement
jobstore_isful (js) = false // there is no max capacity

(* ****** ****** *)

implement
jobstore_get_job (js) = let
  var x: myjob? // uninitialized
  val ans = $HP.linheap_delmin<myjob> (js, cmp, x)
in
//
if ans then let
  prval () = opt_unsome {myjob} (x) in Some_vt ((myjob2job)x)
end else let
  prval () = opt_unnone {myjob} (x) in None_vt ()
end // end of [if]
//
end // end of [jobstore_get_job]

(* ****** ****** *)

implement
jobstore_put_job (js, x) = let
  val x = job2myjob (x)
  val () = $HP.linheap_insert<myjob> (js, x, cmp) in None_vt ()
end // end of [jobstore_put_job]

(* ****** ****** *)

(* end of [workshop_jobstore_hp.dats] *)