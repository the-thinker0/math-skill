# 切空间 (Tangent Space)

## 最小定义

切空间 $T_pM$ 是流形 $M$ 在点 $p$ 处的所有切向量构成的 $n$ 维向量空间，是流形的局部线性化。光滑映射 $f: M \to N$ 在 $p$ 处的微分（pushforward）$df_p: T_pM \to T_{f(p)}N$ 是切空间之间的线性映射。

## 核心公式

- 切向量作为导子：$v(f) = \sum_i v^i \frac{\partial f}{\partial x^i}\bigg|_p$
- Pushforward（微分）：$df_p: T_pM \to T_{f(p)}N$，坐标表示为 Jacobian 矩阵 $J_f(p)$
- 切丛：$TM = \bigsqcup_{p \in M} T_pM$
- 余切空间：标量函数的微分 $df_p\in T_p^*M$；梯度 $\operatorname{grad}_g f=(df)^\sharp$ 才是切向量。

## 适用问题

- 反向传播的几何理解：链式法则 = 余切丛上的 pullback（拉回），即 VJP（vector-Jacobian product）= 余向量的拉回 $df_p^*(\omega) = J^T \omega$。注意：pushforward 对应的是 JVP（前向模式 AD），不是反向传播
- 梯度方向的正确计算：autodiff 输出是余向量（1-form），需要度量才能变成下降方向
- 约束优化中梯度投影：将欧氏梯度投影到约束子流形的切空间
- 流形上的线性化近似：在切空间中用线性方法处理局部问题

## AI 设计翻译

- **自然梯度层**：$\tilde{\nabla} L = g^{-1} \nabla L$，用 Fisher 度量将余向量（autodiff 输出）升为切向量，对重参数化不变
- **切空间投影模块**：$W\in\mathrm{St}(n,p)$ 的切空间为 $W^TZ+Z^TW=0$；仅 $W\Omega$ 漏掉正交补方向。嵌入欧氏度量的投影为 $Z-W\operatorname{sym}(W^TZ)$。
- **Jacobian-vector product (JVP) 加速**：pushforward $df_p(v)$ 天然对应 JVP，是 forward-mode AD 的几何原型
- **切空间特征表示**：在流形优化中，将动量/历史梯度存放在切空间中，通过 vector transport 跨点搬运

## 工程可行性

GPU 友好度高。切空间的核心操作是线性代数：
- Pushforward/JVP：若显式 Jacobian 为 m×n，乘法为 $O(mn)$；自动微分通常不物化完整 Jacobian，成本由原计算图决定。
- Pullback $df_p^*(\omega) = J^T \omega$：转置矩阵-向量乘法，即反向传播本身
- 切空间投影：$\Pi_W(Z)=Z-W\operatorname{sym}(W^TZ)$，$O(np^2)$；$(I-WW^T)Z$ 仅是 Grassmann 水平方向，不是完整 Stiefel 投影。
- 度量升指标：对角求解为 $O(n)$；稠密分解一般 $O(n^3)$、后续单次回代 $O(n^2)$。矩阵无关方案依赖每次乘积成本和迭代数。

## 风险与失效条件

- **混淆梯度与下降方向**：忘记度量升指标，把 raw autodiff 输出（余向量）直接当下降方向（切向量），在弯曲空间中方向错误
- **大度量求解**：需要 $g^{-1}df$ 的作用，不一定需要显式逆；可用矩阵无关乘积加迭代求解，或结构近似，并检查条件数与残差。
- **切空间与原空间混淆**：在弯曲流形上直接做切空间的向量加法，忽略曲率导致的非线性偏差
- **Vector transport 缺失**：不同点的切空间无法直接相加，动量需要合适的 vector transport（不必是精确 parallel transport）；Adam 二阶状态还需指定表示与更新规则

## 深入参考

- 蒸馏稿：../../references/books/smooth-manifolds.md（Ch 3 Tangent Vectors, Ch 11 The Cotangent Bundle）
- 蒸馏稿：../../references/books/differential-geometry.md（Ch 1-2, Ch 7 Tensors）
- 原书：John M. Lee, *Introduction to Smooth Manifolds*, 2nd Edition, Ch 3（切空间、pushforward、切丛）
- 原书：John M. Lee, *Introduction to Smooth Manifolds*, Ch 11（余切丛、1-form、pullback）


## 路由扩展
- 若需要在流形上计算梯度 → `../optimization/riemannian-optimization.md`（流形上的梯度下降）
- 若涉及群结构的切空间 → `../lie-theory/lie-algebra.md`（李群在单位元处的切空间配上 Lie 括号即李代数）
- 若需要协变导数 → `connection.md`（联络定义协变微分）

## 可扩展方向
- 余切空间：标量函数的微分 $df_p\in T_p^*M$；梯度 $\operatorname{grad}_g f=(df)^\sharp$ 才是切向量。
- 微分/前推算子（differential / pushforward）：光滑映射的切映射
- 向量场（vector field）：流形上的光滑向量场
- Lie 括号（Lie bracket）：向量场的对易关系
- 积分曲线（integral curve）：向量场的积分曲线与流
- 指数映射（exponential map）：从切空间到流形的映射
