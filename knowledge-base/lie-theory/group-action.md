# 群作用 (Group Action)

## 最小定义

群 $G$ 作用在集合 $X$ 上是一个同态 $\rho: G \to \text{Bij}(X)$，满足 $\rho(e) = \text{id}$ 和 $\rho(g_1 g_2) = \rho(g_1) \circ \rho(g_2)$。它将群元素转化为集合上的变换，是"对称性"的数学实现：群的代数结构决定了几何变换的结构。

## 核心公式

- 群作用：$g \cdot x = \rho(g)(x)$，满足 $e \cdot x = x$，$(gh)\cdot x = g \cdot (h \cdot x)$
- 轨道（orbit）：$\text{Orb}(x) = \{g \cdot x \mid g \in G\}$
- 稳定子群（stabilizer）：$\text{Stab}(x) = \{g \in G \mid g \cdot x = x\}$
- 有限群的轨道-稳定子定理：$|G|=|\mathrm{Orb}(x)|\,|G_x|$；一般群有轨道与陪集空间 $G/G_x$ 的集合双射。
- 不变函数：$f(g \cdot x) = f(x), \forall g \in G$
- 等变映射：$\phi(g \cdot x) = g \cdot \phi(x)$

## 适用问题

- 数据具有已知对称性：旋转、平移、置换、尺度变换，需要模型尊重这些对称
- 输出应随输入协变：姿态估计中，物体旋转后输出位姿也应相应旋转
- 数据增广：从群轨道采样是遍历的一种近似；有限训练样本不自动保证全群不变或等变。
- 商空间构造：$X/G$ 是轨道集合；$G/G_x$ 参数化单条轨道，不是 $X/G$。

## AI 设计翻译

- **等变网络层**：$f(g \cdot x) = g \cdot f(x)$，将群作用硬编码进网络结构，无需数据增广即获得等变性
- **不变池化层**：对轨道求平均/最大 $\frac{1}{|G|}\sum_g f(g \cdot x)$，从等变特征中提取不变量
- **群卷积**：$(f * h)(g) = \sum_{g'} f(g') h(g'^{-1} g)$，在群本身上做卷积，适用于信号定义在群上的场景
- **轨道采样数据增广**：用群作用生成训练样本的对称等价类，扩大有效训练集

## 工程可行性

GPU 友好度取决于群的类型：
- **有限群上的卷积**：朴素标量卷积为 $O(|G|^2)$；若核仅有 s 个非零群元素则可降至 $O(|G|s)$，还需计通道数与实际核实现。
- **连续紧群 SO(n)/SU(n)**：可用采样/频域展开（Peter-Weyl）或直接表示约束；采样不是实现等变层的必需步骤。
- **置换群 $S_n$**：不枚举 $n!$ 元素；sum/mean/max 等对称聚合可精确不变，排序需处理 ties 与可微性。
- **群 FFT**：循环/有限阿贝尔群有高效 FFT；任意有限群不自动拥有统一的 $O(|G|\log|G|)$ 卷积界，需计 irrep 变换和块矩阵乘法。
- 关键瓶颈：连续群的离散化若不精确，等变性会悄悄破缺

## 风险与失效条件

- **连续群无脑离散化**：采样不当导致等变性破缺 + 不规则 gather/scatter，GPU 不友好
- **群作用定义错误**：左右作用混淆、群乘法顺序不一致导致等变性验证通过但推理失败
- **轨道遍历不可行**：大群/连续群的轨道无法完整遍历，近似不变化引入偏差
- **过度约束**：不是所有任务都需要严格等变，弱对称任务硬上群作用可能牺牲表达力

## 深入参考

- 蒸馏稿：../../references/books/micro-lie-theory.md（§II-B 群作用）
- 蒸馏稿：../../references/books/smooth-manifolds.md（Ch 7 Lie Groups）
- 原书：Joan Sola et al., *A micro Lie theory*, §II-B（群作用定义与机器人中的应用）
- 原书：John M. Lee, *Introduction to Smooth Manifolds*, Ch 7（李群与群作用）


## 路由扩展
- 若需要等变映射的设计 → `equivariance.md`（群作用下的等变性）
- 若需要线性化群作用 → `representation.md`（群表示即线性群作用）
- 若需要不变量分析 → `symmetry`（设计模式层的对称性分析）

## 可扩展方向
- 有限群的轨道-稳定子定理：$|G|=|\mathrm{Orb}(x)|\,|G_x|$；一般群有轨道与陪集空间 $G/G_x$ 的集合双射。
- 传递/自由作用（transitive / free actions）：群作用的特殊类型
- 齐性空间 G/H：传递作用下的一条轨道（光滑结构需相应条件），不同于一般轨道集合 X/G。
- 商流形（quotient manifold）：光滑群作用下的商结构
- 切片定理（slice theorem）：紧群作用的局部结构
- 动量映射（momentum map）：Hamilton 群作用的守恒量
