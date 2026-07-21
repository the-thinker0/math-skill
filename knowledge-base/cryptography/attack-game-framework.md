# 攻击游戏框架 / Attack Game Framework

## 最小定义
攻击游戏（attack game）是 challenger $\mathcal{C}$ 与 adversary $\mathcal{A}$ 之间的形式化交互过程，用于定义"安全"。安全 = 不存在 PPT 敌手 $\mathcal{A}$ 能以非忽略概率赢游戏。这是密码学把"直觉上安全"变成可证明性质的统一范式。

典型游戏结构：
1. **初始化**：挑战者生成密钥 / 系统参数
2. **训练阶段（查询）**：敌手可向挑战者查询 oracle（加密 / 解密 / 签名等），受限于威胁模型（CPA / CCA1 / CCA2）
3. **挑战**：敌手提交两个挑战消息 $m_0, m_1$；挑战者随机选 $b$，返回 $c=\mathsf{Enc}_k(m_b)$
4. **后续查询阶段**（取决于威胁模型）：敌手可继续查询（除挑战密文本身）
5. **输出猜测**：敌手输出 $b'$；赢当且仅当 $b'=b$

## 核心公式
- **优势定义（双实验）**：$\mathsf{Adv}_{\mathcal{A}}=|\Pr[W_0]-\Pr[W_1]|$，其中 $W_i$ 是敌手在实验 $i$ 中输出 1 的事件
- **优势定义（猜 bit）**：$\mathsf{Adv}^{*}_{\mathcal{A}}=2\cdot\Pr[b'=b]-1$，与双实验等价：$\mathsf{Adv}^{*}=2\cdot\mathsf{Adv}$
- **归约闭合性**：$\mathsf{poly}\cdot\mathsf{neg}=\mathsf{neg}$；$\mathsf{neg}+\mathsf{neg}=\mathsf{neg}$；使 hybrid 论证可行
- **Birthday 界**：$q$ 次随机查询碰撞概率 $\le q^{2}/2^{n}$，给出生日攻击的查询数下界
- **安全 = 优势可忽略**：方案安全当且仅当对所有 PPT $\mathcal{A}$，$\mathsf{Adv}_{\mathcal{A}}\le\mathsf{negl}(n)$

## 适用问题
- 任何需要形式化威胁模型的 AI 场景：
  - **白盒 vs 黑盒 vs 自适应对抗**：ML 鲁棒性威胁模型层级化建模
  - **对抗样本**：敌手能力预算（扰动范数）+ 胜利条件（误分类）+ 不可破证明
  - **模型窃取**：敌手查询次数受限 + 窃取成功率可忽略
  - **数据投毒**：敌手可修改训练数据比例 + 性能下降可忽略
  - **后门检测**：敌手植入后门但不可被检测器识别
  - **水印可追踪性证明**：敌手移除水印 ⇒ 不可忽略概率失败
  - **可验证推理**：敌手伪造推理输出 ⇒ 解某困难假设

## AI 设计翻译
- **把攻击游戏套到 ML 鲁棒性**：定义敌手能力预算（扰动 $\|\delta\|_p\le\epsilon$）→ 定义胜利条件（误分类或置信度偏移）→ 证不可破。这把"直觉上鲁棒"变成可证明性质。注意：ML 场景敌手能力难以严格形式化，往往需要假设敌手用某种攻击算法类。
- **威胁模型层级化**：CPA / CCA / AE 对应 ML 中的"黑盒查询预算 / 白盒梯度访问 / 自适应对抗训练"。层级选择决定威胁强度。
- **优势界作为鲁棒性证书**：给出 $\mathsf{Adv}_{\mathcal{A}}\le\mathsf{negl}(n)$ 类型的界，作为"相对安全"证书。
- 对应设计模式见 `../../design-patterns/`（如 constraint-penalty）；无对应模式时标为"临时设计翻译"。

## 工程可行性
攻击游戏框架是纯方法论，不落 GPU：
- 游戏定义是逻辑构造，不涉及张量运算
- 优势界计算是数学推理，不产生 GPU kernel
- 敌手能力建模是威胁建模，不涉及低精度数值
GPU 八维评估不适用；密码学产出通过归约紧度 + 假设依赖 + 实现陷阱检查（不走 GPU 门）。详见 `../../references/gpu-friendly-math.md` 的"密码学 GPU 友好性警告"。

## 风险与失效条件
- **敌手能力建模过弱**：游戏形式化时若敌手能力建模过弱（如只允许 $L_\infty$ 扰动而忽略 $L_2$、$L_0$ 等其他范数），会出现"游戏安全但实际不安全"——这是 ML 鲁棒性证明最常见的失效模式
- **ML 场景敌手能力难以形式化**：真实攻击者可能用任意算法，形式化时往往限制敌手为某类（如 PGD 攻击类），但实际攻击可能超出该类
- **忽略函数定义在多项式安全参数下**：$\mathsf{negl}(n)$ 要求 $n$ 是安全参数；ML 参数规模可能使界失效（如 $n$ 是输入维度，$n\to\infty$ 时 $\mathsf{negl}(n)$ 不可控）
- **敌手查询预算与实际部署不符**：游戏可能限制敌手 $q$ 次查询，但实际部署中敌手查询数无界
- **归约闭合性假设依赖**：$\mathsf{poly}\cdot\mathsf{neg}=\mathsf{neg}$ 要求敌手是 PPT；若敌手非多项式（如指数时间）则证明失效
- **随机性假设**：游戏要求挑战者真随机，ML 场景的随机性（如 PRNG 种子）是否真随机需验证

## 深入参考
- 蒸馏稿：`../../references/books/applied-cryptography.md`（§2 攻击游戏框架、§2.2 优势定义、§2.3 PPT + 忽略函数）
- 蒸馏稿：`../../references/books/foundations-of-cryptography.md`（§III 定义方法论）
- 蒸馏稿：`../../references/books/introduction-to-modern-cryptography.md`（形式化安全定义）
- 原书：Boneh & Shoup, *A Graduate Course in Applied Cryptography*, §2；Goldreich, *Foundations of Cryptography Vol. 1*, §III

## 路由扩展
- 若需要归约 → `reduction-proof-template.md`（黑盒归约、紧度分析）
- 若需要威胁层级 → `cca-cpa-ae-hierarchy.md`（CPA/CCA/AE）
- 若需要假设形式化 → `prf-prg-owf.md`（OWF/PRG/PRF）
- 若需要博弈视角 → `../../lenses/game.md`（多方策略互动）
- 若需要概率工具 → `../probability/concentration-inequality.md`（birthday 界、优势累加）

## 可扩展方向
- UC 框架（Universal Composability）：通用可组合安全定义
- 模拟范式（simulation paradigm）：敌手视角 ↔ 模拟器视角的等价
- 零知识游戏：完备/统计/计算零知识的三档定义
- 多方游戏：多方协议的安全定义（BEKW 框架）
- 细粒度安全游戏：参数化的具体安全界
- 量子敌手游戏：量子计算能力下的安全定义
