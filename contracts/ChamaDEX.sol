// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ChamaCoin.sol";

/// @title Simple In-House DEX for ChamaCoin trading
contract ChamaDEX {
    struct Trade {
        address seller;
        address token;
        uint256 amount;
        uint256 pricePerToken; // in KES (scaled)
        bool active;
    }

    mapping(uint256 => Trade) public trades;
    uint256 public tradeCounter;

    event TradeListed(uint256 tradeId, address seller, address token, uint256 amount, uint256 pricePerToken);
    event TradeExecuted(uint256 tradeId, address buyer, uint256 amount);

    function listTrade(address token, uint256 amount, uint256 pricePerToken) external {
        ChamaCoin(token).transferFrom(msg.sender, address(this), amount);
        tradeCounter++;
        trades[tradeCounter] = Trade(msg.sender, token, amount, pricePerToken, true);
        emit TradeListed(tradeCounter, msg.sender, token, amount, pricePerToken);
    }

    function executeTrade(uint256 tradeId) external payable {
        Trade storage trade = trades[tradeId];
        require(trade.active, "Trade not active");
        uint256 totalPrice = trade.amount * trade.pricePerToken;
        require(msg.value >= totalPrice, "Insufficient payment");
        ChamaCoin(trade.token).transfer(msg.sender, trade.amount);
        payable(trade.seller).transfer(totalPrice);
        trade.active = false;
        emit TradeExecuted(tradeId, msg.sender, trade.amount);
    }

    function cancelTrade(uint256 tradeId) external {
        Trade storage trade = trades[tradeId];
        require(trade.seller == msg.sender && trade.active, "Not authorized");
        ChamaCoin(trade.token).transfer(msg.sender, trade.amount);
        trade.active = false;
    }
}