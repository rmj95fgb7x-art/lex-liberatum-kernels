import React, { useState, useEffect, useMemo } from 'react';
import { Activity, Shield, Waves, Zap, BarChart3, Clock, ExternalLink, ArrowUpRight, Database } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { motion } from 'framer-motion';
import { ethers } from 'ethers';
import { FFT_WEI_STATS } from './data/mockData';
import deploymentsData from './data/deployments.json';

// Types for deployment data
interface Deployments {
  network: string;
  splitter: string;
  beneficiary?: string; // May be added in the future
  kernels: Record<string, string>;
  lastProofTx: string;
  timestamp: string;
}

const deployments = deploymentsData as Deployments;
const BENEFICIARY_ADDRESS = FFT_WEI_STATS.beneficiary;
const RPC_URL = "https://sepolia.base.org";

const SPLITTER_ABI = [
  "event RoyaltySplit(string indexed vertical, uint256 fee, uint256 royalty)",
  "function kernelFee(string) view returns (uint256)"
];

const chartData = [
  { month: 'Jan', royalty: 12000 },
  { month: 'Feb', royalty: 28000 },
  { month: 'Mar', royalty: 45000 },
  { month: 'Apr', royalty: 72000 },
  { month: 'May', royalty: 105000 },
  { month: 'Jun', royalty: 158000 },
  { month: 'Jul', royalty: 210000 },
  { month: 'Aug', royalty: 300000 },
];

export default function App() {
  const [liveBalance, setLiveBalance] = useState("0.000000");
  const [events, setEvents] = useState<any[]>([]);
  const [isLive, setIsLive] = useState(false);

  // Map kernels from deployments or use a fallback if none exist
  const kernelList = useMemo(() => {
    const entries = Object.entries(deployments.kernels);
    if (entries.length === 0) return [];
    return entries.map(([name, address]) => ({
      name,
      address,
      vertical: name,
      feeEth: "0.0003",
    }));
  }, []);

  useEffect(() => {
    const provider = new ethers.JsonRpcProvider(RPC_URL);

    // 1. Fetch live balance of beneficiary
    const fetchBalance = async () => {
      try {
        const balance = await provider.getBalance(BENEFICIARY_ADDRESS);
        setLiveBalance(ethers.formatEther(balance));
        setIsLive(true);
      } catch (err) {
        console.error("Balance fetch failed:", err);
      }
    };

    fetchBalance();
    const balanceInterval = setInterval(fetchBalance, 10000); // Poll every 10s

    // 2. Listen for RoyaltySplit events if splitter address is real
    if (deployments.splitter && deployments.splitter !== ethers.ZeroAddress) {
      const splitterContract = new ethers.Contract(deployments.splitter, SPLITTER_ABI, provider);

      const onSplit = (vertical: string, fee: bigint, royalty: bigint) => {
        const newEvent = {
          vertical,
          fee: ethers.formatEther(fee),
          royalty: ethers.formatEther(royalty),
          time: new Date().toLocaleTimeString()
        };
        setEvents(prev => [newEvent, ...prev].slice(0, 5));
        fetchBalance(); // Refresh balance on event
      };

      splitterContract.on("RoyaltySplit", onSplit);
      return () => {
        splitterContract.off("RoyaltySplit", onSplit);
        clearInterval(balanceInterval);
      };
    }

    return () => clearInterval(balanceInterval);
  }, []);

  return (
    <div className="min-h-screen bg-background text-foreground p-4 md:p-8 font-mono">
      {/* Header */}
      <header className="flex flex-col md:flex-row justify-between items-start md:items-center mb-12 gap-4">
        <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }}>
          <h1 className="text-3xl font-bold tracking-tighter flex items-center gap-2 italic">
            <Shield className="text-accent w-8 h-8" />
            LEX LIBERATUM <span className="text-accent underline">DASHBOARD</span>
          </h1>
          <p className="text-white/40 text-[10px] mt-1 tracking-widest uppercase">DETERMINISTIC SPECTRAL ROYALTY ENGINE v1.0.2</p>
        </motion.div>
        <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="glass px-4 py-2 flex items-center gap-3">
          <div className={`w-2 h-2 rounded-full animate-pulse shadow-[0_0_8px_#00f2ff] ${isLive ? 'bg-accent' : 'bg-red-500'}`} />
          <div className="flex flex-col">
            <span className="text-[10px] text-white/60 uppercase tracking-tighter">
              BENEFICIARY: {BENEFICIARY_ADDRESS.slice(0, 8)}...{BENEFICIARY_ADDRESS.slice(-4)}
            </span>
            {deployments.splitter !== ethers.ZeroAddress && (
              <span className="text-[8px] text-accent/60 flex items-center gap-1 uppercase tracking-tighter">
                <Database className="w-2 h-2" /> SPLITTER: {deployments.splitter.slice(0, 8)}...
              </span>
            )}
          </div>
        </motion.div>
      </header>

      {/* Main Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
          <StatCard
            icon={<Waves className="text-accent" />}
            label="REAL-TIME ROYALTY POOL"
            value={`${liveBalance} ETH`}
            sub="BENEFICIARY ON-CHAIN BALANCE"
          />
        </motion.div>
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}>
          <StatCard
            icon={<Zap className="text-accent" />}
            label="ANOMALY DECISIONS (MORAN)"
            value={FFT_WEI_STATS.totalDecisions.toLocaleString()}
            sub="PROCESSED"
          />
        </motion.div>
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}>
          <StatCard
            icon={<BarChart3 className="text-accent" />}
            label="YEAR 1 FFT-WEI PROJECTION"
            value={`$${FFT_WEI_STATS.year1Projection.toLocaleString()}`}
            sub={`${kernelList.length || 10} KERNELS IDENTIFIED`}
          />
        </motion.div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Chart View */}
        <motion.div
          className="lg:col-span-8 glass p-6"
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.4 }}
        >
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-sm font-bold flex items-center gap-2">
              <Activity className="w-4 h-4 text-accent" /> ROYALTY GROWTH PROJECTION
            </h3>
            <span className="text-[10px] text-white/30 uppercase tracking-widest">Base Sepolia Main Stream</span>
          </div>
          <div className="h-[300px] w-full">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={chartData}>
                <defs>
                  <linearGradient id="colorRoyalty" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#00f2ff" stopOpacity={0.3} />
                    <stop offset="95%" stopColor="#00f2ff" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#ffffff05" vertical={false} />
                <XAxis dataKey="month" stroke="#ffffff20" fontSize={10} axisLine={false} tickLine={false} />
                <YAxis hide />
                <Tooltip
                  contentStyle={{ backgroundColor: '#1a1a1e', border: '1px solid #ffffff10', fontSize: '12px' }}
                  itemStyle={{ color: '#00f2ff' }}
                />
                <Area type="monotone" dataKey="royalty" stroke="#00f2ff" fillOpacity={1} fill="url(#colorRoyalty)" strokeWidth={2} />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </motion.div>

        {/* Kernel Stack */}
        <motion.div
          className="lg:col-span-4 flex flex-col gap-6"
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 0.5 }}
        >
          <div className="glass p-6 flex-1 overflow-hidden h-[400px] flex flex-col">
            <h3 className="text-sm font-bold mb-4 flex items-center justify-between">
              LIVE KERNEL REGISTRY
              <Clock className="w-3 h-3 text-white/30" />
            </h3>
            <div className="space-y-3 overflow-y-auto pr-2 scrollbar-active-blue">
              {kernelList.length > 0 ? (
                kernelList.map((k, idx) => (
                  <div key={idx} className="bg-white/5 p-3 rounded-lg border border-white/5 hover:border-accent/30 transition-colors cursor-pointer group">
                    <div className="flex justify-between items-start mb-1">
                      <span className="text-xs font-bold text-white/80 uppercase">{k.name}</span>
                      <span className="text-[9px] text-accent/80 font-mono tracking-tighter uppercase">{k.feeEth} ETH FEE</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <code className="text-[9px] text-white/20">{k.address}</code>
                      <ArrowUpRight className="w-3 h-3 text-white/20 group-hover:text-accent" />
                    </div>
                  </div>
                ))
              ) : (
                <div className="flex flex-col items-center justify-center h-full text-white/20 text-xs italic">
                  Awaiting quickstart deployment...
                </div>
              )}
            </div>
          </div>
        </motion.div>
      </div>

      {/* TX Ledger */}
      <footer className="mt-12 opacity-50 hover:opacity-100 transition-opacity">
        <div className="flex flex-col md:flex-row items-center gap-4 text-[10px] text-white/40 uppercase tracking-widest">
          <Clock className="w-3 h-3" />
          LIVE DATA-FEED VERIFIED BY BASE SEPOLIA
          {deployments.lastProofTx && (
            <span
              onClick={() => window.open(`https://sepolia.basescan.org/tx/${deployments.lastProofTx}`, '_blank')}
              className="text-accent/50 underline cursor-pointer flex items-center gap-1"
            >
              VIEW LATEST PROOF ON BASESCAN <ExternalLink className="w-2 h-2" />
            </span>
          )}
        </div>
      </footer>
    </div>
  );
}

function StatCard({ icon, label, value, sub }: { icon: React.ReactNode, label: string, value: string, sub: string }) {
  return (
    <div className="glass p-6 glow relative overflow-hidden group h-full">
      <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
        {icon}
      </div>
      <p className="text-[10px] text-white/40 font-bold mb-2 tracking-[0.2em]">{label}</p>
      <div className="text-2xl font-bold tracking-tighter mb-1 select-all">{value}</div>
      <p className="text-[10px] text-accent uppercase font-mono italic">{sub}</p>
    </div>
  );
}
