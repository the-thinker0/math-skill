# 归约证明模板 / Reduction-Proof Template

## 最小定义

安全归约构造算法 $B$，把破坏方案的敌手 $A$ 当作子程序，用 $A$ 的成功来解决某个已定义的困难问题。正确结论是条件式：若假设问题对给定资源的算法仍困难，且模拟与参数界成立，则不存在相应资源范围内的成功敌手。

## 核心公式

典型具体安全界写成
$$
\operatorname{Adv}^{\mathsf{scheme}}(A)
\le L(q,n)\operatorname{Adv}^{\mathsf{assump}}(B)+\delta(q,n),
$$
其中 $L$ 是归约损失，$\delta$ 汇总碰撞、模拟失败等项。必须同时报告 $B$ 的运行时间和 oracle 查询数，不能只比较优势。

- Difference Lemma：两游戏仅在 `bad` 后分歧时，优势差至多 $\Pr[\mathsf{bad}]$。
- Hybrid：$|p_0-p_t|\le\sum_{i=0}^{t-1}|p_i-p_{i+1}|$；每步界与步数都要进入最终损失。
- 渐近闭合性 $\operatorname{poly}\cdot\operatorname{negl}=\operatorname{negl}$ 只说明最终仍可忽略，不说明固定参数下数值可接受。

## 适用问题

- 从 PRF/PRP、OWF、DDH/LWE 等假设证明加密、MAC、签名或协议安全。
- 审查 reduction 的模拟是否完美/统计接近/计算不可区分。
- 跟踪 guessing、rewinding、hybrid、forking 等步骤的损失。
- 比较标准模型、ROM/QROM、黑盒/非黑盒证明的假设边界。

## 密码学构造与跨域边界

- 归约不是因果推断，也不是“两个问题相似”的类比；必须给出可执行的 $B$、接口模拟和成功概率关系。
- AI 鲁棒性或水印只有在安全游戏、安全参数、敌手资源和底层困难问题都被正式定义时，才可声称密码学归约。普通 Lipschitz 证书、统计泛化界或差分隐私保证不是“密码学困难假设”。
- Hybrid 的求和技巧可用于一般分布变化分析，但那只是数学不等式；不要因此宣称获得密码学安全。
- 模拟器能生成某种输出分布，并不自动证明训练数据隐私；需要明确的 indistinguishability/simulation 定义或正式的 DP 参数。

## 实现注意事项

- 写出 $B$ 如何生成公共参数、回答每类查询、嵌入挑战、处理 abort，并从 $A$ 的输出提取解。
- 为每个游戏跳转注明依据：完全相同、统计距离、计算假设或 bad-event bound。
- 具体参数选择应把优势、时间、查询、多用户和失败项一起代入；不能用“多项式损失”替代数值分析。
- GPU 性能与归约有效性正交；仅当用户问具体原语实现时另做性能分析。

## 风险与失效条件

- **方向写反**：从“能解假设 ⇒ 能攻击方案”通常不能推出“攻击方案 ⇒ 能解假设”。
- **模拟不可分辨未证明**：$A$ 在模拟环境中的视图若与真实游戏可区分，调用其优势无效。
- **紧度与资源漏项**：优势损失小但 $B$ 运行时间或查询数过大，仍可能没有有意义的具体安全。
- **模型错配**：ROM/QROM、选择性/自适应安全、单用户/多用户之间不能静默切换。
- **abort/guessing 未计入**：猜 challenge index 或条件中止会产生显著损失。
- **把存在性当实用参数**：渐近归约成立不保证当前 key size 足够。

## 深入参考

- `../../references/books/foundations-of-cryptography.md`
- `../../references/books/applied-cryptography.md`
- `../../references/books/introduction-to-modern-cryptography.md`

## 路由扩展

- 攻击游戏：`attack-game-framework.md`
- PRF/OWF：`prf-prg-owf.md`
- CPA/CCA/AE：`cca-cpa-ae-hierarchy.md`
