(*
** Implementing a workshop
*)

(* ****** ****** *)

staload "libc/SATS/time.sats"

(* ****** ****** *)

staload "workshop2.sats"
staload "workshop2_job.sats"
staload "gtkcairoclock.sats"

(* ****** ****** *)

implement
job_new_jobknd (n,shop) =
  jobvt2job (JOB (n, shop))

(* ****** ****** *)

implement
job_get_priority_jobknd
  (x) = let
  prval () = job_decode (x)
  val JOB (pri, _) = x
  prval () = fold@ (x)
  prval () = job_encode (x)
in
  lint_of_int (pri)
end // end of [job_get_priority]

implement
job_compare_jobknd
  (x1, x2) = let
  val p1 = job_get_priority_jobknd (x1)
  and p2 = job_get_priority_jobknd (x2)
in
  compare_lint_lint (p1, p2)
end // end of [job_compare_jobknd]

(* ****** ****** *)

implement
job_finish_jobknd (x) = let
  prval () = job_decode (x)
  val+ ~JOB (pri, shop) = x
  val cont = ftimeout()
in
  if cont then let
    val time = time_get()
    val tstamp  = (lint_of_time)time + (lint_of_int)1
    val tj = job_new_tjobknd(tstamp,0,shop)
    val () = workshop_put_tjob(shop,tj)
  in end
  else 
    ()
end // end of [job_finish]

(* ****** ****** *)

(* end of [workshop2_job.dats] *)