# Hankel 算子与状态空间模型 (Hankel Operator & State-Space Models)

## 最小定义

线性时不变（LTI）系统的行为完全由其**脉冲响应**（马尔可夫参数）$h = (CB, CAB, CA^2B, \ldots)$ 决定。Hankel 矩阵 $\mathcal{H}_{ij} = h_{i+j}$ 把卷积运算变成矩阵：Hankel 秩 = 系统的最小状态维数（Ho–Kalman 实现定理）。状态空间模型（SSM）$x' = Ax + Bu,\ y = Cx + Du$ 是长序列建模中"无限卷积核"的有限参数化。

## 核心公式

- **连续/离散 SSM**：$\dot{x} = Ax + Bu,\ y = Cx$（连续）；$x_{k+1} = Ax_k + Bu_k,\ y_k = Cx_k$（离散）
- **卷积等价**：离散 SSM 的输出是输入与核 $\bar{K} = (C\bar{B}, C\bar{A}\bar{B}, \ldots, C\bar{A}^{L-1}\bar{B})$ 的卷积 $y = \bar{K} * u$，长度 $L$ 的核只需 $O(N)$ 个状态参数
- **Hankel 秩定理**：$\operatorname{rank} \mathcal{H}$ = 最小实现的状态维数；低秩 Hankel ⇒ 存在低维状态空间实现
- **HiPPO 矩阵**（勒让德投影的最优递归）：$A_{nk} = -\begin{cases} \sqrt{(2n+1)(2k+1)} & n > k \\ n+1 & n = k \\ 0 & n < k \end{cases}$，使 $x(t)$ 在线压缩历史为对勒让德基的系数
- **离散化**（双线性/Tustin，步长 $\Delta$）：$\bar{A} = (I - \Delta/2 \cdot A)^{-1}(I + \Delta/2 \cdot A)$，$\bar{B} = (I - \Delta/2 \cdot A)^{-1} \Delta B$
- **卷积模式计算**：$y = \bar{K} * u$ 用 FFT 在 $O(L \log L)$ 完成；**递归模式**逐步 $O(1)$ 状态更新，适合自回归推理

## 适用问题

- **长序列建模**：Transformer 注意力的 $O(L^2)$ 瓶颈替代品；长度外推、流式推理
- **系统辨识**：从输入输出数据恢复 $(A, B, C)$（Ho–Kalman / 子空间辨识）
- **序列压缩的理论解释**：为什么 SSM 的 $O(N)$ 状态能近似任意长历史——勒让德投影的逼近论保证
- **线性注意力/RNN 的统一视角**：线性 RNN、线性注意力、卷积都是 Hankel 低秩结构的不同参数化

## AI 设计翻译

- **S4 类层**：初始化 $A$ 为 HiPPO（或其正规部分），训练时卷积模式（FFT，可并行扫描全序列），推理时递归模式（每 token $O(N)$ 状态更新）。训练吞吐与 Transformer 同量级，推理显存不随长度增长
- **选择性 SSM（Mamba 类）**：让 $B, C, \Delta$ 依赖输入（时变系统），牺牲纯卷积模式换取内容感知；用硬件感知的并行扫描（associative scan）保持训练并行度
- **Hankel 低秩压缩**：把学到的长卷积核 $\bar{K}$ 排成 Hankel 矩阵做截断 SVD，得到低维状态空间压缩；用于蒸馏长卷积层为小型 RNN

## 工程可行性

- **主要操作**：训练 = FFT 卷积（matmul 之外的标准 GPU 原语）或并行扫描；推理 = 逐 token 的小矩阵状态更新 $O(N^2)$ 或对角化后 $O(N)$
- **GPU 友好度**：高。FFT/扫描都是成熟原语；对角 SSM（S4D/S5）把 $A$ 对角化后全部运算 elementwise + cumsum 类
- **复杂度**：训练 $O(L \log L \cdot N)$（FFT 卷积）vs 注意力 $O(L^2 d)$；推理每 token $O(N^2)$（稠密）或 $O(N)$（对角），显存 $O(N)$ 不随 $L$ 增长
- **低精度**：递归模式的误差沿时间累积，对角化后特征值模接近 1 时 bf16 下相位漂移明显；状态建议 fp32

## 风险与失效条件

- **非对角化的数值不稳定**：稠密 $A$ 的幂 $\bar{A}^k$ 在特征值模 > 1 时爆炸、< 1 时遗忘；必须参数化保证稳定（如特征值实部为负 + 指数参数化）
- **HiPPO 初始化不是万能**：对强局部模式（复制、归纳头）任务，纯 SSM 弱于注意力；混合架构（SSM + 少量注意力层）通常是更稳的选择
- **卷积模式与递归模式不一致**：离散化误差、低精度下两种模式输出漂移，训练-推理不一致；需对齐离散化方案并在目标精度下验证
- **Hankel 秩 ≠ 实际可分性**：低秩是存在性结论，从噪声数据恢复低秩实现是病态问题（对 Hankel 奇异值间隙敏感）

## 深入参考

- 蒸馏稿：`../../references/books/matrix-analysis.md`（SVD 与低秩；Hankel 具体理论超出该书范围）
- Gu et al. "HiPPO: Recurrent Memory with Optimal Polynomial Projections." *NeurIPS*, 2020
- Gu, Goel, Ré. "Efficiently Modeling Long Sequences with Structured State Spaces." *ICLR*, 2022 (S4)
- Ho & Kalman. "Effective construction of linear state-variable models from input/output functions." 1966

## 路由扩展

- 若需要谱初始化分析 → `spectral-decomposition.md`（$A$ 的特征值决定记忆时间尺度）
- 若需要长卷积的低秩压缩 → `low-rank-approximation.md`（Hankel 截断 SVD）
- 若需要卷积的频域计算 → `spectral-decomposition.md`（FFT 即循环矩阵的谱分解）

## 可扩展方向

- 子空间系统辨识（subspace identification, N4SID）：从数据直接估计状态空间
- 平衡截断（balanced truncation）：可控/可观 Gramian 引导的模型降阶
- 时变与输入依赖 SSM（selective SSM）：Mamba 类的硬件感知扫描
- 正交多项式族推广（HiPPO-LegS/LagT）：不同测度下的最优记忆投影
- 非线性扩展（Hammerstein/Wiener 系统）：SSM + 逐点非线性的系统理论
