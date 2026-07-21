# 现代密码学导论 / Introduction to Modern Cryptography

> Jonathan Katz & Yehuda Lindell, *Introduction to Modern Cryptography*, 2nd Edition, CRC Press, 2015。以**形式化定义 + 工程落地**为统一主题的现代密码学教科书——定义、假设、证明三原则的实战入门。

## 概要

本书把现代密码学（1980s 后）与古典密码学区分开来的三大原则：**(1) 形式化定义、(2) 精确假设、(3) 安全证明**。定义先于设计：先说清"破是什么、敌手能做什么"，再构造。证明是归约——破方案 ⇒ 违反假设。Kerckhoffs 原则：安全完全在密钥，算法公开。

**激活边界**：本书是**定义与工程并重**——讲形式化安全定义（EAV/CPA/CCA/AE）、构造范式（SPN/Feistel/Merkle-Damgård/KEM-DEM/Fiat-Shamir）、攻击模型、实现陷阱，比 Boneh-Shoup 更入门、比 Goldreich 更工程。这里给的是"安全定义怎么写、构造怎么选、实现哪里翻车"的**激活索引**。

## 可迁移到 AI/系统设计的核心结构

| 定义/构造（章节） | 迁移到 AI/ML/系统设计 |
|---|---|
| **三原则（定义/假设/证明，§1）** | 任何安全系统的科学方法论：先形式化威胁，再声明假设，再归约证明 |
| **Kerckhoffs 原则（§1.3）** | 系统除密钥外均可公开；迁移到其他安全系统时这是设计原则，不是自动成立的定理 |
| **概率论即安全语言（§2.1）** | Bayes 定理分析信息泄露；K 与 M 独立；随机化加密的必要性 |
| **渐近 vs 具体安全（§2.3）** | asymptotic 给理论，concrete 给部署；ML 安全分析需要具体 bit 级界 |
| **熵与最小熵（§2.4）** | 最小熵 = 一次猜测成功率；ML 中的"可猜性"量化 |
| **完美保密层级（§3.1-3.2）** | 信息论安全（|K|≥|M|）⇒ 计算安全（PPT + negl）的放松链 |
| **CPA/CCA/AE 定义族（§3.2-3.5）** | 加密安全的不同敌手接口与目标；AE 同时提供机密性与密文完整性，具体等价关系依定义而定 |
| **MAC 不可伪造性（§3.4）** | 强不可伪造（不允许新 tag on 已签消息）；常数时间验证；重放需上层处理 |
| **Hash 与 birthday（§3.6）** | 碰撞、第二原像和原像抗性是不同性质，一般不能写成无条件蕴含链；理想 n-bit 哈希的通用碰撞攻击约为 2^(n/2) 次查询 |
| **归约证明范式（§5）** | 假设矛盾→构造 B 用 A→B 成功概率非忽略；模拟须完美 |
| **Hybrid argument（§5.3）** | 相邻 hybrid 差异 ≤ ε，poly·ε 仍忽略；渐近安全的基石 |
| **Game-hopping（§5.4）** | 现代版 hybrid：G₀→G₁→...→G_k，相邻用假设，末态敌手优势=1/2 |
| **OWF / PRG / PRF 的存在性关系（§6）** | 标准定义下的构造与归约链；通用构造通常不作为实际密码实现 |
| **数论假设族（§7）** | DL/CDH/DDH 严格强弱；RSA ≤ factoring；群选择影响 DDH |
| **SPN/Feistel 构造（§8.1-8.2）** | confusion-diffusion 范式；Feistel 不要求 f 可逆；Luby-Rackoff 3/4 轮 |
| **Merkle-Damgård（§8.3）** | 抗碰撞压缩函数 ⇒ 抗碰撞哈希；但 length-extension 攻击，非 ROM |
| **KEM/DEM 混合加密（§8.4）** | KEM 封装会话密钥、DEM 保护消息；整体安全取决于目标安全级别及 KEM、DEM 的匹配定义，不能用固定倍数概括性能 |
| **Hash-and-Sign + Fiat-Shamir（§8.5-8.6）** | 签名先哈再签；FS 把交互识别转非交互签名（ROM） |
| **ROM 方法论与争议（§9）** | extractability + programmability；Canetti 反例；比无证明强 |

**激活家族**：

- **定义系（§3）**：EAV/CPA/CCA/AE、MAC 不可伪造、Hash 抗碰撞——回答"安全到底指什么"。
- **证明系（§5）**：归约模板、distinguisher-to-adversary、hybrid、game-hopping——回答"怎么证明"。
- **原语系（§6）**：OWF/PRG/PRF/PRP/hardcore bit——回答"基础工具与蕴含链"。
- **假设系（§7）**：factoring/RSA/DL/CDH/DDH/GDH——回答"公钥密码的依赖图"。
- **构造系（§8）**：SPN/Feistel/Merkle-Damgård/KEM-DEM/Hash-and-Sign/Fiat-Shamir——回答"工程构造怎么选"。

## 关键桥接事实（激活速记）

- **三原则：定义先、假设明、证明归约**（§1.1）：缺一定义则"是否安全"无从谈起。
- **Shannon：完美保密 ⇒ |K|≥|M|**（§3.1）：在相应有限消息/密钥空间和正确性条件下的下界；OTP 达到该界，但不能据此声称所有最优方案字面上都唯一等于 OTP。
- **EAV ⇔ 语义安全**（§3.2）：敌手对 c 能算的，无 c 也能算——计算不可区分的具象化。
- **确定性加密 ⇏ CPA 安全**（§3.2）：公钥/对称下都破，LR-oracle 一查即破。
- **IND-CPA 的多消息安全可由标准 hybrid 推出**：对公钥和私钥加密都需在相应定义及随机性/nonce 条件下陈述，不能把对称情形一概排除。
- **CCA 与不可延展性紧密相关**（§3.2）：精确蕴含或等价需固定不可延展定义与设置，不能只凭直觉替换安全游戏。
- **EtM 是通用而稳健的组合路径**：在合适的 IND-CPA 加密、强不可伪造 MAC、独立密钥与验证顺序下可得到认证加密；MtE/EaM 不能脱离具体方案和实现笼统判定。
- **生日攻击：n-bit hash 抗碰撞仅 n/2-bit**（§3.6）： Floyd 循环查找 O(2^{n/2}) 时间常量空间。
- **OWF、PRG、PRF 的存在性关系**（§6.5）：通用构造主要是理论存在性结果；AES 是分组密码，SHA 家族是哈希函数，不能把二者当作同一种原语的“实际版本”。
- **Goldreich-Levin：任何 OWF 可加 hardcore bit**（§6.2）：⟨x,r⟩ mod 2 是 hardcore；列表解码。
- **PRP Switching Lemma：Q 查询区分 PRP/随机函数 ≤ Q²/2^{n+1}**（§6.4）：AES 当 PRF。
- **DL/CDH/DDH 与 RSA/factoring 的关系要按归约方向陈述**（§7）：能解 DL 通常可解 CDH、能解 CDH 可判定 DDH；能分解 RSA 模数可反演 RSA，但反向一般未知。群选择会改变 DDH 难度。
- **CRT：Z_N ≅ Z_p × Z_q**（§7.4）：结构分解，加速 RSA 解密，Hastad 广播攻击根因。
- **Luby-Rackoff：3 轮 Feistel + PRF = PRP；4 轮 = 强 PRP**（§8.2）：Feistel 不要求 f 可逆。
- **Merkle-Damgård：抗碰撞压缩函数 ⇒ 抗碰撞哈希；但 length-extension 攻击**（§8.3）：非 ROM。
- **KEM/DEM 合成依安全目标而定**（§8.4）：CPA/CCA 等目标要求相应的 KEM 与 DEM 定义、密钥派生和上下文绑定；不要以固定“加速倍数”替代复杂度或基准。
- **ROM：extractability + programmability；存在反例但实用**（§9）：比无证明强，比标准模型弱。

## 适合激活的问题类型

- **威胁模型分层**：CPA/CCA/AE 哪层贴需求？敌手能力边界在哪？是否需要不可延展？
- **构造选择**：对称选 AES-CTR/GCM 还是 ChaCha20？公钥选 RSA-OAEP/ElGamal/ECC？哈希选 SHA-2/SHA-3/BLAKE3？
- **归约证明书写**：假设→构造 B 用 A→B 成功非忽略；模拟完美否？紧度多少？
- **参数计算**：n-bit 安全需多大 key/输出？生日/量子下打几折？归约紧度补偿？
- **实现陷阱诊断**：常数时间比较？IV/nonce 唯一？密钥独立？padding oracle？length-extension？
- **协议合成审查**：EtM/MtE/EaM？独立密钥？上下文绑定？降级防护（transcript hash）？
- **AI×密码交叉**：若借用攻击游戏、commitment 或归约，是否重新定义了敌手接口、成功事件与假设？CPA/CCA 不能直接改名为黑盒/白盒 ML 攻击。

## 可能的算法启发

> 本书工程导向，可迁移的算法启发比 Goldreich 更具体：

1. **AES-CTR + EtM 作为组合案例**：说明机密性与完整性职责分离、独立密钥和先验 MAC 验证的重要性；AES-NI 是 CPU 加速特性，不是 GPU/GEMM 证据。
2. **KEM/DEM 的职责分离**：可启发接口分层，但不直接证明 ML 系统的安全或性能；性能必须按具体原语、硬件与消息规模实测。
3. **Hash-and-Sign 迁移到内容寻址**：先哈希再处理，任意长输入压到固定长——ML 数据指纹、模型版本管理。*落点：D1——哈希廉价。*
4. **Fiat-Shamir 迁移到可验证推理**：交互证明转非交互，让 AI 推理产出可独立验证的证明。*落点：D3——验证端廉价。*
5. **ROM 只在密码学证明中按其形式接口使用**：把普通 ML 黑盒称为“随机预言机”不会获得 ROM 的独立随机性或可编程性。

## GPU 友好性警告

> 本书涉及的多数密码学原语不在 GPU 友好维度，与 AI 方向书稿相反：

**天然不友好但可专用硬件加速：**
- **AES（SPN）/SHA-3（sponge）**：通常使用位运算、SIMD 或专用指令/内核，不走 GEMM；AES-NI/SHA 扩展是 CPU ISA，GPU 需不同实现。D1/D2 对纯密码任务通常是 `N/A`，不是安全否决项。
- **RSA/ElGamal 大数模乘**：bigint，非张量化。*违反 D1/D2/D3。*
- **EC 标量乘**：通常由有限域算术和点运算实现，而非 GEMM；纯密码任务中 D2 通常为 `N/A`。

**方法论层面友好：**
- **归约/hybrid/game-hopping**：纯逻辑推理，不涉及 GPU。
- **KEM/DEM 分离**：DEM 常可批量并行，但通常仍是密码专用位运算内核，并非 GEMM。
- **Hash-and-Sign**：哈希可批量并行；SHA 扩展是 CPU ISA，GPU 需使用相应批量内核。

**反模式警告：**
- 把 AES/SHA 当 GEMM 算子优化——南辕北辙，走专用指令。
- 在训练循环里频繁调用密码学原语——非张量化、拖垮 SM。
- 用密码学哈希做 ML loss——不可导，无法反传。
- 用 Merkle-Damgård 哈希做 MAC 又当 ROM——length-extension 攻击。

## 该调用哪个思想透镜

配合 `../../lenses/` 下的思想透镜：

- **`axiomatization`（公理化）**：三原则中的"定义先于设计"；假设的相容性、独立性。
- **`algorithmic`（算法）**：归约即算法变换；复杂度可行性；SPN/Feistel 的迭代结构。
- **`probabilistic`（概率统计）**：忽略函数、优势、生日悖论、Bayes 分析信息泄露。
- **`duality`（对偶）**：信息论 vs 计算安全；敌手 ↔ 模拟器；定义中"易 ↔ 难"对偶。
- **`symmetry`（对称）**：Feistel 的左右对称；SPN 的混淆-扩散对称；群作用的对称性。
- **`categorical`（范畴化）**：原语蕴含偏序（OWF⇒PRG⇒PRF⇒...）；标准型即等价类代表。
- **`game`（博弈）**：攻击游戏、威胁模型、敌手能力层级（CPA/CCA/AE）。
- **`perturbation`（扰动）**：归约紧度分析、参数补偿、量子威胁下的安全降级。

## 反模式

- **无定义就谈安全**："直觉上安全"是空话；先写攻击游戏再谈构造。
- **混淆必要与充分**：密钥长度、碰撞抗性、第二原像抗性和原像抗性必须按各自定义与参数分析，不能用一条无条件蕴含链替代证明。
- **假设"密钥难恢复=安全"**：Enc_k(m)=m 密钥不可恢复但零安全。
- **加密与 MAC 共用密钥**：EtM 要独立密钥，否则跨原语交互致破。
- **确定性公钥加密**：公钥场景下确定性必破（加密-比对）。
- **IV/nonce 重用**：CTR/GCM 重用即灾难；GCM 重用甚至泄露 GHASH key。
- **非常数时间 MAC 比较**：`memcmp` 短路泄露前缀，时序攻击可伪造。
- **Merkle-Damgård 当 ROM**：length-extension 攻击；需 HMAC 或 sponge。
- **RSA 明文签名**：plain RSA 签名可伪造；需 PSS/FDH padding。
- **DSA/ECDSA nonce 重用**：重复 nonce 直接泄露私钥。
- **堆定理而不诊断瓶颈**：先问"威胁模型哪层、归约假设什么、实现陷阱在哪"，再选工具。

## 深挖入口

> **书目信息**：Jonathan Katz & Yehuda Lindell, *Introduction to Modern Cryptography*, 2nd Edition, CRC Press, 2015. ISBN 978-1-4665-7026-1.
>
> **启用方式**：将 `Introduction to Modern Cryptography.pdf` 放入 `math_book/`，Agent 自动 `pdftotext` + grep 定位原文页。

值得深读的真实章节：

> 以下章节号对应原书 Katz-Lindell 2nd ed. 实际目录（非精简版自编），用于 `math_book/` PDF 回查定位。

- **§1 现代密码学范式**：三原则、Kerckhoffs、安全证明的相对性。
- **§2 数学基础**：概率、渐近安全、具体 vs 渐近、熵。
- **§3 安全定义层级**：完美保密、EAV/CPA/CCA、多重加密、MAC、AE、Hash。
- **§4 不可区分性框架**：计算不可区分、实验模板、1/2+negl 的意义。
- **§5 归约证明方法论**：归约模板、distinguisher-to-adversary、hybrid、game-hopping。
- **§6 原语与归约**：OWF、hardcore、PRG、PRF/PRP、Switching Lemma、假设层级链。
- **§7 数论假设**：factoring/RSA、DL/CDH/DDH、CRT、群选择。
- **§8 构造范式**：SPN、Feistel、Luby-Rackoff、Merkle-Damgård、KEM/DEM、Hash-and-Sign、Fiat-Shamir。
- **§9 ROM**：定义、extractability/programmability、争议、Canetti 反例。
- **§10 攻击模型**：攻击层级、延展性、侧信道与实现攻击、敌手建模。
- **§11 关键定理与不可能性**：Shannon 界、确定性公钥不可 CPA、CPA⇔多重（公钥）、DDH⇒ElGamal CPA、EtM⇒CCA、Merkle-Damgård 抗碰撞提升。
- **§12 证明工具箱**：直接模拟、嵌入挑战、随机猜测放大、ROM oracle 检查；并/差/switching lemma。
- **§13 信息论 vs 计算**：哲学分野、三重放松、何时用何框架。
- **§14 领域设计原则**：对称/公钥/Hash/签名各自的工程铁律。
- **§15 数学工具参考**：数论、群论、概率、渐近速查。
- **§16 跨域迁移**：威胁建模方法论、可迁移概念（优势量化、合成不保安全、必要 vs 充分、假设最小化、可证明安全的局限）。
