(*
** Implementing a workshop
*)

(* ****** ****** *)

staload HP = "libats/SATS/linheap_binomial.sats"
staload _(*anon*) = "libats/DATS/linheap_binomial.dats"

(* ****** ****** *)

staload "workshop2.sats"

(* ****** ****** *)

assume jobstore (a:type) = $HP.heap (job (a))

(* ****** ****** *)

implement{a}
jobstore_make_nil () = $HP.linheap_make_nil ()

(* ****** ****** *)

local

fn{a:type}
cmp (
  x1: &job a, x2: &job a
) :<cloref> int = job_compare (x1, x2)
// end of [cmp]

in // in of [local]

implement{a}
jobstore_get_job
  (js) = let
  stadef job = job (a)
  var x: job? // uninitialized
  val ans = $HP.linheap_delmin<job> (js, cmp, x)
in
//
if ans then let
  prval () = opt_unsome {job} (x) in Some_vt (x)
end else let
  prval () = opt_unnone {job} (x) in None_vt ()
end // end of [if]
//
end // end of [jobstore_get_job]

implement{a}
jobstore_put_job
  (js, x) = let
  stadef job = job (a)
  val () = $HP.linheap_insert<job> (js, x, cmp) in None_vt ()
end // end of [jobstore_put_job]

(* ****** ****** *)

implement{a}
jobstore_getmin_priority
  (js) = let
  viewtypedef job = job (a)
  val p =
    $HP.linheap_getminptr (js, cmp)
  val [l:addr] p = ptr1_of_ptr (p)
in
if p > null then let
  prval (pf, fpf) = __assert () where {
    extern praxi __assert (): (job @ l, job @ l -<lin,prf> void)
  } // end of [prval]
  val pri = job_get_priority (!p)
  prval () = fpf (pf)
in
  pri
end else ~1L (* a special value *)
//
end // end of [jobstore_getmin_priority]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

(* end of [workshop2_jobstore_hp.dats] *)