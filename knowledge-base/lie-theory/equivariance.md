# 等变性 (Equivariance)

## 最小定义

映射 $f: X \to Y$ 关于群 $G$ 的作用等变，若 $f(g \cdot x) = g \cdot f(x)$ 对所有 $g \in G, x \in X$ 成立。等变性是比不变性（$f(g \cdot x) = f(x)$）更精细的结构保持：输出随输入按同一群作用"协动"。

## 核心公式

- 等变性条件：$f(\rho_X(g) x) = \rho_Y(g) f(x), \quad \forall g \in G$
- 不变性 = 等变到平凡表示：$f(g \cdot x) = f(x)$（$\rho_Y = \text{id}$）
- 卷积的平移等变性：$f(T_a x) = T_a f(x)$，其中 $T_a$ 是平移算子
- 规范等变性（gauge equivariance）：$f(\alpha \cdot_\omega x) = \alpha \cdot_{f(\omega)} f(x)$，$\alpha$ 是局部规范变换，$\omega$ 是联络
- 伴随等变性：$f(X \oplus \tau) = f(X) \oplus (\text{Ad}_X \tau)$（李群场景）

## 适用问题

- 3D 点云/分子：输入旋转后，输出（分割/力/位姿）应同样旋转
- 球面/流形上的信号处理：局部坐标选择不应影响预测结果
- 多视角/多传感器：相机朝向变化时，特征应协变而非重新学习
- 物理模拟：力、速度等矢量应随坐标系变换正确旋转

## AI 设计翻译

- **E(n)-等变 GNN**：节点特征 + 坐标，消息传递同时更新标量特征和等变更新坐标 $x_i \to x_i + \sum_j \phi(r_{ij}) \cdot (x_i - x_j)$
- **Gauge-equivariant CNN**：每条边携带 $G$-联络对齐局部 frame，卷积核对局部坐标选择不变；适用于 mesh/球面/图
- **Steerable CNN**：特征场是群表示的直和 $\bigoplus_l \rho_l$，卷积核被 Schur 引理约束为块结构，参数少但严格等变
- **伴随等变输出头**：位姿回归 $f: X \to SE(3)$ 满足 $f(g \cdot X) = g \cdot f(X)$，用 $\exp$ 和李代数实现
- **等变性验证损失**：$L_{\text{eq}} = \|f(g \cdot x) - g \cdot f(x)\|^2$ 作为辅助正则，强制近似等变

## 工程可行性

GPU 友好度取决于群的离散化程度：
- **离散群（$C_n$, 八面体群等）**：群卷积可展开为 GEMM，等变约束使权重块对角化（参数减少），GPU 友好
- **平移群（标准 CNN）**：天然等变，weight sharing 就是等变性的工程实现，完美 GPU 友好
- **连续群 SO(3)/SE(3)**：需频域展开（球谐）或采样离散化；球谐变换有快速算法但实现复杂
- **Gauge-equivariant**：每边一个 $G$-元素作用 = 小矩阵乘特征向量，可表达为 sparse matmul
- **近似等变（正则化）**：等变性损失 $L_{\text{eq}}$ 是普通的 MSE，完全 GPU 友好，但等变性不严格
- 关键权衡：严格等变（结构约束）vs 近似等变（正则化）——前者参数少但实现复杂，后者简单但不保证

## 风险与失效条件

- **连续群离散化误差**：采样不当导致等变性悄悄破缺，验证时通过但推理时失败
- **等变性与表达力的权衡**：严格等变约束减少参数空间，可能不足以拟合复杂函数
- **多群作用的组合爆炸**：同时要求旋转 + 平移 + 置换等变时，约束交叉复杂
- **数据噪声破坏等变性**：传感器噪声使 $g \cdot x$ 的精确计算不可靠，等变性前提失效
- **等变层的数值精度**：球谐/CG 系数在大 $l$ 下的浮点误差会破坏等变性，需 fp32 累加
- **过度等变约束**：任务只需近似对称时硬上严格等变，不如用正则化软约束

## 深入参考

- 蒸馏稿：references/books/micro-lie-theory.md（§II-F 伴随 Ad_X，等变性的代数实现）
- 蒸馏稿：references/books/differential-geometry.md（§6.8 Principal Bundles, §12.12 G-Connections, 规范等变）
- 蒸馏稿：references/books/differential-geometry.md（Ch 5 Lie Groups, 连续对称作为先验）
- 原书：Jeffrey M. Lee, *Manifolds and Differential Geometry*, §6.8 + §12.12（规范等变的几何基础）
