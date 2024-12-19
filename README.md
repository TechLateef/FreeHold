# **Freehold**  
### A Decentralized Stablecoin Protocol on Ethereum  

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)  
[![Build Status](https://img.shields.io/github/actions/workflow/status/yourusername/yourrepo/ci.yml?branch=main)]  
[![Solidity](https://img.shields.io/badge/solidity-^0.8.0-lightgrey)]  

## **Introduction**  
**[Project Name]** is a decentralized, algorithmically stabilized stablecoin protocol built on Ethereum. It leverages collateralized crypto assets and a robust stability mechanism to maintain a $1.00 peg. With a focus on decentralization, transparency, and security, the protocol empowers users to mint stablecoins backed by wETH and wBTC.  

---

## **Features**  
- **Pegged Stability**: Stablecoin value anchored to $1.00 using Chainlink price feeds.  
- **Decentralized Minting**: Users can mint stablecoins only with sufficient collateral, ensuring algorithmic stability.  
- **Supported Collateral**:  
  - **wETH**  
  - **wBTC**  
- **Secure Oracles**: Integrates Chainlink price feeds to provide reliable asset pricing.  

---

## **How It Works**  

### 1. **Relative Stability**  
- The protocol maintains a **$1.00 peg** using a combination of decentralized oracles and market mechanisms.  
- **Price Feeds**: Uses Chainlink oracles to fetch real-time ETH and BTC prices for accurate conversions.  
- **Exchange Function**: Supports the exchange of ETH or BTC to the stablecoin.  

### 2. **Stability Mechanism (Minting)**  
- The stablecoin is algorithmically minted when users lock sufficient collateral.  
- **Collateralization Requirements**: Ensures that minted stablecoins are overcollateralized to prevent depegging.  
  - Example: Mint $100 worth of stablecoins by locking $150 worth of wETH or wBTC.  

### 3. **Collateral Management**  
- **Exogenous Collateral**: Relies on crypto assets like wETH and wBTC to back the stablecoin.  
- Ensures safety and decentralization by allowing only trusted assets as collateral.  

---

## **Getting Started**  

### Prerequisites  
- **Foundry**: Install Foundry tools ([documentation here](https://book.getfoundry.sh/))  
- **MetaMask Wallet**  
- **Node.js** (`>=16.x` for frontend interactions if applicable)  

### Installation  
1. Clone the repository:  
   ```bash  
   git clone https://github.com/yourusername/yourrepo.git  
   cd yourrepo  
   ```  

2. Install Foundry:  
   ```bash  
   curl -L https://foundry.paradigm.xyz | bash  
   foundryup  
   ```  

3. Compile contracts:  
   ```bash  
   forge build  
   ```  

4. Run tests:  
   ```bash  
   forge test  
   ```  

---

## **Usage**  

## Build

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


### Deploying Contracts  
1. Configure environment variables in `.env` for deployment.  
   Example:  
   ```env  
   PRIVATE_KEY=your-private-key  
   RPC_URL=https://your-eth-rpc-endpoint  
   ```  

2. Deploy using Foundry scripts:  
   ```bash  
   forge script scripts/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast  
   ```  

### Minting Stablecoins  
1. Lock collateral:  
   ```bash  
   forge script scripts/Mint.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast  
   ```  

2. Exchange ETH or BTC for stablecoins using the provided exchange function.  

---

## **Technologies Used**  
- **Foundry**: For Solidity development and testing.  
- **Chainlink**: Price feeds for reliable oracle data.  
- **Solidity**: Smart contract language.  
- **ERC20**: Standard interface for the stablecoin.  

---

## **Contributing**  
We welcome contributions to **[Project Name]**! If you find bugs, want to suggest improvements, or add features, feel free to open an issue or a pull request.  

---

## **License**  


---

## **Acknowledgments**  
- Inspired by MakerDAO and other decentralized stablecoin protocols.  
- Thanks to the Chainlink community for reliable oracle services.  


## Usage

#
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
