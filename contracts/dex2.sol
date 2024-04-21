// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

pragma experimental ABIEncoderV2;

import "./Wallet.sol";

contract Dex is Wallet {
    using SafeMath for uint256;

    enum Side {
        BUY,
        SELL
    }

    struct Order {
        uint id;
        address trader;
        Side side;
        bytes32 ticker;
        uint amount;
        uint price;
        uint filled;
    }

    uint public nextOrderId = 0;

    mapping(bytes32 => mapping(uint => Order[])) public orderBook;

    event OrderCreated(uint orderId, address indexed trader, Side side, bytes32 indexed ticker, uint amount, uint price, uint filled);

    function getOrderBook(bytes32 ticker, Side side) external view returns(Order[] memory) {
        return orderBook[ticker][uint(side)];
    }

    function createLimitOrder(Side side, bytes32 ticker, uint amount, uint price) external {
        require(ticker != bytes32(0), "Ticker cannot be empty");
        require(price > 0, "Price must be greater than zero");
        require(amount > 0, "Amount must be greater than zero");

        if(side == Side.BUY){
            require(balances[msg.sender]["ETH"] >= amount.mul(price), "Insufficient ETH balance");
        }
        else if(side == Side.SELL){
            require(balances[msg.sender][ticker] >= amount, "Insufficient token balance");
        }

        Order[] storage orders = orderBook[ticker][uint(side)];
        orders.push(
            Order(nextOrderId, msg.sender, side, ticker, amount, price, 0)
        );

        emit OrderCreated(nextOrderId, msg.sender, side, ticker, amount, price, 0);

        // Increment order ID for the next order
        nextOrderId++;
    }

    function createMarketOrder(Side side, bytes32 ticker, uint amount) external {
        require(ticker != bytes32(0), "Ticker cannot be empty");
        require(amount > 0, "Amount must be greater than zero");

        if(side == Side.SELL){
            require(balances[msg.sender][ticker] >= amount, "Insufficient token balance");
        }

        uint orderBookSide = side == Side.BUY ? 1 : 0;
        Order[] storage orders = orderBook[ticker][orderBookSide];

        uint totalFilled = 0;

        for (uint256 i = 0; i < orders.length && totalFilled < amount; i++) {
            uint leftToFill = amount.sub(totalFilled);
            uint availableToFill = orders[i].amount.sub(orders[i].filled);
            uint filled = leftToFill > availableToFill ? availableToFill : leftToFill;

            totalFilled = totalFilled.add(filled);
            orders[i].filled = orders[i].filled.add(filled);
            uint cost = filled.mul(orders[i].price);

            if(side == Side.BUY){
                require(balances[msg.sender]["ETH"] >= cost, "Insufficient ETH balance");

                // Transfer tokens from trader to buyer
                transferTokens(orders[i].trader, msg.sender, ticker, filled);
                // Transfer ETH from buyer to trader
                transferETH(msg.sender, orders[i].trader, cost);
            }
            else if(side == Side.SELL){
                // Transfer tokens from seller to trader
                transferTokens(msg.sender, orders[i].trader, ticker, filled);
                // Transfer ETH from trader to seller
                transferETH(orders[i].trader, msg.sender, cost);
            }
        }

        // Remove fully filled orders from the order book
        removeFilledOrders(ticker, side);
    }

    function removeFilledOrders(bytes32 ticker, Side side) private {
        Order[] storage orders = orderBook[ticker][uint(side)];
        uint i = 0;
        while (i < orders.length && orders[i].filled == orders[i].amount) {
            i++;
        }
        if (i > 0) {
            for (uint256 j = 0; j < orders.length - i; j++) {
                orders[j] = orders[j + i];
            }
            for (uint256 j = orders.length - i; j < orders.length; j++) {
                delete orders[j];
            }
            orders.pop();
        }
    }
}
