(*
** Implementing a workshop
*)

(* ****** ****** *)

staload "libc/SATS/time.sats"
staload "libc/sys/SATS/types.sats"

(* ****** ****** *)

staload "workshop2.sats"
staload "workshop2_job.sats"

(* ****** ****** *)

dataviewtype
tjobvt = TJOB of (lint(*stamp*), int(*priority*), workshop)

extern castfn tjob2tjobvt (x: tjob):<> tjobvt
extern castfn tjobvt2tjob (x: tjobvt):<> tjob

extern praxi tjob_encode (x: !tjobvt >> tjob): void
extern praxi tjob_decode (x: !tjob >> tjobvt): void

(* ****** ****** *)

implement
tjob2job (x) = let
  val x = tjob2tjobvt (x)
  val ~TJOB (t, pri, shop) = x in jobvt2job (JOB (pri, shop))
end // end of [tjob2job]

(* ****** ****** *)

#define i2l lint_of_int

implement
job_new_tjobknd (timestamp,n,shop) = let
//  val t = time_get ()
//  val nt = (lint_of_int)n + (lint_of_time)t
  val () = ()
in
  tjobvt2tjob (TJOB (timestamp, n, shop))
end // end of [job_new]

(* ****** ****** *)

implement
job_get_priority_tjobknd
  (x) = let
  prval () = tjob_decode (x)
  val TJOB (nt, pri, _) = x
  prval () = fold@ (x)
  prval () = tjob_encode (x)
in
  nt
end // end of [job_get_priority_tjobknd]

(* ****** ****** *)

implement
job_compare_tjobknd (x1, x2) = let
  prval () = tjob_decode (x1)
  val TJOB (nt1, _, _) = x1; prval () = fold@ (x1)
  prval () = tjob_encode (x1)
  prval () = tjob_decode (x2)
  val TJOB (nt2, _, _) = x2; prval () = fold@ (x2)
  prval () = tjob_encode (x2)
in
  compare_lint_lint (nt1, nt2)
end // end of [job_compare_tjobknd]

(* ****** ****** *)

(* end of [workshop2_tjob.dats] *)