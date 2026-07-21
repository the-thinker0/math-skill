# 格拉斯曼流形与 Plücker 嵌入 / Grassmannian and Plücker Embedding

## 最小定义
格拉斯曼流形 $\mathsf{Gr}(k,n)$ 是 $n$ 维向量空间中所有 $k$ 维线性子空间的参数空间，是一个 $k(n-k)$ 维光滑射影簇。它把"子空间"作为几何点参数化，使子空间运算（投影、求交、距离）可表示为几何运算。

Plücker 嵌入 $\mathsf{Gr}(k,n)\hookrightarrow\mathbb{P}(\Lambda^k\mathbb{C}^n)$ 把每个子空间 $V=\mathsf{span}(v_1,\ldots,v_k)$ 映射为其基底的外积 $[v_1\wedge\cdots\wedge v_k]$（最高权向量），将子空间表示为射影齐次坐标。这是把几何对象（子空间）转化为代数对象（外代数元素）的标准方式。

## 核心公式
- **格拉斯曼流形定义**：$\mathsf{Gr}(k,n)=\{k\text{-dim subspaces of }\mathbb{C}^n\}$
- **维数**：$\dim\mathsf{Gr}(k,n)=k(n-k)$
- **Plücker 嵌入**：$V=\mathsf{span}(v_1,\ldots,v_k)\mapsto[v_1\wedge\cdots\wedge v_k]\in\mathbb{P}(\Lambda^k\mathbb{C}^n)$
- **Plücker 坐标**：$p_{i_1\cdots i_k}=\det(v_{i_j}^{(i)})$（基底向量在 $i_1,\ldots,i_k$ 行上的子行列式），共 $\binom{n}{k}$ 个
- **Plücker 关系**（Plücker 坐标满足的二次关系）：$\sum_{j=1}^{k+1}(-1)^j p_{i_1\cdots\hat{i_j}\cdots i_{k+1}}\cdot p_{j_1\cdots j_{k-1}i_j}=0$
- **Schubert 胞腔分解**：$\mathsf{Gr}(k,n)=\bigsqcup_\lambda\Omega_\lambda$（按子空间与固定 flag 的相对位置分层）
- **Plücker 坐标在低秩时反扩张**：当 $k$ 接近 $n/2$ 时 $\binom{n}{k}$ 急剧膨胀；存基底 $O(Lk)$ 远小于存 Plücker $O(\binom{L}{k})$——这是"低秩时存基底而非 Plücker 坐标"的根本原因
- **度量**：$\mathsf{Gr}(k,n)$ 上有自然 Riemannian 度量（投影度量），子空间距离 $d(V,W)=\|\sin\Theta\|_F$（$\Theta$ 为主角度对角矩阵）

## 适用问题
- **子空间表示压缩**：KV-Cache、LoRA、低秩注意力的子空间参数化——把"存 $L\times d$ 矩阵"转为"存 $k$ 维子空间点"
- **子空间聚类**：多个低秩子空间的并集表示
- **表示学习的几何结构分析**：特征空间作为子空间族，度量子空间间距离
- **特征空间中的距离/度量定义**：用投影度量而非欧氏距离
- **多模态对齐**：各模态表示子空间的对齐
- **主角度与主向量**：子空间间的"夹角"作为相似度度量

## AI 设计翻译
- **子空间表示用格拉斯曼点参数化**：把 KV-Cache、LoRA 的低秩子空间作为 $\mathsf{Gr}(k,d)$ 上的点，存基底向量而非完整矩阵
- **存基底而非 Plücker 坐标避免低秩反扩张**：低秩时 $\binom{d}{k}\gg dk$，存 Plücker 坐标反扩张，存基底（外积向量的因子）更经济
- **主角度作为子空间相似度**：$d(V,W)=\|\sin\Theta\|_F$ 作为子空间距离，用于多视图对齐
- 对应设计模式见 `../../design-patterns/compression/low-rank-kv-cache.md`、`../../design-patterns/representation/shared-private-decomposition.md`、`../../design-patterns/representation/subspace-alignment.md`；无对应模式时标为"临时设计翻译"。

## 工程可行性
格拉斯曼流形 GPU 友好度中等：
- **D1[v]**：子空间由基底矩阵 $V\in\mathbb{R}^{n\times k}$ 表示，完美张量化
- **D2[v]**：Plücker 坐标计算是外积（小矩阵行列式），可用 batched GEMM
- **D3[~]**：Plücker 坐标数 $\binom{n}{k}$ 在 $k\approx n/2$ 时爆炸；存基底 $O(nk)$ 远小于存 Plücker $O(\binom{n}{k})$
- **D4[v]**：存基底 $O(Lk+kd)$ 压缩比高；存 Plücker 坐标反扩张
- **D5[v]**：正交基底计算（QR）在 bf16 下稳定；Plücker 行列式建议 fp32
- **D6[v]**：多个子空间点完全并行
- **D7[~]**：子空间距离计算涉及 SVD（主角度），可用随机化近似
- **D8[v]**：QR + 外积 + 行列式可融合
**关键点**：存基底而非 Plücker 坐标；用主角度作为相似度度量；低秩时压缩比取决于 $k/d$ 比

## 风险与失效条件
- **Plücker 坐标在 $k$ 较大时维度爆炸**：$\binom{n}{k}$ 在 $k\approx n/2$ 时达到峰值 $\sim 2^n/\sqrt{n}$，不可存
- **存 Plücker 而非基底在低秩时反扩张**：这是 `../../design-patterns/compression/low-rank-kv-cache.md` 中明确警告的反模式——低秩时 Plücker 坐标数远大于基底维度
- **子空间距离定义依赖度量选择**：投影度量、Chordal 度量、Fubini-Study 度量给出不同结果，需明确选择
- **子空间非唯一表示**：同一子空间可由不同基底表示（基底选择自由），需用等价类或规范形（如 QR 后的正交基）
- **主角度计算的数值稳定性**：当子空间接近重合时主角度接近 0，$\sin\Theta$ 数值不稳定
- **Schubert 胞腔分层的选择依赖**：Schubert 分解依赖固定 flag 的选择，不同 flag 给出不同分层

## 深入参考
- 蒸馏稿：`../../references/books/algebraic-geometry-rising-sea.md`
- 蒸馏稿：`../../references/books/matrix-analysis.md`（§2.6 SVD、主角度）
- 原书：Ravi Vakil, *The Rising Sea*, Ch on Grassmannians
- 原书：Horn & Johnson, *Matrix Analysis* 2nd Ed., §2.5 (angles between subspaces)

## 路由扩展
- 若需要低秩近似 → `../matrix-analysis/low-rank-approximation.md`（Eckart-Young、随机化 SVD）
- 若需要子空间投影 → `../matrix-analysis/projection.md`（正交投影）
- 若需要矩阵扰动 → `../matrix-analysis/matrix-perturbation.md`（Davis-Kahan 主角度扰动界）
- 若需要几何视角 → `../../lenses/geometric.md`（度量/曲率）
- 若需要对称性视角 → `../../lenses/symmetry.md`（GL(n) 作用）

## 可扩展方向
- 量子 Grassmannian（quantum Grassmannian）：量子群作用下的 Grassmannian
- 非交换几何（non-commutative geometry）：非交换 Grassmannian
- Tannakian 重建（Tannakian reconstruction）：从表示范畴重建群
- 模空间参数化（moduli spaces）：曲线模空间、矢量丛模空间
- Hall 代数（Hall algebra）：Grassmannian 的 Hall 代数结构
- 持续 Grassmannian（persistent Grassmannian）：结合持续同调的子空间演化
