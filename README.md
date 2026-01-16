
# ChronoVault – Decentralized Time-Locked Savings dApp

ChronoVault is a decentralized savings application that lets users deposit ETH into an on-chain, time-locked vault. Users can only withdraw after the lock expires, encouraging disciplined savings. This repository contains the **React + Vite** frontend, which connects to a `Vault` smart contract deployed on the Base network.

---


## Key Features
- Time-locked savings with enforced lock periods
- Wallet integration (REOWN AppKit, WalletConnect v2)
- Real-time balance tracking
- Multi-network support (Local, Base Sepolia, Base Mainnet)




## Overview
ChronoVault encourages disciplined savings by enforcing time-locked deposits on-chain. The frontend (in `frontend/`) connects to a deployed `Vault` smart contract. The contract code should be managed in a separate Solidity/Foundry repository (e.g., `chrono-vault-contracts`).

---


## Tech Stack
- React 19, Vite 7, TypeScript
- TanStack Query, Wagmi, Viem
- REOWN AppKit, WalletConnect v2
- Solidity (Foundry, external)

---


## Project Structure

- `frontend/` – React + Vite dApp (UI and wallet integration)
- `README.md` – Project-level documentation (this file)

See `frontend/README.md` for frontend details. The `Vault` smart contract should live in a separate repo (e.g., `chronovault-contracts`).


## Quickstart

1. **Clone this repo and your contracts repo.**
2. Deploy the `Vault` contract (see your contracts repo for instructions).
3. In this repo:
   ```bash
   cd frontend
   npm install
   cp .env.example .env
   # Set VITE_REOWN_PROJECT_ID and VITE_VAULT_ADDRESS in .env
   npm run dev
   ```

For advanced setup, see `frontend/README.md` and your contracts repo.

---


## Basic Configuration

1. Node.js v18+, npm, and a WalletConnect-compatible wallet are required.
2. Get a REOWN Project ID from [REOWN Cloud](https://cloud.reown.com/).
3. Set up your `.env` in `frontend/`:
   ```env
   VITE_REOWN_PROJECT_ID=your_reown_project_id_here
   VITE_VAULT_ADDRESS=your_deployed_vault_contract_address_here
   ```


Contract addresses are network-specific. Always use the correct address for your target network (local, testnet, or mainnet).

---


## Smart Contract

The `Vault` contract should be managed and deployed from your contracts repository (e.g., `chronovault-contracts`). The frontend connects to it via its address and ABI. See your contracts repo for details.

---


## Testing

From the `frontend/` directory:
- Lint: `npm run lint`
- Type-check: `npm run type-check`
- Run tests: `npm run test`

---


## Deployment

1. Build the frontend:
   ```bash
   cd frontend
   npm run build
   ```
2. Deploy `frontend/dist` to your preferred static hosting (Vercel, Netlify, etc).
3. Set the correct environment variables in production.

---


## CI/CD

This repo includes a GitHub Actions workflow for linting, type-checking, and building the app. See `.github/workflows/ci.yml` for details.

---


## Security and Disclaimer

- Audit and test smart contracts before mainnet deployment.
- Do not deposit more than you are willing to lose during development.
- Provided for educational and experimental purposes; no guarantees.

---


## License

MIT
