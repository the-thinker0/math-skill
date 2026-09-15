# Topology-Preserving Compression（拓扑保持压缩）
> **证据标注**：[v] 有明确假设或记录验证支持；[~] 待验证的工程方案；[x] 在所述条件下不相容；[N/A] 不适用。伪代码用于定义算子，不是完整生产实现。

## 适用问题
当压缩表示时需要同构保持数据的本质拓扑结构（连通性、环、空腔）时使用：隐空间压缩（环形流形不能压成线段）、知识蒸馏（学生-教师同调等价）、3D 网格简化（genus 不变）、KV-Cache 语义保持（聚类结构不坍缩）。核心诉求：**压缩维度或数量，同时约束并实测持续同调的 persistence diagram 变化**。

## 数学思想来源
- 透镜：../../lenses/topological.md（拓扑不变量——连通性、洞数在连续变形下不变）、../../lenses/spectral.md（Gauss-Bonnet 连接曲率与欧拉示性数）、../../lenses/variational.md（压缩率 vs. 拓扑保真度的约束优化）
- 知识：../../knowledge-base/topology/persistent-homology.md（持续同调、Vietoris-Rips 滤流、Bottleneck 距离）、../../knowledge-base/topology/euler-characteristic.md（欧拉示性数快速拓扑诊断）、../../knowledge-base/matrix-analysis/matrix-perturbation.md（Davis-Kahan 子空间扰动界）

## 需要的数学知识

- **明确过滤定义**：有限度量空间的 Rips 单形以直径 $\le\epsilon$ 定义、固定同调阶数并取域系数时，$d_B(D_{VR}(X),D_{VR}(Y))\le2d_{GH}(X,Y)$。同域上的 tame 次水平函数满足 $d_B(D(f),D(g))\le\|f-g\|_\infty$。常数随过滤参数口径变化。[几何复形持久稳定性原论文](https://arxiv.org/abs/1207.3885)。
- **稳定性究竟保证什么**：$\eta$ 的瓶颈界使图中点在 $\eta$ 内匹配；寿命 $>2\eta$ 的有限区间不能匹配到对角线。这不等于单一尺度所有特征的通用同构。
- **Euler 曲线**：$\chi(\epsilon)=\sum_q(-1)^q c_q(\epsilon)$ 须计数所有包含维度的单形。顶点减边仅是图复形 Euler 数，不是含三角形及更高单形的完整 Rips 复形。
- **复杂度变量**：边界矩阵约化最坏 $O(M^3)$ 的 $M$ 是单形数，不是点数 $N$；维数不受限时 Rips 单形数可随 $N$ 指数增长。
- **可微性**：硬阈值 Euler 计数分段常数、几乎处处梯度为0。平滑指示器是代理量；持久景观/图像仍需 birth/death 可微计算及配对变化处理。

## AI 模块形式

```python
# 方案A：廉价的图复形平滑 Euler 代理；不包含填充三角形
D_x, D_z = cdist(X, X), cdist(encoder(X), encoder(X))
upper = strictly_upper_triangle_mask(N)
for eps in eps_grid:
    chi_x = N - sigmoid((eps - D_x) / temperature)[upper].sum()
    chi_z = N - sigmoid((eps - D_z) / temperature)[upper].sum()
    loss += (chi_x - chi_z)**2
# 在采样数据上单独验证硬 Betti/持久同调诊断。
```
对固定稀疏/立方复形，明确胞腔、过滤及平滑代理。可微持久同调应限制维数与单形数、选用输入梯度已验证的库，并在非并列值处用有限差分比较 birth/death 与配对变化。

推理时令 $\rho$ 表示**保留比例**，诊断失败则设 $\rho\leftarrow\min(1,1.2\rho)$ 并重新压缩；报告监控的维度、尺度及容差。仅 Euler 匹配不是保拓扑证书。

## 可实现结构

- 明确复形定义的采样图/立方 Euler 诊断。
- 报告覆盖及逼近误差的 landmark Rips/witness 近似。
- 教师/学生使用相同尺度与度量口径的持久损失。
- 廉价训练代理之外，单独评估留出拓扑及下游任务质量。

## GPU 可行性

- **D1/D2[~]**：成对距离和平滑图计数是张量操作；高维复形构造与约化不规则。
- **D3[~]**：稠密距离 $O(N^2d)$；图复形阈值扫描 $O(N^2|\epsilon|)$。高维 Euler/PH 需计实际单形数。FPS 为 $O(Nmd)$，在 $m$ 次 landmark 选择间有串行依赖。
- **D4[~]**：稠密 fp32 距离阵为 $4N^2$ 字节（$N=8192$ 时256 MiB），尚未计复形或梯度；限制单形数，不只点数。
- **D5[~]**：GEMM 平方距离公式可消减失精；使用 fp32，检查小/负计算距离与阈值敏感性。
- **D6/D8[~]**：阈值可批处理，但硬 PH 约化及 landmark 选择存在依赖；自定义融合须 profiling。
- **D7[~]**：稀疏复形只在邻域结构与近似条件受控时才有帮助。

## 论文表述方式
"以持续同调的 Bottleneck 稳定性定理为理论基础，通过 Euler characteristic curve 或 landmark 近似构造可计算的拓扑正则。Bottleneck 距离可在滤流函数扰动受控时界定 persistence diagram 的变化；Euler curve 只是不完整代理，不能单独保证每阶 Betti 数偏差受控，需报告 persistence/Betti 曲线的实测偏差。"

## 风险

- 相同 Euler 数或持久图不蕴含同胚或语义等价。
- 采样、landmark、尺度与代理温度可能抹除或制造表观特征。
- 长持久是鲁棒性启发式，不是有意义信号的证明；使用零模型对照。
- 即便距离阵可放入显存，精确 PH 也可能受复形大小支配。
