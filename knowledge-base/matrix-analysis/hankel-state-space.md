# Hankel 算子与状态空间模型 (Hankel Operator & State-Space Models)

## 最小定义

零初态的因果离散 LTI 系统，其脉冲响应（含直通项 $D$）决定输入输出映射。严格真部分的马尔可夫参数 $h_j=CA^jB$（$j\ge0$）构成块 Hankel 矩阵 $\mathcal H_{ij}=h_{i+j}$，将过去输入映射到未来输出。卷积本身对应 Toeplitz 矩阵。无限 Hankel 秩等于最小有限维实现的维数；有限截块需足够大才显现该秩。

## 核心公式

- **索引约定**：$x_{k+1}=\bar A x_k+\bar B u_k$、$y_k=Cx_k+Du_k$、$x_0=0$，则 $y_k=Du_k+\sum_{j=0}^{k-1}C\bar A^{k-1-j}\bar B u_j$。若从更新后的状态读取输出，则 $(C\bar B,C\bar A\bar B,\ldots)$ 从零延迟开始；须明确该位移。
- **参数量**：$N$ 维稠密 SISO 实现使用 $O(N^2)$ 参数，对角/结构化实现可使用 $O(N)$ 参数。两者递归状态均为 $O(N)$，不随序列长 $L$ 增长；状态存储和参数量是不同量。
- **Hankel 秩定理**：$\operatorname{rank} \mathcal{H}$ = 最小实现的状态维数；低秩 Hankel ⇒ 存在低维状态空间实现
- **HiPPO-LegS 矩阵**：$A_{nk}=-\begin{cases}\sqrt{(2n+1)(2k+1)}&n>k\\n+1&n=k\\0&n<k\end{cases}$。原始缩放历史投影采用 $\dot x(t)=A x(t)/t+B u(t)/t$，并指定测度及基归一化；由该矩阵构造的固定步长 LTI S4 参数化不自动继承所有原始投影恒等式。
- **离散化**（双线性/Tustin，步长 $\Delta$）：$\bar{A} = (I - \Delta/2 \cdot A)^{-1}(I + \Delta/2 \cdot A)$，$\bar{B} = (I - \Delta/2 \cdot A)^{-1} \Delta B$
- **卷积模式**：给定长 $L$ 的标量核，FFT 卷积为 $O(L\log L)$；核构造与通道混合另算。**递归模式**每 token 对稠密 $A$ 为 $O(N^2)$、对角 $A$ 为 $O(N)$；仅相对于 $L$ 是常数。

## 适用问题

- **长序列建模**：Transformer 注意力的 $O(L^2)$ 瓶颈替代品；长度外推、流式推理
- **系统辨识**：从输入输出数据恢复 $(A, B, C)$（Ho–Kalman / 子空间辨识）
- **历史压缩**：多项式投影误差依赖历史函数、逼近阶数、测度及光滑性；固定大小状态不能无损保留任意长的所有输入历史。
- **递归算子比较**：线性时不变 RNN 与固定卷积共享实现理论。内容依赖的线性注意力和选择性 SSM 通常是时变/非线性输入输出映射，不能直接套固定 LTI Hankel 秩定理。

## AI 设计翻译

- **S4 类层**：训练使用结构化状态矩阵及 FFT 卷积，流式推理使用适当递归实现。状态存储不随长度增长，但吞吐及相对注意力的盈亏点须测量。[S4 原论文](https://arxiv.org/abs/2111.00396)。
- **选择性 SSM（Mamba 类）**：让 $B, C, \Delta$ 依赖输入（时变系统），牺牲纯卷积模式换取内容感知；用硬件感知的并行扫描（associative scan）保持训练并行度
- **Hankel 压缩**：截断 SVD 用于估计主实现子空间，随后进行结构化实现/模型降阶。任意截断秩近似未必仍是 Hankel 矩阵；需验证重建脉冲响应及稳定性。

## 工程可行性

- **主要操作**：训练 = FFT 卷积（matmul 之外的标准 GPU 原语）或并行扫描；推理 = 逐 token 的小矩阵状态更新 $O(N^2)$ 或对角化后 $O(N)$
- **GPU 友好度**：高。FFT/扫描都是成熟原语；对角 SSM（S4D/S5）把 $A$ 对角化后全部运算 elementwise + cumsum 类
- **复杂度**：单个对角 SISO 通道直接构造核为 $O(LN)$，FFT 应用为 $O(L\log L)$；结构化快速核构造可能不同。递归每 token $O(N)$、状态 $O(N)$；稠密状态更新为 $O(N^2)$。通道数及混合成本另报。
- **低精度**：递归模式的误差沿时间累积，对角化后特征值模接近 1 时 bf16 下相位漂移明显；状态建议 fp32

## 风险与失效条件

- **稳定性与瞬态**：$\rho(\bar A)<1$ 保证固定 LTI 状态渐近衰减，但非正规矩阵可有巨大瞬态放大。对角化本身不保证稳定，病态特征基反而可恶化数值；检查幂范数增长与扰动敏感性。
- **任务依赖的逼近**：在实际任务比较检索、复制、长程召回及吞吐；HiPPO 初始化与混合注意力不提供通用精度排序。
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
