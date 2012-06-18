(*
** Implementing a workshop
*)

(* ****** ****** *)

staload _(*anon*) = "prelude/DATS/pointer.dats"

(* ****** ****** *)
//
staload "libc/SATS/time.sats"
staload "libc/sys/SATS/types.sats"
//
staload "libc/SATS/signal.sats"
//
staload "libc/SATS/unistd.sats"
//
(* ****** ****** *)

staload "workshop2.sats"
staload _(*anon*) = "workshop2_jobstore_hp.dats"
staload _(*anon*) = "workshop2_jobstorelock.dats"

(* ****** ****** *)

local
#include "workshop2.hats"
in (*
empty
*) end

(* ****** ****** *)

%{^

ats_ptr_type
workshop_new2 (
  ats_ptr_type js, ats_ptr_type tjs
) {
  workshop_struct *p ;
//
  p = ATS_MALLOC (sizeof(workshop_struct)) ;
//
  p->nworker = 0 ;
//
  p->tmanager = (pthread_t)(-1) ;
  p->ntmanager = 0 ;
//
  pthread_mutex_init (&p->jobstorelock.JS_mutex, (pthread_mutexattr_t*)0) ;
  pthread_cond_init (&p->jobstorelock.JSisemp_cond, (pthread_condattr_t*)0) ;
  pthread_cond_init (&p->jobstorelock.JSisful_cond, (pthread_condattr_t*)0) ;
  p->jobstorelock.jobstore = js ;
//
  pthread_mutex_init (&p->tjobstorelock.JS_mutex, (pthread_mutexattr_t*)0) ;
  pthread_cond_init (&p->tjobstorelock.JSisemp_cond, (pthread_condattr_t*)0) ;
  pthread_cond_init (&p->tjobstorelock.JSisful_cond, (pthread_condattr_t*)0) ;
  p->tjobstorelock.jobstore = tjs ;
//
  return (p) ;
//
} // end of [workshop_new2]

%} // end of [%{^]

(* ****** ****** *)

implement
workshop_get_job (ws) = let
  val lock =
    workshop_get_jobstorelock (ws)
  // end of [val]
in
  jobstorelock_get_job<jobknd> (lock)
end // end of [workshop_get_job]

implement
workshop_put_job (ws, x) = let
  val lock =
    workshop_get_jobstorelock (ws)
  // end of [val]
in
  jobstorelock_put_job<jobknd> (lock, x)
end // end of [workshop_put_job]

(* ****** ****** *)

implement
workshop_get_tjob (ws) = let
  val lock =
    workshop_get_tjobstorelock (ws)
  // end of [val]
in
  jobstorelock_get_job<tjobknd> (lock)
end // end of [workshop_get_tjob]

implement
workshop_put_tjob (ws, x) = let
  val lock =
    workshop_get_tjobstorelock (ws)
  val () =
    jobstorelock_put_job<tjobknd> (lock, x)
  // end of [val]
in
  workshop_awaken_tmanager (ws)
end // end of [workshop_put_tjob]

implement
workshop_getready_tjob
  (ws, ready) = let
  val lock =
    workshop_get_tjobstorelock (ws)
  // end of [val]
  var js = jobstorelock_get_jobstore (lock)
  val pmin = jobstore_getmin_priority (js)
//
(*
  val () = (
    print "workshop_getready_tjob: pmin = "; print pmin; print_newline ()
  ) // end of [val]
*)
//
in
//
if pmin >= 0L then let
  val tcur = time_get ()
  val pcur = lint_of_time (tcur)
  val () = ready := pmin - pcur
(*
  val () = (
    print "workshop_getready_tjob: ready = "; print ready; print_newline ()
  ) // end of [val]
*)
in
  if ready <= 0L then let
    val opt = jobstore_get_job (js)
    val () = jobstorelock_put_jobstore (lock, js)
  in
    opt
  end else let
    val () = jobstorelock_put_jobstore (lock, js)
  in
    None_vt ()
  end // end of [if]
end else let
  val () = ready := ~1L
  val () = jobstorelock_put_jobstore (lock, js)
in
  None_vt ()
end // end of [if]
end // end of [workshop_get_tjob]

(* ****** ****** *)

local

staload PT = "libc/SATS/pthread.sats"

extern
fun workshop_inc_nworker
  (ws: workshop): void = "workshop_inc_nworker"
// end of [workshop_inc_nworker]

extern fun workshop_get_tmanager
  (ws: workshop): pthread_t = "workshop_get_tmanager"
extern fun workshop_set_tmanager
  (ws: workshop, tid: pthread_t): void = "workshop_set_tmanager"

fun fhandler (sgn: signum_t): void = ()

in // in of [local]

implement
workshop_add_worker
  (ws) = err where {
//
typedef a = jobknd
typedef env = workshop
//
fun fworker
  (ws: workshop): void = let
  val x = workshop_get_job (ws)
  val () = job_finish<a> (x)
in
  fworker (ws)
end // end of [fworker]
//
var ws1: workshop = ws
var tid: pthread_t // uninitialized
val err = $PT.pthread_create_detached {env} (fworker, ws1, tid)
//
prval () = opt_clear (ws1)
//
val () = if err = 0 then workshop_inc_nworker (ws)
//
} // end of [workshop_add_worker]

(* ****** ****** *)

%{
ats_int_type
tmanager_block
  (ats_uint_type n) {
  struct timespec ts ;
  sigset_t sigmask ;
  ts.tv_sec = n ; ts.tv_nsec = 0 ;
  sigprocmask (0, NULL, &sigmask) ;
  sigdelset (&sigmask, SIGUSR1) ; // temp unblocking
  return pselect (0, NULL, NULL, NULL, &ts, &sigmask) ;
} // end of [tmanager_block]
%}

implement
workshop_add_tmanager
  (ws) = err where {
//
macdef LONGWAIT = 1000000L
//
typedef a = jobknd
typedef env = workshop
//
fun ftmanager
  (ws: workshop): void = let
  var msk: sigset_t
  val err = sigemptyset (msk)
  val () = assertloc (err = 0)
  prval () = opt_unsome {sigset_t} (msk)
  val err = sigaddset (msk, SIGUSR1)
  val err = sigprocmask_null (SIG_BLOCK, msk)
//
  var act: sigaction
  val () = ptr_zero<sigaction>
    (__assert () | act) where {
    extern prfun __assert (): NULLABLE (sigaction)
  } // end of [val]
  val () = act.sa_handler := (sighandler)fhandler
  val err = sigaction_null (SIGUSR1, act)
//
  val () = workshop_inc_ntmanager (ws) where {
    extern fun workshop_inc_ntmanager (ws: workshop): void = "workshop_inc_ntmanager"
  } // end of [val]
//
in
  ftmanager_work (ws)
end // end of [ftmanager]

and ftmanager_work
  (ws: workshop): void = let
//
  var ready: lint // uninitialized
  val opt = workshop_getready_tjob (ws, ready)
//
in
//
case+ opt of
| ~Some_vt (x) => let
    val () = workshop_put_job (ws, tjob2job (x))
  in
    ftmanager_work (ws)
  end // end of [Some_vt]
| ~None_vt () => let
    val nwait = (
      if ready >= 0L then ready else LONGWAIT
    ) : lint // end of [val]
    val nwait = (uint_of_lint)nwait
    val err = tmanager_block (nwait) where {
      extern fun tmanager_block (n: uint): int = "tmanager_block"
    } // end of [val]
    val () = (
      print "ftmanager: tmanager_block: err = "; print err; print_newline ()
    ) // end of [val]
  in
    ftmanager_work (ws)
  end // end of [None_vt]
//
end // end of [ftmanager_work]
//
var ws1: workshop = ws
var tid: pthread_t
val err = $PT.pthread_create_detached {env} (ftmanager, ws1, tid)
val () = (
  print "workshop_add_tmanager: tid = "; print ($PT.lint_of_pthread (tid)); print_newline ()
)
//
prval () = opt_clear (ws1)
//
val () = if err = 0 then {
  val () = workshop_set_tmanager (ws, tid)
} // end of [val]
} // end of [workshop_add_tmanager]

(* ****** ****** *)

implement
workshop_awaken_tmanager
  (ws) = let
  val tid =
    workshop_get_tmanager (ws)
  // end of [val]
  val tid1 = $PT.lint_of_pthread (tid)
(*
  val () = (
    print "workshop_awaken_tmanager: tid = "; print tid1; print_newline ()
  ) // end of [val]
*)
  val n = workshop_get_ntmanager (ws) where {
    extern fun workshop_get_ntmanager (ws: workshop): int = "workshop_get_ntmanager"
  } // end of [val]
in
//
if n > 0 then let
  val err = pthread_kill (tid, SIGUSR1)
in
  (*nothing*)
end else () // end of [if]
//
end // end of [workshop_awaken_tmanager]

end // end of [local]

(* ****** ****** *)

(* end of [workshop2.dats] *)