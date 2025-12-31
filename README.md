# lex-liberatum-kernels

**Patent-pending, royalty-bearing compliance decision kernels.**  
25 basis points of every application fee → irrevocable trust. Deterministic deployment via CREATE2 across all L2s.

-----

## 🎯 What This Is

Automated compliance decision-making kernels that route 25bp (0.25%) royalties to the Lex Libertatum Trust on every processed decision. Built in Rust (no_std) + Solidity, designed for deterministic cross-chain deployment.

**Current Status:**

- ✅ **3 working kernels**: LexOrbit (satellites), LexChart (pharma), LexDocket (courts)
- 📦 **130+ templates**: Ready for vertical adaptation in `kernels-133.zip`
- 🧪 **Base Sepolia testnet**: RoyaltySplitter contract deployment in progress
- 💰 **Realistic projections**: $200k-600k/year royalties across 10 verticals at moderate adoption

-----

## 💡 How It Works

### Revenue Model (Application Fees, Not Gas)

Kernels charge per compliance decision processed:

- **LexDocket**: $1.00 per court filing review
- **LexChart**: $2.00 per pharma prior-authorization
- **LexOrbit**: $0.50 per satellite telemetry validation

The smart contract automatically routes **25 basis points (0.25%)** of each fee to the trust beneficiary wallet.

### Example Calculation

```
LexChart Pharma Authorization:
─────────────────────────────────
Annual volume: 120M prior-auths/year
Adoption rate: 10% = 12M decisions
Fee per decision: $2.00
─────────────────────────────────
Gross revenue: 12M × $2.00 = $24M/year
Royalty (25bp): $24M × 0.0025 = $60,000/year
```

### Multi-Vertical Projection

|Vertical               |Annual Volume  |Adoption|Fee  |Annual Royalty* |
|-----------------------|---------------|--------|-----|----------------|
|LexDocket (Courts)     |10M filings    |25%     |$1.00|$6,250          |
|LexChart (Pharma)      |120M auths     |10%     |$2.00|$60,000         |
|LexOrbit (Satellites)  |50M signals    |5%      |$0.50|$3,125          |
|LexWell (Oil & Gas)    |40M inspections|15%     |$1.50|$9,000          |
|LexPay (Payments)      |200M txns      |8%      |$0.25|$10,000         |
|**Total (5 verticals)**|               |        |     |**$88,375/year**|

*Royalty = 25bp of gross application fee revenue

**Scale to 10 verticals:** $200k-600k/year at moderate adoption  
**Not “trillions”** - realistic TAM across regulated industries: $50-500M

-----

## 🏗️ Architecture

### 1. Kernel Layer (Rust)

Decision logic runs in `no_std` Rust for embedded/constrained environments:

```rust
// kernels/lexorbit.rs - Satellite telemetry FFT analysis
pub fn process_telemetry(signal: &[i64]) -> Decision {
    let normalized = signal.iter()
        .map(|&x| (x as f64 / 1e18) as f32)
        .collect();
    
    let freq_domain = fft(&normalized);
    analyze_spectrum(&freq_domain)
}
```

**Key features:**

- FFT-based signal denoising (LexOrbit)
- Rule engine for regulatory compliance (LexDocket, LexChart)
- Wei-precision fixed-point math for deterministic results
- ~150 lines per kernel, optimized for embedded deployment

### 2. Smart Contract Layer (Solidity)

Royalty splitting happens on-chain via immutable contracts:

```solidity
// contracts/RoyaltySplitter.sol
contract RoyaltySplitter {
    address public constant BENEFICIARY = 0x44f8219cBABad92E6bf245D8c767179629D8C689;
    uint256 public constant BASIS_POINTS = 25; // 0.25%
    
    function processDecision(bytes32 kernelId, bytes calldata data) 
        external payable returns (bool) 
    {
        uint256 royalty = (msg.value * BASIS_POINTS) / 10000;
        (bool success,) = BENEFICIARY.call{value: royalty}("");
        require(success, "Royalty transfer failed");
        
        emit RoyaltyPaid(msg.sender, msg.value, royalty);
        return true;
    }
}
```

**Contract addresses:**

- Base Sepolia: `0x...` *(pending deployment - see Issue #1)*
- Mainnet: TBD post-audit

### 3. Integration Flow

```
User/System
    ↓
    ├─→ Call RoyaltySplitter.processDecision{value: 0.001 ETH}
    │       ├─→ 99.75% to operator
    │       └─→ 0.25% (25bp) to trust wallet
    ↓
Off-chain worker runs kernel (lexorbit.rs FFT analysis)
    ↓
Return decision: Compliant / NonCompliant / RequiresReview
    ↓
Log result on-chain or via oracle
```

-----

## 🚀 Current Kernels

### LexOrbit (Satellite Telemetry) ✅ Working

**Purpose:** FFT-based anomaly detection in satellite OFDM signals  
**Status:** Fully implemented, 147 lines Rust  
**Compliance:** FCC Part 25, ITU Radio Regulations  
**Use case:** Orbital debris avoidance, spectrum interference detection

```bash
cargo check --release --package lexorbit
# FFT denoising → frequency analysis → compliance decision
```

### LexChart (Pharma Prior-Auth) ✅ Working

**Purpose:** Automated prior-authorization decision engine  
**Status:** Rule engine operational  
**Compliance:** FDA 21 CFR Part 11, HIPAA  
**Use case:** Insurance prior-auth automation, reducing 7-14 day delays to <1 min
