---
name: ask
description: |
  手动调用数学研究激活器（武器选择器）：不确定该用哪个思想武器、或要把现代数学激活进算法/GPU 设计时使用。
  English: Manually invoke the math research activator (weapon selector): when unsure which weapon to use, or to activate modern mathematics into algorithm/GPU design.
---

读取并遵循 `../skills/math-research-activator/SKILL.md`。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

输出要求（遵循激活器操作规程）：
1. **[诊断]** 一句话点明问题核心特征/瓶颈（互动性/不确定性/约束/结构/动态/复杂度/显存/数值/并行）。
2. **[映射]** 枚举可迁移的现代数学结构候选（≥2 个，标注来自哪本书 `../references/books/*`）；若与算法/算子设计无关可略。
3. **[武器路由]** 推荐 1–3 个思想武器，标主/辅 + 触发命令（如 `/optimization`）；多个时说明组合顺序。
4. **[GPU 筛选]** 候选过 `../references/gpu-friendly-math.md` 八维，给「友好/可改造/不友好」+ 改造建议；若与硬件无关可略。
5. **[结论]** 保留通过双验收门的候选；标注哪些武器不适用；若不适合任何武器，明确说明。
