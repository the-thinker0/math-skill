# 李群 (Lie Group)

## 最小定义

李群 $G$ 是同时具有光滑流形结构和群结构的空间，使得群乘法 $\mu: G \times G \to G$ 和求逆 $\iota: G \to G$ 都是光滑映射。它是"连续对称变换群"的精确数学对象——既是可微的空间，又是可乘的代数。

## 核心公式

- 指数映射：$\exp: \mathfrak{g} \to G$，$\exp(\xi) = \gamma_\xi(1)$，其中 $\gamma_\xi$ 是单参数子群
- SO(3) Rodrigues 公式：$\exp([\theta]_\times) = I + \frac{\sin\|\theta\|}{\|\theta\|}[\theta]_\times + \frac{1-\cos\|\theta\|}{\|\theta\|^2}[\theta]_\times^2$
- SE(3)：$\exp\begin{pmatrix} [\omega]_\times & v \\ 0 & 0 \end{pmatrix} = \begin{pmatrix} \exp([\omega]_\times) & V(\theta)v \\ 0 & 1 \end{pmatrix}$
- $\oplus/\ominus$ 算子（右版本）：$X \oplus \tau = X \cdot \exp(\tau)$，$X \ominus Y = \log(Y^{-1} X)$
- 伴随映射：$\text{Ad}_X(\tau) = X \tau X^{-1}$（矩阵群），满足 $X \oplus \tau = (\text{Ad}_X \tau) \oplus X$

## 适用问题

- 预测/回归量带几何约束：旋转、位姿、单位四元数——硬塞进欧氏 MLP 会破坏约束
- 需要等变性/不变性：输入做刚体变换，输出应协变或不变（点云、分子、多视几何）
- 状态在李群上演化：惯性预积分、运动模型、可微物理/控制
- 正交/酉约束的权重矩阵：Stiefel 流形上的优化

## AI 设计翻译

- **流形参数化输出头**：网络在切空间 $\mathbb{R}^n$ 自由预测，经 $\exp$ 投回 SO(3)/SE(3)，替代 6D/9D 旋转表示的 ad-hoc 正交化
- **流形损失函数**：用 $\ominus$（测地误差）当 loss，$L = \|X_{\text{pred}} \ominus X_{\text{gt}}\|^2$，天然处理流形拓扑
- **李群 RNN/ODE**：隐状态 $h_t \in G$，更新 $h_{t+1} = h_t \oplus f_\theta(h_t, x_t) = h_t \cdot \exp(f_\theta(h_t, x_t))$
- **正交权重约束**：$W = \exp(A)$ 其中 $A$ 反对称，保证 $W^T W = I$；或用 Cayley 变换 $W = (I-A)(I+A)^{-1}$

## 工程可行性

GPU 友好度：关键看 exp/log 是否有闭式。
- **SO(3)/SE(3) 闭式**：Rodrigues 公式是有限项代数表达式，3x3/4x4 小矩阵，可 batched 为 $[B,3,3]$/ $[B,4,4]$ 张量，逐样本独立，GPU 友好
- **通用矩阵指数**：Taylor 级数 + scaling-and-squaring 迭代，步数数据相关、控制流发散、难张量化，GPU 不友好
- **小矩阵 GEMM**：3x3/4x4 太小，吃不满 Tensor Core，价值在"可批量、可融合"而非"打满算力"
- **低精度致命点**：$\sin\theta/\theta$ 在 $\theta \to 0$ 除零，$\theta \to \pi$ 时 log 奇异；fp16/bf16 直接 NaN，**必须** 对小角做 Taylor 展开切换
- **运动链串行**：连乘 $\exp$ 的离散积分是串行递推，需改写成 parallel scan 才能并行

## 风险与失效条件

- **低精度奇异点**：$\theta \to 0/\pi$ 处不做 Taylor 兜底，fp16 训练直接 NaN；兜底分支又引入 warp divergence
- **左右扰动混用**：$\oplus_R$（右版本/局部坐标系）和 $\oplus_L$（左版本/全局坐标系）混用导致协方差与梯度错位
- **把 SE(3) 当成 T(3)xSO(3)**：二者切空间参数化不同，平移-旋转是否耦合改变雅可比，误用导致系统性偏差
- **通用 matrix exp 当 O(1) 算子**：闭式只属于 SO(3)/SE(3)/SE(2)/S1/S3 等少数群，一般群需迭代级数
- **过度套用**：不需要几何约束的任务硬上李群参数化，徒增复杂度与奇异点风险

## 深入参考

- 蒸馏稿：../../references/books/micro-lie-theory.md（§II-A 李群定义, §II-D 指数映射, §II-E 加减算子）
- 蒸馏稿：../../references/books/differential-geometry.md（Ch 5 Lie Groups）
- 蒸馏稿：../../references/books/smooth-manifolds.md（Ch 7 Lie Groups）
- 原书：Joan Sola et al., *A micro Lie theory*, §II-A ~ §II-F（完整李群工具链）


## 路由扩展
- 若需要无穷小结构 → `lie-algebra.md`（李代数是李群的切空间）
- 若需要线性表示 → `representation.md`（李群的有限维表示）
- 若需要在李群上优化 → `riemannian-optimization.md`（李群上的黎曼优化）

## 可扩展方向
- 单连通李群（simply connected Lie group）：万有覆叠群
- 覆叠群（covering group）：李群之间的覆叠映射
- 极大环面（maximal torus）：紧李群中的极大交换子群
- 紧/半单/可解（compact / semisimple / solvable）：李群的结构分类
- 幂零（nilpotent）：幂零李群与幂零李代数
- 指数映射性质（exponential map properties）：李代数到李群的映射特性
