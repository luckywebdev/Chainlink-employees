// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.6.7;
pragma experimental ABIEncoderV2; 

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV2V3Interface.sol";
import './libraries/TransferHelper.sol';
import './Ownable.sol';


/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract Employees is Ownable {
    struct UserInfo {
        string name;
        string mail;
        uint id;
    }

    // address[] public companies;
    mapping(address => UserInfo[]) public userList;
    
    uint public USER_REGISTER_FEE;
    // receive() external payable {}
    
    AggregatorV3Interface internal priceFeed;
    
    /**
     * Aggregator: ETH/USD
     * Mainnet Address: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
     * Rinkeby Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
     * Kovan Address: 0x9326BFA02ADD2366b30bacB125260Af641031331
     */
    constructor(address _priceFeed) public {
        USER_REGISTER_FEE = 1 ether;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }
    
    function getCompanyUsersLength() public view returns (uint) {
        return userList[msg.sender].length;
    }
    
    // We assume msg.sender is Employer i.e company at the moment.
    function registerUser(string memory _name, string memory _mail, uint _id) public payable returns (uint userIdx) {
        require(msg.value >= USER_REGISTER_FEE, "You should send 1 ETH to register new user");
        // check if user existing in users list already
        userIdx = _getUserIdx(msg.sender, _id);
        require(userIdx == 0, 'User id already exists');
        UserInfo[] storage companyUserInfoList = userList[msg.sender];
        userIdx = companyUserInfoList.length;
        companyUserInfoList.push(UserInfo({
            name: _name,
            mail: _mail,
            id: _id
        }));
        // Fund back ether except only register fee
        if (msg.value - USER_REGISTER_FEE > 0) {
            TransferHelper.safeTransferETH(msg.sender, msg.value - USER_REGISTER_FEE);
        }
    }
    
 
    // Only the company(employer) can update their own user
    function updateUser(string memory _name, string memory _mail, uint _id) public {
        uint userIdx = _getUserIdx(msg.sender, _id);
        require(userIdx > 0, 'User does not exist');
        UserInfo storage userInfo = userList[msg.sender][userIdx - 1];
        userInfo.name = _name;
        userInfo.mail = _mail;
        userInfo.id = _id;
    }
    
    function deleteUser(uint _id) public {
        uint userIdx = _getUserIdx(msg.sender, _id);
        require(userIdx > 0, 'User does not exist');
        UserInfo[] storage companyUsers = userList[msg.sender];
        companyUsers[userIdx - 1] = companyUsers[companyUsers.length - 1];
        companyUsers.pop();
    }
    
    function pickWinner() external view returns(uint) {
        require(userList[msg.sender].length > 1, "You shoud have at least 2 users");
        uint winnerIdx = random(msg.sender) % userList[msg.sender].length;
        return userList[msg.sender][winnerIdx].id;
    }
    
    function viewUser(uint _id) public view returns(UserInfo memory) {
        uint userIdx = _getUserIdx(msg.sender, _id);
        return userList[msg.sender][userIdx - 1];
    }
    
    function getETHUSDPrice() public view returns (int) {
        (,int price,,,) = priceFeed.latestRoundData();
        return price;
    }
    
    function withdrawETH() public onlyOwner {
        require(address(this).balance > 0, "No ETHER at the moment");
        TransferHelper.safeTransferETH(msg.sender, address(this).balance);
    }
    
    function _getUserIdx(address _company, uint _id) internal view returns(uint) {
        uint userIdx = 0;
        UserInfo[] memory companyUsers = userList[_company];
        for (uint ii = 0; ii < companyUsers.length; ii++) {
            if (companyUsers[ii].id == _id) {
                userIdx = ii + 1;
                break;
            }
        }
        return userIdx;
    }
    
    function random(address _company) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, now, _company)));
    }
}
