pragma solidity >=0.8.2 <0.9.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ForumAI is ERC20 {

    address private _owner;

    error Unauthorized(address account);

    modifier onlyOwner(){
        if(msg.sender!=_owner){
            revert Unauthorized(msg.sender);
        }
        _;
    }

    uint256 public iteration = 0;
    uint256 public deployedTime;
    uint256 public stakingUnlock = 666666 ether;

    constructor() ERC20("ForumAI", "FORUM") {
        _owner = msg.sender;
        deployedTime = block.timestamp;
        _mint(msg.sender, 25000000 ether);
    }

    function mintStakingTokens() onlyOwner external{
        require(block.timestamp>=deployedTime + ((30 days) * iteration), "Already claimed for this month!");
        if(iteration==60||iteration==120||iteration==180){
            stakingUnlock = stakingUnlock/2;
        }
        if(iteration==240){
            stakingUnlock = 0;
        }
        iteration += 1;
        _mint(msg.sender, stakingUnlock);
    }

}