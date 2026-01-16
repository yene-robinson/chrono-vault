# ChronoVault

ChronoVault is a decentralized application (dApp) designed to promote disciplined savings through time-locked ETH deposits. Users interact with a secure, on-chain vault smart contract, ensuring funds are only accessible after a specified lock period. This repository contains the **React + Vite** frontend, which connects to the `Vault` smart contract deployed on the Base network.

---

## Table of Contents
1. [Features](#features)
2. [Architecture](#architecture)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Setup & Installation](#setup--installation)
6. [Usage](#usage)
7. [Testing](#testing)
8. [Deployment](#deployment)
9. [Security & Disclaimer](#security--disclaimer)
10. [License](#license)

---

## Features
- **Time-Locked Savings:** Enforced lock periods for ETH deposits.
- **Wallet Integration:** Supports REOWN AppKit and WalletConnect v2.
- **Real-Time Balance Tracking:** Instantly view vault balances.
- **Multi-Network Support:** Compatible with Local, Base Sepolia, and Base Mainnet.

---

## Architecture
ChronoVault consists of two main components:
- **Frontend:** Located in `chrono-vault-frontend/`, built with React and Vite.
- **Smart Contract:** The `Vault` contract (Solidity, Foundry) should be managed in a separate repository (e.g., `chrono-vault-contracts`).

The frontend connects to the deployed contract via its address and ABI. Contract deployment and management are handled externally.

---

## Technology Stack
- React 19
- Vite 7
- TypeScript
- TanStack Query
- Wagmi & Viem
- REOWN AppKit
- WalletConnect v2
- Solidity (Foundry)

---

## Project Structure
- `chrono-vault-frontend/` – React + Vite dApp (UI, wallet integration)
- `README.md` – Project-level documentation

Refer to `chrono-vault-frontend/README.md` for frontend details. The smart contract code should reside in a separate repository.

---

## Setup & Installation
### Prerequisites
- Node.js v18+
- npm
- WalletConnect-compatible wallet

### Steps
1. **Clone this repository and your contracts repository.**
2. **Deploy the `Vault` contract** (see your contracts repo for instructions).
3. **Frontend setup:**
   ```bash
   cd chrono-vault-frontend
   npm install
   cp .env.example .env
   # Set VITE_REOWN_PROJECT_ID and VITE_VAULT_ADDRESS in .env
   npm run dev
   ```
4. **Obtain a REOWN Project ID** from [REOWN Cloud](https://cloud.reown.com/).
5. **Configure environment variables:**
   ```env
   VITE_REOWN_PROJECT_ID=your_reown_project_id_here
   VITE_VAULT_ADDRESS=your_deployed_vault_contract_address_here
   ```

> **Note:** Contract addresses are network-specific. Always use the correct address for your target network (local, testnet, or mainnet).

---

## Usage
After completing setup, launch the frontend locally:
```bash
npm run dev
```
Connect your wallet and interact with the time-locked vault.

---

## Testing
From the `chrono-vault-frontend/` directory:
- Lint: `npm run lint`
- Type-check: `npm run type-check`
- Run tests: `npm run test`

---

## Deployment
1. Build the frontend:
   ```bash
   cd chrono-vault-frontend
   npm run build
   ```
2. Deploy the contents of `chrono-vault-frontend/dist` to your preferred static hosting provider (e.g., Vercel, Netlify).
3. Ensure production environment variables are set correctly.

---

## Security & Disclaimer
- Audit and thoroughly test smart contracts before mainnet deployment.
- Do not deposit more than you are willing to lose during development or testing.
- This project is provided for educational and experimental purposes only; no guarantees are made regarding security or fitness for any purpose.

---

## License
This project is licensed under the MIT License.
