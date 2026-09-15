# Worked example: from PRF security to a MAC forgery bound

Pure cryptography; use the [reduction template](../../knowledge-base/cryptography/reduction-proof-template.en.md), without AI patterns.

## Fix the game

Let $F_k:\{0,1\}^m\to\{0,1\}^t$, with the key generated for a security parameter and fixed $m$-bit messages. Define $\operatorname{Tag}_k(x)=F_k(x)$. An adversary adaptively queries a tag oracle, then submits a previously unqueried message $x^*$ and tag $u^*$. It wins when $u^*=F_k(x^*)$. This game permits one final fresh-message forgery and no verification oracle.

Invalid tags and previously queried messages are rejected before the reduction checks its oracle. The ideal-game success probability is **at most** $2^{-t}$; equality assumes the adversary always outputs a valid fresh message and a $t$-bit tag.

## Reduction

1. $B$ answers tag queries with its own oracle, then queries $x^*$ to check the forgery and outputs success. For at most $q$ tag queries, $B$ makes at most $q+1$ oracle queries and includes adversary plus simulation runtime.
2. Replace $F_k$ by a uniform random function $R$ of the same domain/range. Freshness makes $R(x^*)$ uniform conditional on the previous transcript, so success is at most $2^{-t}$.

With PRF advantage defined as a two-experiment difference,

$$\Pr[\mathrm{Forge}_F(A)]\le\operatorname{Adv}^{\mathrm{PRF}}_F(B)+2^{-t}.$$

There is no automatic $q$-fold hybrid loss or birthday term here. Switching to a PRP, allowing verification queries, or changing freshness requires redoing the game and bound.

## Boundaries and failure controls

- Replaying a queried message/tag is not forgery in this game; counting it would allow certain success after one query.
- Hard key recovery does not imply unforgeability: a public constant-tag function hides an unused key yet permits trivial forgery.
- A fixed-length PRF does not directly handle arbitrary variable-length messages. Use a domain extension or MAC construction with a corresponding proof; do not truncate or concatenate without analysis.
- This reduction does not check side channels, key generation, or implementation bugs. They are assumptions relating deployment to the game.

## Parameters and checks

Evaluate the concrete primitive bound at $q+1$ queries and the stated runtime, then add the tag-guessing term. A $t$-bit tag alone does not establish $t$-bit end-to-end security. Exhausting small tag spaces can check the guessing probability, not PRF security.

Based on the message-integrity material in the [Boneh–Shoup author textbook](https://toc.cryptobook.us/); the bound is a direct reduction for the explicit one-forgery game above.

## Runnable check

Run the following JavaScript with Node.js 18+. The repository test `node --test tests/math-examples.test.mjs` executes both language versions. These finite checks verify this example only; they do not replace the argument above.

```javascript
// Ideal random functions on two messages with two-bit tags.
// Query message 0, then forge fresh message 1. Exhaust all deterministic guesses
// based on the observed tag: four choices for each of four observations.
const tagCount = 4;
for (let strategy = 0; strategy < 4 ** 4; strategy++) {
  let wins = 0;
  for (let observed = 0; observed < tagCount; observed++) {
    const guess = (strategy >> (2 * observed)) & 3;
    for (let fresh = 0; fresh < tagCount; fresh++) {
      if (guess === fresh) wins++;
    }
  }
  if (wins / (tagCount ** 2) !== 2 ** -2) {
    throw new Error('Fresh-tag probability failed');
  }
}
// This finite ideal-game check is not a proof that any concrete PRF is secure.
```
