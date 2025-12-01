# CarbonTrader 智能合约

[Solidity](https://img.shields.io/badge/Solidity-^0.8.12-blue.svg) [License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

## 概述

CarbonTrader 是一个 Solidity 智能合约，用于管理和交易碳配额（也称为碳积分或碳信用）。它提供了以下功能：

- **配额管理**：发行、查询、冻结、解冻和销毁碳配额。只有合约所有者（管理员）可以执行发行或冻结等受限操作。
- **交易系统**：用户可以创建碳配额的交易（拍卖），放置押金（竞标），退还押金，设置竞标信息（加密），并通过转移配额和支付来完成拍卖。
- **安全特性**：使用 ERC20 代币进行支付，包括配额、冻结配额和交易特定数据的映射。包含针对无效操作的错误处理。

此合约适用于去中心化碳交易平台，确保交易的安全性和透明度。它与外部 ERC20 代币集成，用于货币交换。

**注意**：此合约假设存在一个用于支付的 ERC20 代币（在构造函数中传入）。它不处理原生 ETH 转账。

## 特性

- **仅所有者控制**：对配额发行和管理的安全管理。
- **交易创建和管理**：卖家可以创建带有冻结配额的交易；买家可以放置竞标并完成购买。
- **加密竞标信息**：支持存储加密的买家信息和解密密钥，以保护隐私。
- **事件发射**：发射新交易事件，以启用链下跟踪。
- **错误处理**：针对常见故障情况（如押金不足或无效参数）的自定义错误。

## 先决条件

- Solidity 编译器版本 ^0.8.12。
- OpenZeppelin Contracts 库（用于 IERC20 接口）。
- 一个现有的 ERC20 代币合约，用于支付。

## 安装

1. 克隆仓库：

    text

    ```
    git clone https://github.com/ShaoyeLi/CarbonTrader.git
    cd src
    ```

2. 安装依赖项（使用 Foundry 框架）：

    - 对于 Foundry：使用提供的库。

3. 编译合约：

    - 使用 forge build

## 部署





## 使用方法

### 配额管理（仅所有者）

- 发行配额：issueAllowance(userAddress, amount)
- 获取配额：getAllowance(userAddress)
- 冻结配额：freezeAllowance(userAddress, amount)
- 解冻配额：unfreezeAllowance(userAddress, amount)
- 获取冻结配额：getFrozenAllowance(userAddress)
- 销毁配额：destroyAllowance(userAddress, amount) 或 destroyAllAllowance(userAddress)

### 交易

- 创建交易：createTrade(tradeId, amount, startAmount, pricePerUnit, startTime, endTime)
    - 发射 NewTrade 事件。
- 获取交易详情：getTrade(tradeId)
- 放置押金：deposit(tradeId, amount, encryptedInfo)
- 获取押金：getDeposit(tradeId)
- 退还押金：refund(tradeId)
- 设置竞标信息：setBidInfo(tradeId, info)
- 设置解密密钥：setBidKey(tradeId, key)
- 获取竞标信息：getBidInfo(tradeId)
- 完成拍卖：finalizeAuctionAndTransferCarbon(tradeId, allowanceAmount, additionalPayment)
- 提取收益（卖家）：withdrawAuctionAmount()

**重要注意事项**：

- 买家必须在放置押金或完成前批准合约进行 ERC20 转账。
- 交易使用唯一的字符串 ID；确保唯一性以避免覆盖。
- 在交易期间配额被冻结，并在完成时转移。

## 安全考虑

- **审计**：此合约尚未经过审计。请自行承担风险，并在生产环境中考虑专业审计。
- **访问控制**：依赖 onlyOwner 修饰符；考虑为实际使用添加多重签名或基于角色的访问。
- **重入攻击**：使用简单的转账；如果扩展功能，请添加重入防护。
- **Gas 优化**：映射和结构高效，但深度映射可能会增加 Gas 成本。

## 测试

- 使用 Hardhat 或 Foundry 等框架编写单元测试。
- 关键场景：配额发行/冻结、交易创建/完成、押金/退还流程、错误情况。

使用 Hardhat 的示例测试设置：

JavaScript

```
describe("CarbonTrader", function () {
  it("Should issue allowances", async function () {
    // 测试逻辑在这里
  });
});
```

## 贡献

欢迎贡献！请 fork 仓库并提交拉取请求。

1. Fork 仓库。
2. 创建新分支（git checkout -b feature-branch）。
3. 提交更改（git commit -am '添加新功能'）。
4. 推送到分支（git push origin feature-branch）。
5. 创建拉取请求。

## 许可

此项目根据 MIT 许可协议授权 - 详情请参阅 LICENSE 文件。