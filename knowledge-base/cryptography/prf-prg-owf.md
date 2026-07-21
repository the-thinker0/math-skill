# 伪随机函数族、伪随机生成器与单向函数 / PRF, PRG, and OWF

## 最小定义
- **单向函数（OWF）**：多项式时间可计算但任何 PPT 敌手以忽略函数概率成功求逆的函数 $f$。形式化：$\Pr[f(\mathcal{A}(f(x))) = f(x)] \le \mathsf{negl}(n)$。
- **伪随机生成器（PRG）**：确定性多项式时间算法 $\mathcal{G}:\{0,1\}^{n}\to\{0,1\}^{m(n)}$，$m(n)>n$，输出与均匀分布在多项式时间内计算不可区分。
- **伪随机函数族（PRF）**：密钥函数族 $\{F_k\}_{k\in\mathcal{K}}$，与真随机函数族在计算不可区分意义下等价。
- **等价链**（密码学的核心结构定理）：OWF ⇔ PRG（HILL 定理，1989）；PRG ⇒ PRF（GGM 树构造，Goldreich-Goldwasser-Micali）；PRF ⇒ PRP（Luby-Rackoff，4 轮 Feistel）。

## 核心公式
- **OWF 定义**：$f$ 多项式可计算，$\forall\mathsf{PPT}\,\mathcal{A}$：$\Pr_{x\leftarrow\{0,1\}^{n}}\big[f(\mathcal{A}(f(x),1^{n}))=f(x)\big]\le\mathsf{negl}(n)$。
- **PRG 计算不可区分**：$\{\mathcal{G}(U_n)\}_{n}\stackrel{c}{\approx}\{U_{m(n)}\}_{n}$，$m(n)>n$，优势 $\mathsf{Adv}^{\mathsf{prg}}(\mathcal{D})=|\Pr[\mathcal{D}(\mathcal{G}(U_n))=1]-\Pr[\mathcal{D}(U_{m(n)})=1]|$。
- **PRF 安全游戏**：敌手可任意询问 $F_k$ 或真随机函数 $\mathcal{R}$，挑战者随机选 $b$；$\mathsf{Adv}^{\mathsf{prf}}_{\mathcal{A}}=|\Pr[\mathcal{A}^{F_k}=1]-\Pr[\mathcal{A}^{\mathcal{R}}=1]|$，安全当且仅当对所有 PPT $\mathcal{A}$ 此优势可忽略。
- **PRP Switching Lemma**（PRP 当 PRF 用）：$q$ 次查询区分 $n$-bit PRP 与真随机函数优势 $\le q^{2}/2^{n+1}$。
- **GGM 构造**：从长度倍增 PRG $\mathcal{G}:\{0,1\}^{n}\to\{0,1\}^{2n}$ 构造 PRF $F_k(x_1\cdots x_n)=\mathcal{G}_{x_n}\circ\cdots\circ\mathcal{G}_{x_1}(k)$，深度 $n$ 的二叉树。
- **Luby-Rackoff**：4 轮 Feistel 把 PRF 升级为 PRP（强伪随机置换需要 3 轮 PRF + 3 轮可逆性）。

## 适用问题
- 需要"可验证伪随机"的 AI 场景：路由 seed 不可预测、数据划分可复现、随机化算法 seed 管理
- 需要"难逆映射"的场景：单向哈希式注意力、可验证水印（哈希链）
- 需要形式化"伪随机性"的鲁棒性证明：对抗样本不可建模为随机噪声的形式化
- 需要形式化"可识别 vs 真随机"的分布评估：生成分布 vs 真实分布的严格语言
- 需要密钥派生的密码学 pipeline：主密钥派生子密钥

## AI 设计翻译
- **PRF 作为可验证伪随机源**：用 PRF 生成路由 seed / 数据划分 / 投影采样，保证可复现且敌手不可预测。落点：D1/D2，小开销 GEMM 友好。
- **OWF 作为难逆映射设计模式**：哈希注意力（query 的 OWF 变换不可逆推原始 query）、可验证水印（OWF 嵌入权重）。
- **不可预测性⇔伪随机性（Yao 定理）迁移**：序列模型下一 token 不可预测 ⇒ 整体伪随机；可作生成模型评估的理论语言。
- 对应设计模式见 `../../design-patterns/`（如 constraint-penalty、shared-private-decomposition）；如无对应模式，标为"临时设计翻译"。

## 工程可行性
密码学原语 GPU 友好度参差：
- **AES-NI / SHA-NI**：走专用指令不走 GEMM（违反 D1/D2），单卡 SM 占用低
- **GGM 树构造**：级联 PRG 是顺序展开的二叉树，并行性差（违反 D6）；理论存在性证明而非实用
- **PRF 评估**：$F_k(x)$ 通常是 small GEMM 或查表（D2 友好）
- **Hadamard 内积（Goldreich-Levin）**：可张量化但实际用于密码学而非 ML
- **数学方法论层不落 GPU**：等价链、定义、归约证明是纯逻辑推理
GPU 八维评估详见 `../../references/gpu-friendly-math.md` 的"密码学 GPU 友好性警告"。

## 风险与失效条件
- **HILL 构造常数巨大**：OWF ⇒ PRG 的归约在多项式界内但常数不可实用；理论存在性证明非实用构造
- **GGM 树深度有限**：实际构造深度 $n$ 受限，长 PRF key 序列生成有开销
- **经验 PRF 假设依赖**：AES 当作 PRF 使用是**假设非定理**——AES 没有被证明是 PRF，只有经验强度。任何把"AES 是 PRF"当前提的证明本质是把假设换成 AES 假设
- **量子威胁**：Grover 算法使对称原语的安全位减半（AES-128 量子下仅 64-bit 安全）；Shor 算法破 RSA/DL 但对对称原语无影响
- **不可预测性假设迁移风险**：把"下一 bit 不可预测⇒整体伪随机"迁移到 ML 序列时，hybrid 链长度是 $n$，若 $n$ 不是多项式界则论证失效
- **分布漂移破坏归约**：归约要求敌手输入匹配特定分布，ML 场景分布漂移会破坏假设

## 深入参考
- 蒸馏稿：`../../references/books/foundations-of-cryptography.md`（§III OWF/PRG 等价、§V GGM 构造、§5.1 Goldreich-Levin hardcore bit）
- 蒸馏稿：`../../references/books/applied-cryptography.md`（§5 PRP/PRF、§14 假设族）
- 原书：Goldreich, *Foundations of Cryptography Vol. 1*, §2-§3、§7；Boneh & Shoup, *A Graduate Course in Applied Cryptography*, §5、§14

## 路由扩展
- 若需要归约证明 → `reduction-proof-template.md`（黑盒归约、紧度分析）
- 若需要攻击游戏形式化 → `attack-game-framework.md`（challenger vs adversary 框架）
- 若需要安全层级 → `cca-cpa-ae-hierarchy.md`（CPA/CCA/AE 威胁模型）
- 若需要概率论工具 → `../probability/concentration-inequality.md`（生日攻击、advantage 界）
- 若需要博弈视角 → `../../lenses/game.md`（多方策略互动）

## 可扩展方向
- PRP/SPRP（强伪随机置换）：伪随机置换的加强版
- 可抵抗相关源 PRG（correlation-robust PRG）：抗相关输入攻击
- 非均匀假设下的 PRF：电路敌手 vs 图灵机敌手
- 量子安全 PRF（quantum-secure PRF）：抗量子敌手
- 可提取单向函数（extractable OWF）：知识型论证协议基石
- 输入不可区分 PRF（input-indistinguishable）：功能加密场景
