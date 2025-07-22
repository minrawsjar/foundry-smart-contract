# Foundry Smart Contract Lottery (Raffle)

## Description
This project is a decentralized raffle (lottery) smart contract built using Solidity and Foundry. It leverages Chainlink VRF v2.5 for verifiable randomness to pick a fair winner at regular intervals. The contract allows users to enter the raffle by paying an entrance fee, and after a set time interval, a winner is automatically selected and awarded the contract balance.

## Features
- Users can enter the raffle by paying a configurable entrance fee.
- Chainlink VRF integration for secure and verifiable randomness.
- Automated upkeep using Chainlink Keepers to trigger winner selection.
- Transparent and trustless raffle process.
- Easily configurable parameters such as entrance fee, interval, and gas limits.

## Prerequisites
- [Foundry](https://book.getfoundry.sh/) installed and configured.
- An Ethereum wallet with testnet/mainnet funds.
- Chainlink VRF subscription ID and LINK tokens for funding (for live networks).
- RPC URL for the target network.

## Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd foundry-smart-contract-lottery-f23
   ```
2. Install dependencies:
   ```bash
   forge install
   ```
3. Configure your environment variables or update the `HelperConfig.s.sol` with your network details.

## Deployment
Deploy the Raffle contract using the provided Foundry script:

```bash
forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --broadcast
```

This script will:
- Create and fund a Chainlink VRF subscription if needed.
- Deploy the Raffle contract with the configured parameters.
- Add the deployed contract as a consumer to the VRF subscription.

## Usage
- Users can enter the raffle by sending the entrance fee to the `enterRaffle` function.
- The contract automatically checks upkeep conditions and requests a random winner after the configured interval.
- The winner receives the entire contract balance.

## Testing
Run the unit and integration tests using Foundry:

```bash
forge test
```

## Technologies Used
- Solidity 0.8.19
- Foundry (Forge, Cast, Anvil)
- Chainlink VRF v2.5
- Ethereum smart contracts

## License
This project is licensed under the MIT License.

---

For more information on Foundry, visit the [Foundry Book](https://book.getfoundry.sh/).
