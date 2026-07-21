# Eval: Should Trigger — Verification (Scenario D)

These prompts SHOULD trigger the verification route: 1–2 knowledge anchors (or a temporary card) → compact conditions/boundaries check. Output is short and conclusion-first; load the full critic only for an explicitly comprehensive review.

## Test Cases

1. "这个公式成立吗：$\|A\|_F^2 = \sum_i \sigma_i^2$？有什么前提？"
2. "KL 散度能不能用作距离？为什么不满足三角不等式？"
3. "这个 Weyl 不等式能保证 attention 输出的误差界吗？"
4. "Does natural gradient guarantee convergence? Under what conditions?"
5. "Eckart-Young 给出的 $\sigma_{k+1}$ 界，能直接推出 attention 输出误差吗？"
6. "这个归约证明的紧度 $\varepsilon \approx Q \cdot \varepsilon_{\mathsf{assumption}}$ 中 $Q$ 多大才算松？"
7. "用 Plücker 坐标表示低秩子空间，比直接存基底更省存储吗？"
8. "If I use a PRF to seed my router, is this provably unpredictable to an adversary?"

## Expected Behavior

- Activator diagnoses Scenario D (verification)
- Loads relevant knowledge anchors (e.g., `matrix-analysis/spectral-decomposition`, `probability/kl-divergence`, `cryptography/prf-prg-owf`) or generates temporary cards if uncovered
- Output is a short conclusion followed by the decisive conditions, failure boundary, and maximum justified guarantee; engineering feasibility appears only when implementation matters
- For AI implementation questions, checks only relevant GPU dimensions and marks unrelated ones `N/A`
- For crypto domain: passes reduction tightness + assumption dependency + implementation pitfall checks (GPU gate not required)
- **Must identify common verification pitfalls**:
  - Test 3: Weyl bounds eigenvalue/singular-value perturbation, not the full attention output; an output bound additionally needs the perturbation path, norm choices, and Lipschitz/boundedness assumptions
  - Test 5: Eckart–Young bounds matrix approximation error, not attention output error; propagating it needs bounds on Q, softmax, and V as appropriate
  - Test 6: "loose reduction = secure" is an anti-pattern; Q large requires parameter compensation
  - Test 7: Plücker coordinates expand at low rank (anti-pattern warned in the low-rank-kv-cache design pattern)
  - Test 8: seeding a router with a secure PRF does not by itself make the router output pseudorandom; the construction, key secrecy, query interface, and post-processing all enter the claim

## Key Assertions

- Output follows the short-conclusion + conditions/boundaries format
- Relevant knowledge anchors or temporary cards are loaded
- Common verification pitfalls are explicitly identified
- For crypto, reduction tightness is checked (not just "is there a reduction")
