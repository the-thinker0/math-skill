# 微分几何 激活索引 / Differential Geometry Activation Index

## 领域信号
当问题涉及以下信号时，激活本领域方向：
- 参数空间曲率：参数空间的几何弯曲影响优化或推断
- 流形约束：参数必须保持在特定流形上
- 测地线距离：需要沿流形计算最短路径或距离
- 联络/平行移动：需要在流形上比较不同点的切向量
- 黎曼度量：需要定义流形上的内积和长度
- 指标升降：需要在切空间与余切空间之间转换

## 核心锚点
- `manifold.md` — 流形的基本概念
- `tangent-space.md` — 切空间与切映射
- `metric-tensor.md` — 度量张量与黎曼度量
- `geodesic.md` — 测地线
- `curvature.md` — 曲率
- `connection.md` — 联络与协变导数

## 扩展概念
当核心锚点不够时，以下概念可能需要临时激活：
- Lie derivative：Lie 导数与沿向量场的变化率
- exterior calculus（differential forms, wedge product, exterior derivative）：外微分与微分形式运算
- Hodge decomposition：Hodge 分解定理
- fiber bundle：纤维丛与截面
- principal bundle：主丛与规范理论
- holonomy：和乐群与平行移动的闭合性
- Riemannian submersion：黎曼浸没与商度量
- symmetric space：对称空间
- homogeneous space：齐性空间 G/H
- Cartan geometry：Cartan 几何与活动标架
- spin structure：旋量结构
- Dirac operator：Dirac 算子
- Ricci flow：Ricci 流

## 参考书方向
- `../../references/books/differential-geometry.md`：黎曼几何的核心内容
- `../../references/books/smooth-manifolds.md`：光滑流形、向量丛和微分形式

## 临时激活规则
当问题需要的数学不在核心锚点中时：
1. 先检查扩展概念中是否有匹配
2. 若有，根据透镜生成临时知识卡
3. 若无，进入 Knowledge Gap Protocol
