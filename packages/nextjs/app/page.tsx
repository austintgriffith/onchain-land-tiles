"use client";

import { useEffect, useState } from "react";
import type { NextPage } from "next";
import { useAccount } from "wagmi";
import Grid from "~~/components/Grid";
import { Address } from "~~/components/scaffold-eth";
import { useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";

const Home: NextPage = () => {
  const { address: connectedAddress } = useAccount();
  const [lastTokenIds, setLastTokenIds] = useState<number[]>([]);

  const { data: balance } = useScaffoldReadContract({
    contractName: "GridNFT",
    functionName: "balanceOf",
    args: [connectedAddress],
  });

  const { data: totalSupply } = useScaffoldReadContract({
    contractName: "GridNFT",
    functionName: "totalSupply",
  });

  const { writeContractAsync: createGrid } = useScaffoldWriteContract("GridNFT");

  useEffect(() => {
    if (totalSupply) {
      const totalSupplyNum = Number(totalSupply); // Convert BigInt to Number
      const last10 = [];
      for (let i = Math.max(1, totalSupplyNum - 9); i <= totalSupplyNum; i++) {
        last10.push(i);
      }
      setLastTokenIds(last10.reverse());
    }
  }, [totalSupply]);

  return (
    <>
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          <p>Total Supply: {totalSupply ? totalSupply.toString() : "0"}</p>
        </div>

        <div className="pt-5"></div>
        <div className="px-5">
          <Address address={connectedAddress} />
        </div>

        <div className="px-5">
          <p>Your Grid Balance: {balance ? balance.toString() : "0"}</p>
        </div>

        <div className="pb-10">
          <button
            onClick={() => createGrid({ functionName: "createGrid" })}
            className="mt-5 btn btn-primary font-bold py-2 px-4 rounded"
          >
            Create Grid
          </button>
        </div>

        <div className="overflow-x-auto w-full">
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 justify-center">
            {lastTokenIds.map(tokenId => (
              <div key={tokenId} className="flex justify-center">
                <Grid tokenId={tokenId} />
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
