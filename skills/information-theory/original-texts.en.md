# Mathematical Sources and Classic Texts

## Shannon's Information Theory (1948)

> H(X) = -Sum p(x) log p(x) -- Entropy, the average uncertainty of an information source
> I(X;Y) = H(X) - H(X|Y) -- Mutual information, the information contribution of observing Y about X
> C = max_{p(x)} I(X;Y) -- Channel capacity, the upper bound on the rate of reliable communication
>
> Source coding theorem: optimal compression >= H(X) bits/symbol
> Channel coding theorem: when R < C, there exists a coding scheme that drives the error rate to zero

**Meaning**: Information can be precisely quantified; there exist insurmountable mathematical limits on compression and communication, not merely limits imposed by the current state of engineering. Entropy measures "average surprise" -- low-probability events carry more information when they occur. Mutual information measures "reduction in uncertainty" -- how much observing Y reduces our uncertainty about X.

**Mathematical background**: Claude Shannon founded information theory in "A Mathematical Theory of Communication" (1948). Core contributions: (1) Defined entropy H(X) = -Sum p(x) log p(x), where the choice of logarithm base determines the unit (base 2 -> bits, base e -> nats); (2) The source coding theorem proves that the average length L of an optimal prefix code satisfies L >= H(X), with equality if and only if all probabilities are powers of 2; (3) The channel coding theorem proves that when R < C there exist coding sequences such that P(error) -> 0, while for R > C, P(error) > 0 is unavoidable. Shannon's proofs use random coding arguments -- constructing a random codebook and then showing that the error rate of a "typical" code approaches zero, thereby establishing the existence of at least one such code.

## Huffman Coding (1952)

> Greedy construction of optimal prefix codes: repeatedly merge the two symbols with the smallest probabilities, building the tree bottom-up.
> Average code length L(Huffman) <= H(X) + 1; when probabilities are powers of 2, L = H(X).

**Meaning**: An optimal prefix code (unambiguously decodable) can be constructed exactly via a greedy algorithm, with average length approaching the entropy bound.

**Mathematical background**: David Huffman published this algorithm in 1952 as an MIT student, proving its optimality. Huffman coding is a variable-length prefix code -- more frequent symbols receive shorter codewords, and the prefix condition guarantees that no codeword is a prefix of another, enabling instantaneous decoding. When symbol probabilities are not all powers of 2, the average length of Huffman coding is strictly greater than H(X); arithmetic coding encodes an entire message as an interval and can approach the entropy bound more closely.

## Hamming Codes (1950)

> [7,4] Hamming code: 4 information bits + 3 parity bits = 7-bit codeword, minimum Hamming distance d_min = 3
> Can correct 1-bit errors or detect 2-bit errors
> General [2^r - 1, 2^r - 1 - r] Hamming code: r parity bits, minimum distance 3

**Meaning**: The first systematic construction of error-correcting codes -- a small amount of redundancy can protect information from corruption by noise.

**Mathematical background**: Richard Hamming, working at Bell Labs, designed the first systematic error-correcting code after hardware errors in early computers caused his programs to crash. Hamming distance d(x,y) = the number of positions at which two binary strings differ; a minimum distance d_min >= 2t+1 allows correction of t-bit errors. Hamming codes are perfect codes -- the sphere packing exactly fills the entire space. Subsequent developments: Reed-Solomon codes (1960) for burst error correction and CD/DVD; LDPC codes (Gallager 1962) and Turbo codes (1993) approach the Shannon limit.

## Kolmogorov Complexity (1965)

> K(x) = the length of the shortest program that outputs x (on a universal Turing machine)
> Kolmogorov complexity is an algorithmic measure of information -- complementary to Shannon entropy
>
> Uncomputability: K(x) is not computable in general (Chaitin's incompleteness theorem)

**Meaning**: The shortest program description length is the intrinsic information content of an object -- a more fundamental measure of information than Shannon entropy, independent of any probability distribution.

**Mathematical background**: Andrey Kolmogorov proposed algorithmic information theory in 1965, defining K(x) as the length |p| of the shortest program p that outputs x on a universal Turing machine U: K_U(x) = min{|p| : U(p) = x}. Key properties: (1) Uncomputability -- no algorithm can compute K(x) in general; (2) Invariance theorem -- the values of K_U(x) on different universal Turing machines differ by at most a constant c (depending on the choice of machine); (3) Relation to entropy -- for i.i.d. sequences, E[K(x)] is approximately nH(X) (the algorithmic analogue of Shannon entropy); (4) Chaitin's incompleteness theorem -- a formal system cannot prove K(x) > c for most x. Kolmogorov complexity is the theoretical foundation of the MDL principle.

## KL Divergence (Kullback-Leibler, 1951)

> D(P||Q) = Sum p(x) log(p(x)/q(x)) = E_P[log(p(X)/q(X))]
>
> D(P||Q) >= 0, with equality if and only if P = Q
> D(P||Q) is not equal to D(Q||P) -- it is asymmetric
> D(P||Q) is not a distance (asymmetric, does not satisfy the triangle inequality)

**Meaning**: KL divergence measures "the number of extra bits needed to encode data from distribution P using distribution Q" -- a one-directional measure of information loss.

**Mathematical background**: Solomon Kullback and Richard Leibler proposed relative entropy in 1951, defined as D(P||Q) = Sum p(x) log(p(x)/q(x)). Core properties: (1) Non-negativity D(P||Q) >= 0 (proved via Gibbs' inequality); (2) Asymmetry D(P||Q) is not equal to D(Q||P) -- the interpretation of D(P||Q) is "the expected extra length of encoding data from P using Q," and the direction cannot be interchanged; (3) Relation to mutual information: I(X;Y) = D(p(x,y)||p(x)p(y)) -- mutual information is the KL divergence between the joint distribution and the product of the marginals; (4) Relation to entropy: H(P) + D(P||Q) = Sum p(x)(-log q(x)) -- cross-entropy equals entropy plus KL divergence. The cross-entropy loss function is central to deep learning: minimizing H(P) + D(P||Q) = minimizing Sum p(x)(-log q(x)).

## Rate-Distortion Theory (Shannon, 1959)

> R(D) = min_{p(z|x): E[d(x,z)] <= D} I(X;Z)
>
> The minimum rate R(D) required under an allowed distortion D
> R(0) = H(X) (lossless compression), R(D_max) = 0 (maximum allowable distortion)

**Meaning**: Lossy compression has a fundamental limit given by the rate-distortion function R(D) -- lower rates require accepting greater distortion.

**Mathematical background**: Shannon extended the source coding theorem to lossy compression in 1959. The rate-distortion function R(D) is defined as the minimum of mutual information I(X;Z) subject to the constraint that expected distortion E[d(x,z)] <= D. The distortion measure d(x,z) can be Hamming distortion (binary), squared error (continuous), etc. R(D) is monotonically decreasing and convex -- greater tolerance for distortion yields lower required rate. The inverse function D(R) gives the minimum achievable distortion at a given rate. Practical applications: JPEG/MPEG compression, speech coding, and related technologies follow this theoretical framework.

## Fisher Information (1925)

> I(theta) = E[(d log f(X;theta)/d theta)^2] = -E[d^2 log f(X;theta)/d theta^2]
>
> Cramer-Rao lower bound: Var(theta_hat) >= 1/I(theta), for any unbiased estimator theta_hat
> Fisher information measures the information content of data about parameter theta

**Meaning**: Fisher information is the information-theoretic measure in statistical inference -- it connects information theory to the theoretical limits of parameter estimation.

**Mathematical background**: R.A. Fisher proposed the concept of information content I(theta) in 1925, measuring the discriminative power of a single observation with respect to parameter theta. Cramer (1946) and Rao (1945) independently proved the Cramer-Rao lower bound Var(theta_hat) >= 1/(nI(theta)). Key connections: (1) Fisher information and KL divergence -- I(theta) = lim_{theta' -> theta} 2D(f(x;theta)||f(x;theta'))/(theta - theta')^2, the local second-order approximation of KL divergence; (2) Fisher information and Bayesian information -- the Jeffreys prior p(theta) proportional to |I(theta)|^(1/2) makes the volume uniform under the Fisher information metric in parameter space; (3) Large-sample properties of maximum likelihood estimation -- theta_hat_MLE is asymptotically normal N(theta, 1/(nI(theta))), achieving the Cramer-Rao lower bound. Fisher information is the bridge between information theory and statistical inference.

## MDL Principle (Rissanen, 1978)

> MDL(M, D) = L(D|M) + L(M)
>
> Choose the model that minimizes "description length of data given the model + description length of the model itself"
> L(D|M) = -log P(D|M) (negative log-likelihood of the data)
> L(M) = model encoding length (complexity penalty)

**Meaning**: MDL is the information-theoretic version of Occam's razor -- a good model is both accurate (short data description) and parsimonious (short model description).

**Mathematical background**: Jorma Rissanen proposed the Minimum Description Length principle in 1978, reducing model selection to a coding problem. Relationships between MDL and other criteria: (1) MDL and BIC -- two-part MDL (L(D|M) + L(M)) is asymptotically equivalent to BIC (-2 ln L + k ln(n)) for large samples; (2) MDL and Kolmogorov complexity -- ideal MDL uses Kolmogorov complexity K(M) to measure model complexity, but K(M) is uncomputable; practical MDL approximates it with parameter encoding length. Normalized MDL (1996) uses mixture coding to handle parameters, avoiding the arbitrary-precision problem. The central insight of MDL: model selection is fundamentally data compression -- the best model is the one that compresses the data best.

## Mutual Information and Channel Capacity

> I(X;Y) = H(X) - H(X|Y) = H(Y) - H(Y|X) = H(X) + H(Y) - H(X,Y)
>
> Symmetry of mutual information: I(X;Y) = I(Y;X)
> Non-negativity of mutual information: I(X;Y) >= 0, with equality if and only if X and Y are independent
>
> Channel capacity C = max_{p(x)} I(X;Y)
> Typical set A_epsilon^n: {x^n : |-log p(x^n)/n - H(X)| < epsilon}

**Meaning**: Mutual information is a precise measure of the dependence between two random variables -- it is zero if and only if they are independent, and positive if statistical association exists. Channel capacity is the maximum of mutual information over all input distributions, defining the theoretical limit of reliable communication.

**Mathematical background**: Mutual information I(X;Y) = Sum p(x,y) log(p(x,y)/(p(x)p(y))) = D(p(x,y)||p(x)p(y)) -- the KL divergence between the joint distribution and the product of the marginals. The typical set is the key tool in Shannon's proofs of coding theorems: for an i.i.d. source X^n, typical sequences x^n satisfy |-1/n log p(x^n) - H(X)| < epsilon; the probability of the typical set approaches 1 (as n -> infinity), yet the size of the typical set is approximately 2^{nH(X)}, far smaller than the entire space 2^n (when H(X) < 1). This explains why compression to nH(X) bits suffices to cover nearly all valid sequences.

## Joint Entropy, Conditional Entropy, and Chain Rules

> H(X,Y) = H(X) + H(Y|X) -- Chain rule for joint entropy
> H(Y|X) = Sum p(x) H(Y|X=x) -- Conditional entropy
> I(X;Y) = H(X) - H(X|Y) = H(Y) - H(Y|X) -- Mutual information
> I(X;Y|Z) = H(X|Z) - H(X|Y,Z) -- Conditional mutual information
> Chain expansion of I(X1;X2;...;Xn): I(X;Y,Z) = I(X;Y) + I(X;Z|Y)

**Meaning**: The chain rule for entropy decomposes joint uncertainty into the contributions of individual variables -- enabling an understanding of the information structure of multivariate systems.

**Mathematical background**: Joint entropy H(X,Y) = -Sum p(x,y) log p(x,y) measures the total uncertainty of a pair of random variables. The chain rule H(X,Y) = H(X) + H(Y|X) states: once X is known, the additional uncertainty of Y is H(Y|X). Generalized to n variables: H(X1,...,Xn) = Sum_i H(Xi|X1,...,Xi-1). Conditional mutual information I(X;Y|Z) measures "the additional information that Y provides about X, given that Z is already known" -- a key tool in information bottleneck methods and causal inference. The chain expansion of multivariate mutual information: I(X;Y,Z) = I(X;Y) + I(X;Z|Y), showing that the joint information of Y and Z about X equals the direct information from Y plus the conditional information from Z.

## Everyday Insights from Information Theory and Coding Theory

> "The core of information theory is not about computing precise bit counts, but about cultivating the habit of mind that uncertainty is quantifiable, information has value, and fundamental limits cannot be transcended."

- Do not ignore uncertainty -- entropy H(X) quantifies it
- Information has direction and magnitude -- mutual information I(X;Y) measures it
- Compression has limits -- the source coding theorem defines them
- Communication has limits -- the channel coding theorem defines them
- Model selection has information-theoretic criteria -- AIC/BIC/MDL guide it
- There is an information-theoretic distance between probability distributions -- KL divergence measures it
