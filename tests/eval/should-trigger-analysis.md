# Eval: Should Trigger — Analysis (Scenario A)

These prompts SHOULD trigger the analysis route: 1–2 lenses → compact assumption/logic/boundary review. Do not load the full critic unless the user asks for a comprehensive or paper-grade review.

## Test Cases

1. "这个 attention 设计在数值上稳定吗？bf16 会不会出问题？"
2. "我这个 loss 同时要保证正交性和判别性，逻辑上有没有矛盾？"
3. "用流形优化更新参数，但是参数其实不在流形上，这个推理对吗？"
4. "Is the reduction proof in this paper tight? Does the security loss Q matter?"
5. "这个 contrastive loss 真的能保证 domain alignment 吗？推导链有没有漏洞？"
6. "用李群等变性约束网络，但数据其实只是近似对称，这个假设合理吗？"
7. "我的 routing 设计声称是全局最优，但其实是贪心分配——这个表述有没有问题？"
8. "Does my orthogonality regularization with σ²(1-σ²) penalty actually penalize overlap? It's 0 at both σ=0 and σ=1!"

## Expected Behavior

- Activator diagnoses Scenario A (analysis)
- Selects 1–2 relevant lenses; do not narrate rejected lenses unless that changes the conclusion
- Leads with the conclusion, then gives only the 2–4 decisive assumptions, boundaries, or counterexamples; no fixed diagnostic/lens headings are required
- Does not draft a new design or add GPU analysis unless the question requires it
- Uses the compact review checklist by default; full critic is conditional
- **Must give a conclusion, not just analysis** — never output analysis alone without convergence
- For test case 8, must distinguish “encourages binary singular values” from “penalizes overlap”: `σ²(1-σ²)` is zero at both 0 and 1, while no-overlap needs a monotone penalty such as `Σσ²`; a barrier near 1 is an option only when strict separation is intended

## Key Assertions

- Output is conclusion-first and omits internal route narration unless routing itself is under test
- Assumptions and logic are reviewed without requiring the full critic file
- No design pattern loading unless the user explicitly asks for a redesign
- Conclusion is actionable, not just descriptive
