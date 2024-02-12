pragma solidity >=0.8.2 <0.9.0;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";


contract LLMMarket{

    address private _owner;
    //bool public paused;

    error Unauthorized(address account);

    modifier onlyOwner(){
        if(msg.sender!=_owner){
            revert Unauthorized(msg.sender);
        }
        _;
    }

    IERC20 paymentToken;

    constructor(address owner, address paymentTokenAddress) {
        _owner = owner;
        paymentToken = IERC20(paymentTokenAddress);
    }

    struct Hoster{
        string url;
        address hostAccount;
        uint256 price;
    }

    struct Request{
        uint256 uniqueCode;
        uint256 feesPaid;
    }

    Hoster[] public allHosts;

    mapping(address host => Request[]) public activeRequests;
    mapping(address host => bool) public paused;

    function changePaymentToken(address newPaymentTokenAddress) external onlyOwner returns (bool) {
        paymentToken = IERC20(newPaymentTokenAddress);
        return true;
    }


    function addHost(string memory url, address account, uint256 price) external onlyOwner returns (bool) {
        allHosts.push(Hoster(url, account, price));
        return true;
    }

    function removeHost(address account) external onlyOwner returns (bool) {
        for(uint256 i=0; i<allHosts.length; i++){
            if(allHosts[i].hostAccount == account){
                delete allHosts[i];
                for(uint u=i; u<allHosts.length-1; u++){
                    allHosts[u] = allHosts[u+1];
                }
                allHosts.pop();
                return true;
            }
        }
        return false;
    }

    function changePrice(uint256 price) external returns (bool) {
        for(uint256 i=0; i<allHosts.length; i++){
            if(allHosts[i].hostAccount == msg.sender){
                allHosts[i].price = price;
                return true;
            }
        }
        return false;
    }

    function pause() external returns (bool){
        paused[msg.sender] = true;
        return true;
    }

    function unpause() external returns (bool){
        paused[msg.sender] = false;
        return true;
    }

    function getHosts() external view returns (Hoster[] memory){
        return allHosts;
    }

    
    function addRequest(uint256 code, address host, uint256 value) external returns (bool) {
        require(paused[host] == false, "Currently paused!");
        require(value >= 10**15, "Below minimum payment!");
        require(paymentToken.allowance(msg.sender, address(this))>=value, "Not enough allowance!");
        paymentToken.transferFrom(msg.sender, host, value);
        activeRequests[host].push(Request(code, value));
        return true;
    }

    function clearListAndReedemFunds() external returns (bool) {
        delete activeRequests[msg.sender];
        return true;
    }

    function getActiveRequests(address host) external view returns (Request[] memory) {
        return activeRequests[host];
    }

    function getPaused(address host) external view returns (bool){
        return paused[host];
    }

}
