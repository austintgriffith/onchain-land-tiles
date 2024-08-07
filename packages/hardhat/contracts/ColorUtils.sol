// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Colors.sol";

library ColorUtils {
	using Colors for Colors.Color;

	function smoothColor(
		Colors.Color[12][12] memory grid,
		uint256 x,
		uint256 y,
		uint256 GRID_SIZE
	) internal pure returns (Colors.Color memory) {
		uint256 left = (x == 0) ? 0 : x - 1;
		uint256 right = (x == GRID_SIZE - 1) ? GRID_SIZE - 1 : x + 1;
		uint256 up = (y == 0) ? 0 : y - 1;
		uint256 down = (y == GRID_SIZE - 1) ? GRID_SIZE - 1 : y + 1;

		Colors.Color memory center = grid[x][y];
		uint256 sumRed = center.red;
		uint256 sumGreen = center.green;
		uint256 sumBlue = center.blue;

		Colors.Color[4] memory neighbors = [
			grid[left][y],
			grid[right][y],
			grid[x][up],
			grid[x][down]
		];

		unchecked {
			for (uint256 i = 0; i < 4; i++) {
				sumRed += neighbors[i].red;
				sumGreen += neighbors[i].green;
				sumBlue += neighbors[i].blue;
			}

			uint8 avgRed = uint8(sumRed / 5);
			uint8 avgGreen = uint8(sumGreen / 5);
			uint8 avgBlue = uint8(sumBlue / 5);

			return Colors.Color(avgRed, avgGreen, avgBlue);
		}
	}

	function classifyColor(
		Colors.Color memory color
	) internal pure returns (Colors.Color memory) {
		uint256 distanceSand = distance(color, Colors.SAND());
		uint256 distanceWater = distance(color, Colors.WATER());
		uint256 distancePlants = distance(color, Colors.PLANTS());

		if (distanceSand <= distanceWater && distanceSand <= distancePlants) {
			return Colors.SAND();
		} else if (
			distanceWater <= distanceSand && distanceWater <= distancePlants
		) {
			return Colors.WATER();
		} else {
			return Colors.PLANTS();
		}
	}

	function distance(
		Colors.Color memory a,
		Colors.Color memory b
	) internal pure returns (uint256) {
		int256 redDiff = int256(uint256(a.red)) - int256(uint256(b.red));
		int256 greenDiff = int256(uint256(a.green)) - int256(uint256(b.green));
		int256 blueDiff = int256(uint256(a.blue)) - int256(uint256(b.blue));
		return
			uint256(
				redDiff * redDiff + greenDiff * greenDiff + blueDiff * blueDiff
			);
	}
}
