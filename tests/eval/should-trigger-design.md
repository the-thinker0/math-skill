# Eval: Should Trigger — Design (Scenario B)

These prompts SHOULD trigger the minimal design route: lenses → anchors → optional design prototypes → compact review. The full critic is reserved for an explicitly comprehensive or paper-grade review.

## Test Cases

1. 设计新的 KV-Cache 压缩方法，保留长期依赖，不想只做 top-k
2. 设计一个新的 attention 机制，能区分有益迁移和负迁移
3. 我想设计一个新的 MoE routing 策略，用最优传输代替 noisy top-k
4. Design a loss function that enforces orthogonality between attention heads
5. 设计一个共享-私有表示分解模块，用于多域推荐系统

## Expected Behavior

- Activator diagnoses Scenario B (mechanism design)
- Selects 1–2 relevant lenses
- Loads relevant knowledge cards
- Produces one primary design; alternatives only when a decisive tradeoff warrants them
- For operator/training/inference implementation, evaluates only decision-relevant GPU dimensions and quantifies the main cost; unrelated dimensions are `N/A`
- Outputs a conclusion-first proposal with an implementation sketch and falsification/ablation plan
