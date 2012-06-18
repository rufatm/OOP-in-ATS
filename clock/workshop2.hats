(*
** Implementing a workshop
*)

(* ****** ****** *)

implement
job_finish<jobknd> (x) = job_finish_jobknd (x)

implement
job_get_priority<jobknd> (x) = job_get_priority_jobknd (x)
implement
job_get_priority<tjobknd> (x) = job_get_priority_tjobknd (x)

implement
job_compare<jobknd> (x1, x2) = job_compare_jobknd (x1, x2)
implement
job_compare<tjobknd> (x1, x2) = job_compare_tjobknd (x1, x2)

(* ****** ****** *)

(* end of [workshop2.hats] *)