# Subspace Alignment（子空间对齐）
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

## 适用问题
当两个或多个表示空间需要对齐到共同的子空间时使用。典型场景：
(1) 多模态对齐——将文本和图像的表示对齐到共享语义子空间；
(2) 跨层对齐——将浅层特征对齐到深层特征的子空间，便于残差连接或蒸馏；
(3) 专家输出对齐——不同专家的输出维度/分布不同，需要对齐后融合；
(4) 领域适配——源域和目标域的特征分布不同，需要对齐子空间。
核心诉求：**找到两个空间之间的最优线性/非线性映射，使对应语义对齐**。

## 数学思想来源
- 透镜：../../lenses/geometric.md（Grassmann 流形、主角度）、../../lenses/variational.md（Procrustes 问题）
- 知识：../../knowledge-base/matrix-analysis/projection.md（SVD、正交 Procrustes）、
  ../../knowledge-base/differential-geometry/manifold.md（Grassmann 距离、测地线）

## 需要的数学知识

- 方形正交 Procrustes 假设配对 $A,B\in\mathbb R^{N\times d}$、$W\in O(d)$；$A^TB=U\Sigma V^T$ 时，$W^*=UV^T$ 最小化 $\|AW-B\|_F^2$。源/目标维数不同时需另行指定矩形约束或先投影到共同维数。
- CCA 需要**两个**约束 $W_X^T\Sigma_{XX}W_X=I$ 与 $W_Y^T\Sigma_{YY}W_Y=I$；样本须中心化并正则奇异协方差。
- 主角满足 $\cos\theta_i=\sigma_i(Q_X^TQ_Y)$，其中正交基需位于**同一环境空间**。最大化余弦之和是代理目标，不等于平方测地距离 $\sum_i\theta_i^2$。
- Grassmann/Oja 子空间更新使用 $G=(I-WW^T)xx^TW$ 并重新正交化；只减对角归一化项可能让多个分量坍塌到同一方向。

## AI 模块形式

```python
# 配对且同维的Procrustes
A0, B0 = A - A.mean(0), B - B.mean(0)  # 可选平移对齐，明确声明
assert A0.shape == B0.shape
U, s, Vh = svd(A0.T @ B0, full_matrices=False)
W = U @ Vh
loss_align = ((A0 @ W - B0)**2).sum() / N

# 两模态先投影到r维并中心化，再进行Deep CCA
F, G = center(encoder_A(A)), center(encoder_B(B))
Sxx, Syy = F.T @ F / N + ridge*eye(r), G.T @ G / N + ridge*eye(r)
Sxy = F.T @ G / N
T = inverse_sqrt(Sxx) @ Sxy @ inverse_sqrt(Syy)
loss_cca = -svdvals(T)[:k].sum()  # 求和，不对向量作矩阵trace
```
完整白化需协方差信息；逐坐标均值/方差归一化仅是对角归一化。CCA 相关性和 Grassmann 角度在适当白化空间有关，但一般不是可互换目标。

专家输出 $X_i\in\mathbb R^{N\times d_i}$ 的左奇异向量比较样本空间子空间，要求相同配对样本；右奇异向量比较特征空间子空间，要求共同特征维数。明确所需对象。

在线 `W += eta * outer(x, y - x @ W)` 是无约束最小二乘 SGD，不是 Oja 或保持正交的 Procrustes；需要正交约束时应投影/回缩。

## 可实现结构

- 共同维数的正交对齐，初始化后仍保留约束。
- 正则化完整白化，或明确命名的对角近似。
- Barlow Twins 类相关惩罚是替代目标，不保证 CCA 最优性。
- 随机谱近似以残差及主角验证。

## GPU 可行性

- **D1/D2[~]**：交叉协方差用 GEMM；CCA 另需两个协方差估计、逆平方根及 SVD。
- **D3/D4[~]**：共同宽度 $d$ 时，含 $O(Nd^2)$ 统计、$O(d^3)$ 分解及 $O(d^2)$ 存储；无约束在线 SGD 为 $O(d^2)$，回缩另有成本。
- **D5[~]**：使用 fp32/fp64、ridge 及残差检查。角度公式内加 epsilon 不能解决特征基不可辨识。
- **D6/D8[~]**：独立配对可批处理；协方差归约及分解阶段有依赖，实际融合须 profiling。
- **D7[N/A]**：稀疏特征一般不意味着稀疏协方差；选稀疏求解器前检查协方差。

## 论文表述方式
"基于正交 Procrustes 理论求得源-目标表示间的最优等距映射 W*=UV^T（USV^T=SVD(A^TB)），
将其扩展为深度 CCA 实现非线性子空间对齐，Grassmann 流形上的主角度分析表明
对齐前后的子空间距离可由主角度度量。收敛速率依赖样本独立性、谱间隙和协方差估计条件；Barlow Twins 目标只惩罚交叉相关，不能单独保证语义解耦，应报告主角度、CCA 相关系数和下游迁移指标。"

## 风险
- SVD 在反向传播时奇异值重合导致梯度未定义，需添加 ε 正则化
- CCA 的白化步骤需要矩阵逆，协方差矩阵近奇异时数值不稳定
- 非线性 CCA（深度 CCA）可能过拟合，特别是在小数据集上
- 在线子空间追踪的学习率 η 需要衰减调度，否则持续漂移
