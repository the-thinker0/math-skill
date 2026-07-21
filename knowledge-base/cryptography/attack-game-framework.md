# 攻击游戏框架 / Attack-Game Framework

## 最小定义

攻击游戏是挑战者与敌手之间的概率交互实验，用来精确定义安全目标、敌手能力和胜利事件。方案安全通常表示：对所有给定资源界内的敌手，其优势可忽略（渐近安全）或小于明确数值（具体安全）。

加密的 indistinguishability game 只是一个实例；签名、MAC、承诺和零知识各有不同 oracle、限制与胜利条件，不能统一套用“提交两条消息、猜 bit”的固定流程。

## 核心公式

- 双实验优势：
  $$\operatorname{Adv}_A=\left|\Pr[A\text{ 在实验 }0\text{ 输出 }1]-\Pr[A\text{ 在实验 }1\text{ 输出 }1]\right|.$$
- 猜 bit 游戏常用 $\left|\Pr[b'=b]-\tfrac12\right|$ 或其两倍。比较论文时必须先对齐 convention。
- 序列游戏/Difference Lemma：若两游戏只在事件 `bad` 后可能分歧，则
  $$\left|\Pr[W_0]-\Pr[W_1]\right|\le \Pr[\mathsf{bad}].$$
- $q$ 个均匀 $n$-bit 样本发生碰撞的 union bound 为 $q(q-1)/2^{n+1}$；“$q^2/2^n$”只是量级写法。

## 适用问题

- 为 IND-CPA/CCA、EUF-CMA、PRF、binding/hiding 等性质写正式游戏。
- 比较敌手是否拥有加密、解密、签名、验证、随机预言机或状态泄露接口。
- 检查挑战后的禁止查询、freshness、multi-user、adaptive corruption 等细节。
- 将证明改写成游戏序列并跟踪每一步优势损失。

## 密码学构造与跨域边界

- 游戏框架可以迁移到 AI 安全定义，但只能迁移“显式写敌手、接口、预算和胜利事件”的方法，不能把 CPA/CCA 名称直接重命名为黑盒/白盒攻击。
- ML 鲁棒性中的扰动集、数据分布和错误率一般不是可忽略函数；应使用与任务匹配的风险或认证半径，而非机械要求 $\operatorname{negl}(n)$。
- 只有当 AI 方案实际调用密码学原语或声称密码学安全性质时，才加载本卡的密码学 oracle 细节。

## 实现注意事项

- 游戏是定义；测试代码只能发现实现偏差，不能以有限样本证明所有 PPT 敌手优势可忽略。
- 具体安全报告应列出安全参数、查询数、时间/内存资源、多用户数和所有失败事件。
- 随机数、状态重置、challenge freshness 和禁止查询条件必须在实现与证明中一致。

## 风险与失效条件

- **敌手模型过弱**：遗漏接口、泄露或自适应能力会得到“在错误游戏里安全”的结论。
- **优势 convention 混用**：$|p-1/2|$ 与 $2|p-1/2|$ 相差 2，可能破坏具体参数计算。
- **渐近与具体安全混淆**：可忽略函数并不自动说明固定参数下足够安全。
- **挑战限制漏写**：允许直接查询挑战对象会使游戏平凡；限制过强又会人为抬高安全性。
- **把经验攻击失败当证明**：未找到攻击只给出对已测试敌手的证据。

## 深入参考

- `../../references/books/applied-cryptography.md`
- `../../references/books/foundations-of-cryptography.md`
- `../../references/books/introduction-to-modern-cryptography.md`

## 路由扩展

- 归约：`reduction-proof-template.md`
- CPA/CCA/AE：`cca-cpa-ae-hierarchy.md`
- PRF：`prf-prg-owf.md`
- 概率界：`../probability/concentration-inequality.md`
