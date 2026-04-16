---
name: ask
description: |
  当不知道该用哪个思想武器时，让系统帮你选择。
  English: When unsure which thinking weapon to use, let the system help you choose.
---

读取并遵循 `skills/meta-selector/SKILL.md`。

如果输入包含 "in English"，请使用英文输出；否则使用中文输出。

当前问题：
$ARGUMENTS

输出要求：
1. 一句话描述问题的核心特征（互动性、不确定性、约束性、结构性、动态性）。
2. 推荐最合适的1-3个思想武器，并说明理由。每个工具标注触发命令（如 `/optimization`）。
3. 建议使用科研模式还是生活模式。
4. 如果推荐多个工具，说明组合顺序（前置→主要→辅助）。
5. 明确标注哪些思想武器不适用于此问题，避免误用。
6. 如果问题不适合任何思想武器，明确说明。