# 代数几何 激活索引 / Algebraic Geometry Activation Index

## 领域信号
当问题涉及以下信号时，激活本领域方向：
- 子空间参数化：格拉斯曼流形、Plücker 嵌入、Schubert 胞腔
- 局部到整体障碍：层、层的上同调、Čech 复形、H^i 消失判据
- 几何结构诊断：代数簇、概形、态射、纤维积、除子、线丛
- 热带几何：分段线性门控、tropical semiring、tropical 代数
- 谱与上同调：Hodge 分解、de Rham 上同调与层上同调关系
- 范畴论结构：函子、自然变换、Yoneda 引理、Tannakian 重建

## 核心锚点
- `sheaf-cohomology.md` — 层上同调（局部到整体障碍诊断，Čech 复形）
- `grassmannian-plucker.md` — 格拉斯曼流形与 Plücker 嵌入（子空间参数化）

## 扩展概念
当核心锚点不够时，以下概念可能需要临时激活：
- 概形与态射（schemes and morphisms）：仿射概形、射影概形、proper morphism
- 纤维丛与向量丛（fiber bundles and vector bundles）：截面、联络、曲率
- 除子与线丛（divisors and line bundles）：Cartier 除子、Weil 除子、Picard 群
- Hodge 理论（Hodge theory）：Hodge 分解、Hodge 谱序列、Calabi-Yau
- Motives（motives）：纯 motive、混合 motive、Voevodsky 的分类
- 热带几何（tropical geometry）：tropical semiring、tropical 多项式、tropical 曲线
- 代数群（algebraic groups）：线性代数群、Abelian 簇、Picard 簇
- Abelian 簇（abelian varieties）：Jacobi 簇、Albanese 簇
- 稳定映射与 Gromov-Witten（stable maps and Gromov-Witten）：模空间、枚举几何
- 特征类（characteristic classes）：Chern 类、Pontryagin 类、Stiefel-Whitney 类
- 层上的微分算子（D-modules）：D-模、微分代数方程的几何

## 参考书方向
- `../../references/books/algebraic-geometry-rising-sea.md`：Ravi Vakil, *The Rising Sea*，代数几何的现代综合
- `../../references/books/abstract-algebra.md`：Gallian, *Contemporary Abstract Algebra*，代数基础（群/环/域）
- 原书：Ravi Vakil, *The Rising Sea: Foundations of Algebraic Geometry*

## AI 翻译方向
- 层上同调 → 特征场上的局部到整体推理；H¹ 作为多视图融合一致性度量
- 格拉斯曼 → 子空间表示压缩（KV-Cache、LoRA、低秩注意力的子空间参数化）
- 热带几何 → 分段线性门控替代离散选择（Top-K → tropical max-plus）
- 上同调 → 结构障碍诊断（表示空间中的拓扑障碍）
- Schubert 胞腔 → 子空间分层与路由

## 临时激活规则
当问题需要的数学不在核心锚点中时：
1. 先检查扩展概念中是否有匹配
2. 若有，根据透镜（categorical/local-to-global/topological/spectral/geometric）生成临时知识卡
3. 若无，进入 Knowledge Gap Protocol
4. 临时卡标注 domain 为 "AI" 或 "shared"，便于后续升级
