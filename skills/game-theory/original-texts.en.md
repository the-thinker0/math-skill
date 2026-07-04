# Mathematical Sources and Classic Texts

## Zermelo's Theorem (1913)

> Zermelo (1913) proved: in any finite two-player game of perfect information (such as chess), either the first player or the second player has a winning strategy, or both players have a drawing strategy. That is, the game is "determined."

**Core thesis**: For any finite game of perfect information, $\exists$ a winning strategy for the first player $\lor$ $\exists$ a winning strategy for the second player $\lor$ $\exists$ a drawing strategy for both. This proves that no genuine "uncertainty" exists in such games — the source of uncertainty is computational complexity rather than logical structure.

**Key ideas**: The outcome of a perfect-information game is logically predetermined — uncertainty arises from limitations in computational power, not from the game itself. Zermelo's proof employed backward induction, which later became the central tool for subgame perfect equilibrium. Mathematical context: in the same year, Zermelo also introduced the Axiom of Choice (AC) in set theory. Game theory and set theory share the logic that "finite choices can always be exhaustively enumerated."

## von Neumann's Minimax Theorem (1928)

> von Neumann (1928) proved: in a two-player zero-sum game, $\max_{x \in \Delta} \min_{y \in \Delta} \sum_{ij} a_{ij} x_i y_j = \min_{y \in \Delta} \max_{x \in \Delta} \sum_{ij} a_{ij} x_i y_j$. That is, the optimal outcome under a conservative strategy equals the optimal outcome under the opponent's conservative strategy — max-min = min-max.

**Core theorem**: For any two-player zero-sum matrix game $A$, there exist mixed strategies $x^*$ and $y^*$ such that

$$v^* = \max_x \min_y x^\top A y = \min_y \max_x x^\top A y$$

$v^*$ is called the value of the game. The proof utilizes the convex set separation theorem (which later revealed deep connections with the Brouwer fixed-point theorem).

**Key ideas**: The minimax theorem reveals the structural symmetry of zero-sum games — "my maximizing my gain" is equivalent to "the opponent minimizing my gain." The optimal mixed strategy renders the opponent indifferent among all pure strategies. This theorem foreshadowed the duality of linear programming: Dantzig (1947) discovered that LP duality is equivalent to minimax, and von Neumann independently found the same connection.

## Existence of Nash Equilibrium (1950)

> Nash (1950) proved: every finite game (any number of players, non-zero-sum) has at least one mixed-strategy Nash equilibrium. The proof uses the Brouwer fixed-point theorem — constructing a best-response mapping $BR: \Delta \to \Delta$ whose fixed point is a Nash equilibrium.

**Core theorem**: For any finite game $(N, \{S_i\}, \{u_i\})$, $\exists \sigma^* \in \Delta_1 \times \cdots \times \Delta_n$ such that for all $i$ and $s_i \in S_i$,

$$u_i(\sigma^*) \geq u_i(s_i, \sigma^*_{-i})$$

Nash's proof applies the Brouwer fixed-point theorem to the best-response mapping: $F(\sigma) = (BR_1(\sigma_{-1}), \ldots, BR_n(\sigma_{-n}))$, where the fixed point of $F$ is an equilibrium. Subsequent proofs also use the Kakutani fixed-point theorem (for set-valued correspondences).

**Key ideas**: The existence of Nash equilibrium does not depend on the "goodwill" or "cooperative intent" of the players — it is a logical necessity of self-interested behavior in strategic interaction. The Nash equilibrium generalizes the minimax theorem from zero-sum games to non-zero-sum games, and from two-player adversarial settings to multi-player interaction. Mathematical context: the Brouwer fixed-point theorem (1911) is a central result in topology — every continuous map has a fixed point — and game theory and topology converge here.

## Prisoner's Dilemma

> The Prisoner's Dilemma is the most classic example in game theory: two players each have "cooperate" and "defect" strategies. Defection is the dominant strategy, yet (Defect, Defect) is Pareto-dominated by (Cooperate, Cooperate) — individual rationality leads to collective irrationalality.

**Payoff matrix**:

| | Cooperate (C) | Defect (D) |
|---|---|---|
| Cooperate (C) | (3, 3) | (0, 5) |
| Defect (D) | (5, 0) | (1, 1) |

Strictly dominant strategy analysis: for each player, defection strictly dominates cooperation ($5 > 3$ and $1 > 0$). The unique Nash equilibrium (D, D) yields payoff (1, 1), which is Pareto-dominated by (C, C) with payoff (3, 3).

**Key ideas**: The Prisoner's Dilemma reveals the fundamental tension between individual and collective rationality — Nash equilibrium does not guarantee Pareto optimality. This dilemma is ubiquitous in reality: arms races, the tragedy of the commons, price wars, carbon emissions. Axelrod (1984) showed through computer tournaments that in the iterated Prisoner's Dilemma, the "Tit-for-Tat" strategy can sustain cooperation — repeated interaction changes the equilibrium structure.

## Backward Induction & Subgame Perfection

> Backward induction is the central analytical tool for sequential games: starting from terminal nodes and working backward, choosing the optimal action at each step. Selten (1965) defined the subgame perfect equilibrium (SPE): a strategy profile that constitutes a Nash equilibrium in every subgame — eliminating equilibria based on non-credible threats.

**Core concept**: Nash equilibrium permits "non-credible threats" — a player claims they will take a certain action, but when that node is reached, deviation is more profitable. SPE requires the equilibrium to hold in every subgame, thereby eliminating non-credible threats. Backward induction is the standard method for computing SPE.

**Key ideas**: In sequential games, the temporal structure introduces commitment and credibility issues — a "threat" must be rational to be effective. Backward induction decomposes multi-stage decisions into single-stage subproblems, in the spirit of Bellman's principle of optimality. Mathematical context: Zermelo's (1913) theorem used backward induction, and Selten (1965) systematized it into the SPE concept. Selten shared the 1994 Nobel Prize in Economics with Nash and Harsanyi.

## Shapley Value & Cooperative Game Theory (1953)

> Shapley (1953) proposed the unique allocation rule in cooperative games satisfying efficiency, symmetry, dummy player, and additivity — the Shapley value $\phi_i(v)$. It allocates coalition payoffs according to average marginal contributions.

$$\phi_i(v) = \sum_{S \subseteq N \setminus \{i\}} \frac{|S|!(n - |S| - 1)!}{n!} [v(S \cup \{i\}) - v(S)]$$

The Shapley value is the unique allocation satisfying the following four axioms:
1. **Efficiency**: $\sum_i \phi_i(v) = v(N)$
2. **Symmetry**: if $i$ and $j$ contribute equally in all coalitions, then $\phi_i = \phi_j$
3. **Dummy player**: if $i$ contributes zero marginal value to every coalition, then $\phi_i = 0$
4. **Additivity**: $\phi_i(v + w) = \phi_i(v) + \phi_i(w)$

**Key ideas**: The Shapley value translates "fairness" into mathematical axioms — fairness is not subjective judgment but logical necessity. The central question of cooperative game theory: how should the total payoff generated by a coalition be distributed? The Shapley value provides the unique axiomatically justified answer. The core is another solution concept — no coalition receives less than its standalone value — but the core may be empty.

## Nash Bargaining Solution (1950)

> Nash (1950) proposed the unique bargaining solution satisfying Pareto optimality, symmetry, scale invariance, and independence of irrelevant alternatives. Given a disagreement point $d = (d_1, d_2)$ and a feasible set $S \subseteq \mathbb{R}^2$, the Nash solution maximizes $(u_1 - d_1)(u_2 - d_2)$.

$$\max_{(u_1, u_2) \in S, u_i \geq d_i} (u_1 - d_1)(u_2 - d_2)$$

Nash proved that this solution is the unique allocation satisfying the four axioms. The disagreement point $d$ is each party's payoff when negotiations break down — the more favorable the disagreement point, the more favorable the bargaining outcome.

**Key ideas**: The bargaining problem translates "negotiation" into mathematical optimization — maximizing joint surplus subject to the feasible set and disagreement point constraints. The symmetry and Pareto optimality of the Nash solution make it a natural benchmark for fair negotiation. Mathematical context: this model connects cooperative and non-cooperative game theory — the Nash program asserts that all cooperative game solutions should be derived through non-cooperative game models.

## Evolutionary Game Theory (Maynard Smith, 1973)

> Maynard Smith (1973) proposed the Evolutionarily Stable Strategy (ESS): a strategy $\sigma^*$ is an ESS if for any invading strategy $\sigma \neq \sigma^*$, either $u(\sigma^*, \sigma^*) > u(\sigma, \sigma^*)$, or $u(\sigma^*, \sigma^*) = u(\sigma, \sigma^*)$ and $u(\sigma^*, \sigma) > u(\sigma, \sigma)$.

**Core definition**: ESS is a stronger stability concept than Nash equilibrium — it requires not only "no incentive to deviate" but also "resistance to invasion." Nash equilibrium is a necessary condition for ESS, but ESS adds a stability requirement.

**Key ideas**: Evolutionary game theory extends game theory from "rational choice" to "adaptive dynamics" — players need not be rational, they only need to adjust strategies through repeated interaction. Biological applications: sex-ratio games, Hawk-Dove games, resource competition. Economic applications: formation of market conventions, diffusion of technology standards. Mathematical context: ESS is connected to replicator dynamics — an ESS is a locally stable fixed point of the replicator dynamics.

## Vickrey Auction & Auction Theory (1961)

> Vickrey (1961) proposed the second-price sealed-bid auction: the highest bidder wins but pays the second-highest bid. Bidding one's true valuation is a dominant strategy — a foundational work in mechanism design.

**Core theorem**: In a Vickrey auction, bidding one's true valuation $b_i = v_i$ is a weakly dominant strategy for every bidder. Proof: let $v_i$ be the true valuation and $p$ the second-highest bid. If $v_i > p$, bidding $b_i = v_i$ wins with payoff $v_i - p > 0$; if $b_i > v_i > p$, one still wins with the same payoff; if $b_i < v_i$, one may forgo positive surplus. Hence truthful reporting is optimal.

Vickrey proved that for symmetric risk-neutral bidders, the four standard auctions (English, Dutch, first-price sealed-bid, second-price sealed-bid) yield equal expected revenue — the **Revenue Equivalence Theorem**. Milgrom & Weber (1982) generalized this to affiliated values, finding that the English auction yields the highest revenue.

**Key ideas**: The Vickrey auction is the paradigm of an incentive-compatible mechanism — through clever design of the payment rule, self-interested behavior automatically leads to efficient outcomes. Auction theory applies game theory to market design: how can rules be designed to guide rational agents toward optimal outcomes? Mathematical context: Vickrey shared the 1996 Nobel Prize in Economics.

## Mechanism Design (Hurwicz, Myerson, Maskin — Nobel 2007)

> Mechanism design is the "reverse engineering" of game theory — given a desired outcome, design the rules of the game so that rational agents' self-interested behavior automatically achieves that goal. Hurwicz, Myerson, and Maskin received the 2007 Nobel Prize in Economics for this work.

**Core concepts**:
- **Incentive Compatibility**: truthful type reporting is an equilibrium strategy — agents have no incentive to misreport
- **Revelation Principle**: any equilibrium of a Bayesian game can be implemented by a direct mechanism — agents truthfully report types in equilibrium, eliminating the need for complex strategies
- **Myerson's optimal auction**: under the independent private values model, the mechanism maximizing the seller's expected revenue allocates to the bidder with the highest virtual valuation $v_i - (1 - F_i(v_i))/f_i(v_i)$

$$\text{Virtual valuation: } \varphi_i(v_i) = v_i - \frac{1 - F_i(v_i)}{f_i(v_i)}$$

- **Maskin Monotonicity**: a necessary condition for a social choice function to be Nash-implementable — monotonicity of preferences

**Key ideas**: Mechanism design answers "how to design the rules" rather than "how to act under given rules" — working backward from the desired outcome to the structure of the game. The revelation principle simplifies mechanism design: one need only consider direct mechanisms. Incentive compatibility ensures alignment between rules and incentives — institutional design is not wishful thinking but mathematically verifiable engineering. Mathematical context: Hurwicz (1960s) introduced the concept of incentive compatibility; Myerson (1981) developed optimal auction theory; Maskin (1977/1999) developed Nash implementability theory.

## Signaling Games (Spence, 1973)

> Spence (1973) proposed the signaling model: under asymmetric information, a sender with private information communicates information to a receiver through observable actions (signals). Classic application: education as a signal of ability — high-ability individuals face lower costs of acquiring education, so educational investment conveys information about ability.

**Core model**: The sender has type $t \in \{H, L\}$ (high/low ability), chooses signal $s \in \{e, 0\}$ (educated/uneducated), and the receiver observes $s$ and then chooses response $a$. Separating equilibrium: $H$ chooses $e$, $L$ chooses $0$ — the signal perfectly reveals type. Pooling equilibrium: both types choose the same signal — the signal carries no information.

**Key ideas**: Signaling games reveal the economics of information transmission — signals must have differential costs to convey information (otherwise everyone would imitate). In the Spence model, the social value of education may be entirely signaling value rather than productivity enhancement — this sparked a profound discussion about the nature of education. Spence shared the 2001 Nobel Prize in Economics. Mathematical context: signaling games are a subclass of Bayesian games — type is private information, and strategies are type-dependent.

## Repeated Games & Folk Theorem

> Folk Theorem (informally circulated in the 1970s, systematized by Aumann 1981): in an infinitely repeated game, any individually rational payoff $v_i \geq \min_{s_{-i}} \max_{s_i} u_i(s_i, s_{-i})$ (the minimax payoff) can be sustained as the average payoff of a subgame perfect equilibrium.

**Core theorem**: Let $v = (v_1, \ldots, v_n)$ be a feasible and individually rational payoff vector ($v_i \geq \underline{v}_i$, where $\underline{v}_i$ is $i$'s minimax value). Then, when the discount factor $\delta$ is sufficiently close to 1, $v$ can be realized as the average payoff of a subgame perfect equilibrium of the infinitely repeated game.

Implementation mechanism: punishment strategy — a deviator is "punished" back to the minimax payoff level, so the short-term gain from deviation is offset by the long-term punishment.

**Key ideas**: The Folk Theorem is the central result in repeated games — it explains why cooperation can be sustained in long-run interactions: the short-term gain from deviation is outweighed by the long-term loss from punishment. The theorem also explains why repeated games have infinitely many equilibria — virtually any feasible payoff can be realized. Aumann (2005 Nobel Prize) systematized this theory. Mathematical context: the discount factor $\delta$ approaching 1 makes future punishment sufficiently severe — $\delta \geq \frac{g}{g + l}$, where $g$ is the gain from deviation and $l$ is the punishment loss.
