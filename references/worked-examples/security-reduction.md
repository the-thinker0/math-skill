# 案例：把 PRF 安全转成 MAC 伪造界

这是纯密码案例，配 [归约模板](../../knowledge-base/cryptography/reduction-proof-template.md)；不加载 AI 设计模式。

## 固定游戏

设 $F_k:\{0,1\}^m\to\{0,1\}^t$，$k$ 随安全参数生成，消息固定 $m$ 位。定义 $\operatorname{Tag}_k(x)=F_k(x)$。敌手可自适应查询 tag oracle，最后输出此前未查询消息 $x^*$ 及标签 $u^*$；当 $u^*=F_k(x^*)$ 时获胜。这里只分析一次最终 fresh-message 伪造，没有 verification oracle。

归约先拒绝非新鲜消息及格式非法的标签，再查询自己的 oracle 作检查。理想游戏成功概率**至多**为 $2^{-t}$；等号以敌手总输出合法新鲜消息和 $t$ 位标签为前提。

## 两步归约

1. 归约 $B$ 用自己的 oracle 回答敌手的所有 tag 查询；最后再查询 $x^*$，检查标签并输出是否成功。若敌手做至多 $q$ 次 tag 查询，$B$ 做至多 $q+1$ 次查询，运行时间包含敌手与模拟成本。
2. 把 $F_k$ 替换为同域同值域的均匀随机函数 $R$。由于 $x^*$ 新鲜，$R(x^*)$ 在已有 transcript 条件下仍均匀，故成功概率至多为 $2^{-t}$。

采用双实验差的 PRF 优势 convention，可得

$$\Pr[\mathrm{Forge}_F(A)]\le\operatorname{Adv}^{\mathrm{PRF}}_F(B)+2^{-t}.$$

这里没有必然的 $q$ 倍 hybrid 损失，也没有生日碰撞项；若换成 PRP、允许多次验证或改变新鲜性定义，必须重做游戏与界。

## 边界和失败对照

- 重放已查询的消息/标签不能计作此游戏的伪造，否则敌手一次查询后必胜。
- 密钥难恢复不足以证明不可伪造；例如公开常数标签函数无法恢复隐藏但未使用的密钥，却能直接伪造。
- 固定长度 PRF 不能直接处理任意变长消息；应选有对应证明的域扩展或 MAC 构造，不能未经分析截断/拼接。
- 归约未检查侧信道、密钥生成和实现错误；这些属于所部署实现与游戏之间的假设，不由该证明覆盖。

## 参数与核验

将 $q+1$ 查询、运行时间和标签长度代入具体原语界，再看总成功概率是否达标。$t$ 位标签本身不代表 $t$ 位端到端安全。对小 $t$ 可以穷举随机标签核对 $2^{-t}$ 猜测概率，但这不证明所选 PRF 安全。

依据：[Boneh–Shoup 作者教材](https://toc.cryptobook.us/)，Message integrity 相关章节。上式为这里明确的一次伪造游戏的直接归约。

## 可运行检查

下面的 JavaScript 可用 Node.js 18+ 运行；仓库中的 `node --test tests/math-examples.test.mjs` 会执行中英两个版本。有限检查只核对本例，不替代上面的论证。

```javascript
// Ideal random functions on two messages with two-bit tags.
// Query message 0, then forge fresh message 1. Exhaust all deterministic guesses
// based on the observed tag: four choices for each of four observations.
const tagCount = 4;
for (let strategy = 0; strategy < 4 ** 4; strategy++) {
  let wins = 0;
  for (let observed = 0; observed < tagCount; observed++) {
    const guess = (strategy >> (2 * observed)) & 3;
    for (let fresh = 0; fresh < tagCount; fresh++) {
      if (guess === fresh) wins++;
    }
  }
  if (wins / (tagCount ** 2) !== 2 ** -2) {
    throw new Error('Fresh-tag probability failed');
  }
}
// This finite ideal-game check is not a proof that any concrete PRF is secure.
```
