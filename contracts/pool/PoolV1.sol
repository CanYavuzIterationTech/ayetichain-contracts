// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract AssetPool is ERC20, ERC20Burnable {
    address public owner;
    address public asset;

    // AssetPool should mint and burn tokens as needed
    // Tokens represent a share of the pool
    // The pool should be able to receive and send the asset
    // The pool should be able to receive and send tokens
    // The pool should be able to calculate the value of a share

    uint256 public totalValueLocked;
    uint256 public totalShares;

    event Withdrawal(uint256 amount, uint256 when);
    event Deposit(uint256 amount, uint256 when);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute");
        _;
    }

    constructor(address _asset) ERC20("PoolV1", "POOL") {
        owner = msg.sender;
        asset = _asset;
    }

    function deposit(address _toAddress, uint256 _amount) public {
        require(
            IERC20(asset).transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        _mint(_toAddress, _amount);
        totalValueLocked += _amount;
        totalShares += _amount;
        emit Deposit(_amount, block.timestamp);
    }

    function withdraw(uint256 _amount) public {
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance");
        _burn(msg.sender, _amount);
        totalValueLocked -= _amount;
        totalShares -= _amount;
        require(IERC20(asset).transfer(msg.sender, _amount), "Transfer failed");
        emit Withdrawal(_amount, block.timestamp);
    }

    
}
