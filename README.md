# CarbonTrader Smart Contract

[Solidity](https://img.shields.io/badge/Solidity-^0.8.12-blue.svg) [License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

## Overview

CarbonTrader is a Solidity smart contract designed for managing and trading carbon allowances (also referred to as carbon credits or points). It provides functionality for:

- **Allowance Management**: Issuing, querying, freezing, unfreezing, and destroying carbon allowances. Only the contract owner (administrator) can perform restricted actions like issuing or freezing.
- **Trading System**: Users can create trades (auctions) for selling allowances, place deposits (bids), refund deposits, set bid information (encrypted), and finalize auctions by transferring allowances and payments.
- **Security Features**: Uses ERC20 tokens for payments, with mappings for allowances, frozen allowances, and trade-specific data. Includes error handling for invalid operations.

This contract is suitable for decentralized carbon trading platforms, ensuring secure and transparent transactions. It integrates with an external ERC20 token for monetary exchanges.

**Note**: This contract assumes an existing ERC20 token for payments (passed in the constructor). It does not handle native ETH transfers.

## Features

- **Owner-Only Controls**: Secure administration for allowance issuance and management.
- **Trade Creation and Management**: Sellers can create trades with frozen allowances; buyers can deposit bids and finalize purchases.
- **Encrypted Bid Information**: Supports storing encrypted buyer info and decryption keys for privacy.
- **Event Emissions**: Emits events for new trades to enable off-chain tracking.
- **Error Handling**: Custom errors for common failure cases like insufficient deposits or invalid parameters.

## Prerequisites

- Solidity compiler version ^0.8.12.
- OpenZeppelin Contracts library (for IERC20 interface).
- An existing ERC20 token contract for payments.

## Installation

1. Clone the repository:

    text

    ```
    git clone https://github.com/ShaoyeLi/CarbonTrader.git
    cd src
    ```

2. Install dependencies (if using a framework like Hardhat or Foundry):

    - For Hardhat: npm install @openzeppelin/contracts
    - For Foundry: Use the provided libraries.

3. Compile the contract:

    - Using solc: solc --bin CarbonTrader.sol

## Deployment





## Usage

### Allowance Management (Owner Only)

- Issue allowances: issueAllowance(userAddress, amount)
- Get allowance: getAllowance(userAddress)
- Freeze allowances: freezeAllowance(userAddress, amount)
- Unfreeze allowances: unfreezeAllowance(userAddress, amount)
- Get frozen allowance: getFrozenAllowance(userAddress)
- Destroy allowances: destroyAllowance(userAddress, amount) or destroyAllAllowance(userAddress)

### Trading

- Create a trade: createTrade(tradeId, amount, startAmount, pricePerUnit, startTime, endTime)
    - Emits NewTrade event.
- Get trade details: getTrade(tradeId)
- Deposit bid: deposit(tradeId, amount, encryptedInfo)
- Get deposit: getDeposit(tradeId)
- Refund deposit: refund(tradeId)
- Set bid info: setBidInfo(tradeId, info)
- Set decryption key: setBidKey(tradeId, key)
- Get bid info: getBidInfo(tradeId)
- Finalize auction: finalizeAuctionAndTransferCarbon(tradeId, allowanceAmount, additionalPayment)
- Withdraw proceeds (seller): withdrawAuctionAmount()

**Important Notes**:

- Buyers must approve the contract for ERC20 transfers before depositing or finalizing.
- Trades use unique string IDs; ensure uniqueness to avoid overwrites.
- Allowances are frozen during trades and transferred upon finalization.

## Security Considerations

- **Audits**: This contract has not been audited. Use at your own risk and consider professional audits for production.
- **Access Control**: Relies on onlyOwner modifier; consider adding multi-sig or role-based access for real-world use.
- **Reentrancy**: Uses simple transfers; add reentrancy guards if extending functionality.
- **Gas Optimization**: Mappings and structs are efficient, but deep mappings may increase gas costs.

## Testing

- Use frameworks  Foundry to write unit tests.

## Contributing

Contributions are welcome! Please fork the repo and submit a pull request.

1. Fork the repository.
2. Create a new branch (git checkout -b feature-branch).
3. Commit your changes (git commit -am 'Add new feature').
4. Push to the branch (git push origin feature-branch).
5. Create a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.





## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
