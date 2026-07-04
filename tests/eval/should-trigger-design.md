# Eval: Should Trigger — Design (Scenario B)

These prompts SHOULD trigger the full design pipeline: Lenses → Knowledge → Design → Critic.

## Test Cases

1. 设计新的 KV-Cache 压缩方法，保留长期依赖，不想只做 top-k
2. 设计一个新的 attention 机制，能区分有益迁移和负迁移
3. 我想设计一个新的 MoE routing 策略，用最优传输代替 noisy top-k
4. Design a loss function that enforces orthogonality between attention heads
5. 设计一个共享-私有表示分解模块，用于多域推荐系统

## Expected Behavior

- Activator diagnoses Scenario B (mechanism design)
- Selects 1-3 relevant lenses
- Loads relevant knowledge cards
- Generates design pattern candidates
- Runs GPU 8-dimension gate
- Outputs structured design proposal with implementation sketch
