
(* ****** ****** *)

staload "workshop2.sats"

(* ****** ****** *)

dataviewtype
jobvt = JOB of (int(*priority*), workshop)

castfn job2jobvt (x: job):<> jobvt
castfn jobvt2job (x: jobvt):<> job

praxi job_encode (x: !jobvt >> job): void
praxi job_decode (x: !job >> jobvt): void

(* ****** ****** *)

(* end of [workshop2_job.sats] *)