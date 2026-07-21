# Eval: Should Trigger — Verification (Scenario D)

These prompts SHOULD trigger the verification pipeline: Knowledge anchors (or temporary cards) → Critic. Output is short conclusion first, then conditions/boundaries.

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
- Output structure:
  1. 成立条件 (conditions under which it holds)
  2. 不成立条件 (conditions under which it fails)
  3. 最多能保证什么 (what it can guarantee at most)
  4. 不能保证什么 (what it cannot guarantee)
  5. 工程可行性 (engineering feasibility, only when implementation / GPU matters)
- Short conclusion first, then conditions/boundaries
- For AI domain: passes GPU gate if implementation is involved
- For crypto domain: passes reduction tightness + assumption dependency + implementation pitfall checks (GPU gate not required)
- **Must identify common verification pitfalls**:
  - Test 3: Eckart-Young bounds K/V matrix error, NOT attention output error — softmax Lipschitz and Q-bound needed
  - Test 6: "loose reduction = secure" is an anti-pattern; Q large requires parameter compensation
  - Test 7: Plücker coordinates expand at low rank (anti-pattern warned in the low-rank-kv-cache design pattern)
  - Test 8: "AES as PRF" is an assumption not a theorem; adversary capability depends on deployment

## Key Assertions

- Output follows the short-conclusion + conditions/boundaries format
- Relevant knowledge anchors or temporary cards are loaded
- Common verification pitfalls are explicitly identified
- For crypto, reduction tightness is checked (not just "is there a reduction")
