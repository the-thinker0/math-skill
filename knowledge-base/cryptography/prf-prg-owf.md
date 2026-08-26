# 单向函数、伪随机生成器与伪随机函数 / OWF, PRG, and PRF

## 最小定义

- **单向函数（OWF）**：易于计算，但对随机输入的像，任何概率多项式时间（PPT）算法都只能以可忽略概率找到任一原像。
- **伪随机生成器（PRG）**：确定性多项式时间算法 $G:\{0,1\}^n\to\{0,1\}^{\ell(n)}$，其中 $\ell(n)>n$，且 $G(U_n)$ 与 $U_{\ell(n)}$ 对所有 PPT 区分器计算不可区分。
- **伪随机函数族（PRF）**：高效密钥函数族 $F_k:\mathcal X\to\mathcal Y$，其可查询接口与从所有 $\mathcal X\to\mathcal Y$ 函数中均匀抽取的真随机函数，对所有 PPT oracle 区分器计算不可区分。

这些都是关于**安全参数增长下的族**的渐近定义，不是对某个固定参数实现的无条件结论。

## 核心公式

- OWF：对所有 PPT $A$，
  $$\Pr_{x\leftarrow U_n}\left[f(A(1^n,f(x)))=f(x)\right]\le \operatorname{negl}(n).$$
- PRG 优势：
  $$\operatorname{Adv}^{\rm prg}_{G}(D)=\left|\Pr[D(G(U_n))=1]-\Pr[D(U_{\ell(n)})=1]\right|.$$
- PRF 优势：
  $$\operatorname{Adv}^{\rm prf}_{F}(A)=\left|\Pr_{k}[A^{F_k}=1]-\Pr_{R}[A^{R}=1]\right|.$$
- 存在性关系：OWF 存在当且仅当 PRG 存在；PRG 可经 GGM 构造 PRF。由 PRF 经 Feistel 可构造 PRP：经典 Luby--Rackoff 结论是 3 轮给出选择明文意义下的 PRP，4 轮给出允许正反向查询的强 PRP（具体界依赖查询数与分组长度）。
- PRP/随机函数切换界的典型量级为生日界 $O(q^2/2^n)$；精确常数取决于采用的游戏和是否允许逆向查询，不能脱离版本固定写成唯一公式。

## 适用问题

- 判断一个 keyed construction 是否满足 PRF 定义，并写出真实/随机 oracle 游戏。
- 用 hybrid argument 分析 GGM 类构造或从 PRF 构造加密/MAC。
- 区分“标准模型中的存在性定理”“基于某原语的归约”和“把 AES/HMAC 当 PRF 的具体安全假设”。
- 估计查询数带来的生日界损失，检查 key/domain separation 与多用户安全。

## 密码学构造与跨域边界

- 实用系统通常使用经分析的 PRF 候选或标准化构造（例如 HMAC、CMAC/KMAC 或基于分组密码的模式），而不是直接实现 HILL/GGM 的通用存在性构造。
- 在 AI×密码交叉问题中，PRF 可作为带密钥、可复现的伪随机源，但结论只针对明确的 oracle/泄露模型。模型参数、梯度、日志或分布式训练若泄露密钥相关信息，原安全游戏可能不再适用。
- OWF 不会自动让“哈希后的特征”保密：输入分布、辅助信息、碰撞和成员推断都需单独建模。
- Yao 的 next-bit characterization 针对二进制分布族和高效预测器。它不能不经编码、条件分布与安全参数定义，直接推出自然语言模型“下一 token 难预测 ⇒ 整段输出伪随机”。

## 实现注意事项

- PRF 实现通常是位运算、置换、哈希/压缩函数或专用密码指令，不是“小 GEMM”。AES-NI/SHA-NI 是 CPU 指令集特性，不能作为 GPU 可行性的证据。
- nonce、counter、domain tag 和派生子密钥必须按协议唯一/分离；“同一 PRF 到处复用”会破坏证明所需的独立性。
- 若用户明确问 GPU 吞吐，再按具体实现分析并行批量、访存与侧信道；这属于性能检查，不替代安全证明。
- 量子查询模型必须明确。Grover 给出理想黑盒查询复杂度的平方级加速，但具体安全强度还取决于电路深度、并行资源和攻击模型，不能只写“密钥位数减半”作为完整评估。

## 风险与失效条件

- **具体原语当定理**：AES/HMAC 的 PRF 性质是广泛采用的安全假设/分析结论，不是从其规范无条件证明出的定理。
- **忽略查询与多用户损失**：$q$、用户数和消息长度可能通过生日界或 hybrid 次数放大优势。
- **混淆不可预测与不可区分**：两者的等价需要精确定义与归约；经验预测准确率不能直接替代密码学优势。
- **把通用构造当工程方案**：HILL/GGM 说明存在性和可归约性，不代表常数、并行性或吞吐可接受。
- **跨域假设失配**：ML 部署中的侧信息、分布漂移和自适应查询可能超出原安全游戏。

## 深入参考

- `../../references/books/foundations-of-cryptography.md`：OWF/PRG 与 GGM 的理论链。
- `../../references/books/applied-cryptography.md`：PRF/PRP 游戏和切换论证。
- `../../references/books/introduction-to-modern-cryptography.md`：形式化定义与 Feistel 构造。

## 路由扩展

- 归约证明：`reduction-proof-template.md`
- 攻击游戏：`attack-game-framework.md`
- CPA/CCA/AE：`cca-cpa-ae-hierarchy.md`
- 概率界：`../probability/concentration-inequality.md`
