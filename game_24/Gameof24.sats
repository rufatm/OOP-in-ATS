//
// Title: Object-Oriented Software Principles
// Number: CAS CS 511
// Semester: Spring 2012
// Class Time: MW 1:00-2:30
// Instructor: Hongwei Xi (hwxiATcsDOTbuDOTedu)
//

(* ****** ****** *)

(*
** Assignment 6
** Due Time: Wednesday, February 29, 2012
** 40 points in total
*)

(* ****** ****** *)

(*
** Solving Game-of-24
*)

(* ****** ****** *)

abstype card_type
typedef card = card_type

fun fprint_card (out: FILEref, c: card): void

fun card_make_stamp_int
  (stamp: int, i: int): card
fun add_card_card (c1: card, c2: card): card
fun sub_card_card (c1: card, c2: card): card
fun mul_card_card (c1: card, c2: card): card
fun div_card_card (c1: card, c2: card): card

fun card_eval (c: card): double // HX: cut the corner ...

(* ****** ****** *)

abstype task (n: int) // a task of size n
abstype subtask (n:int, i:int, j:int) // a subtask of size n

(* ****** ****** *)

abstype taskset (n: int) // a set of task(n)
fun taskset2lst {n:nat} (xs: taskset (n)): List (task(n))

(* ****** ****** *)

fun task_get_card_at
  {n,i:nat | i < n} (x: task(n), i: int i): card

fun task_rem2_add1
  {n:int}
  {i,j:nat | i < j; j < n} (
  x: task (n), n: int n, i: int i, j: int j, c: card
) : task(n-1) // end of [task_rem2_add1]

(* ****** ****** *)

typedef task1 = task (1)
typedef task1lst = List (task1)

fun task1_check (x: task1): bool

fun task2subtask
  {n:int | n >= 2} (x: task (n)): subtask (n, 0, 1)
// end of [task2subtask]

fun subtask_red1
  {n:int}
  {i,j:nat | i < j; j < n} (
  x: subtask (n, i, j), n: int n, i: int i, j: int j
) : (taskset (n-1), subtask (n, i, j+1))

fun subtask_red2
  {n:int}{i:nat | i < n}
  (x: subtask (n, i, n)): subtask (n, i+1, i+2)
// end of [subtask_red2]

fun subtask_red3 {n:int} (x: subtask (n, n, n+1)): void

(* ****** ****** *)

fun task_solve
  {n:int | n >= 1} (x: task (n), n: int n): task1lst
// end of [task_solve]

(* ****** ****** *)

fun task_make_cards
  {n:nat} (cs: list (card, n)): task (n)
// end of [task_make_cards]

(* ****** ****** *)

fun solve24 (
  n1: int, n2: int, n3: int, n4: int
) : task1lst // end of [solve24]

(* ****** ****** *)

(* end of [Gameof24.sats] *)