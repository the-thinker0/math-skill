# Eval: Should Trigger — Knowledge Query (Scenario C)

These prompts SHOULD trigger direct knowledge card loading without full design pipeline.

## Test Cases

1. 流形上的切空间到底是什么？和梯度有什么关系？
2. 正交投影定理能用来做什么？在 AI 里怎么实现？
3. What is information bottleneck and how does it relate to VAE?
4. KL 散度和 JS 散度有什么区别？什么时候用哪个？
5. 黎曼优化和普通的梯度下降有什么本质区别？
6. Explain persistent homology and how it could be used as a regularizer

## Expected Behavior

- Activator diagnoses Scenario C (knowledge query)
- Loads relevant knowledge card(s) directly
- Outputs a minimal definition, one core formula/intuition, and the key applicability boundary
- Adds AI translation, engineering feasibility, risks, or references only when the prompt asks for them or they change the answer
- Does NOT load design patterns unless user asks for implementation
