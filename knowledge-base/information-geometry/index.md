# 信息几何 激活索引 / Information Geometry Activation Index

## 领域信号
当问题涉及以下信号时，激活本领域方向：
- 分布族几何：概率分布族本身具有几何结构
- 参数化无关优化：优化方法应不依赖于具体参数化方式
- 统计模型复杂度：需要度量统计模型的内在复杂度
- 分布间距离：需要在分布空间中定义几何距离
- 自然梯度：梯度方向需要考虑参数空间的几何结构

## 核心锚点
- `natural-gradient.md` — 自然梯度
- `fisher-metric.md` — Fisher 度量

## 扩展概念
当核心锚点不够时，以下概念可能需要临时激活：
- alpha-divergence：alpha-散度族
- Amari-Chentsov tensor：Amari-Chentsov 张量与三次微分结构
- dually flat manifold：对偶平坦流形
- e-connection / m-connection：指数联络与混合联络
- Pythagorean theorem for KL：KL 散度的广义勾股定理
- Bregman divergence：Bregman 散度与凸对偶
- mirror descent as natural gradient：镜像下降与自然梯度的等价性
- EM algorithm geometry：EM 算法的几何解释
- variational Bayes geometry：变分贝叶斯的几何结构
- information geometry of neural networks（loss landscape curvature）：神经网络的信息几何与损失景观曲率
- neural tangent kernel as metric：神经切线核作为度量
- Fisher-Rao gradient flow：Fisher-Rao 梯度流
- Wasserstein gradient flow：Wasserstein 梯度流

## 参考书方向
- `../../references/books/smooth-manifolds.md`：第 13 章黎曼度量，为信息几何提供微分几何基础

## 临时激活规则
当问题需要的数学不在核心锚点中时：
1. 先检查扩展概念中是否有匹配
2. 若有，根据透镜生成临时知识卡
3. 若无，进入 Knowledge Gap Protocol
