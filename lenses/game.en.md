# 🎯 Game Lens

> Your optimal choice depends on others' choices — thinking must be not only deep but interactive.

## What Perspective It Offers

This is a "player's" perspective — in environments where multiple decision-makers mutually influence one another, each participant's optimal action depends on others' actions, and others' optimal actions in turn depend on yours. It demands recursive depth of reasoning: "I think that you think that I think..." The core is not optimizing one's own payoff, but finding a stable state from which no one is willing to unilaterally deviate — the Nash equilibrium.

## What Problems It Is Suited to Diagnose

- Multiple decision-makers whose strategies affect one another's payoffs
- Designing incentive mechanisms that channel self-interested behavior toward desired social outcomes
- Analyzing optimal strategies and equilibrium predictions in competitive or adversarial scenarios
- Anticipating others' actions and adjusting one's own decisions accordingly

## What Problems It Is Not Suited For

- Single-agent decision problems with no interaction with others — optimization thinking is more appropriate
- Purely cooperative problems where all participants share identical objectives — strategic analysis is unnecessary
- Deterministic problems where outcomes are uniquely determined by one's own actions — no others' responses are involved
- Outcomes determined purely by luck, with no strategic choices available to any party

## Which Knowledge Domains It Routes To

- Game theory (Nash equilibrium / dominant strategies / mixed strategies): the core framework for analyzing strategic interaction
- Mechanism design: redesigning the rules when equilibria are undesirable, making cooperation the self-interested choice
- Optimization theory (minimax / linear programming): computational tools for zero-sum games and equilibrium computation
- Probability theory (Bayesian games / expected payoffs): handling asymmetric information and type uncertainty

## What AI Designs It May Produce

- Game-type classifier: zero-sum / non-zero-sum / sequential / cooperative → automatic matching of solution methods
- Equilibrium solver and stability checker: Nash equilibrium + trembling-hand perfection + evolutionary stability
- Mechanism design engine: when equilibria are undesirable, automatically generating payoff-structure / rule-modification recommendations

## Reasoning Protocol

1. **Identify players and strategy sets**: Who is making decisions? What can each choose? Omitting a key player is the most common error
2. **Determine the game type**: Zero-sum / general-sum? Simultaneous / sequential? Complete / incomplete information? The type determines the method
3. **Construct the payoff structure**: Write out the payoff matrix or payoff functions; verify completeness and accuracy
4. **Solve for equilibrium**: Dominant strategies → pure-strategy Nash → mixed strategies → subgame perfection; rank multiple equilibria by Pareto dominance
5. **Test stability and design mechanisms**: Is the equilibrium robust? If the equilibrium is undesirable, redesign the rules so that good outcomes become the self-interested choice

## Acceptance Criteria

- All players have been identified; strategy sets and payoff functions are explicitly defined
- The game type has been determined and the corresponding solution method selected
- Equilibria have been computed (pure / mixed / subgame-perfect); multiple equilibria are annotated and ranked
- Stability checks have been performed (trembling-hand / evolutionary stability / deviation incentives)
- If equilibria are undesirable, mechanism design recommendations have been provided (rule changes / payoff modifications / reputation mechanisms)
