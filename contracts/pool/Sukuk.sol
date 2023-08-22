// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


contract Sukuk is ERC20, ERC20Burnable {
    struct RentContract {
        uint256 amount; // 3000 2200 365 gün için 365 gün %10 faiz olmayan faiz
        uint256 amountOriginal; // 2000 orjinal miktar
        uint256 startDate; // koyduğun tarih
        uint256 endDate; // son günü 30-365
        bool isPaid; // ödendi mi
    }

    address public owner;
    uint256 public rentalIncome;
    address public baseToken;

    mapping(address => uint256) public tokenBalance;
    mapping(address => uint256) public sukukAmount;
    mapping(address => uint256) public supplied;

    uint256 public totalSupplied;

    mapping(address => RentContract[]) public rentContracts;

    event RentalIncomeDistributed(uint256 totalIncome);

    constructor(
        address _baseToken,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        owner = msg.sender;
        baseToken = _baseToken;
    }

    // Everyone starts from here
    function deposit(uint256 _amount) public {
        // deposits IERC20 tokens into the contract
        require(
            IERC20(baseToken).transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        tokenBalance[msg.sender] += _amount;
    }

    function withdraw(uint256 _amount) public {
        require(
            IERC20(baseToken).transferFrom(address(this), msg.sender, _amount),
            "Transfer failed"
        );

        // Balance is only allowed to be withdrawn if it is not locked in a contract

        tokenBalance[msg.sender] -= _amount;
    }

    function createRentContract(uint256 _amount, uint256 _duration) public {
        //require(msg.sender == owner, "Only owner can execute");
        require(_amount <= tokenBalance[msg.sender], "Insufficient balance");
        //balanceOf[owner] -= _amount;

        require(
            30 days <= _duration && _duration <= 365 days,
            "Duration must be between 30 and 365 days"
        );

   

        //console.log(_amount);
        //console.log(tokenBalance[msg.sender]);
        //console.log(calculateThreeTwos(_amount));
        require(
            calculateThreeTwos(_amount) <= tokenBalance[msg.sender],
            "Insufficient balance"
        );

        RentContract memory newRentContract = RentContract({
            amount: computeRent(_duration, _amount),
            amountOriginal: _amount,
            startDate: block.timestamp,
            endDate: block.timestamp + 365 days,
            isPaid: false
        });

        rentContracts[msg.sender].push(newRentContract);

        tokenBalance[msg.sender] -= _amount; // 2000
        sukukAmount[msg.sender] += computeRent(_duration, _amount); // 2200

        require(
            IERC20(baseToken).transfer(msg.sender, _amount),
            "Transfer failed"
        );
    }

    function payRent(uint256 _index) public {
        require(
            rentContracts[msg.sender][_index].isPaid == false,
            "Rent already paid"
        );
        require(
            block.timestamp <= rentContracts[msg.sender][_index].endDate,
            "Rent is expired"
        );
        require(
            IERC20(baseToken).transferFrom(
                msg.sender,
                address(this),
                rentContracts[msg.sender][_index].amount
            ),
            "Transfer failed"
        );
        rentContracts[msg.sender][_index].isPaid = true;
        sukukAmount[msg.sender] -= rentContracts[msg.sender][_index].amount;
        tokenBalance[msg.sender] += rentContracts[msg.sender][_index]
            .amountOriginal;
        totalSupplied +=
            rentContracts[msg.sender][_index].amount -
            rentContracts[msg.sender][_index].amountOriginal;

        rentalIncome += rentContracts[msg.sender][_index].amount;
    }

    function supply(uint256 _amount) public {
        require(tokenBalance[msg.sender] >= _amount, "Transfer failed");

  
        tokenBalance[msg.sender] -= _amount;

        // 100 supply 1000 ETH
        // 2000 ETH 200 supply LP Token



        totalSupplied += calculateAmountToBeMinted(
            _amount,
            totalSupply(),
            totalSupplied
        );

        _mint(
            msg.sender,
            calculateAmountToBeMinted(_amount, totalSupply(), totalSupplied)
        );
    }

    function withdrawSupply(uint256 _amount) public {
        // require(balanceOf(msg.sender) >= _amount, "Transfer failed");

        uint256 amountToBeEarned = calculateAmountToBeEarned(
            _amount,
            totalSupply(),
            totalSupplied
        );


        tokenBalance[msg.sender] += amountToBeEarned;

        totalSupplied -= amountToBeEarned;
        _burn(msg.sender, _amount);
    }

    function calculateTwoThirds(uint256 _amount) public pure returns (uint256) {
        ////require(msg.sender == owner, "Only owner can execute");
        uint256 twoThirds = (_amount * 2) / 3;
        //balanceOf[owner] -= twoThirds;
        //balanceOf[owner] += twoThirds;
        return twoThirds;
    }

    function calculateThreeTwos(uint256 _amount) public pure returns (uint256) {
        ////require(msg.sender == owner, "Only owner can execute");
        uint256 threeTwos = (_amount * 3) / 2;
        //balanceOf[owner] -= threeTwos;
        //balanceOf[owner] += threeTwos;
        return threeTwos;
    }

    // LP token share calculation

    function calculateAmountToBeMinted(
        uint256 _amount,
        uint256 _totalSupply,
        uint256 _totalSupplied
    ) public pure returns (uint256) {
        // Calculates the percentage amount of the input

        if (_totalSupply == 0) {
            return _amount;
        }

        uint256 percentage = (_amount * 100) / _totalSupply; // 100 * 100 / 10000 = 1

        uint256 amountToBeMinted = (_totalSupplied * percentage) / 100; // 10000 * 1 / 100 = 100
        return amountToBeMinted;
    }

    function calculateAmountToBeEarned(
        uint256 _amountSupplied,
        uint256 _totalSupply,
        uint256 _totalSupplied
    ) public pure returns (uint256) {
        // Calculates the percentage amount of the input
        // if amount is 1000 and totalSupply is 10000 and totalSupplied is 10000
        // then the percentage is 10%
        // and the amount to be earned is 1000 * 10 / 100 = 100

        if (_totalSupply == 0) {
            return _amountSupplied;
        }

        uint256 percentage = (_amountSupplied * 100) / _totalSupply; // 1000 * 100 / 10000 = 10

        uint256 amountToBeEarned = (_totalSupplied * percentage) / 100; // 10000 * 10 / 100 = 1000

        return amountToBeEarned;
    }

    function calculateRentCost(
        uint256 _amount,
        uint256 _duration
    ) public pure returns (uint256) {
        // Calculates the cost of the rent contract
        // It scales linearly
        // For 30 days it is 0.83%
        // For 365 days it is 10%

        uint256 percentage = (_duration * 100) / 365 days;
        uint256 rentCost = (_amount * percentage) / 100;

        return rentCost;
    }

    function computeRent(
        uint256 _duration,
        uint256 _amount
    ) public pure returns (uint256) {
        uint256 secondsIn30Days = 30 days;
        uint256 secondsIn365Days = 365 days;

        require(
            _duration >= secondsIn30Days && _duration <= secondsIn365Days,
            "Seconds out of range"
        );

        // Using the rates as per mille additions (e.g., 83 for 0.83% and 10000 for 10%)
        uint256 base30 = 83; // 0.83%
        uint256 base365 = 1000; // 10%

        // Calculate how much rate should be interpolated
        uint256 interpolatedIncrement = base30 +
            ((_duration - secondsIn30Days) * (base365 - base30)) /
            (secondsIn365Days - secondsIn30Days);

        // Calculate the total cost.
        // The original amount plus the rent. We're doing the multiplication first to avoid precision issues.
        return _amount + (_amount * interpolatedIncrement) / 10000; // Using 10000 to convert the per mille rate to a proper multiplier
    }

    // Total supplied should be generated from the total supply of the token
}
