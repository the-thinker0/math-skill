# 安全层级：CPA/CCA/AE / Security Hierarchy: CPA/CCA/AE

## 最小定义
威胁模型的能力递增层级，按敌手能查询的 oracle 强度递增：
- **CPA（选择明文攻击，Chosen-Plaintext Attack）**：敌手可获取任意明文的加密。对私钥加密，这是最低标准；对公钥加密，敌手本就能任意加密（公钥公开）。
- **CCA1（非自适应选择密文攻击）**：敌手在挑战前可解密任意密文（除挑战密文）。又称"午餐攻击"。
- **CCA2（自适应选择密文攻击）**：敌手在挑战前后均可解密任意密文（除挑战密文本身）。这是对加密最强的标准威胁模型。
- **AE（认证加密，Authenticated Encryption）**：AE = IND-CCA2 + INT-CTXT（密文完整性）。既保密又完整。

## 核心公式
- **IND-CPA 游戏**：敌手提交 $m_0, m_1$（等长），挑战者返回 $\mathsf{Enc}_k(m_b)$；安全当且仅当 $\mathsf{Adv}^{\mathsf{ind\text{-}cpa}}_{\mathcal{A}}=|\Pr[b'=b]-1/2|\le\mathsf{negl}(n)$
- **IND-CCA1**：训练阶段敌手可查询解密 oracle，但挑战后不可
- **IND-CCA2**：敌手可在挑战前后查询解密 oracle（除挑战密文本身）；最强加密安全
- **INT-CTXT（密文完整性）**：敌手不能产生一个新的合法密文（即使已知其他合法密文）
- **EtM vs MtE vs EaM 合成范式**：
  - **EtM（Encrypt-then-MAC）**：$\mathsf{CT}=\mathsf{Enc}_k(m)\|\mathsf{MAC}_{k'}(\mathsf{Enc}_k(m))$，**安全**
  - **MtE（MAC-then-Encrypt）**：$\mathsf{CT}=\mathsf{Enc}_k(m\|\mathsf{MAC}_{k'}(m))$，**存在 padding oracle 攻击，不安全**
  - **EaM（Encrypt-and-MAC）**：$\mathsf{CT}=\mathsf{Enc}_k(m)\|\mathsf{MAC}_{k'}(m)$，**泄露信息，不安全**
- **Shannon 完美保密**：信息论安全的代价 $|K|\ge|M|$（密钥不得短于消息，OTP 的根源）；计算安全突破此限制
- **CPA 安全 ⇏ 多重加密安全（对称）；公钥 CPA ⇒ 多重安全**（公钥敌手本可任意加密）

## 适用问题
- AI 场景中威胁模型层级化建模：
  - **白盒 vs 黑盒 vs 自适应对抗**：对应 CPA / CCA1 / CCA2 层级
  - **对抗样本强度**：扰动预算 + 自适应查询能力的层级化
  - **模型窃取**：敌手查询预算与训练数据访问权限的层级
  - **可验证推理的 AE 类比**：既保证推理正确（完整性），又保证不可伪造（保密性）
  - **对抗训练的 CCA 类比**：敌手在训练时（挑战前）和部署时（挑战后）都可查询
  - **合成 pipeline 的安全审查**：EtM/MtE/EaM 对应 ML pipeline 中"加密 + 防篡改"的组合方式

## AI 设计翻译
- **把 CPA/CCA 层级套到 ML 对抗强度**：
  - CPA 类比：黑盒查询敌手（仅有查询权限，无梯度访问）
  - CCA1 类比：白盒敌手在训练时可访问梯度，部署时不可
  - CCA2 类比：自适应对抗训练敌手（训练 + 部署均可访问梯度）
  - AE 类比：既保证输出正确（防篡改），又保证不可伪造（防泄漏）
- **EtM/MtE/EaM 合成范式迁移**：ML pipeline 中"模型推理 + 完整性校验"的组合方式，对应 EtM 安全 / MtE 不安全。警告：合成陷阱可能迁移。
- 对应设计模式见 `../../design-patterns/`（如 constraint-penalty）；无对应模式时标为"临时设计翻译"。

## 工程可行性
威胁层级定义是纯方法论，不落 GPU：
- 安全游戏是逻辑构造，不涉及张量运算
- 合成范式审查是设计推理，不产生 GPU kernel
- IND/CCA 证明是数学推理，不涉及低精度数值
GPU 八维评估不适用；密码学产出通过归约紧度 + 假设依赖 + 实现陷阱检查（详见 `../../references/gpu-friendly-math.md` 的"密码学 GPU 友好性警告"）。

## 风险与失效条件
- **层级选择过强限制方案实用性**：要求 CCA2 安全会排除很多高效构造；ML 场景中要求"自适应对抗鲁棒"会使训练成本爆炸
- **ML 场景的"敌手能力"难以严格形式化**：白盒 / 黑盒的界限模糊（如蒸馏模型可泄露教师模型信息）
- **EtM/MtE 合成陷阱可能迁移到 ML pipeline**：例如"先校验后推理"对应 EtM（安全），"先推理后校验"对应 MtE（可能不安全）；padding oracle 类的攻击可能迁移
- **Shannon 完美保密代价迁移**：若需要信息论安全的 ML 鲁棒性，"密钥量 ≥ 消息量"对应"训练数据量 ≥ 模型参数量"——实践中不可达
- **多重加密安全假设迁移**：CPA 安全的对称加密在多次加密下不安全，对应 ML 多次查询下的鲁棒性可能退化
- **量子威胁**：Shor 破公钥加密；Grover 使对称加密安全位减半；AE 中对称 + 公钥混合时需考虑量子层级

## 深入参考
- 蒸馏稿：`../../references/books/applied-cryptography.md`（§4 CPA/CCA/AE、§7.9 EtM/MtE/EaM、§9.2 合成安全）
- 蒸馏稿：`../../references/books/introduction-to-modern-cryptography.md`（形式化安全定义、IND/CCA、MAC）
- 原书：Boneh & Shoup, *A Graduate Course in Applied Cryptography*, §4, §7.9, §9.2；Katz & Lindell, *Introduction to Modern Cryptography*, 2nd ed.

## 路由扩展
- 若需要攻击游戏形式化 → `attack-game-framework.md`（challenger vs adversary）
- 若需要归约 → `reduction-proof-template.md`（紧度分析）
- 若需要假设形式化 → `prf-prg-owf.md`（OWF/PRG/PRF）
- 若需要博弈视角 → `../../lenses/game.md`（机制设计、均衡）
- 若需要公理化视角 → `../../lenses/axiomatization.md`（安全定义即公理）

## 可扩展方向
- 前向安全（Forward Security, PFS）：会话密钥泄露不破坏历史
- 后向安全（Backward Security）：未来密钥不破坏当前
- 密钥泄露安全（Key Compromise Resilience）：部分密钥泄露不破坏整体
- 无状态 vs 有状态方案（stateless / stateful）：状态管理的安全影响
- 非对称加密层级（asymmetric hierarchy）：KEM-DEM 范式
- 后量子 AE（post-quantum AE）：抗量子敌手的认证加密
