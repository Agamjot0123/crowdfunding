"use client";
import { useState, useEffect } from "react";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount, useReadContract, useWriteContract, useWaitForTransactionReceipt, useBalance } from "wagmi";
import { parseEther, formatEther } from "viem";

const FUND_ABI = [
  {
    type: "function",
    name: "i_goal",
    stateMutability: "view",
    inputs: [],
    outputs: [{ type: "uint256" }],
  },
  {
    type: "function",
    name: "fund",
    stateMutability: "payable",
    inputs: [],
    outputs: [],
  },
] as const;

const CONTRACT_ADDRESS = "0x92d2a5ee595d41c0c3c73a2e890253d7b71725dd" as const;

export default function Home() {
  const [mounted, setMounted] = useState(false);
  const { isConnected } = useAccount();
  const [amount, setAmount] = useState("0.01");

  // Prevent hydration mismatch by ensuring code only runs on the client
  useEffect(() => {
    setMounted(true);
  }, []);

  const { data: goal } = useReadContract({
    address: CONTRACT_ADDRESS,
    abi: FUND_ABI,
    functionName: "i_goal",
  });

  const { data: balance } = useBalance({
    address: CONTRACT_ADDRESS,
  });

  const { data: hash, writeContract } = useWriteContract();
  const { isLoading: isConfirming, isSuccess } = useWaitForTransactionReceipt({ hash });

  const handleFund = () => {
    writeContract({
      address: CONTRACT_ADDRESS,
      abi: FUND_ABI,
      functionName: "fund",
      value: parseEther(amount),
    });
  };

  const progress = goal && balance ? (Number(balance.value) / Number(goal)) * 100 : 0;

  if (!mounted) return null;

  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-6 p-8">
      <h1 className="text-4xl font-bold">🚀 CrowdFund</h1>
      <ConnectButton />
      {isConnected && (
        <>
          <p>Goal: {goal ? formatEther(goal) : "…"} ETH</p>
          <p>Raised: {balance ? formatEther(balance.value) : "…"} ETH</p>
          <div className="w-64 h-4 bg-gray-200 rounded">
            <div className="h-4 bg-green-500 rounded" style={{ width: `${Math.min(progress, 100)}%` }} />
          </div>
          <input
            type="number"
            step="0.01"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className="border p-2 rounded text-black"
          />
          <button
            onClick={handleFund}
            disabled={isConfirming}
            className="bg-blue-600 text-white px-6 py-2 rounded disabled:opacity-50"
          >
            {isConfirming ? "Confirming…" : `Fund ${amount} ETH`}
          </button>
          {isSuccess && <p className="text-green-600">Funded! 🎉 Check your NFT on Sepolia Etherscan.</p>}
          {hash && <p className="text-xs text-gray-500 break-all">{hash}</p>}
        </>
      )}
    </main>
  );
}