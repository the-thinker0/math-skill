# Eval: Should Trigger — Analysis (Scenario A)

These prompts SHOULD trigger the analysis pipeline: Lenses → Critic (no design output, no GPU gate unless analysis explicitly involves GPU).

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
- Selects 1-3 relevant lenses (with reasons why each is/is not suitable)
- Outputs structure: **[诊断]** problem type + core tension → **[透镜]** recommended perspectives → **[结论]** conclusion
- Does NOT output [设计] (no design draft) or [GPU] (unless analysis explicitly involves GPU)
- Loads critic for review
- **Must give a conclusion, not just analysis** — never output analysis alone without convergence
- For test case 8, must identify the bug (penalty is 0 at both extremes) and recommend the correct log-barrier form

## Key Assertions

- Output follows the [诊断] → [透镜] → [结论] format
- Critic is invoked to review assumptions and logic
- No design pattern loading unless the user explicitly asks for a redesign
- Conclusion is actionable, not just descriptive
