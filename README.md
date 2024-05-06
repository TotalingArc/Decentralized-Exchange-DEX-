# Decentralized Exchange (DEX) Smart Contract

This Solidity smart contract implements a decentralized exchange (DEX) allowing users to create limit and market orders for trading tokens on the Ethereum blockchain.

## Features

- **Limit Orders**: Users can create limit orders specifying the side (BUY or SELL), ticker symbol, amount, and price.
- **Market Orders**: Users can create market orders specifying the side and ticker symbol, which are matched with existing limit orders.
- **Order Book**: The contract maintains an order book for each ticker symbol, containing both BUY and SELL orders.
- **Safety Checks**: The contract includes various safety checks to ensure valid and secure trading operations, such as balance validations and overflow/underflow protections.
- **Gas Efficiency**: Gas-efficient implementations are employed to optimize contract execution costs, minimizing transaction fees for users.
- **Security Measures**: Best practices for smart contract security are followed, including the use of SafeMath for arithmetic operations and access control to restrict function calls.

## Prerequisites

- Solidity Compiler: Ensure you have a compatible Solidity compiler installed. The contract is designed for Solidity version `>=0.7.0 <0.9.0`.
- Ethereum Development Environment: Set up an Ethereum development environment such as Truffle or Hardhat for contract deployment and testing.
- Dependencies: Make sure to install any required dependencies or libraries used in the contract, such as SafeMath.

## Deployment

1. Compile the Smart Contract: Use the Solidity compiler to compile the DEX smart contract.
2. Deploy to Ethereum Network: Deploy the compiled contract to the desired Ethereum network (e.g., Mainnet, Ropsten, Rinkeby, or a local testnet).

## Usage

1. **Creating Limit Orders**: Call the `createLimitOrder` function to create a limit order specifying the side (BUY or SELL), ticker symbol, amount, and price.
2. **Creating Market Orders**: Call the `createMarketOrder` function to create a market order specifying the side and ticker symbol. Market orders are matched with existing limit orders.
3. **Viewing Order Book**: Use the `getOrderBook` function to view the order book for a specific ticker symbol and side.
4. **Trading Tokens**: Users can trade tokens by creating and executing limit or market orders through the contract.

## Security Considerations

- **Secure Access Control**: Implement access control mechanisms to restrict function calls to authorized users.
- **Safe Arithmetic Operations**: Utilize SafeMath or equivalent libraries to prevent arithmetic overflows and underflows.
- **Input Validation**: Validate user inputs and ensure that all parameters meet expected constraints to prevent unintended behavior.

## Gas Efficiency

- **View Functions**: Utilize view functions for read-only operations to minimize gas consumption.
- **Optimized Storage Usage**: Limit unnecessary storage writes and optimize data structures to reduce gas costs.
- **Loop Iterations**: Optimize loop iterations to avoid excessive gas consumption, especially in functions that process large datasets.

## License

This DEX smart contract is licensed under the [MIT License](LICENSE).
