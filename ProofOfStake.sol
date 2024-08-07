pragma solidity >=0.8.2 <0.9.0;

import {Mixtral8x7BMarket} from "./Mixtral8xModelMarket.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";


contract POSForumAI{

    IERC20 public paymentToken;
    Mixtral8x7BMarket public modelMarket;

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
        owner = _owner;
    }

    function setModelMarket(address _modelMarket) external onlyOwner{
        modelMarket = Mixtral8x7BMarket(_modelMarket);
    }

    function addNode(string memory url, uint256 price) external{
        require(paymentToken.allowance(msg.sender, address(this))>=1000*(10**6), "Not enough allowance!");
        require(nodeStakers[msg.sender]==false, "Already staked with this address!");
        paymentToken.transferFrom(msg.sender, address(this), 1000*(10**6));
        nodeStakers[msg.sender] = true;
        modelMarket.addHost(url, msg.sender, price);
    }

    function removeNode() external{
        require(nodeStakers[msg.sender]==true, "Not staked yet!");
        nodeStakers[msg.sender] = false;
        modelMarket.removeHost(msg.sender);
        paymentToken.transfer(msg.sender, 1000*(10**6));
    }

    function addValidator(address validator) onlyOwner external{
        validators[validator] = true;
    }

    function removeValidator(address validator) onlyOwner external{
        validators[validator] = false;
    }

    function slashNode(address nodeToSlash) onlyValidators external{
        require(nodeStakers[nodeToSlash], "Not a node!");
        nodeStakers[nodeToSlash] = false;
        modelMarket.removeHost(nodeToSlash);
    }

    function pauseNode(address nodeToPause) onlyValidators external{
        require(nodeStakers[nodeToPause], "Not a node!");
        modelMarket.pauseFromProofOfStake(nodeToPause);
    }
}
