# 拓扑 激活索引 / Topology Activation Index

## 领域信号
当问题涉及以下信号时，激活本领域方向：
- 连通性保持：需要保持或检测空间的连通性结构
- 表示空间断裂：隐空间或表示空间出现拓扑断裂
- 局部到全局一致性：局部信息是否能一致地拼接成全局结构
- 多模态对齐 obstruction：多模态对齐是否存在拓扑障碍
- 压缩是否破坏结构：降维或压缩是否改变了数据的拓扑特征

## 核心锚点
- `persistent-homology.md` — 持续同调
- `euler-characteristic.md` — Euler 示性数
- `fundamental-group.md` — 基本群

## 扩展概念
当核心锚点不够时，以下概念可能需要临时激活：
- simplicial complex：单纯复形（Vietoris-Rips, alpha complex 等）
- Cech complex：Cech 复形与覆盖
- sheaf theory（section, restriction map, gluing, Cech cohomology）：层论基础与 Cech 上同调
- covering space：覆叠空间与覆叠映射
- homotopy group：高阶同伦群
- CW complex：CW 复形与胞腔结构
- Morse theory：Morse 理论与临界点分析
- Betti numbers：Betti 数与拓扑不变量
- topological data analysis（Mapper algorithm）：拓扑数据分析与 Mapper 算法
- obstruction theory：障碍理论
- classifying space：分类空间
- K-theory：K 理论
- cobordism：配边理论

## 参考书方向
- `../../references/books/smooth-manifolds.md`：第 17-18 章，覆盖同调论基础
- `../../references/books/algebraic-geometry-rising-sea.md`：Cech 上同调部分

## 临时激活规则
当问题需要的数学不在核心锚点中时：
1. 先检查扩展概念中是否有匹配
2. 若有，根据透镜生成临时知识卡
3. 若无，进入 Knowledge Gap Protocol
