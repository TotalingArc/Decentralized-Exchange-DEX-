// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Wallet is Ownable {
    using SafeMath for uint256;

    struct Token {
        bytes32 ticker;
        address tokenAddress;
    }

    mapping(bytes32 => Token) public tokenMapping;
    bytes32[] public tokenList;
    mapping(address => mapping(bytes32 => uint256)) public balances;

    event TokenAdded(bytes32 indexed ticker, address indexed tokenAddress);
    event Deposited(address indexed account, bytes32 indexed ticker, uint256 amount);
    event Withdrawn(address indexed account, bytes32 indexed ticker, uint256 amount);
    event EthDeposited(address indexed account, uint256 amount);
    event EthWithdrawn(address indexed account, uint256 amount);

    function addToken(bytes32 ticker, address tokenAddress) external onlyOwner {
        require(tokenAddress != address(0), "Token address cannot be zero");
        require(tokenMapping[ticker].tokenAddress == address(0), "Token already exists");
        tokenMapping[ticker] = Token(ticker, tokenAddress);
        tokenList.push(ticker);

        emit TokenAdded(ticker, tokenAddress);
    }

    function deposit(uint amount, bytes32 ticker) external tokenExist(ticker) {
        IERC20(tokenMapping[ticker].tokenAddress).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender][ticker] = balances[msg.sender][ticker].add(amount);

        emit Deposited(msg.sender, ticker, amount);
    }

    function withdraw(uint amount, bytes32 ticker) external tokenExist(ticker) {
        require(balances[msg.sender][ticker] >= amount, "Insufficient balance");
        balances[msg.sender][ticker] = balances[msg.sender][ticker].sub(amount);
        IERC20(tokenMapping[ticker].tokenAddress).transfer(msg.sender, amount);

        emit Withdrawn(msg.sender, ticker, amount);
    }

    function depositEth() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].add(msg.value);

        emit EthDeposited(msg.sender, msg.value);
    }

    function withdrawEth(uint amount) external {
        require(balances[msg.sender][bytes32("ETH")] >= amount, "Insufficient balance");
        balances[msg.sender][bytes32("ETH")] = balances[msg.sender][bytes32("ETH")].sub(amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit EthWithdrawn(msg.sender, amount);
    }

    modifier tokenExist(bytes32 ticker) {
        require(tokenMapping[ticker].tokenAddress != address(0), "Token does not exist");
        _;
    }
}
