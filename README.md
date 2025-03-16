# Foundry Fund Me 💰  

A beginner-friendly smart contract project for learning **Solidity** and **Foundry**. This repository contains a **FundMe** contract that allows users to fund ETH to the contract, while the owner can withdraw the funds. It also includes deployment scripts and tests compatible across different networks.  

---

## 🚀 Features  
✅ Users can send ETH to the contract  
✅ Only the contract owner can withdraw funds  
✅ Uses **Chainlink Price Feeds** to enforce minimum funding amount  
✅ Deployment and testing scripts included (compatible with local & testnet environments)  
✅ Uses **Foundry** for smart contract development and testing  

---

## 🛠 Installation  

1. **Clone the Repository**  
```sh
git clone https://github.com/yourusername/foundry-fund-me.git
cd foundry-fund-me
```
2. Install Foundry (if not installed)
```sh
curl -L https://foundry.paradigm.xyz | bash
foundryup
```
3. Install Dependencies
```sh
forge install
```
## 🔧 Usage
# 1️⃣ Compile the Smart Contract
```sh
forge build
```
# 2️⃣ Run Tests
```sh
forge test
```
# 3️⃣ Deploy Locally (Anvil)
Start a local Anvil node:
```sh
anvil  
```
Deploy using Foundry:
```sh
forge script script/DeployFundMe.s.sol --broadcast --rpc-url http://localhost:8545
```
# 4️⃣ Deploy to Sepolia Testnet
```sh
forge script script/DeployFundMe.s.sol --rpc-url https://eth-sepolia.g.alchemy.com/v2/YOUR_ALCHEMY_KEY --private-key YOUR_PRIVATE_KEY --broadcast --verify --etherscan-api-key        YOUR_ETHERSCAN_KEY
```

## 📜 Smart Contract Overview

# FundMe.sol
- Allows users to fund ETH to the contract.
- Only the contract owner can withdraw funds.
- Uses Chainlink Price Feeds for minimum funding logic.

# PriceConverter.sol
- Library to fetch ETH/USD price from Chainlink Oracles.

# Deployment & Interaction Scripts
- DeployFundMe.s.sol → Deploys FundMe contract
- HelperConfig.s.sol → Manages configuration for different networks
- Interactions.s.sol → Script for interacting with the contract

# Tests
- Unit Tests → test/unit/FundMeTest.t.sol
- Integration Tests → test/integration/FundMeTestIntegration.t.sol
- Uses Foundry’s forge testing framework

# 📜 License
- This project is open-source and available under the MIT License.

# 👨‍💻 Author
- 🐀 tunnelrat07:- https://github.com/tunnelrat07
🚀 Learning Solidity & smart contracts with Foundry!

# ⭐️ Show Some Love
- If you find this project helpful, feel free to star ⭐ the repo and follow for more updates! 😊

# This README provides:  
✅ Clear **project description**  
✅ **Installation & usage** steps  
✅ **Deployment instructions**  
✅ **Contract & file overview**  

Let me know if you want to modify anything! 🚀
