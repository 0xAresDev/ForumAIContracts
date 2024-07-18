pragma solidity >=0.8.2 <0.9.0;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";


contract Mixtral8x7BMarket{

    address private _proofOfStakeContract;

    event Request(address _host, uint256 _uniqueCode, uint256 _feesPaid);


    error Unauthorized(address account);

    modifier onlyProofOfStake(){
        if(msg.sender!=_proofOfStakeContract){
            revert Unauthorized(msg.sender);
        }
        _;
    }

    IERC20 paymentToken;

    constructor(address proofOfStakeContract, address paymentTokenAddress) {
        _proofOfStakeContract = proofOfStakeContract;
        paymentToken = IERC20(paymentTokenAddress);
    }

    struct Hoster{
        string url;
        address hostAccount;
        uint256 price;
    }


    Hoster[] public allHosts;

    mapping(address host => bool) public paused;

    function addHost(string memory url, address account, uint256 price) external onlyProofOfStake{
        allHosts.push(Hoster(url, account, price));
    }

    function removeHost(address account) external onlyProofOfStake{
        for(uint256 i=0; i<allHosts.length; i++){
            if(allHosts[i].hostAccount == account){
                delete allHosts[i];
                for(uint u=i; u<allHosts.length-1; u++){
                    allHosts[u] = allHosts[u+1];
                }
                allHosts.pop();
            }
        }
    }

    function changePrice(uint256 price) external{
        for(uint256 i=0; i<allHosts.length; i++){
            if(allHosts[i].hostAccount == msg.sender){
                allHosts[i].price = price;
            }
        }
    }

    function pause() external{
        paused[msg.sender] = true;
    }

    function unpause() external{
        paused[msg.sender] = false;
    }


    function pauseFromProofOfStake(address node) onlyProofOfStake external {
        paused[node] = true;
    }


    function getHosts() external view returns (Hoster[] memory){
        return allHosts;
    }

    
    function addRequest(uint256 code, address host, uint256 value) external returns (bool) {
        require(paused[host] == false, "Currently paused!");
        require(value >= 100, "Below minimum payment!");
        require(paymentToken.allowance(msg.sender, address(this))>=value, "Not enough allowance!");
        paymentToken.transferFrom(msg.sender, host, value);
        emit Request(host, code, value); 
    }


    function getPaused(address host) external view returns (bool){
        return paused[host];
    }

}
