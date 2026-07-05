# 李代数 (Lie Algebra)

## 最小定义

李代数 $\mathfrak{g}$ 是李群 $G$ 在单位元 $e$ 处的切空间 $T_e G$，配备李括号 $[\cdot, \cdot]: \mathfrak{g} \times \mathfrak{g} \to \mathfrak{g}$ 满足双线性、反对称性和 Jacobi 恒等式。它是"无穷小生成元"的线性空间——把曲的非线性群局部线性化为平的向量空间。

## 核心公式

- 李括号：$[X, Y] = XY - YX$（矩阵群），满足 $[X,[Y,Z]] + [Y,[Z,X]] + [Z,[X,Y]] = 0$
- $\text{so}(3)$：反对称矩阵，$[\omega]_\times = \begin{pmatrix} 0 & -\omega_3 & \omega_2 \\ \omega_3 & 0 & -\omega_1 \\ -\omega_2 & \omega_1 & 0 \end{pmatrix}$
- hat/vee 算子：$\hat{\cdot}: \mathbb{R}^n \to \mathfrak{g}$（向量→反对称矩阵），$\check{\cdot}: \mathfrak{g} \to \mathbb{R}^n$（逆）
- Baker-Campbell-Hausdorff：$\log(\exp(X)\exp(Y)) = X + Y + \frac{1}{2}[X,Y] + \cdots$
- 伴随表示：$\text{ad}_X(Y) = [X,Y]$，是 $\text{Ad}$ 的微分

## 适用问题

- 旋转/位姿的局部线性化：在小邻域内用李代数向量 $\delta \in \mathbb{R}^n$ 近似群上的非线性变化
- 约束优化的重参数化：将正交/旋转约束转化为无约束李代数参数 + exp 映射
- 对称性的无穷小描述：连续对称群由少数生成元完全刻画
- 误差状态估计：协方差定义在切空间 $\mathbb{R}^n$ 上而非群上

## AI 设计翻译

- **李代数参数化层**：网络输出 $\delta \in \mathbb{R}^3$（so(3)），经 $\exp$ 得到合法旋转矩阵；替代四元数归一化或 6D 表示
- **误差状态 EKF/优化层**：在标称状态 $X$ 附近用 $\delta \in \mathfrak{g}$ 参数化误差 $X_{\text{true}} = X \oplus \delta$，卡尔曼滤波在线性切空间进行
- **李括号正则**：惩罚 $[\xi_i, \xi_j] \neq 0$ 来约束生成元的交换性，或用作对称性一致性损失
- **生成元学习**：学习一组李代数基 $\{E_1, \ldots, E_n\}$ 作为可训练参数，实现数据驱动的对称性发现

## 工程可行性

GPU 友好度高。李代数的核心优势是"线性空间"：
- **hat/vee 映射**：纯索引操作 + 符号翻转，$O(n)$，完美 GPU 友好
- **李括号 $[X,Y] = XY - YX$**：两次小矩阵乘法 + 减法，$O(n^3)$ 小矩阵，可 batched
- **线性组合 $\sum c_i E_i$**：向量加法 + 标量乘，$O(nd)$，完美 GPU 友好
- **BCH 近似**：取前几项即够工程精度，$[X,Y]$ 计算为小矩阵乘法
- 主要开销在 $\exp$ 而非代数运算本身：代数运算全部是线性操作，瓶颈在后续的 exp 映射

## 风险与失效条件

- **BCH 级数截断误差**：高阶项在大角度时不可忽略，一阶近似 $X+Y$ 仅对小扰动有效
- **李括号非零的误读**：非交换群的 $[X,Y] \neq 0$ 意味着群合成顺序敏感，不能随意交换操作
- **基的选择影响优化**：李代数基的选取不唯一，差的条件数会导致优化困难
- **把李代数当全局坐标**：exp 映射只是局部微分同胚，大范围需要多张覆盖（atlas）
- **左右约定不统一**：右雅可比 vs 左雅可比、局部 vs 全局坐标系，不统一则梯度与协方差错位

## 深入参考

- 蒸馏稿：../../references/books/micro-lie-theory.md（§II-C 切空间与李代数, hat/vee 算子）
- 蒸馏稿：../../references/books/differential-geometry.md（Ch 5 Lie Groups, 李代数部分）
- 原书：Joan Sola et al., *A micro Lie theory*, §II-C（李代数定义与 hat/vee）、§II-D（exp/log 桥梁）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, Ch 5（李群与李代数）


## 路由扩展
- 若需要对应的全局群 → `lie-group.md`（李代数积分得到李群）
- 若需要代数表示 → `representation.md`（李代数的表示理论）
- 若作为群的切空间 → `tangent-space.md`（切空间的李代数结构）

## 可扩展方向
- 结构常数（structure constants）：李括号在基下的分量
- Jacobi 恒等式：李代数的基本公理
- 理想/子代数（ideal / subalgebra）：李代数的子结构
- 幂零/可解/半单分类（nilpotent / solvable / semisimple）：李代数的结构定理
- Killing 型（Killing form）：李代数的不变双线性型
- Cartan 子代数（Cartan subalgebra）：半单李代数的极大环面子代数
- 根系（root system）：半单李代数的根系分类
