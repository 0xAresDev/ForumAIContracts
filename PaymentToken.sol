pragma solidity >=0.8.2 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ForumUSD is ERC20 {

    constructor() ERC20("ForumUSD", "FUSD") {}

    function mint() external{
        _mint(msg.sender, 5 ether);
    }

}