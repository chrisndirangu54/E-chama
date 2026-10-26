// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ChamaCoin - Asset-backed token for a specific chama
/// @notice Value is determined by totalAssets / totalSupply
contract ChamaCoin is ERC20, Ownable {
    uint256 public totalAssets; // In KES (scaled by 1e18)
    mapping(string => uint256) public assetValues;
    event AssetUpdated(string assetType, uint256 oldValue, uint256 newValue);
    event AssetsUpdated(uint256 newTotalAssets);

    constructor(string memory name, string memory symbol)
        ERC20(name, symbol)
        Ownable(msg.sender)
    {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
        totalAssets += amount;
        emit AssetsUpdated(totalAssets);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
        if (totalAssets >= amount) {
            totalAssets -= amount;
        }
        emit AssetsUpdated(totalAssets);
    }

    function updateAsset(string memory assetType, uint256 newValue) external onlyOwner {
        uint256 oldValue = assetValues[assetType];
        totalAssets = totalAssets - oldValue + newValue;
        assetValues[assetType] = newValue;
        emit AssetUpdated(assetType, oldValue, newValue);
        emit AssetsUpdated(totalAssets);
    }

    function getTokenValue() public view returns (uint256) {
        uint256 supply = totalSupply();
        return supply > 0 ? totalAssets / supply : 0;
    }
}