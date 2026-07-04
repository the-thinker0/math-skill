# Eval: Should NOT Trigger

These prompts should NOT trigger the math research OS at all.

## Test Cases

1. 帮我修一下这个 Python 的 import 错误
2. 这个函数的 tensor shape 对不上，帮我 debug
3. 把 batch size 从 32 改成 64，看看 loss 变化
4. 帮我重构一下这个 training loop，太乱了
5. 这个代码审查意见你怎么看？有没有逻辑错误？
6. 帮我写个 README 文档
7. 把 argparse 的参数改成 yaml 配置文件
8. Fix the CUDA out of memory error in this training script
9. Can you review this PR for code quality issues?
10. Add logging to the training loop so I can track loss per epoch

## Expected Behavior

- Activator diagnoses Scenario E (pure engineering)
- Does NOT load any lenses, knowledge cards, or design patterns
- Either stays silent or explicitly says "this is an engineering task, math system not applicable"
- Gate 0 (exclusion gate) should catch all of these
