# 加密安全层级：CPA、CCA 与 AE

## 最小定义

- **IND-CPA**：敌手可获得加密 oracle，并不能区分两条等长消息的挑战密文。
- **IND-CCA1**：挑战前可查询解密 oracle，挑战后不可。
- **IND-CCA2**：挑战前后均可查询解密 oracle，但禁止提交挑战密文本身（及定义规定的等价变体）。
- **INT-CTXT**：敌手不能产生未由加密 oracle 返回过、但能通过解密验证的新密文。
- **认证加密（AE）**：同时提供机密性与密文完整性。常见形式化采用 IND-CPA + INT-CTXT，并可推出相应的 CCA 机密性；不同文献的 AE/AEAD 游戏需对齐。

这是常用层级，不表示 IND-CCA2 是所有协议场景中“最强可能”的安全定义。

## 核心公式

- IND 优势按采用的 convention 写为 $|\Pr[b'=b]-1/2|$ 或其两倍。
- 典型蕴含：IND-CCA2 $\Rightarrow$ IND-CCA1 $\Rightarrow$ IND-CPA；逆向一般不成立。
- 在独立密钥和合适原语假设下，Encrypt-then-MAC（EtM）是构造 AE 的通用方法。
- MAC-then-Encrypt 和 Encrypt-and-MAC **不是无条件不安全**；它们缺少与 EtM 同样宽泛的通用合成定理，具体安全性取决于加密/MAC、编码、错误处理和泄露模型。
- 对有限消息空间的完美保密，密钥空间/熵必须足以覆盖消息不确定性；常见均匀有限情形给出 $|\mathcal K|\ge|\mathcal M|$。这不是计算安全方案的一般密钥长度公式。

## 适用问题

- 为加密、KEM-DEM、记录层或存储协议选择机密性与完整性目标。
- 检查解密 oracle、错误信息和重放接口是否升级了敌手能力。
- 审查 EtM/AEAD 的 key separation、nonce 和 associated data 绑定。
- 判断论文声称的 CPA/CCA/AE 是否与实际 API 一致。

## 密码学构造与跨域边界

- CPA/CCA 描述的是加密 oracle 能力，不等同于 ML 的黑盒/白盒/梯度访问层级。
- “输出正确”“不可伪造”“保密”是不同性质；可验证推理若需要密码学保证，应分别定义 soundness、zero knowledge/privacy 和 authentication，而不是统称 AE。
- EtM 的经验不能按“先校验后推理/先推理后校验”的文字顺序直接迁移到任意 ML pipeline；必须先定义被认证的字节串、解析行为与失败侧信道。

## 实现注意事项

- 优先使用标准 AEAD API，保证 nonce 按方案要求唯一或随机，并把协议上下文绑定为 associated data。
- 独立派生加密与认证密钥；验证 tag 后再释放明文，错误路径保持统一。
- CCA 安全不自动解决重放、流量分析、端点泄露或侧信道，需要协议层机制。

## 风险与失效条件

- **把蕴含当等价**：IND-CPA 不能推出 IND-CCA；机密性也不能推出完整性。
- **无条件评价组合顺序**：MtE/EaM 的结论依赖具体构造，不能只按缩写判安全或不安全。
- **nonce/密钥复用**：很多 AEAD 在 nonce 重复时同时失去机密性和完整性。
- **解密错误侧信道**：padding/tag/解析错误差异可形成 oracle。
- **完美保密类比误用**：$|\mathcal K|\ge|\mathcal M|$ 不能映射成“训练数据量 ≥ 模型参数量”。

## 深入参考

- `../../references/books/applied-cryptography.md`
- `../../references/books/introduction-to-modern-cryptography.md`

## 路由扩展

- 攻击游戏：`attack-game-framework.md`
- 归约：`reduction-proof-template.md`
- PRF：`prf-prg-owf.md`
