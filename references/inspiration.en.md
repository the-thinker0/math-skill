# Inspiration

> Mathematics is more than a computational tool — it is a way of thinking. This file records the technical inspiration of math-skill — the cross-domain activation value of mathematical tools far exceeding their original intent. For philosophical and life reflections (split in v3.2.1), see `musings.en.md`.

---

## 1. The Dragon-Slaying Blade: The Origin of Lie Groups and Lie Algebras

I still remember reading a Zhihu answer while pondering the question "How to understand that the original motivation of Lie groups and Lie algebras was to solve differential equations?" — one response left an indelible impression on me [Source: https://www.zhihu.com/question/356243536/answer/1992290356713259459].

Sophus Lie was a blacksmith who wanted to forge a **dragon-slaying blade** — a universal method for solving all differential equations.

Although the final blade could not slay every dragon, the craft of its forging — the correspondence between Lie groups and Lie algebras — has been passed down through generations. Later researchers discovered that while this blade cannot cut through every differential equation, it serves as a divine instrument for **chopping vegetables** (linearizing nonlinear problems), for **sculpting** (describing physical symmetries), and for **building houses** (robot state estimation).

So, when you stare at a screen full of `se(3)` and exponential map notation and feel dizzy, do not forget that all of this began with a single Norwegian mathematician wondering: what miracles would unfold if you took Galois's game of permuting roots and extended it to the infinitesimal?

**This is what makes mathematics most enchanting.**

A tool invented to solve a specific problem ultimately reveals value far beyond its original intent in entirely different domains. Axiomatic thinking was initially developed to make geometry rigorous, yet it became the foundational language of every mathematical discipline. The Fourier transform was originally devised to solve the heat equation, yet it became central to signal processing and quantum mechanics. Euler's generating functions were initially created to count integer partitions, yet they became universal tools in combinatorics and probability theory.

Mathematical thinking works the same way — you may learn it to review a paper or solve a specific problem, but its true value lies in how it transforms the way you see the world.

---

## Connection to This Project

The inspiration for this project stems precisely from this insight:

**The value of mathematical tools far exceeds their original intent** — Sophus Lie's dragon-slaying blade story teaches us that a tool invented for solving differential equations ultimately became the universal language for describing symmetry. This is the core idea behind math-skill's "thinking lenses" and "activation anchors": every mathematical concept carries transferable value far beyond its original application domain. The skill's job is to guide the activation of such cross-domain transfer, not to fixate on specific application scenarios.

> After the v3.2.1 design philosophy refinement, this idea is made explicit: knowledge-base/ anchors describe mathematical structures themselves (manifolds, spectra, sheaf cohomology, etc.), not specific AI architectures; design-patterns/ is translation-prototype demonstration, not a template library. This is exactly what the "dragon-slaying blade" story reflects in the skill's positioning — **the true value of a tool lies in cross-domain activation, not in being fixated on a single application**.

> The philosophical and life reflection part ("Life as an Optimization Problem," etc.) has been moved to `musings.en.md`, separated from the skill's rigorous technical core.

---

> **The "Life as an Optimization Problem" section below has been moved to `musings.en.md`.** For philosophical reflections, see `musings.en.md`.
