# Eval: Knowledge Gap Protocol

These prompts require mathematics NOT in the existing knowledge-base/, triggering the 6-step Knowledge Gap Protocol: gap identification → lens fallback → candidate localization → temporary card → design translation → upgrade recommendation.

## Test Cases

1. "用 tropical geometry 的分段线性门控替代 top-k，怎么做？"（tropical semiring 不在 knowledge-base）
2. "Optimal transport 的多边际版本怎么用到 multi-task routing？"（multi-marginal OT 无锚点）
3. "用 persistent sheaf theory 做模型诊断，理论依据是什么？"（sheaf 持续同调无独立锚点，虽有 sheaf-cohomology 锚点）
4. "How to use rough paths theory for sequence modeling with long-range structure?"（rough paths 无锚点）
5. "用量子纠缠的数学结构定义特征间的相关性，有道理吗？"（量子信息结构无锚点）
6. "用 free probability theory 分析大随机矩阵的特征值分布，能迁移到模型权重分析吗？"（free probability 无锚点）

## Expected Behavior

For each prompt, the activator MUST execute the 6-step Knowledge Gap Protocol:

1. **缺口识别 (Gap Identification)**: Explicitly state that no fully corresponding knowledge card exists. Classify the gap as: new domain / new theorem family / new structure / new application scenario / combinatorial extension.
   - e.g., for test 1: "tropical geometry is not in knowledge-base/; this is a new domain gap"
   - e.g., for test 3: "sheaf-cohomology.md exists but does not cover persistent variants; this is a combinatorial extension gap"

2. **透镜回退 (Lens Fallback)**: Select 1-3 most relevant thinking lenses to determine the problem's mathematical structure.
   - e.g., for test 1: algorithmic lens (tropical semiring as piecewise-linear alternative to Top-K) + algebraic lens (semiring structure)
   - e.g., for test 4: local-to-global lens (rough paths as local-to-global structure for sequences)

3. **候选知识定位 (Candidate Knowledge Localization)**: Provide mathematical keywords, theorem families, concept clusters, and reference book directions.
   - e.g., for test 4: "rough paths theory, signature transform, iterated integrals, Lyons' extension theorem"

4. **临时知识卡 (Temporary Knowledge Card)**: Generate in the same format as formal cards:
   - Minimal definition
   - Core structure
   - Applicable problems
   - AI design translation
   - GPU feasibility
   - Risks and failure conditions
   - **Source & Confidence (required)**:
     - Knowledge source: label as "Agent inference / Lens derivation / Reference extrapolation / Requires external verification"
     - Confidence: High (theorem-backed) / Medium (reasonable inference, not rigorously proven) / Low (exploratory hypothesis)
     - Unverified claims: list key conclusions requiring subsequent verification

5. **设计翻译 (Design Translation)**: If the goal is mechanism design, translate the temporary knowledge into candidate AI modules, losses, routing, attention, representation, or compression schemes.

6. **升级建议 (Upgrade Recommendation)**: If this gap recurs frequently, recommend adding a formal knowledge card or design pattern. Tag the temporary card's domain (AI / crypto / shared) for subsequent upgrade.

## Key Assertions

- All 6 steps are executed in order, with explicit headers
- Gap identification is specific (not generic "this is a new area")
- Lens fallback selects relevant lenses with reasons
- Candidate knowledge localization provides concrete theorem families (not vague directions)
- Temporary card has the required Source & Confidence fields (not missing)
- Confidence level is calibrated (High only if theorem-backed; Medium/Low for exploratory cases)
- Unverified claims are explicitly listed
- Domain tag is present for subsequent upgrade tracking
