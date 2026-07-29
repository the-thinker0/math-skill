---
name: ask
description: |
  数学研究操作系统入口：自动诊断用户意图，路由到思想透镜、数学知识库或设计翻译层。
  English: Math Research OS entry: auto-diagnose user intent, route to thinking lenses, math knowledge base, or design translation layer.
---

## 语言路由（内联）

判定主语言：看句式、动词、语气词的主框架。AI/数学/工程术语（attention、loss、routing 等）不计入语言判定。代码、路径、公式不计入。中英比例接近时沿用上一轮语言，无上下文默认中文。显式"用英文/用中文"优先。

- 中文主语言 → 读取 `../SKILL.md`（权威入口，可中英作答）
- 英文主语言 → 读取 `../SKILL.en.md`（英文兼容入口）
- 两者不同时加载

当前问题：
$ARGUMENTS
