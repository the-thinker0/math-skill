# Eval: Knowledge Gap Protocol

These prompts require mathematics not fully covered by the existing anchors. The response should perform the Knowledge Gap Protocol internally and expose only the parts needed to make the proposed result auditable.

## Test Cases

1. "用 tropical geometry 的分段线性门控替代 top-k，怎么做？"（tropical semiring 不在 knowledge-base）
2. "Optimal transport 的多边际版本怎么用到 multi-task routing？"（multi-marginal OT 无锚点）
3. "用 persistent sheaf theory 做模型诊断，理论依据是什么？"（sheaf 持续同调无独立锚点，虽有 sheaf-cohomology 锚点）
4. "How to use rough paths theory for sequence modeling with long-range structure?"（rough paths 无锚点）
5. "用量子纠缠的数学结构定义特征间的相关性，有道理吗？"（量子信息结构无锚点）
6. "用 free probability theory 分析大随机矩阵的特征值分布，能迁移到模型权重分析吗？"（free probability 无锚点）

## Expected Behavior

For each prompt, the activator should cover the following six decisions. Fixed headings and route narration are not required.

1. **缺口识别 (Gap Identification)**: State the missing mathematical object or theorem family and classify the gap when that fact helps calibrate the answer.
   - e.g., for test 1: "tropical geometry is not in knowledge-base/; this is a new domain gap"
   - e.g., for test 3: "sheaf-cohomology.md exists but does not cover persistent variants; this is a combinatorial extension gap"

2. **透镜回退 (Lens Fallback)**: Use 1–2 relevant lenses internally; name them only if doing so explains a consequential choice.
   - e.g., for test 1: algorithmic analysis (does the proposed operation preserve Top-K's selection semantics?) + algebraic analysis (which semiring operation is actually intended?)
   - e.g., for test 4: local-to-global lens (rough paths as local-to-global structure for sequences)

3. **候选知识定位 (Candidate Knowledge Localization)**: Provide mathematical keywords, theorem families, concept clusters, and reference book directions.
   - e.g., for test 4: "rough paths theory, signature transform, iterated integrals, Lyons' extension theorem"

4. **临时知识卡 (Temporary Knowledge Card)**: Generate the smallest sufficient card rather than copying the full formal-card template:
   - Minimal definition
   - Core structure
   - Applicable problems
   - AI design translation only for design tasks
   - Implementation/GPU feasibility only when it affects the decision
   - Risks and failure conditions
   - **Source & Confidence (required)**:
     - Knowledge source: label as "Agent inference / Lens derivation / Reference extrapolation / Requires external verification"
     - Confidence: High (theorem-backed) / Medium (reasonable inference, not rigorously proven) / Low (exploratory hypothesis)
     - Unverified claims: list key conclusions requiring subsequent verification

5. **设计翻译 (Design Translation)**: If the goal is mechanism design, translate the temporary knowledge into candidate AI modules, losses, routing, attention, representation, or compression schemes.

6. **升级建议 (Upgrade Recommendation)**: Recommend a permanent card only if the gap is recurring; always tag the temporary card's domain (AI / crypto / shared).

## Key Assertions

- The six decisions are covered without requiring six visible headers
- Gap identification is specific (not generic "this is a new area")
- Lens selection is minimal and is exposed only when decision-relevant
- Candidate knowledge localization provides concrete theorem families (not vague directions)
- Temporary card has the required Source & Confidence fields (not missing)
- Confidence level is calibrated (High only if theorem-backed; Medium/Low for exploratory cases)
- Unverified claims are explicitly listed
- Domain, source/confidence, and unverified claims are present; upgrade advice is conditional on recurrence
