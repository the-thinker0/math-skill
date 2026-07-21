# 层上同调 / Sheaf Cohomology

## 最小定义
层 $\mathcal{F}$ 是给拓扑空间每个开集 $U$ 赋一个代数结构（群/环/向量空间）$\mathcal{F}(U)$ 并满足局部到整体粘合规则的对象。具体地：
- **局部截面**：$\mathcal{F}(U)$ 是 $U$ 上的"局部解"集合
- **粘合公理（sheaf axiom）**：若 $\{U_i\}$ 是 $U$ 的开覆盖，且 $s_i\in\mathcal{F}(U_i)$ 在交叠 $U_i\cap U_j$ 上一致，则存在唯一 $s\in\mathcal{F}(U)$ 限制到每个 $U_i$ 为 $s_i$

层上同调 $H^i(X,\mathcal{F})$ 度量比“截面粘合公理”更细的局部到整体障碍——例如扩张类、主丛分类或高阶粘合问题。一阶上同调 $H^1$ 是最常用的障碍诊断量；Čech 上同调用开覆盖的交并复形计算，是工程上最常用的近似形式。

## 核心公式
- **层条件**（粘合公理）：$\mathcal{F}(U)\to\prod_i\mathcal{F}(U_i)\rightrightarrows\prod_{i,j}\mathcal{F}(U_i\cap U_j)$ 是等化子
- **Čech 复形**：$C^p(\mathcal{U},\mathcal{F})=\prod_{i_0<\cdots<i_p}\mathcal{F}(U_{i_0\cdots i_p})$，微分 $d^p:C^p\to C^{p+1}$ 由限制映射构成
- **上同调群**：$H^i(X,\mathcal{F})=\ker d^i/\mathsf{im}\,d^{i-1}$
- **$H^1=0$ 的含义**：对许多扩张、主丛或粘合障碍问题，$H^1$ 刻画局部数据能否升成全局对象。注意：真层本身已由粘合公理保证“交叠一致的截面 ⇒ 唯一全局截面”，因此不能把 $H^1=0$ 笼统写成任意“局部一致 ⇒ 全局一致”的充要条件；工程诊断应先写清所测障碍对应哪一类上同调问题。
- **谱序列（Leray）**：$E_2^{p,q}=H^p(\mathcal{U},\mathcal{H}^q)$ 收敛到 $H^{p+q}(X,\mathcal{F})$，计算高阶上同调
- **与 de Rham 上同调关系**：$H^i_{\mathsf{dR}}(X)\cong H^i(X,\Omega_X^{\bullet})$，de Rham 上同调是层上同调的特例
- **消失定理**（Cartan Theorem A/B、Serre）：仿射簇上凝聚层的 $H^i=0$（$i>0$）；投影空间上线丛 $\mathcal{O}(d)$ 的 $H^i$ 在某些 $d$ 范围消失

## 适用问题
- 诊断"局部数据一致但全局存在障碍"的结构：
  - **多视图特征对齐**：各视图局部对齐一致，但全局对齐失败——$H^1$ 度量对齐障碍
  - **多模态融合不一致性**：各模态局部信息一致，全局融合存在矛盾
  - **分布式训练的全局一致性**：各节点局部梯度一致，但全局聚合存在障碍
  - **表示空间中的拓扑障碍**：特征空间的"洞"或"环"影响下游任务
- 模型诊断：检测表示空间是否存在结构性障碍（非平凡 $H^1$）
- 知识图谱推理：实体关系的局部一致 vs 全局矛盾

## AI 设计翻译
- **层上同调作为"局部到整体障碍诊断器"**：把多视图 / 多模态 / 多节点局部一致性建模为层截面，$H^1$ 作为融合失败的形式化度量
- **H¹ 作为多视图融合一致性度量**：对多视图特征定义层，计算 Čech 上同调，$H^1=0$ 表示可融合，$H^1\ne 0$ 表示存在障碍
- **持续层上同调（persistent sheaf cohomology）**：结合持续同调与层上同调，作为表示空间的拓扑诊断
- 对应设计模式见 `../../design-patterns/compression/topology-preserving-compression.md`、`../../design-patterns/representation/shared-private-decomposition.md`；无对应模式时标为"临时设计翻译"。

## 工程可行性
层上同调 GPU 友好度挑战很大：
- **D1[x]**：精确 Čech 上同调需要构造开覆盖 + 计算高阶交并复形，非张量化
- **D2[x]**：边界矩阵约化高度串行，不可 GEMM 化
- **D3[x]**：精确 Čech 上同调 $O(N^3)$ 起步，$N$ 为开覆盖规模；高阶上同调 $O(N^{p+3})$
- **D4[~]**：可降维到 landmark 采样 $O(m^3)$，$m\ll N$；但仍非 GPU 友好
- **D5[v]**：整数运算（边界矩阵）无精度问题；浮点近似可 bf16
- **D6[x]**：约化算法高度串行；landmark 选择可并行
- **D7[~]**：稀疏边界矩阵可 CSR 存储；SpMM 有效但约化仍串行
- **D8[x]**：边界矩阵约化不可融合
**关键改造**：用 landmark 采样 $O(m^3)$ 替代全量 $O(N^3)$；用持续同调的近似版本；用 Euler curve 作代理；**精确同调不应塞进训练循环**，只作为诊断或正则项。

## 风险与失效条件
- **精确同调不可算**：$O(N^3)$ 串行算法在 $N>10^4$ 时不可行，必须依赖近似
- **Čech 近似依赖覆盖选择**：开覆盖的选取影响结果，不同覆盖给出不同 $H^i$；landmark 选择可能引入偏差
- **层结构错误参数化导致上同调失真**：若层 $\mathcal{F}$ 的截面定义错误，$H^i$ 失去诊断意义
- **$H^1=0$ 不保证高阶无障碍**：$H^1=0$ 只保证局部解可全局粘合，但 $H^2$ 及以上可能有障碍
- **Euler curve 信息退化**：$\chi=\sum(-1)^k\beta_k$ 把多阶压成单值，不同拓扑可共享同一 $\chi$
- **拓扑 ≠ 语义**：拓扑保持不等于语义保持；两个语义不同的空间可能拓扑同构
- **上同调基域选择敏感**：$\mathbb{Z}$ 系数 vs $\mathbb{R}$ 系数 vs $\mathbb{F}_p$ 系数给出不同的 torsion 信息

## 深入参考
- 蒸馏稿：`../../references/books/algebraic-geometry-rising-sea.md`
- 原书：Ravi Vakil, *The Rising Sea: Foundations of Algebraic Geometry*, Ch 18-22（层与上同调）
- 原书：Robin Hartshorne, *Algebraic Geometry*, Ch III（Cohomology）

## 路由扩展
- 若需要局部到整体 → `../../lenses/local-to-global.md`（局部性质拼接为全局）
- 若需要拓扑诊断 → `../topology/persistent-homology.md`（持续同调、Betti 数）
- 若需要范畴论语言 → `../../lenses/categorical.md`（层是范畴论的核心构造）
- 若需要欧拉示性数 → `../topology/euler-characteristic.md`（快速拓扑诊断代理）

## 可扩展方向
- 导出函子（derived functors）：$\mathsf{Ext}^i$、$\mathsf{Tor}_i$ 作为导出函子
- 谱序列（spectral sequences）：Leray、Grothendieck、Atiyah-Hirzebruch
- Hodge 分解（Hodge decomposition）：$\mathbb{C}$ 上的代数簇上同调分解
- D-模（D-modules）：层上的微分算子理论
- 皮卡群（Picard group）：线丛的同构类群，$H^1(X,\mathcal{O}^{\times})$
- 持续层上同调（persistent sheaf cohomology）：持续同调与层上同调的结合
