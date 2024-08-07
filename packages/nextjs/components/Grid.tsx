"use client";

import { useEffect, useState } from "react";
import { Address } from "./scaffold-eth";
import { useAccount } from "wagmi";
import { useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";

const Grid = ({ tokenId }: { tokenId: number }) => {
  const { address: connectedAddress } = useAccount();
  const [owner, setOwner] = useState<string | null>(null);
  const [svgDataUri, setSvgDataUri] = useState<string | null>(null);
  const [isProcessed, setIsProcessed] = useState<boolean>(false);

  const { data: tokenURI } = useScaffoldReadContract({
    contractName: "GridNFT",
    functionName: "tokenURI",
    args: [BigInt(tokenId)],
  });

  const { data: ownerOf } = useScaffoldReadContract({
    contractName: "GridNFT",
    functionName: "ownerOf",
    args: [BigInt(tokenId)],
  });

  const { data: processedGrids } = useScaffoldReadContract({
    contractName: "GridNFT",
    functionName: "processedGrids",
    args: [BigInt(tokenId)],
  });

  const { writeContractAsync: processGrid } = useScaffoldWriteContract("GridNFT");

  useEffect(() => {
    if (ownerOf) {
      setOwner(ownerOf.toLowerCase());
    }
  }, [ownerOf]);

  useEffect(() => {
    if (tokenURI) {
      const base64Json = tokenURI.replace("data:application/json;base64,", "");
      const json = JSON.parse(atob(base64Json));
      const imageUri = json.image;
      setSvgDataUri(imageUri);
    }
  }, [tokenURI]);

  useEffect(() => {
    if (processedGrids !== undefined) {
      setIsProcessed(processedGrids);
    }
  }, [processedGrids]);

  const handleProcessGrid = async () => {
    try {
      await processGrid({ functionName: "processGrid", args: [BigInt(tokenId)] });
      setIsProcessed(true); // Set to true after successful processing
    } catch (error) {
      console.error("Error processing grid:", error);
    }
  };

  return (
    <div className="mb-4">
      <p>12x12 #{tokenId}</p>
      <div className="pb-4">
        <Address address={ownerOf} />
      </div>
      {svgDataUri ? (
        <div>
          <img src={svgDataUri} alt={`Grid SVG for token ${tokenId}`} />
        </div>
      ) : (
        <p>Loading...</p>
      )}
      {owner === connectedAddress?.toLowerCase() && !isProcessed && (
        <button onClick={handleProcessGrid} className="mt-2 btn btn-primary font-bold py-1 px-2 rounded">
          Generate
        </button>
      )}
    </div>
  );
};

export default Grid;
