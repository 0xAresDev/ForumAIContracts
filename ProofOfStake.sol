pragma solidity >=0.8.2 <0.9.0;

import {Mixtral8x7BModelMarket} from "./ModelMarket.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";


contract ProofOfStakeForumAI{

    IERC20 public paymentToken;
    Mixtral8x7BModelMarket public modelMarket;

    error Unauthorized(address account);

    mapping(address=>bool) public nodeStakers;
    mapping(address=>bool) public validators;

    modifier onlyValidators(){
        if(!validators[msg.sender]){
            revert Unauthorized(msg.sender);
        }
        _;
    }

    address private owner;
    //bool public paused;

    modifier onlyOwner(){
        if(msg.sender!=owner){
            revert Unauthorized(msg.sender);
        }
        _;
    }

    constructor(address paymentTokenAddress, address _owner) {
        paymentToken = IERC20(paymentTokenAddress);
        modelMarket = new Mixtral8x7BModelMarket(address(this), paymentTokenAddress);
        owner = _owner;
    }

    function addNode(string memory url, uint256 price) external returns (bool){
        require(paymentToken.allowance(msg.sender, address(this))>=1000 ether, "Not enough allowance!");
        require(nodeStakers[msg.sender]==false, "Already staked with this address!");
        paymentToken.transferFrom(msg.sender, address(this), 1000 ether);
        nodeStakers[msg.sender] = true;
        modelMarket.addHost(url, msg.sender, price);
        return true;
    }

    function removeNode() external returns (bool){
        require(nodeStakers[msg.sender]==true, "Not staked yet!");
        nodeStakers[msg.sender] = false;
        modelMarket.removeHost(msg.sender);
        paymentToken.transfer(msg.sender, 1000 ether);
        return true;
    }

    function addValidator(address validator) onlyOwner external returns (bool){
        validators[validator] = true;
        return true;
    }

    function removeValidator(address validator) onlyOwner external returns (bool){
        validators[validator] = false;
        return true;
    }

    function slashNode(address nodeToSlash) onlyValidators external returns (bool){
        require(nodeStakers[nodeToSlash], "Not a node!");
        nodeStakers[nodeToSlash] = false;
        modelMarket.removeHost(nodeToSlash);
        return true;
    }

    function pauseNode(address nodeToPause) onlyValidators external returns (bool){
        require(nodeStakers[nodeToPause], "Not a node!");
        modelMarket.pauseFromProofOfStake(nodeToPause);
        return true;
    }
}
