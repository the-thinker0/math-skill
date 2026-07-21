# 归约证明模板 / Reduction Proof Template

## 最小定义
归约证明是"破方案 $Y$ ⇒ 解困难假设 $X$"的构造性推理范式。核心是构造一个 PPT 算法 $\mathcal{B}$（称为 reduction/wrapper），以敌手 $\mathcal{A}$ 为子程序：若 $\mathcal{A}$ 以优势 $\varepsilon$ 破方案 $Y$，则 $\mathcal{B}$ 以优势 $\varepsilon'=\mathsf{poly}(\varepsilon)$ 解假设 $X$。因此若 $X$ 困难，则 $Y$ 安全。

归约证明是密码学把"相对安全"形式化的标准范式：安全不是绝对属性，而是"在假设 $X$ 困难下的相对不可破"。

## 核心公式
- **归约紧度**：$\varepsilon_{\mathsf{scheme}}\le Q\cdot\varepsilon_{\mathsf{assumption}}$，其中 $Q$ 是查询数 / 混合步数 / 归约中的损失因子；$Q$ 越大归约越松
- **归约成功概率**：$\Pr[\mathcal{B}^{O_X}\text{ wins}]\ge\frac{\varepsilon_{\mathcal{A}}}{\mathsf{poly}(n)}$，其中 $\varepsilon_{\mathcal{A}}$ 是敌手优势
- **Difference Lemma（序列游戏）**：若 $W_0$ 与 $W_1$ 仅在某个"bad event"分支不同，则 $|\Pr[W_0]-\Pr[W_1]|\le\Pr[\text{bad}]$
- **Hybrid argument**：$H^i$ 与 $H^{i+1}$ 不可区分，$\mathsf{poly}(n)$ 步混合链 ⇒ $H^0$ 与 $H^{\mathsf{poly}(n)}$ 不可区分；优势累加 $\varepsilon\le n\cdot\varepsilon_{\text{step}}$
- **归约闭合性**：$\mathsf{poly}\cdot\mathsf{neg}=\mathsf{neg}$，$\mathsf{neg}+\mathsf{neg}=\mathsf{neg}$，$\mathsf{poly}\cdot\mathsf{poly}=\mathsf{poly}$——多项式次数闭合是 hybrid 论证的基石

## 适用问题
- 任何需要"相对安全"证书的 AI 研究场景：
  - 模型鲁棒性证书：破鲁棒性 ⇒ 解某困难假设（如语义可分性、LWE）
  - 可验证推理：推理产出可被验证但不可伪造 ⇒ 解某困难假设
  - 模型水印不可伪造性：水印可被验证但不可伪造 ⇒ OWF
  - 对抗样本归约：构造攻击 ⇒ 解困难假设；或反向：解假设 ⇒ 攻击存在
  - 隐私保证：模型输出 ⇒ 训练数据泄露 ⇒ 解差分隐私假设
- 分布漂移分析：把多步训练的分布漂移拆成单步可界
- 弱→强放大：弱学习器放大为强学习器（PAC-boosting 的镜像）

## AI 设计翻译
- **归约范式迁移到 ML 安全**：把"破方案⇒解假设"框架套到 ML 鲁棒性——若能构造 reduction 把"攻击鲁棒性"归约到"解某困难假设"，则给出"相对安全"证书。注意：ML 场景下分布漂移会破坏归约假设。
- **Hybrid argument 迁移到分布漂移**：把多步训练的分布漂移拆成相邻 hybrid，相邻差异可界 ⇒ 全程漂移可界。混合步数必须 $\mathsf{poly}(n)$，否则论证失效。
- **模拟范式迁移到隐私证书**：构造模拟器证明"模型输出可被独立生成" ⇒ 训练数据未泄露。
- 对应设计模式见 `../../design-patterns/`（如 constraint-penalty、information-bottleneck-loss）；无对应模式时标为"临时设计翻译"。

## 工程可行性
归约证明是纯方法论，不落 GPU：
- 归约 $\mathcal{B}$ 是逻辑构造，不涉及张量运算
- hybrid argument、模拟范式是推理工具，不产生 GPU kernel
- 紧度分析是数学推理，不涉及低精度数值
GPU 八维评估在此不适用；密码学产出不通过 GPU 验收门（详见 `../../references/gpu-friendly-math.md` 的"密码学 GPU 友好性警告"小节）。对应 Domain Router 规则：密码学 domain 走"归约紧度 + 假设依赖 + 实现陷阱检查"，不走 GPU 八维。

## 风险与失效条件
- **归约松（$Q$ 大）需参数补偿**：例如 RSA-FDH 签名归约紧度 $\varepsilon_{\mathsf{sig}}\approx q_H\cdot\varepsilon_{\mathsf{RSA}}$，需把模数加倍补偿；声称"松归约=安全"是反模式
- **ROM 归约有反例**：随机预言机模型（ROM）下的证明存在反例——存在方案在 ROM 下安全但任意具体实例化都不安全。把 ROM 证明当绝对保证是反模式
- **黑盒分离结果限制**：某些归约在黑盒模型下不可能——例如单向置换 ⇒ 不可伪造签名在某些黑盒归约下不可能，需非黑盒技术
- **AI 场景下分布漂移破坏归约假设**：归约要求敌手输入匹配特定分布，ML 场景中训练分布与部署分布漂移会破坏归约的分布匹配前提
- **假设可达性需重新审视**：把密码学假设迁移到 ML 时，原假设（如 PRF 的 PRF 假设）在 ML 部署场景是否可达成需重新审视——例如 ML 训练中的随机性是否真随机，密钥管理是否安全
- **模拟器复杂度**：模拟范式要求模拟器是 PPT，若模拟器复杂度不可控则零知识证明失效

## 深入参考
- 蒸馏稿：`../../references/books/foundations-of-cryptography.md`（§IV 归约论证、hybrid、放大、模拟范式、不可预测⇔伪随机）
- 蒸馏稿：`../../references/books/applied-cryptography.md`（§3 归约证明模板、§3.4-3.5 序列游戏 + Difference Lemma、§10.3 归约紧度）
- 原书：Goldreich, *Foundations of Cryptography Vol. 1*, §4；Boneh & Shoup, *A Graduate Course in Applied Cryptography*, §3, §10.3

## 路由扩展
- 若需要假设形式化 → `prf-prg-owf.md`（OWF/PRG/PRF 假设）
- 若需要攻击游戏 → `attack-game-framework.md`（challenger vs adversary）
- 若需要安全层级 → `cca-cpa-ae-hierarchy.md`（CPA/CCA/AE）
- 若需要博弈视角 → `../../lenses/game.md`（机制设计、均衡）
- 若需要因果视角 → `../../lenses/causal.md`（"破 Y 则破 X"是因果链）

## 可扩展方向
- 具体安全（concrete security）：非渐近的具体安全界
- 非黑盒归约（non-black-box reduction）：利用敌手代码内部结构
- 归约紧度下界（reduction lower bound）：证明归约紧度不可改进
- ROM 归约与反例（ROM reductions and counterexamples）：随机预言机模型的可证明性与局限
- QROM（量子随机预言机）：量子敌手下的 ROM 证明
- 归约的可行不可达性（fine-grained reductions）：参数化的细粒度归约
