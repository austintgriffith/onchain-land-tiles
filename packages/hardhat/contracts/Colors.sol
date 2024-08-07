// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Colors {
	struct Color {
		uint8 red;
		uint8 green;
		uint8 blue;
	}

	function SAND() internal pure returns (Color memory) {
		return Color(210, 180, 140);
	}

	function WATER() internal pure returns (Color memory) {
		return Color(0, 0, 255);
	}

	function PLANTS() internal pure returns (Color memory) {
		return Color(34, 139, 34);
	}
}
