# 李理论 激活索引 / Lie Theory Activation Index

## 领域信号
当问题涉及以下信号时，激活本领域方向：
- 对称性/等变性：模型需要对群变换保持等变或不变
- 群参数化：需要参数化连续对称群（旋转、刚体运动等）
- 旋转/刚体运动：涉及 SO(3)、SE(3) 等具体李群
- 守恒律：对称性与守恒量的对应关系
- 群表示：需要将群作用线性化以设计网络结构
- 轨道结构：需要分析群作用的轨道与稳定子

## 核心锚点
- `group-action.md` — 群作用
- `lie-group.md` — 李群
- `lie-algebra.md` — 李代数
- `representation.md` — 群表示
- `equivariance.md` — 等变性

## 扩展概念
当核心锚点不够时，以下概念可能需要临时激活：
- Lie bracket：Lie 括号与对易关系
- adjoint representation：伴随表示与结构常数
- coadjoint orbit：余伴随轨道与辛结构
- symplectic structure：辛形式与辛流形
- momentum map：动量映射与守恒量
- geometric quantization：几何量子化
- representation ring：表示环与张量积分解
- character theory：特征标理论
- Weyl group：Weyl 群与根系
- root system：根系与 Dynkin 图
- Dynkin diagram：Dynkin 图与分类
- highest weight classification：最高权分类
- Peter-Weyl theorem：Peter-Weyl 定理与调和分析
- harmonic analysis on groups：群上的调和分析
- automorphic forms：自守形式

## 参考书方向
- `../../references/books/micro-lie-theory.md`：李群与李代数的核心内容
- `../../references/books/abstract-algebra.md`：抽象代数基础，群论部分

## 临时激活规则
当问题需要的数学不在核心锚点中时：
1. 先检查扩展概念中是否有匹配
2. 若有，根据透镜生成临时知识卡
3. 若无，进入 Knowledge Gap Protocol
