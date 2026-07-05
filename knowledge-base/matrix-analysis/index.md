# 矩阵分析 激活索引 / Matrix Analysis Activation Index

## 领域信号
当问题涉及以下信号时，激活本领域方向：
- 降维/压缩：需要将高维数据或参数压缩到低维子空间
- 低秩近似：需要用低秩矩阵近似大规模矩阵
- 条件数/病态：矩阵运算的数值稳定性出现问题
- 正交分解：需要将空间分解为正交子空间
- 谱结构：需要分析矩阵的特征值/奇异值分布
- 子空间分离：需要度量或控制子空间之间的关系

## 核心锚点
- `projection.md` — 投影算子与子空间投影
- `spectral-decomposition.md` — 谱分解与特征分解
- `low-rank-approximation.md` — 低秩近似与截断 SVD
- `positive-semidefinite.md` — 半正定矩阵与 PSD 锥
- `matrix-perturbation.md` — 矩阵扰动理论与误差界

## 扩展概念
当核心锚点不够时，以下概念可能需要临时激活：
- SVD 变体（truncated SVD, randomized SVD）：大规模矩阵的快速分解方法
- PCA / kernel PCA：主成分分析及其核化版本
- condition number：条件数的计算与控制
- pseudoinverse：Moore-Penrose 广义逆及其应用
- matrix equation（Sylvester / Lyapunov）：矩阵方程的解法与稳定性
- Schur decomposition：Schur 分解与不变子空间
- Jordan form：Jordan 标准形与广义特征空间
- matrix function：矩阵函数的定义与计算
- Kronecker product / vectorization：张量积与向量化运算
- randomized linear algebra：随机化线性代数方法
- CUR decomposition：基于列/行采样的矩阵近似
- Nystrom approximation：核矩阵的低秩近似
- matrix concentration inequalities：随机矩阵的集中不等式

## 参考书方向
- `../../references/books/matrix-analysis.md`：矩阵分析全面覆盖，特别是谱分解、扰动理论和矩阵函数章节

## 临时激活规则
当问题需要的数学不在核心锚点中时：
1. 先检查扩展概念中是否有匹配
2. 若有，根据透镜生成临时知识卡
3. 若无，进入 Knowledge Gap Protocol
