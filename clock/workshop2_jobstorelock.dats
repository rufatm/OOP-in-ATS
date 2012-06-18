(*
** Implementing a workshop
*)

(* ****** ****** *)

staload "workshop2.sats"

(* ****** ****** *)

implement{a}
jobstorelock_get_job
  (ws) = let
  var js =
    jobstorelock_get_jobstore (ws)
  // end of [var]
  val opt = jobstore_get_job (js)
in
//
case+ opt of
| ~Some_vt (x) => let
    val () =
      jobstorelock_put_jobstore (ws, js)
    // end of [val]
    val () = jobstorelock_unblock_isful (ws)
  in
    x // job is obtained
  end // end of [Some_vt]
| ~None_vt () => let
    val () = jobstorelock_block_isemp (ws, js)
  in
    jobstorelock_get_job (ws)
  end // end of [None_vt]
//
end // end of [jobstorelock_get_job]

(* ****** ****** *)

implement{a}
jobstorelock_put_job
  (lock, x) = let
  var js =
    jobstorelock_get_jobstore (lock)
  // end of [var]
  val opt = jobstore_put_job (js, x)
in
//
case+ opt of
| ~Some_vt (x) => let
    val () = jobstorelock_block_isful (lock, js)
  in
    jobstorelock_put_job (lock, x)
  end // end of [Some_vt]
| ~None_vt () => let
    val () =
      jobstorelock_put_jobstore (lock, js)
    // end of [val]
    val () = jobstorelock_unblock_isemp (lock)
  in
    // job is submitted
  end // end of [None_vt]
//
end // end of [jobstorelock_put_job]

(* ****** ****** *)

(* end of [workshop2_jobstorelock.dats] *)