# 最优化 激活索引 / Optimization Activation Index

## 领域信号
当问题涉及以下信号时，激活本领域方向：
- 约束优化：目标函数需要满足等式或不等式约束
- 对偶间隙：需要分析原始问题与对偶问题的关系
- 鞍点问题：min-max 优化或博弈论结构
- 非凸 landscape：损失函数的几何结构分析
- 流形约束：参数需要在流形上优化
- 分裂算子：目标函数可分解为多个部分的组合优化

## 核心锚点
- `lagrangian-duality.md` — Lagrange 对偶理论
- `convex-optimization.md` — 凸优化基础
- `constrained-optimization.md` — 约束优化方法
- `riemannian-optimization.md` — 黎曼优化
- `proximal-method.md` — 近端方法

## 扩展概念
当核心锚点不够时，以下概念可能需要临时激活：
- ADMM：交替方向乘子法，适用于分裂结构
- mirror descent：镜像下降，适用于非欧几何
- Frank-Wolfe：条件梯度法，适用于稀疏约束
- stochastic optimization（SGD / SAdam convergence）：随机优化的收敛理论
- second-order methods（Newton / quasi-Newton）：二阶与拟牛顿方法
- trust region：信赖域方法
- line search：线搜索策略与收敛保证
- gradient clipping theory：梯度裁剪的理论分析
- sharpness-aware minimization (SAM)：尖锐度感知最小化
- neural tangent kernel optimization landscape：NTK 下的优化景观
- implicit regularization：隐式正则化效应
- bilevel optimization：双层优化与超参数优化
- minimax optimization：极小极大优化理论
- meta-learning optimization：元学习的优化框架

## 参考书方向
- `../../references/books/optimization-ml.md`：机器学习优化的全面覆盖，包括凸优化、随机方法和二阶方法

## AI 翻译方向
- lagrangian duality → primal-dual training / adversarial loss / constrained generation
- convex optimization → convex regularizers / proximal updates / mirror descent optimizer
- constrained optimization → projected gradient / penalty loss / barrier methods in training
- riemannian optimization → manifold-constrained parameters / natural gradient / geodesic update
- proximal method → sparse regularization / ISTA/FISTA layers / proximal neural networks

## 临时激活规则
当问题需要的数学不在核心锚点中时：
1. 先检查扩展概念中是否有匹配
2. 若有，根据透镜生成临时知识卡
3. 若无，进入 Knowledge Gap Protocol
