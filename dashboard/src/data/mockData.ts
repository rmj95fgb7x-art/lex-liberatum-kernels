export interface KernelDeployment {
    name: string;
    address: string;
    vertical: string;
    feeEth: string;
    adoption: number; // simulated
}

export const mockDeployments: KernelDeployment[] = [
    { name: "LexBOP", address: "0xBD7...1B16", vertical: "LexBOP-OilGas", feeEth: "0.0003", adoption: 85 },
    { name: "LexPay", address: "0x3b8...abc9", vertical: "LexPay-PCI-AML", feeEth: "0.0002", adoption: 92 },
    { name: "LexBlood", address: "0x12E...E2d5", vertical: "LexBlood-ColdChain", feeEth: "0.0004", adoption: 78 },
    { name: "LexOrbit", address: "0x44f...8C68", vertical: "LexOrbit-ITU", feeEth: "0.0003", adoption: 65 },
    { name: "LexESG", address: "0x55g...9D12", vertical: "LexESG-Carbon", feeEth: "0.0006", adoption: 88 },
    { name: "LexWell", address: "0x66h...A432", vertical: "LexWell-OilGas", feeEth: "0.0005", adoption: 72 },
    { name: "LexYacht", address: "0x77i...B543", vertical: "LexYacht-Safety", feeEth: "0.0004", adoption: 95 },
    { name: "LexPort", address: "0x88j...C654", vertical: "LexPort-Customs", feeEth: "0.0003", adoption: 81 },
    { name: "LexSeal", address: "0x99k...D765", vertical: "LexSeal-Courts", feeEth: "0.0002", adoption: 99 },
    { name: "LexCarbon", address: "0x00l...E876", vertical: "LexCarbon-Monitor", feeEth: "0.0006", adoption: 83 },
];

export const FFT_WEI_STATS = {
    totalDecisions: 120000,
    royaltyBps: 25,
    beneficiary: "0x44f8219cBABad92E6bf245D8c767179629D8C689",
    year1Projection: 300000, // USD
};
