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

staload
PT = "libc/SATS/pthread.sats"
typedef pthread = $PT.pthread_t

(* ****** ****** *)

staload "workshop.sats"

(* ****** ****** *)

%{^

ats_ptr_type
workshop_new (
  ats_ptr_type js
) {
  workshop_struct *p ;
//
  p = ATS_MALLOC (sizeof(workshop_struct)) ;
//
  pthread_mutex_init (&p->JS_mutex, (pthread_mutexattr_t*)0) ;
  pthread_cond_init (&p->JSisemp_cond, (pthread_condattr_t*)0) ;
  pthread_cond_init (&p->JSisful_cond, (pthread_condattr_t*)0) ;
//
  pthread_mutex_init (&p->NWK_mutex, (pthread_mutexattr_t*)0) ;
  pthread_cond_init (&p->NWKiszero_cond, (pthread_condattr_t*)0) ;
  p->nworker = 0 ;
//
  p->jobstore = js ;
//
  pthread_spin_init (&p->RES_lock, 0/*pshared*/) ;
  p->res = NULL ;
//
  return (p) ;
//
} // end of [workshop_new]

/* ****** ****** */

ats_void_type
workshop_wait_nwisz
  (ats_ptr_type ws0) {
  workshop ws = (workshop)ws0 ;
  pthread_mutex_lock (&ws->NWK_mutex) ;
  while (1) {
    if (ws->nworker == 0) break ;
    pthread_cond_wait (&ws->NWKiszero_cond, &ws->NWK_mutex) ;
  } // end of [while]
  pthread_mutex_unlock (&ws->NWK_mutex) ;
  return ;
} // end of [workshop_wait_nwisz]

%} // end of [%{^]

(* ****** ****** *)

implement
workshop_get_job
  (ws) = let
  var js =
    workshop_get_jobstore (ws)
  // end of [var]
  val isful = jobstore_isful (js)
  val opt = jobstore_get_job (js)
in
//
case+ opt of
| ~Some_vt (x) => let
    val () =
      workshop_put_jobstore (ws, js)
    // end of [val]
    val () = if isful then workshop_unblock_isful (ws)
  in
    x // job is obtained
  end // end of [Some_vt]
| ~None_vt () => let
    val () = workshop_block_isemp (ws, js)
  in
    workshop_get_job (ws)
  end // end of [None_vt]
//
end // end of [workshop_get_job]

(* ****** ****** *)

implement
workshop_put_job
  (ws, x) = let
  var js =
    workshop_get_jobstore (ws)
  // end of [var]
  val isemp = jobstore_isemp (js)
  val opt = jobstore_put_job (js, x)
in
//
case+ opt of
| ~Some_vt (x) => let
    val () = workshop_block_isful (ws, js)
  in
    workshop_put_job (ws, x)
  end // end of [Some_vt]
| ~None_vt () => let
    val () =
      workshop_put_jobstore (ws, js)
    // end of [val]
    val () = if isemp then workshop_unblock_isemp (ws)
  in
    // job is submitted
  end // end of [None_vt]
//
end // end of [workshop_put_job]

(* ****** ****** *)

local

staload PT = "libc/SATS/pthread.sats"

extern
fun workshop_inc_nworker
  (ws: workshop): void = "workshop_inc_nworker"
// end of [workshop_inc_nworker]
extern
fun workshop_dec_nworker
  (ws: workshop): void = "workshop_dec_nworker"
// end of [workshop_dec_nworker]

in // in of [local]

implement
workshop_add_worker
  (ws) = err where {
//
typedef env = workshop
//
fun fworker (
  ws: workshop
) : void = let
  val x = workshop_get_job (ws)
  val knd = job_get_kind (x)
  val () = job_finish (ws, x)
in
  if knd > 0 then fworker (ws) else let
    val () = workshop_dec_nworker (ws) in (*quit*)
  end // end of [if]
end // end of [fworker]
//
var ws1: workshop = ws
var tid: pthread // uninitialized
val err = $PT.pthread_create_detached {env} (fworker, ws1, tid)
//
prval () = opt_clear (ws1)
//
val () = if err = 0 then workshop_inc_nworker (ws)
//
} // end of [workshop_add_worker]

end // end of [local]

(* ****** ****** *)

(* end of [workshop.dats] *)