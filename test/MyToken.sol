// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "TOKEN") {
        uint256 initialSupply = 10000000 * (10 ** uint256(decimals()));
        _mint(msg.sender, initialSupply);
    }
}
