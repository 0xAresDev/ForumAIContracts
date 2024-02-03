pragma solidity >=0.8.2 <0.9.0;

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

    constructor(address owner) {
        _owner = owner;
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

    function addHost(string memory url, address account, uint256 price) external onlyOwner returns (bool) {
        allHosts.push(Hoster(url, account, price));
        return true;
    }

    function removeHost(address account) external onlyOwner returns (bool) {
        for(uint256 i=0; i<allHosts.length; i++){
            if(allHosts[i].hostAccount == account){
                delete allHosts[i];
                return true;
            }
        }
        return true;
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

    function addRequest(uint256 code, address host) external payable returns (bool) {
        require(paused[host] == false, "Currently paused!");
        require(msg.value >= 10**15, "Insufficient funding!");
        activeRequests[host].push(Request(code, msg.value));
        return true;
    }

    function clearListAndReedemFunds() external returns (bool) {
        uint256 totalSendOut = 0;
        for(uint i = 0; i < activeRequests[msg.sender].length; i++){
            totalSendOut = totalSendOut + activeRequests[msg.sender][i].feesPaid;
        }
        delete activeRequests[msg.sender];
        payable(msg.sender).transfer(totalSendOut);
        return true;
    }

    function getActiveRequests(address host) external view returns (Request[] memory) {
        return activeRequests[host];
    }

    function getPaused(address host) external view returns (bool){
        return paused[host];
    }

}