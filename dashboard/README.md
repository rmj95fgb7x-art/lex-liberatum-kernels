# 📡 Lex Liberatum Dashboard

A premium, real-time "Trust Engineering" dashboard designed for the Lex Liberatum protocol. This dashboard provides a live window into the royalty engine, monitoring kernel compliance and the 25bp royalty stream on Base Sepolia.


## Features

- **Live Royalty Pool**: Real-time tracking of the beneficiary's ETH balance on Base Sepolia via `ethers.js`.
- **Protocol Event Stream**: Reactive UI that listens for `RoyaltySplit` events directly from the `RoyaltySplitter` contract.
- **Kernel Registry**: Dynamic list of all compliance kernels with their live on-chain addresses.
- **FFT-Wei Projections**: Visualization of projected royalty growth and Moran decision metrics.
- **On-Chain Proofs**: Direct integration with Basescan for verifying legal decisions and value transfers.

## Tech Stack

- **Framework**: [Vite](https://vitejs.dev/) + [React 19](https://react.dev/)
- **Styling**: [Tailwind CSS v4](https://tailwindcss.com/) (Early Access)
- **Web3**: [Ethers.js v6](https://docs.ethers.org/v6/)
- **Charts**: [Recharts](https://recharts.org/)
- **Animations**: [Framer Motion](https://www.framer.com/motion/)
- **Icons**: [Lucide React](https://lucide.dev/)

## Getting Started

### 1. Installation
Navigate to the dashboard directory and install dependencies:
```bash
cd dashboard
npm install
```

### 2. Synchronization
The dashboard consumes deployment data from `src/data/deployments.json`. This file is automatically updated when you run the project's root deployment script:
```bash
./quickstart.sh
```

### 3. Development Mode
Start the local development server:
```bash
npm run dev
```
The dashboard will be available at `http://localhost:5173`.

## Structure

- `src/App.tsx`: Main dashboard interface and Web3 logic.
- `src/data/deployments.json`: Live contract addresses and network state (synced by `quickstart.sh`).
- `src/data/mockData.ts`: Baseline metrics and fallback stats.
- `src/index.css`: Tailwind v4 configuration and glassmorphism design tokens.
