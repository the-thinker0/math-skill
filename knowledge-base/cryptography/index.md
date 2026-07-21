# 密码学 激活索引 / Cryptography Activation Index

## 领域信号
当问题涉及以下信号时，激活本领域方向：
- 安全定义：CPA/CCA1/CCA2/AE/EUF-CMA 等威胁模型的形式化
- 原语：OWF/PRG/PRF/PRP/CRHF/TDF 及其等价与构造链
- 假设：DL/CDH/DDH/RSA/LWE/量子威胁（Shor/Grover）
- 归约证明：黑盒归约、hybrid argument、模拟范式、紧度分析
- 协议：加密/MAC/签名/零知识/AKE/多方安全计算
- 攻击游戏：challenger vs adversary 的形式化交互框架
- 后量子：格密码、编码密码、哈希签名
- 高级构造：同态加密、属性基加密、函数加密、可验证计算

## 核心锚点
- `prf-prg-owf.md` — 伪随机函数族、伪随机生成器与单向函数（最小假设→基本原语等价链）
- `reduction-proof-template.md` — 归约证明模板（"破方案⇒解假设"的构造性推理范式）
- `attack-game-framework.md` — 攻击游戏框架（challenger vs adversary 的安全定义范式）
- `cca-cpa-ae-hierarchy.md` — 安全层级 CPA/CCA/AE（威胁模型能力递增层级）

## 扩展概念
当核心锚点不够时，以下概念可能需要临时激活：
- 零知识证明：交互式/非交互式（Fiat-Shamir）、Sigma 协议、zk-SNARK/zk-STARK
- 承诺方案：隐藏性 + 绑定性、哈希承诺、Pedersen 承诺
- 秘密共享：Shamir 门限、Baum-Waidner 可验证秘密共享
- 同态加密：部分同态（FHE/TFHE/CKKS）、自举（bootstrapping）
- 多方安全计算（MPC）：Yao 混淆电路、GMW、BGW、SPDZ
- 可验证计算（VC）：PCP、zk-SNARK、GKR、interactive proofs
- 差分隐私与密码学交集：对相邻数据集的不可区分性、与计算不可区分的关系
- 后量子密码学（PQC）：格基密码（LWE/RLWE）、编码基（McEliece）、哈希基（SPHINCS+）、多变量密码
- 基于身份的密码学（IBE）：主密钥派生、Boneh-Franklin
- 属性基加密（ABE）：密钥策略 vs 密文策略、访问结构
- 函数加密（FE）：带函数密钥的加密
- 不可能性与分离结果：黑盒分离、Oracle 分离、meta-theorem

## 参考书方向
- `../../references/books/applied-cryptography.md`：Boneh & Shoup，攻击游戏 + 归约证明 + 构造与协议
- `../../references/books/foundations-of-cryptography.md`：Goldreich，定义方法论 + 归约可构造性 + 元定理
- `../../references/books/introduction-to-modern-cryptography.md`：Katz & Lindell，形式化安全定义 + 构造范式 + 实现陷阱

## AI 翻译方向
密码学本身不直接产 GPU kernel，但其**设计思想**可迁移到 AI 安全/可验证计算：
- PRF → 可验证伪随机源（路由 seed、数据划分、可复现实验）
- OWF → 难逆映射的设计模式（哈希注意力、可验证水印）
- 归约范式 → ML 鲁棒性证书（破鲁棒性 ⇒ 解困难问题）
- 攻击游戏 → ML 对抗性建模（敌手能力预算 + 胜利条件 + 不可破证明）
- 承诺方案 → 模型水印与可追踪分发
- 零知识 → 可验证推理（推理产出 SNARK 式证明，验证者低成本核对）
- 差分隐私 → 隐私训练（梯度噪声注入的形式化保证）
- 模拟范式 → 隐私证书（模型输出可被独立生成 ⇒ 未泄露训练数据）

## 临时激活规则
当问题需要的数学不在核心锚点中时：
1. 先检查扩展概念中是否有匹配
2. 若有，根据透镜（game/axiomatization/algorithmic/probabilistic/duality/causal/categorical）生成临时知识卡
3. 若无，进入 Knowledge Gap Protocol
4. 临时卡标注 domain 为 "crypto" 或 "shared"，便于后续升级
