---
name: game-theory
description: |
  Trigger when optimal strategy depends on others' choices, needing Nash equilibrium computation, zero-sum/non-zero-sum analysis, mechanism design; or designing strategies for multi-agent systems, adversarial training, routing games.
---

# 🎯 Game Theory

> "Your optimal choice depends on others' choices — thinking must be interactive, not just deep."
>
> — Game Theory, Decision Theory, Mechanism Design

## Core Principle

**Strategic interaction — your best action depends on what others do, and theirs depend on what you do. Nash equilibrium: strategy profile where no player benefits from unilateral deviation.**

Key concepts: **Payoff Matrix**, **Dominant Strategy**, **Mixed Strategy**, **Pareto Optimality**. Classification dimensions: cooperative vs. non-cooperative, zero-sum vs. general-sum, simultaneous vs. sequential.

> **Mathematical Formalization**
>
> Formal definition: $n$ players, each with strategy set $S_i$ and payoff function $u_i: S_1 \times \cdots \times S_n \to \mathbb{R}$.
>
> Nash equilibrium: strategy profile $s^* = (s_1^*, \ldots, s_n^*)$ satisfying $u_i(s^*) \geq u_i(s_i, s^*_{-i})$ for all $s_i \in S_i$ and all $i$, where $s^*_{-i}$ denotes the strategies of all players except $i$. Mixed-strategy Nash equilibrium: probability distribution $\sigma^*$ such that $u_i(\sigma^*) \geq u_i(s_i, \sigma^*_{-i})$.
>
> Dominant strategy: strict $u_i(s_i^*, s_{-i}) > u_i(s_i, s_{-i})$; weak dominance $\geq$ with at least one strict inequality.
>
> Zero-sum minimax: $\max_x \min_y f(x,y) = \min_y \max_x f(x,y)$.

## GPU-Friendliness (Cross-Cutting Check)

Game-solving maps to GPU with widely varying capability; pass through the eight-dimensional gate in `../../references/gpu-friendly-math.md`:

- **Matrix games / two-player zero-sum (minimax)**: Equivalent to linear programming (LP); payoff matrix operations are GEMM-compatible and batch-parallelizable — **friendly**.
- **Mixed-strategy equilibrium computation**: Linear systems / indifference equations on the support; small-scale problems are batch-solvable; watch for sparsity and condition number at scale.
- **Exact large-scale multi-agent equilibrium**: $n$-player Nash equilibrium is PPAD-complete; general case is **intractable** → **anti-pattern**; switch to approximate / learning-based methods (fictitious play, self-play, multi-agent RL, NFSP).
- **Evolutionary / repeated game simulation**: Population and strategy batch updates are parallelizable; watch for inter-agent communication and synchronization overhead.

Eight-dimensional minimum assessment (formal terms): **Tensorization** — whether players / strategies / rounds admit batched unfolding; **GEMM-mappability** — whether payoff matrices, minimax, LP / linear systems fall into matrix operations; **Complexity** — flag PPAD / combinatorial explosion risks for Nash / mechanism solving; **Memory and KV-Cache** — whether the strategy-state Cartesian product is compressible; **Low-precision stability** — whether equilibrium solving, LP, soft best-response have controlled condition numbers; **Parallelism and communication** — synchronization cost of multi-agent rollouts; **Sparse structure** — whether the interaction graph is structured; **Operator fusion** — whether payoff, mask, and best-response updates can be fused.

> Use in conjunction with `../../references/books/optimization-ml.md` (duality / minimax, game learning algorithms) and `../../references/books/matrix-analysis.md` (matrix games, linear systems).

## When NOT to Use

- **Single-agent decision problems with no interaction** — optimization thinking is more appropriate; no need to model others' strategic responses.
- **Purely cooperative problems with no conflict of interest** — players' objectives are fully aligned; strategic analysis is unnecessary.
- **Deterministic problems with no strategic uncertainty** — outcomes are uniquely determined by one's own actions; no reaction from others is involved.
- **Outcomes determined purely by chance with no strategic choice** — no strategy sets to analyze; game theory does not apply.

## When to Use

- Multiple decision-makers interact; each player's strategy affects others' payoffs; the optimal strategy depends on predicting others' responses.
- Need to design incentive mechanisms so that self-interested behavior leads to socially optimal outcomes; predict equilibrium states under given rules.
- Analyze pricing, entry, and exit in competitive markets; benefit allocation and threat points in negotiation / bargaining.
- **Design strategies and equilibrium objectives for multi-agent systems, adversarial training (GAN / robust learning), and routing games.**

## Method

### Step 1: Identify Players and Strategies
Define the fundamental elements of the game: players $N=\{1,\ldots,n\}$; strategy sets $S_i$; payoff functions $u_i: S_1\times\cdots\times S_n\to\mathbb{R}$; information structure (symmetric or not? incomplete information? sequential actions? communication possible?). The core task is identifying the "interaction structure" — whose choices affect whose outcomes. Missing a key player is the most common error.

### Step 2: Analyze the Game Type
First classify: zero-sum / general-sum, simultaneous / sequential, cooperative / non-cooperative, complete / incomplete information. The type determines the method: zero-sum uses minimax / LP; sequential games use backward induction and subgame-perfect equilibrium; cooperative games use the Shapley value to allocate by marginal contribution:
$$\phi_i(v)=\sum_{S\subseteq N\setminus\{i\}}\frac{|S|!(n-|S|-1)!}{n!}[v(S\cup\{i\})-v(S)]$$
Misclassifying the type leads directly to applying the wrong equilibrium concept and solution method.

### Step 3: Construct the Payoff Matrix / Function
For two-player games, use a payoff matrix with cells $(u_1,u_2)$; for $n$-player games, use $u_i(s_1,\ldots,s_n)$. Verify completeness: are any players or strategies missing? Do payoffs accurately reflect preferences? Are there externalities? Payoffs are the foundation of all analysis; inaccurate assessment biases everything downstream.

### Step 4: Search for Dominant Strategies
Strict dominance: $u_i(s_i^*,s_{-i}) > u_i(s_i,s_{-i})$ for all $s_i\neq s_i^*$ and all $s_{-i}$; weak dominance: $\geq$ with at least one strict inequality. **Iterated elimination of dominated strategies** successively removes inferior strategies to shrink the strategy space. A dominant-strategy equilibrium is the strongest possible conclusion — no player has any incentive to deviate. If none exists, proceed to equilibrium analysis.

### Step 5: Compute Equilibria
Select the method based on the game type from Step 2. Pure-strategy Nash: for each $s_{-i}$, find the best response $BR_i(s_{-i})$; intersections are equilibria. Mixed strategies: find probability distributions that make others indifferent, $u_j(s_j,\sigma^*_{-j})=u_j(s_j',\sigma^*_{-j})$ for all $s_j,s_j'\in S_j$. Zero-sum matrix games use minimax $\max_x\min_y f=\min_y\max_x f$; sequential games use backward induction; cooperative games output allocation schemes rather than standard Nash. For multiple equilibria, perform Pareto ranking and label optimal vs. inferior equilibria.

### Step 6: Check Equilibrium Stability
Trembling-hand perfection (stable under small perturbations, excluding equilibria that rely on "opponents never make mistakes"); evolutionarily stable strategy ESS (resists invasion in repeated interactions); off-equilibrium-path incentives (in sequential games, whether there is motivation to honor commitments). Ask: is the equilibrium unique or multiple? Is it robust to small perturbations? Only stable equilibria constitute credible predictions.

### Step 7: Mechanism Design and Improvement
If no good equilibrium exists, redesign the game: modify the payoff structure (incentives and penalties), add enforceable rules, introduce communication and reputation mechanisms, Vickrey auctions (truthful valuation reporting is a dominant strategy). Mechanism design formalization:
$$\max\ \text{social welfare}\quad\text{s.t.}\quad\text{incentive compatibility + individual rationality}$$
The revelation principle: any Bayesian game equilibrium can be implemented by a direct mechanism — truthful type reporting is an equilibrium. Mechanism design is the most practical branch — rather than lamenting non-cooperation, change the rules so that cooperation becomes the self-interested choice.

## Common Errors

| Error | Critique | Correct Approach |
|---|---|---|
| Assuming others think the same way you do | Others have different payoff functions / rationality levels; $u_i\neq u_j$ | Explicitly specify each player's payoff function and beliefs |
| Ignoring mixed strategies | Pure-strategy equilibria may not exist; mixed equilibria always exist (Nash, 1950) | Check whether mixed-strategy analysis is needed |
| Confusing Nash equilibrium with Pareto optimality | Nash equilibrium can be Pareto-dominated (Prisoner's Dilemma); the two are independent | Separately annotate equilibrium properties and efficiency properties |
| Ignoring information asymmetry | Incomplete-information equilibria differ fundamentally from complete-information ones | Distinguish Bayesian games from complete-information games |
| Oversimplifying payoff structure | Omitting key payoff dimensions distorts the equilibrium | Systematically check complete payoffs for all players |
| Ignoring repeated interaction dynamics | One-shot equilibria may change in repeated games (folk theorem) | Analyze subgame-perfect equilibria |
| Intractable exact large-scale equilibrium | $n$-player Nash equilibrium is PPAD-complete; exact solutions are infeasible | Pass through the GPU eight-dimensional gate; switch to approximate / learning methods (self-play, MARL) |

## Operating Procedure

When this skill is triggered, the output must include:

1. **[Players]**: All decision-makers and their types (rational / boundedly rational / unknown).
2. **[Strategy Sets]**: Available strategies for each player; label finite / infinite.
3. **[Payoff Matrix]**: Payoff values $(u_1,u_2,\ldots)$ for core strategy profiles, or payoff function form.
4. **[Game Type]**: Zero-sum / non-zero-sum / sequential / cooperative, with corresponding analytical method.
5. **[Equilibria]**: All applicable equilibria (pure strategy, mixed strategy, subgame-perfect, cooperative allocation, etc.); label multiple equilibria.
6. **[Stability]**: Trembling-hand perfection, evolutionary stability, off-equilibrium-path incentives.
7. **[Mechanism Recommendations]**: If equilibria are undesirable, propose mechanism design suggestions (modify payoffs, add rules, introduce reputation, etc.).
8. **[GPU Feasibility]**: Matrix games / minimax → LP is GEMM-compatible; large-scale multi-agent equilibria may be intractable → approximate / learning methods; pass through the eight-dimensional gate.

**Output must not consist of analysis alone without conclusions.**

## Relations to Other Skills

- **Optimization Thinking**: Nash equilibrium is mutual optimization — each player optimizes their own payoff subject to others' strategies; the equilibrium is the common solution to all optimization problems.
- **Probability and Statistics**: Mixed strategies select actions via probability distributions; Bayesian games handle type uncertainty probabilistically; equilibria depend on expected payoffs.
- **Information Theory Thinking**: Information asymmetry and signaling — in Spence signaling games, the information structure directly affects equilibrium existence and properties.
- **Causal Inference Thinking**: Strategic choices causally affect others' payoffs; causal chains in strategic interaction are bidirectional.
- **Algorithmic Thinking**: Nash equilibrium computation complexity (PPAD-complete), Lemke-Howson algorithm, evolutionary game simulation.
- **Modern Mathematics Activation**: `../../references/books/optimization-ml.md` (duality / minimax, game learning algorithms), `../../references/books/matrix-analysis.md` (matrix games, linear algebraic structure of payoff matrices).
