// SPDX-License-Identifier: MIT

/*
  $$\    $$$$$$\              $$\    $$$$$$\  
$$$$ |  $$  __$$\           $$$$ |  $$  __$$\ 
\_$$ |  \__/  $$ |$$\   $$\ \_$$ |  \__/  $$ |
  $$ |   $$$$$$  |\$$\ $$  |  $$ |   $$$$$$  |
  $$ |  $$  ____/  \$$$$  /   $$ |  $$  ____/ 
  $$ |  $$ |       $$  $$<    $$ |  $$ |      
$$$$$$\ $$$$$$$$\ $$  /\$$\ $$$$$$\ $$$$$$$$\ 
\______|\________|\__/  \__|\______|\________|
  water, sand, and plants onchain
*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./Grid256.sol";

contract GridNFT is ERC721 {
	using Counters for Counters.Counter;
	Counters.Counter private _tokenIds;

	mapping(uint256 => Grid256) public grids;
	mapping(uint256 => bool) public processedGrids; // Track if a grid has been processed

	event GridCreated(uint256 indexed tokenId, address indexed owner);
	event GridProcessed(uint256 indexed tokenId);

	constructor() ERC721("12x12Land", "12x12") {}

	function createGrid() public returns (uint256) {
		_tokenIds.increment();
		uint256 newItemId = _tokenIds.current();
		_mint(msg.sender, newItemId);

		Grid256 newGrid = new Grid256();
		grids[newItemId] = newGrid;

		emit GridCreated(newItemId, msg.sender);

		return newItemId;
	}

	function processGrid(uint256 tokenId) public {
		require(
			_isApprovedOrOwner(_msgSender(), tokenId),
			"Caller is not owner nor approved"
		);
		require(!processedGrids[tokenId], "Grid has already been processed");

		Grid256 grid = grids[tokenId];
		grid.processGrid();
		processedGrids[tokenId] = true;

		emit GridProcessed(tokenId);
	}

	function printGrid(
		uint256 tokenId
	) public view returns (Colors.Color[12][12] memory) {
		Grid256 grid = grids[tokenId];
		return grid.printGrid();
	}

	function totalSupply() public view returns (uint256) {
		return _tokenIds.current();
	}

	function tokenURI(
		uint256 tokenId
	) public view override returns (string memory) {
		Grid256 grid = grids[tokenId];
		string memory svg = generateSVG(grid);
		string memory json = Base64.encode(
			bytes(
				string(
					abi.encodePacked(
						'{"name": "12x12 #',
						toString(tokenId),
						'", "description": "A dynamically generated 12x12 grid of onchain water, sand, and plants.", "image": "data:image/svg+xml;base64,',
						Base64.encode(bytes(svg)),
						'"}'
					)
				)
			)
		);
		return string(abi.encodePacked("data:application/json;base64,", json));
	}

	function generateSVG(Grid256 grid) internal view returns (string memory) {
		Colors.Color[12][12] memory gridData = grid.printGrid();
		string
			memory svg = "<svg xmlns='http://www.w3.org/2000/svg' width='240' height='240' viewBox='0 0 240 240'>";
		for (uint256 i = 0; i < 12; i++) {
			for (uint256 j = 0; j < 12; j++) {
				Colors.Color memory color = gridData[i][j];
				string memory colorHex = string(
					abi.encodePacked(
						"#",
						toHexString(color.red),
						toHexString(color.green),
						toHexString(color.blue)
					)
				);
				svg = string(
					abi.encodePacked(
						svg,
						"<rect x='",
						toString(i * 20),
						"' y='",
						toString(j * 20),
						"' width='20' height='20' fill='",
						colorHex,
						"' />"
					)
				);
			}
		}
		svg = string(abi.encodePacked(svg, "</svg>"));
		return svg;
	}

	function toHexString(uint8 value) internal pure returns (string memory) {
		bytes memory alphabet = "0123456789abcdef";
		bytes memory str = new bytes(2);
		str[0] = alphabet[uint8(value >> 4)];
		str[1] = alphabet[uint8(value & 0x0f)];
		return string(str);
	}

	function toString(uint256 value) internal pure returns (string memory) {
		if (value == 0) {
			return "0";
		}
		uint256 temp = value;
		uint256 digits;
		while (temp != 0) {
			digits++;
			temp /= 10;
		}
		bytes memory buffer = new bytes(digits);
		while (value != 0) {
			digits -= 1;
			buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
			value /= 10;
		}
		return string(buffer);
	}
}
