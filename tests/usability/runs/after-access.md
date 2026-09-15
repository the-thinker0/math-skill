这是执行代理对实际资源读取的自报记录，不是可信运行时 trace。任务期间未读取 `.usability-study/` 中的 baseline、其他代理答案、快照或审计报告；仅写入指定 after 文件和 after-probe 产物。下面列出读过正文的 skill 资源，不把仅由 `rg --files` 看见的文件名算作正文读取。

| 实际读取的资源绝对路径 | 服务请求及用途 |
|---|---|
| `/home/yinshuheng/code/math-skill/SKILL.md` | 请求 1、2；指定入口 |
| `/home/yinshuheng/code/math-skill/references/design-workbench.md` | 请求 1、2；从信息可见性、可保持量和定理条件构造方案 |
| `/home/yinshuheng/code/math-skill/references/construction-moves.md` | 请求 1 的误差传播/序贯决策，请求 2 的输入驱动不动点；工具按完整文件读取 |
| `/home/yinshuheng/code/math-skill/knowledge-base/matrix-analysis/matrix-perturbation.md` | 请求 1；区分局部扰动和后续输出影响，评估全局范数界是否适用 |
| `/home/yinshuheng/code/math-skill/knowledge-base/optimization/proximal-method.md` | 请求 2；比较带约束迭代构造；最终采用可直接强制收缩的映射，未采用 prox 算法 |
| `/home/yinshuheng/code/math-skill/references/agentic-workflow.md` | 请求 2；准备实际训练、收敛与失效对照，并据检查结果保留约束 |
| `/home/yinshuheng/code/math-skill/design-patterns/routing/moe-routing.md` | 请求 1；候选形成后对照普通路由的前向、梯度和成本，确认需通过消融检验增量 |

另外仅列举了 `knowledge-base/`、`design-patterns/`、`lenses/` 下的文件名以定位相关资源；没有据此读取其全部正文，没有读取 books、密码资源、英文兼容入口或其他已安装 skill。

网络一手来源：请求 1 实际查看了 CALM（arXiv 2207.07061）、Mixture-of-Depths（arXiv 2404.02258）、ADEPT（arXiv 2601.03700）的原作者条目/摘要；另查看 MIT 6.231 Lecture 5 资源页面，最终未使用最优停止递推作为主算法。请求 2 查看了 NeurIPS 2019 Deep Equilibrium Models 原论文 PDF，并定位隐式梯度相关段落。CALM 的一次 HTML `v4` 访问返回 404，随后使用成功获取的 arXiv 条目，不把失败访问当作已阅读正文。搜索结果里的第三方综述、博客和论坛没有作为推导或结论依据。

实际执行了 `after-probe/verify_iteration.py` 与 `after-probe/verify_skip_budget.py`。第一份含真实 CPU 小规模参数训练、收敛与停止检查、解析解对照和失效对照；第二份仅为局部误差与输出放大的解析诊断。没有执行 Transformer 训练、实际大模型 decode 或 GPU 测速。
