/-
Copyright (c) 2017 Robert Y. Lewis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Robert Y. Lewis
-/

import mathematica
import datatypes
import data.real.basic
open expr tactic nat

local attribute [simp] left_distrib right_distrib

open mmexpr nat

-- this will be unnecessary when the arithmetic simplifier is finished
@[simp] lemma {u} n2a {α : Type u} [comm_ring α] (x : α) : -(x*2) = (-1)*x + (-1)*x :=
begin rw (mul_comm x 2), change -((1+1)*x) = -1*x + -1*x, simp end

meta def factor (e : expr) (nm : option name) : tactic unit :=
do t ← mathematica.run_command_on (λ s, s ++" // LeanForm // Activate // Factor") e,
   ts ← to_expr t,
   pf ← eq_by_ring e ts,
   match nm with
   | some n := note n none pf >> skip
   | none := do n ← get_unused_name `h none, note n none pf, skip
   end


namespace tactic
namespace interactive
section
open interactive.types interactive
meta def factor (e : parse texpr) (nm : parse using_ident) : tactic unit :=
do e' ← i_to_expr e,
   _root_.factor e' nm
end
end interactive
end tactic

example (x : ℝ) : 1 - 2*x + 3*x^2 - 2*x^3 + x^4 ≥ 0 :=
begin
 factor  1 - 2*x + 3*x^2 - 2*x^3 + x^4  using h,
 rewrite h,
 apply pow_two_nonneg
end

example (x : ℝ) : x^2-2*x+1 ≥ 0 :=
begin
factor x^2-2*x+1 using q,
rewrite q,
apply pow_two_nonneg
end

example (x y : ℝ) : true :=
begin
factor (x^10-y^10),
trace_state,
triv
end
