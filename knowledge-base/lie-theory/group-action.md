# 群作用 (Group Action)

## 最小定义

群 $G$ 作用在集合 $X$ 上是一个同态 $\rho: G \to \text{Bij}(X)$，满足 $\rho(e) = \text{id}$ 和 $\rho(g_1 g_2) = \rho(g_1) \circ \rho(g_2)$。它将群元素转化为集合上的变换，是"对称性"的数学实现：群的代数结构决定了几何变换的结构。

## 核心公式

- 群作用：$g \cdot x = \rho(g)(x)$，满足 $e \cdot x = x$，$(gh)\cdot x = g \cdot (h \cdot x)$
- 轨道（orbit）：$\text{Orb}(x) = \{g \cdot x \mid g \in G\}$
- 稳定子群（stabilizer）：$\text{Stab}(x) = \{g \in G \mid g \cdot x = x\}$
- 轨道-稳定子定理：$|G| = |\text{Orb}(x)| \cdot |\text{Stab}(x)|$
- 不变函数：$f(g \cdot x) = f(x), \forall g \in G$
- 等变映射：$\phi(g \cdot x) = g \cdot \phi(x)$

## 适用问题

- 数据具有已知对称性：旋转、平移、置换、尺度变换，需要模型尊重这些对称
- 输出应随输入协变：姿态估计中，物体旋转后输出位姿也应相应旋转
- 数据增广的理论基础：群轨道上的采样等价于群作用的遍历
- 商空间构造：模去稳定子群得到不变特征空间

## AI 设计翻译

- **等变网络层**：$f(g \cdot x) = g \cdot f(x)$，将群作用硬编码进网络结构，无需数据增广即获得等变性
- **不变池化层**：对轨道求平均/最大 $\frac{1}{|G|}\sum_g f(g \cdot x)$，从等变特征中提取不变量
- **群卷积**：$(f * h)(g) = \sum_{g'} f(g') h(g'^{-1} g)$，在群本身上做卷积，适用于信号定义在群上的场景
- **轨道采样数据增广**：用群作用生成训练样本的对称等价类，扩大有效训练集

## 工程可行性

GPU 友好度取决于群的类型：
- **有限群/离散群**：群卷积可展开为 batched GEMM 或稀疏 matmul，$O(|G|^2)$ 或 $O(|G| \cdot d)$，GPU 友好
- **连续紧群 SO(n)/SU(n)**：需离散采样或频域展开（Peter-Wigner 定理），球谐变换有快速算法
- **置换群 $S_n$**：$n!$ 阶，不可遍历；用排序池化、对称函数等近似不变化
- **群卷积的 Fourier 加速**：有限群的 FFT 将卷积从 $O(|G|^2)$ 降至 $O(|G| \log |G|)$，但实现复杂
- 关键瓶颈：连续群的离散化若不精确，等变性会悄悄破缺

## 风险与失效条件

- **连续群无脑离散化**：采样不当导致等变性破缺 + 不规则 gather/scatter，GPU 不友好
- **群作用定义错误**：左右作用混淆、群乘法顺序不一致导致等变性验证通过但推理失败
- **轨道遍历不可行**：大群/连续群的轨道无法完整遍历，近似不变化引入偏差
- **过度约束**：不是所有任务都需要严格等变，弱对称任务硬上群作用可能牺牲表达力

## 深入参考

- 蒸馏稿：references/books/micro-lie-theory.md（§II-B 群作用）
- 蒸馏稿：references/books/smooth-manifolds.md（Ch 7 Lie Groups）
- 原书：Joan Sola et al., *A micro Lie theory*, §II-B（群作用定义与机器人中的应用）
- 原书：John M. Lee, *Introduction to Smooth Manifolds*, Ch 7（李群与群作用）


## 路由扩展
- 若需要等变映射的设计 → `equivariance.md`（群作用下的等变性）
- 若需要线性化群作用 → `representation.md`（群表示即线性群作用）
- 若需要不变量分析 → `symmetry`（设计模式层的对称性分析）

## 可扩展方向
- 轨道-稳定子定理（orbit-stabilizer theorem）：群作用的轨道与稳定子关系
- 传递/自由作用（transitive / free actions）：群作用的特殊类型
- 齐性空间 G/H：群作用的轨道空间
- 商流形（quotient manifold）：光滑群作用下的商结构
- 切片定理（slice theorem）：紧群作用的局部结构
- 动量映射（momentum map）：Hamilton 群作用的守恒量
