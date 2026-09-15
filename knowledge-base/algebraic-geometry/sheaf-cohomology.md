# 层上同调 (Sheaf Cohomology)

## 最小定义

层 $\mathcal F$ 给开集配截面与限制映射；在重叠处相容的局部截面能唯一黏合。对阿贝尔群层，$H^i(X,\mathcal F)=R^i\Gamma(X,\mathcal F)$ 是全局截面函子的右导出函子。当前局部数据是否受阻由具体障碍类决定，不能只看承载它的群是否非零。

## 核心公式

- Čech 复形：$C^p(\mathcal U,\mathcal F)=\prod_{i_0<\cdots<i_p}\mathcal F(U_{i_0\cdots i_p})$，$\delta^{p+1}\delta^p=0$。
- 固定覆盖的上同调是 $\check H^p(\mathcal U,\mathcal F)=\ker\delta^p/\operatorname{im}\delta^{p-1}$，不能无条件写成 $H^p(X,\mathcal F)$。覆盖的所有非空有限交对该层无高阶上同调时，可用 Leray 覆盖定理比较。
- 连续映射 $f:X\to Y$ 的 Leray 谱序列：$E_2^{p,q}=H^p(Y,R^qf_*\mathcal F)\Rightarrow H^{p+q}(X,\mathcal F)$。
- 通常的光滑流形上，$H^k_{\mathrm{dR}}(M)\cong H^k(M,\underline{\mathbb R})\cong\mathbb H^k(M,\Omega_M^\bullet)$；$\mathbb H$ 是复形的超上同调，非某一张微分形式层的普通上同调。
- 仿射概形上的拟凝聚层无高阶上同调；Cartan B 是 Stein 空间上凝聚解析层的结论，不混用背景范畴。

## 适用问题

- 区分局部残差、全局截面空间与特定提升/平凡化问题的障碍。
- 为多视角、图上数据建立明确的 stalk、限制映射与一致性方程。
- 有限维胞腔层可用线性代数；一般层论需要额外的可计算表示。

## AI 设计翻译

- **一致性代理**：图上向量 $x\in C^0$ 的能量 $\|\delta^0x\|^2$ 为零等价于它是所选模型的全局截面。这不等于 $H^1=0$。
- **给定边数据的可解性**：$\delta^0x=b$ 有解需 $b\in\operatorname{im}\delta^0$。若 $\delta^1b=0$，其障碍类为 $[b]\in H^1$；即使 $H^1\ne0$，具体 $[b]$ 仍可能为零。
- **最小反例**：常值实系数的环图有非零 $H^1$，但 $b=0$ 可由常值节点特征解决。因此“群非零⇒当前融合失败”不成立。
- 作为模型诊断时需先验证数据与层结构的对应；结构一致不能证明语义或事实正确。

## 工程可行性

- 令 $n_p=\dim C^p$，实系数有限复形可通过稀疏乘法、SVD/QR 或线性求解分析；复杂度依矩阵形状、非零元数、秩与容差，不单由覆盖集数量决定。
- 计算 $\|\delta x\|^2$ 通常远便宜于求整个上同调。可微正则项与离散秩判定不是同一计算。
- 有限域消元、整数 Smith 标准型与实数秩估计的代价/数值语义不同；整数也有溢出与位复杂度。
- 实系数近零奇异值会使 Betti 数估计不稳定；bf16 不可默认用于秩/零空间认证。

## 风险与失效条件

- 检查 $\delta^2=0$、覆盖/胞腔定义及系数域后再谈上同调。
- 覆盖近似和 landmark 采样需要误差分析；高阶交集可能组合爆炸。
- $H^1=0$ 只消除所对应的一阶障碍类，不是任意局部到全局问题的充要条件。
- 改变系数可丢失挠信息；一致性残差、上同调与真值不可互换。

## 深入参考

- [书稿](../../references/books/algebraic-geometry-rising-sea.md)。
- [Stacks: Čech 与层上同调比较](https://stacks.math.columbia.edu/tag/01FP)、[de Rham 复形](https://stacks.math.columbia.edu/tag/0FL6)、[H¹ 与 torsor](https://stacks.math.columbia.edu/tag/02FQ)。

## 路由扩展

- 局部到整体：`../../lenses/local-to-global.md`。
- 拓扑诊断：`../topology/persistent-homology.md`。

## 可扩展方向

持续胞腔层、Hodge 分解、Picard 群和高阶障碍；升级前先给具体数学对象与计算表示。
