// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


error CarbonTrader_NotOwner();
error CarbonTrader_ParamError();
error CarbonTrader_TransferFailed();
error CarbonTrader_NotEnoughDeposit();
error CarbonTrader_TradeNotExist();
error CarbonTrader_RefoundFailed();
error CarbonTrader_FinalizeAuctionFailed();


/**
 * @title CarbonTrader
 * @dev Contract for managing carbon allowances trading. It allows issuing, querying, freezing, unfreezing, and destroying carbon allowances.
 * Only the owner can perform administrative actions like issuing or freezing allowances.
 * Users can create trades, deposit bids, refund deposits, and finalize auctions.
 * The contract interacts with an ERC20 token for payments.
 */
contract CarbonTrader {
    event NewTrade(
        address indexed seller,
        uint256 amount,
        uint256 startamount,
        uint256 priceOfUnit,
        uint256 startTime,
        uint256 endTime
        );




    struct Trade{
        address seller;
        uint256 amount;
        uint256 startamount;
        uint256 priceOfUnit;
        uint256 startTime;
        uint256 endTime;
        mapping(address => uint256) deposit;
        mapping(address => string) cryptedInfo;
        mapping(address => string) decrypteKey;
    }

    mapping(address => uint256) userToAllowance;
    mapping(address => uint256) userToFrozenAllowance;
    mapping(address => uint256) auctionAmount;
    mapping(string => Trade) idToTrade;


    address private immutable OWNER; //此处是immutable可否换成private
    IERC20 private token;

    constructor(address tokenAddress){   
        OWNER = msg.sender;
        token = IERC20(tokenAddress);
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }
            
    function _onlyOwner() view internal {
        if(msg.sender != OWNER ) //owner只在函数初始化时候编译一次，此后都固定了，但是发起人是调用合约的人，可以是用户，也可以是管理员。所以需要验证是否owner
            revert CarbonTrader_NotOwner();
    }

    /**
     * @dev Issues carbon allowances to a user. Only callable by the owner.
     * @param user The address of the user to receive allowances.
     * @param amount The amount of allowances to issue.
     */
    function issueAllowance(address user, uint256 amount)public onlyOwner{
        userToAllowance[user] += amount;
    }

    /**
     * @dev Retrieves the carbon allowance balance for a user.
     * @param user The address of the user.
     * @return The allowance balance.
     */
    function getAllowance(address user) public view returns(uint256){
        return (userToAllowance[user]);
    }

    /**
     * @dev Freezes a portion of a user's carbon allowances. Only callable by the owner.
     * @param user The address of the user.
     * @param amount The amount to freeze.
     */
    function freezeAllowance(address user, uint256 amount) public onlyOwner{
        userToAllowance[user] -= amount;
        userToFrozenAllowance[user] += amount;
    }

    /**
     * @dev Unfreezes a portion of a user's frozen carbon allowances. Only callable by the owner.
     * @param user The address of the user.
     * @param amount The amount to unfreeze.
     */
    function unfreezeAllowance(address user, uint256 amount) public onlyOwner{
        userToAllowance[user] += amount;
        userToFrozenAllowance[user] -= amount;
    }

    /**
     * @dev Retrieves the frozen carbon allowance balance for a user.
     * @param user The address of the user.
     * @return The frozen allowance balance.
     */
    function getFrozenAllowance(address user) public view returns(uint256){
        return userToFrozenAllowance[user];
    }

    /**
     * @dev Destroys a portion of a user's carbon allowances. Only callable by the owner.
     * @param user The address of the user.
     * @param amount The amount to destroy.
     */
    function destroyAllowance(address user, uint256 amount) public onlyOwner{
        userToAllowance[user] -= amount;
    }

    /**
     * @dev Destroys all carbon allowances for a user. Only callable by the owner.
     * @param user The address of the user.
     */
    function destroyAllAllowance(address user) public onlyOwner{
        userToAllowance[user] = 0;
    }

    /**
     * @dev Creates a new trade for carbon allowances. The caller is the seller.
     * Freezes the seller's allowances for the trade.
     * @param tradeId Unique identifier for the trade.
     * @param _amount Total amount of allowances for sale.
     * @param _startamount Starting bid amount.
     * @param _priceOfUnit Price per unit of allowance.
     * @param _startTime Start timestamp of the trade.
     * @param _endTime End timestamp of the trade.
     */
    function createTrade(
        string memory tradeId,
       // address _seller,  谁调用合约谁就是卖家，所以不需要传入卖家地址
        uint256 _amount,
        uint256 _startamount,
        uint256 _priceOfUnit,
        uint256 _startTime,
        uint256 _endTime
    )public {
        if(
            _amount <= 0 ||
            _amount > userToAllowance[msg.sender] ||
            _startamount <= 0 ||
            _priceOfUnit <= 0 ||
            _startTime >= _endTime
        )
        revert CarbonTrader_ParamError();

        Trade storage newTrade = idToTrade[tradeId];
        newTrade.seller = msg.sender;
        newTrade.amount = _amount;
        newTrade.startamount = _startamount;
        newTrade.priceOfUnit = _priceOfUnit;
        newTrade.startTime = _startTime;
        newTrade.endTime = _endTime;
        userToAllowance[msg.sender] -= _amount;
        userToFrozenAllowance[msg.sender] += _amount;

        emit NewTrade(
            msg.sender,
            _amount,
            _startamount,
            _priceOfUnit,
            _startTime,
            _endTime
        );
    }

    /**
     * @dev Retrieves details of a trade.
     * @param tradeId The trade identifier.
     * @return seller The seller's address.
     * @return amount Total allowances in the trade.
     * @return startamount Starting bid amount.
     * @return priceOfUnit Price per unit.
     * @return startTime Start timestamp.
     * @return endTime End timestamp.
     */
    function getTrade(string memory tradeId) public view returns(
        address,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
        ){
            if(idToTrade[tradeId].seller == address(0))
                revert CarbonTrader_TradeNotExist();
            return(
                idToTrade[tradeId].seller,
                idToTrade[tradeId].amount,
                idToTrade[tradeId].startamount,
                idToTrade[tradeId].priceOfUnit,
                idToTrade[tradeId].startTime,
                idToTrade[tradeId].endTime
            );
        
    }

    /**
     * @dev Allows a bidder to deposit tokens for a trade and set bid information.
     * Transfers tokens from bidder to the contract.
     * @param tradeId The trade identifier.
     * @param amount The deposit amount.
     * @param info Encrypted bid information.
     */
    function deposit(string memory tradeId, uint256 amount, string memory info) public {
        Trade storage currentTrade = idToTrade[tradeId];

        bool success = token.transferFrom(msg.sender, address(this), amount);//这里是需要授权吗？为什么不用transfer
        if(!success) 
            revert CarbonTrader_NotEnoughDeposit();
        
        currentTrade.deposit[msg.sender] = amount;
        setBidInfo(tradeId, info);
    }

    /**
     * @dev Retrieves the deposit amount for the caller in a trade.
     * @param tradeId The trade identifier.
     * @return The deposit amount.
     */
    function getDeposit(string memory tradeId) public view returns (uint256){
        return idToTrade[tradeId].deposit[msg.sender];
    }

    /**
     * @dev Refunds the deposit for the caller in a trade.
     * Transfers tokens back to the caller.
     * @param tradeId The trade identifier.
     */
    function  refund(string memory tradeId) public{//任何时候都可以发起退款吗？
        Trade storage currentTrade = idToTrade[tradeId];
        uint256 depositAmount = currentTrade.deposit[msg.sender];

        currentTrade.deposit[msg.sender] = 0;

        bool success = token.transfer(msg.sender,depositAmount);
        if(!success) {
            currentTrade.deposit[msg.sender] = depositAmount;
            revert CarbonTrader_RefoundFailed();
        }
        
        

    }

    /**
     * @dev Sets encrypted bid information for the caller in a trade.
     * @param tradeId The trade identifier.
     * @param info The encrypted information.
     */
    function setBidInfo(string memory tradeId,string memory info) public {
        Trade storage currentTrade = idToTrade[tradeId];
        currentTrade.cryptedInfo[msg.sender] = info; 
    }

    /**
     * @dev Sets the decryption key for the caller's bid in a trade.
     * @param tradeId The trade identifier.
     * @param key The decryption key.
     */
    function setBidKey(string memory tradeId, string memory key) public{
        Trade storage currentTrade = idToTrade[tradeId];
        currentTrade.decrypteKey[msg.sender] = key;
    }

    /**
     * @dev Retrieves the encrypted bid information for the caller in a trade.
     * @param tradeId The trade identifier.
     * @return The encrypted information.
     */
    function getBidInfo(string memory tradeId) public view returns (string memory){
        Trade storage currentTrade = idToTrade[tradeId];
        return currentTrade.cryptedInfo[msg.sender];
    }

    /**
     * @dev Finalizes an auction by transferring allowances and handling payments.
     * Caller must be a bidder. Transfers allowances from seller to buyer and payments to seller's auction balance.
     * @param tradeId The trade identifier.
     * @param allowanceAmount The amount of allowances to transfer.
     * @param additionalAmountToPay Additional tokens to pay beyond deposit.
     */
    function finalizeAuctionAndTransferCarbon(
        string memory tradeId,
        uint256 allowanceAmount,
        uint256 additionalAmountToPay
    ) public {
        uint256 depositAmount = idToTrade[tradeId].deposit[msg.sender]; //这是谁的押金？有那么多人付押金怎么办？碳积分是一对一吗？你要买我的，我只卖给你，而不是放在池子里》最终转给卖家的押金？
        idToTrade[tradeId].deposit[msg.sender]=0;

        //把保证金和新补的钱给卖家
        address seller = idToTrade[tradeId].seller;
        auctionAmount[seller] += (depositAmount + additionalAmountToPay);

        //扣除卖家的碳积分
        userToFrozenAllowance[seller] -= allowanceAmount; //从冻结的碳积分里扣除

        //增加买家的碳积分
        userToAllowance[msg.sender] += allowanceAmount;

        //把买家的钱转到合约里
        bool success = token.transferFrom(msg.sender, address(this), additionalAmountToPay);
        if(!success) revert CarbonTrader_FinalizeAuctionFailed();
        
    }            

    /**
     * @dev Allows a seller to withdraw their accumulated auction proceeds.
     * Transfers tokens from contract to caller.
     */
    function withdrawAuctionAmount() public {  //能调用这个函数的本身就是卖家了
        uint256 withdrawAmount = auctionAmount[msg.sender];
        auctionAmount[msg.sender] = 0;
        bool success = token.transfer(msg.sender, withdrawAmount);//这里是需要授权吗？为什么不用transfer
        if(!success) {
            auctionAmount[msg.sender] = withdrawAmount;
            revert CarbonTrader_TransferFailed();
        }
    }
    //转账操作payable关键字只用于以太币转账，不适用于ERC20代币转账
            //这么多函数方法，如何控制谁能调用什么函数呢？比如买家调用取款函数
}