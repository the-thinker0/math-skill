# 密码学基础 / Foundations of Cryptography

Oded Goldreich，*Foundations of Cryptography, Volume 1: Basic Tools*，Cambridge University Press，2001，ISBN 978-0-521-79172-4。[作者目录、勘误与草稿入口](https://www.wisdom.weizmann.ac.il/~oded/foc-vol1.html)（核验：2026-09-07）。

## 什么时候读

用于原语存在性、量词、安全定义与构造归约。**第 1 卷只有第 1–4 章**，加附录；旧索引中的第 5/6/7/9 章与罗马数字“原书 part”不应引用。加密/签名/通用协议的系统展开属于第 2 卷。

## 已核验的查找入口

| 问题 | 第 1 卷位置 |
|---|---|
| 概率与计算模型 | §1.2–1.3 |
| OWF 的强/弱定义与放大 | §2.2–2.3 |
| hardcore predicate | §2.5 |
| 伪随机生成与构造 | 第 3 章，尤其 §3.2–3.4 |
| 伪随机函数 | §3.6 |
| 零知识定义与 NP 构造 | §4.2–4.4 |

## 定义与归约检查

- 明确输入分布、安全参数、均匀/非一致敌手、辅助输入和资源上界。“难优化”的学习目标不等同于平均情形 OWF。
- OWF/PRG/PRF 在标准存在性框架下有等价联系；具体构造的效率不等价，不能把所有 GGM 使用都判作不可行。
- PRG 输出可与均匀分布统计距离很大，却计算不可区分；模型区分器训练失败不是对所有高效区分器的证明。
- 多样本 hybrid 需要相应独立、高效可采样条件。弱→强 OWF 放大可使用独立输入，但共享攻击算法的成功事件不能直接当独立相乘。
- next-bit 伪随机刻画针对二进制分布族和明确的计算模型，不能把自然语言 next-token 准确率直接代入。

## 模拟与跨域边界

零知识检查验证者、模拟器量词、辅助输入、时间类型和统计/计算差异。HVZK 不自动覆盖恶意验证者，并行/并发合成需看具体协议和定义。零知识或“存在模拟器”本身不推出差分隐私。

这里建议用 `axiomatization`、`probabilistic` 或 `algorithmic` 透镜核对定义与归约；不默认枚举其他透镜或读 GPU 清单。若要迁移到 ML，先定义新的实验与功能约束，再判断定理前提是否仍满足。

## 深挖入口

先用 [PRF/PRG/OWF 锚点](../../knowledge-base/cryptography/prf-prg-owf.md) 与 [归约模板](../../knowledge-base/cryptography/reduction-proof-template.md)。需要元定理或证明细节时按作者目录检索原文，引用实际版次和章节；来源不可得时保留未核验状态。
