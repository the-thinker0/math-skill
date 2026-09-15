# 欧拉示性数 (Euler Characteristic)

## 最小定义

以下计数公式采用有限 CW/单纯复形（或相应有限型条件），同伦等价保留 Euler 特征；不对任意无限空间无条件求交错和。

欧拉示性数 $\chi$ 是拓扑空间最基本的整数不变量，定义为各维胞腔（或单纯形）数的交错和：$\chi = \sum_{k=0}^d (-1)^k c_k$。它在连续变形下不变，等于各阶 Betti 数的交错和 $\chi = \sum_k (-1)^k \beta_k$。

## 核心公式

- 胞腔公式：$\chi = c_0 - c_1 + c_2 - c_3 + \cdots = \sum_{k=0}^d (-1)^k c_k$
- Betti 数公式：$\chi = \beta_0 - \beta_1 + \beta_2 - \cdots = \sum_{k=0}^d (-1)^k \beta_k$
- Gauss–Bonnet：闭（紧致无边界）光滑黎曼曲面 $\int_M K\,dA=2\pi\chi(M)$；带边界时另加边界测地曲率与角项。
- 高维 Gauss–Bonnet–Chern 需闭定向偶维黎曼流形及一致的曲率/Pfaffian 约定。
- 乘积公式：$\chi(X \times Y) = \chi(X) \cdot \chi(Y)$
- 常见值：$\chi(S^2) = 2$，$\chi(T^2) = 0$，$\chi(\text{genus-}g) = 2 - 2g$

## 适用问题

- 快速拓扑诊断：一个整数即可区分球面 vs 环面 vs 高亏格曲面
- 网格诊断：只有目标拓扑为球面且满足闭曲面假设时才预期 $\chi=2$；一般三角网格无此要求。
- 损失地形分析：临界点的 Morse 理论中 $\chi$ 约束临界点的数量和类型
- 持续同调的快速摘要：$\chi = \sum (-1)^k \beta_k$ 可从持续图快速算出

## AI 设计翻译

- **拓扑诊断指标**：在固定滤流约定下监控 χ，变化只说明这一统计量变化；不能直接判定生成模型模式坍塌。
- **Gauss–Bonnet 检查**：三角化闭曲面的顶点角缺陷可精确求总曲率；损失 Hessian 的迹不等于高斯曲率积分，不能用作其替代。
- **网格质量损失**：对 3D 生成模型，惩罚 $\chi \neq \chi_{\text{target}}$ 只检查一个必要的拓扑统计量，不保证拓扑完全正确
- **Morse 临界点计数**：对闭光滑流形上的 Morse 函数，$\chi(M)=\sum_k(-1)^k c_k$，$c_k$ 为指数 k 的临界点数；退化或非紧损失地形须另核对条件。
- **Euler characteristic curve**：$\chi(\epsilon) = \chi(VR_\epsilon)$ 作为尺度 $\epsilon$ 的函数，比单一 $\chi$ 信息更丰富

## 工程可行性

GPU 友好度高。欧拉示性数的计算极其廉价：
- **胞腔计数**：$c_k$ 是整数计数，$O(n)$ 求和，完美 GPU 友好
- **从 Betti 数计算**：$\chi = \sum (-1)^k \beta_k$，若已有 Betti 数则 $O(d)$ 求和
- **从持续图计算**：$\beta_k(\epsilon) = |\{(b,d) \in D_k \mid b \leq \epsilon < d\}|$，计数操作，$O(|D_k|)$
- **Gauss–Bonnet 检查**：三角化闭曲面的顶点角缺陷可精确求总曲率；损失 Hessian 的迹不等于高斯曲率积分，不能用作其替代。
- **Euler characteristic curve**：沿 $\epsilon$ 扫描计算 $\chi(\epsilon)$，可用排序 + 累积和实现，$O(n \log n)$
- 已有有限复形上数单纯形通常线性于复形大小；构建复形另计。固定连接关系的 $\chi$ 对坐标变化为常数，直接用作梯度 loss 可能没有信号。

## 风险与失效条件

- **信息极度压缩**：$\chi$ 是单一整数，大量不同拓扑空间共享同一 $\chi$ 值（$\chi = 0$ 可以是环面、Klein 瓶等）
- **对噪声敏感**：点云的小扰动可能添加/删除单纯形，改变 $c_k$ 从而改变 $\chi$；需配合持续同调的尺度分析
- **Gauss–Bonnet 检查**：三角化闭曲面的顶点角缺陷可精确求总曲率；损失 Hessian 的迹不等于高斯曲率积分，不能用作其替代。
- **高维退化**：奇数维闭流形的 $\chi = 0$，失去区分能力；高维 Betti 数计算昂贵
- **只捕捉"整体"不捕捉"局部"**：$\chi$ 是全局不变量，局部拓扑变化可能被抵消

## 深入参考

- 蒸馏稿：../../references/books/smooth-manifolds.md（Ch 17-18 De Rham Cohomology，Betti 数与上同调）
- 蒸馏稿：../../references/books/differential-geometry.md（Ch 4 Curves and Hypersurfaces, Gauss curvature 直觉来源）
- 原书：John M. Lee, *Introduction to Smooth Manifolds*, Ch 17-18（de Rham 上同调与拓扑不变量）
- 延伸：Hatcher, *Algebraic Topology*, Ch 2（单纯同调与欧拉示性数的标准处理）


## 路由扩展
- 若需要多尺度拓扑分析 → `persistent-homology.md`（持续同调提供尺度依赖的拓扑）
- 若涉及曲率-拓扑联系 → `../differential-geometry/curvature.md`（Gauss-Bonnet 定理连接曲率与 Euler 示性数）

## 可扩展方向
- Betti 数（Betti numbers）：各维度的独立环路计数
- Poincare 多项式（Poincare polynomial）：Betti 数的生成函数
- Lefschetz 不动点定理：Euler 示性数与映射不动点
- Morse 不等式（Morse inequalities）：临界点与 Betti 数的关系
- 离散 Morse 理论（discrete Morse theory）：复形上的 Morse 函数
- Euler 示性数曲线（Euler characteristic curve）：多阈值的 Euler 示性数变化
