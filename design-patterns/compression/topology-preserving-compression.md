# Topology-Preserving Compression（拓扑保持压缩）
> **严谨性声明**：本文件中涉及复杂度、显存、FlashAttention 融合、Tensor Core、KV-Cache 压缩的结论均标注为「✅ 已验证 / ⚠️ 可改造需验证 / ❌ 不可行」。未标注的视为理论可行，需工程验证。

## 适用问题
当压缩表示时需要同构保持数据的本质拓扑结构（连通性、环、空腔）时使用：隐空间压缩（环形流形不能压成线段）、知识蒸馏（学生-教师同调等价）、3D 网格简化（genus 不变）、KV-Cache 语义保持（聚类结构不坍缩）。核心诉求：**压缩维度或数量，保证持续同调的 persistence diagram 变化可控**。

## 数学思想来源
- 透镜：lenses/topological.md（拓扑不变量——连通性、洞数在连续变形下不变）、lenses/spectral.md（Gauss-Bonnet 连接曲率与欧拉示性数）、lenses/variational.md（压缩率 vs. 拓扑保真度的约束优化）
- 知识：knowledge-base/topology/persistent-homology.md（持续同调、Vietoris-Rips 滤流、Bottleneck 距离）、knowledge-base/topology/euler-characteristic.md（欧拉示性数快速拓扑诊断）、knowledge-base/matrix-analysis/matrix-perturbation.md（Davis-Kahan 子空间扰动界）

## 需要的数学知识
- **持续同调稳定性定理**：$d_B(D(X), D(Y)) \leq d_{GH}(X, Y)$，Hausdorff 距离界定 persistence diagram 变化
- **欧拉示性数曲线**：$\chi(\epsilon) = \sum_k (-1)^k \beta_k(\epsilon)$，比单一 $\chi$ 信息更丰富，计算 $O(N^2)$
- **映射柱同构**：若 $f: X \to Y$ 是 $\epsilon$-等距，则 $f_*$ 在持续区间 $> 2\epsilon$ 的特征上同构
- **Landmark 近似**：用 witness complex 在 $m$ 个 landmark 上构建，$O(m^3)$ 替代 $O(N^3)$

## AI 模块形式
```
模块：TopologyPreservingCompressor
输入：X ∈ R^{N×d}    参数：拓扑权重 λ_topo，目标维度 r < d

方法1 - Euler curve 匹配（最实用，可微）：
  Z = encoder(X)                              // R^{N×r}
  D_orig = cdist(X, X); D_comp = cdist(Z, Z)  // N×N 距离矩阵
  chi_orig = euler_curve(D_orig, eps_grid)      // |eps_grid| 维向量
  chi_comp = euler_curve(D_comp, eps_grid)
  L_topo = ‖chi_orig - chi_comp‖_2²            // 拓扑匹配损失（可微）
  L_total = L_recon + λ_topo · L_topo

方法2 - 持续同调正则（精确但昂贵）：
  D_orig = persistent_homology(X, max_dim=1)    // H_0 + H_1 barcode
  D_comp = persistent_homology(Z, max_dim=1)
  // 可微代理：persistence landscape/image
  L_topo = ‖landscape(D_orig) - landscape(D_comp)‖_2²

方法3 - 拓扑监控 + 自适应压缩率（推理时）：
  Z = compress(X, ratio=ρ)
  if count_components(Z, τ) < 0.8 * count_components(X, τ):
    ρ *= 1.2; Z = compress(X, ratio=ρ)          // 拓扑坍缩 → 降低压缩比
```

## 可实现结构
- **Euler curve 匹配层**：$\chi(\epsilon)$ 只需距离矩阵 + 阈值计数，$\epsilon$ 扫描可并行
- **Landmark 采样器**：FPS（最远点采样）$O(Nm)$，保证覆盖
- **拓扑感知蒸馏**：教师-学生表示的 persistence image 差异作为附加蒸馏目标
- **拓扑诊断仪表板**：训练中实时绘制 $\beta_0(\epsilon), \beta_1(\epsilon)$ 曲线

## GPU 可行性
- 张量化/GEMM：距离矩阵 `cdist` 核心为 GEMM；$\chi(\epsilon)$ 为阈值计数 + 累积和
- 复杂度：完整持续同调 $O(N^3)$ 不可行；Euler curve $O(N^2 |\epsilon|)$ 可行；Landmark $O(m^3)$
- 显存：$N \times N$ 距离矩阵在 $N > 8K$ 时需分块或 Landmark 降维
- 低精度：距离计算在 bf16 下稳定（正数加法）；$\chi$ 为整数运算无精度问题
- 并行：$\epsilon$ 扫描的每个阈值独立并行；Landmark 选择可批并行
- 算子融合：cdist + threshold + count 可融合避免物化大距离矩阵

## 论文表述方式
"以持续同调的 Bottleneck 稳定性定理为理论基础，通过 Euler characteristic curve 匹配实现 $O(N^2)$ 复杂度的拓扑保真正则化，保证压缩后 Betti 数在持续区间上的偏差受 Hausdorff 距离控制。"

## 风险
- **持续同调计算瓶颈**：精确边界矩阵约化高度串行（$O(N^3)$），必须依赖 Euler curve 或 Landmark 近似
- **Euler curve 信息退化**：$\chi = \sum(-1)^k \beta_k$ 将多阶 Betti 数压成单值，不同拓扑可共享同一 $\chi$
- **拓扑 ≠ 语义**：拓扑保持不等于语义保持——两个语义不同的空间可能拓扑同构
- **尺度参数敏感**：滤流的 $\epsilon$ 范围需手动设定，不同数据集差异大
- **Landmark 采样偏差**：FPS 在高维空间中可能不均匀，导致拓扑估计偏差
