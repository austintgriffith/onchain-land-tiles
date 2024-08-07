// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ColorUtils.sol";
import "./Colors.sol";

contract Grid256 {
	using ColorUtils for Colors.Color[12][12];

	uint256 public constant GRID_SIZE = 12;
	Colors.Color[GRID_SIZE][GRID_SIZE] public grid;

	constructor() {
		initializeGrid();
	}

	function printGrid()
		public
		view
		returns (Colors.Color[GRID_SIZE][GRID_SIZE] memory)
	{
		return grid;
	}

	function initializeGrid() internal {
		for (uint256 i = 0; i < GRID_SIZE; i++) {
			for (uint256 j = 0; j < GRID_SIZE; j++) {
				grid[i][j] = Colors.Color(0, 0, 0);
			}
		}
	}

	function randomizeGridInMemory(
		Colors.Color[GRID_SIZE][GRID_SIZE] memory memoryGrid
	) internal view {
		for (uint256 i = 0; i < GRID_SIZE; i++) {
			for (uint256 j = 0; j < GRID_SIZE; j++) {
				bytes32 hash = keccak256(
					abi.encodePacked(block.timestamp, i, j)
				);
				uint8 colorChoice = uint8(hash[0]) % 3;
				if (colorChoice == 0) {
					memoryGrid[i][j] = Colors.SAND();
				} else if (colorChoice == 1) {
					memoryGrid[i][j] = Colors.WATER();
				} else {
					memoryGrid[i][j] = Colors.PLANTS();
				}
			}
		}
	}

	function smoothGridInMemory(
		Colors.Color[GRID_SIZE][GRID_SIZE] memory memoryGrid
	) internal pure {
		Colors.Color[GRID_SIZE][GRID_SIZE] memory newGrid;
		for (uint256 i = 0; i < GRID_SIZE; i++) {
			for (uint256 j = 0; j < GRID_SIZE; j++) {
				newGrid[i][j] = ColorUtils.smoothColor(
					memoryGrid,
					i,
					j,
					GRID_SIZE
				);
			}
		}
		for (uint256 i = 0; i < GRID_SIZE; i++) {
			for (uint256 j = 0; j < GRID_SIZE; j++) {
				memoryGrid[i][j] = newGrid[i][j];
			}
		}
	}

	function classifyGridInMemory(
		Colors.Color[GRID_SIZE][GRID_SIZE] memory memoryGrid
	) internal pure {
		for (uint256 i = 0; i < GRID_SIZE; i++) {
			for (uint256 j = 0; j < GRID_SIZE; j++) {
				memoryGrid[i][j] = ColorUtils.classifyColor(memoryGrid[i][j]);
			}
		}
	}

	function processGrid() public {
		Colors.Color[GRID_SIZE][GRID_SIZE] memory memoryGrid;

		// Step 1: Randomize the grid in memory
		randomizeGridInMemory(memoryGrid);

		// Step 2: Smooth the grid in memory twice
		smoothGridInMemory(memoryGrid);
		smoothGridInMemory(memoryGrid);

		// Step 3: Classify the smoothed grid in memory
		classifyGridInMemory(memoryGrid);

		// Step 4: Write the processed grid to storage
		for (uint256 i = 0; i < GRID_SIZE; i++) {
			for (uint256 j = 0; j < GRID_SIZE; j++) {
				grid[i][j] = memoryGrid[i][j];
			}
		}
	}
}
