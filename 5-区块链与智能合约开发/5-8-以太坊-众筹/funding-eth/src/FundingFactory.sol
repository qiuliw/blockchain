pragma solidity ^0.8.26;
//import './Funding.sol';

contract FundingFactory {
    // 0. 平台管理员：address platformManager

    // 1. 所有的众筹合约集合：	address[] allFundings
    // 2. 创建人的合约集合:  mapping(address => address[]) creatorFundings ; //key是创建人，value是所创建的所有合约的地址集合
    // 3. 参与人的合约集合：mapping(address => address[]) supportorFundings ; //key是创建人，value是所参与的合约的地址集合

    address public platformManager;

    address[] private allFundings; // 1. 所有的众筹合约集合

    mapping(address => address[]) private creatorFundings; //创建人的合约集合

    //mapping(address => address[]) supportorFundings ; //参与人的合约集合
    SupportorFundingContract public supportorFundings; //0x0000000000000;

    constructor() {
        platformManager = msg.sender;

        //在构造函数时候，创建一个全局的SupportorFundingContract合约实例
        supportorFundings = new SupportorFundingContract();
    }

    function createFunding(
        string memory _name,
        uint256 _targetMoney,
        uint256 _supportMoney,
        uint256 _duration
    ) external {
        //创建一个合约，使用new方法，同时传入参数，返回一个地址
        address funding = address(
            new Funding(_name, _targetMoney, _supportMoney, _duration, msg.sender, supportorFundings)
        );
        allFundings.push(funding);

        //维护创建者所创建的合约集合
        creatorFundings[msg.sender].push(funding);
    }

    //返回当前平台的所有的合约
    function getAllFundings() external view returns (address[] memory) {
        return allFundings;
    }

    //返回当前账户所创建所有的合约
    function getCreatorFundings() external view returns (address[] memory) {
        return creatorFundings[msg.sender];
    }

    //获取回当前账户所的参与的合约的集合
    function getSupportorFunding() external view returns (address[] memory) {
        return supportorFundings.getFundings(msg.sender);
    }
}

//这个合约维护者全局所有参与人所参与的所有众筹合约
contract SupportorFundingContract {
    //     功能：mapping(address => address[]) supportorFundings

    // 方法1，添加合约到集合：setFunding(address _supptor, address _funding)

    // 方法2, 读取合约数据：getFundings(address _supptor) returns(address[])

    mapping(address => address[]) private supportorFundingsMap;

    function setFunding(address _supptor, address _funding) external {
        supportorFundingsMap[_supptor].push(_funding);
    }

    function getFundings(address _supptor) external view returns (address[] memory) {
        return supportorFundingsMap[_supptor];
    }
}

contract Funding {
    // 1. 管理员（项目发起人）
    // 2. 项目名称
    // 3. 项目目标筹集金额
    // 4. 每个人支持多少钱
    // 5. 项目持续多少天

    address public manager;
    string public projectName;
    uint256 public targetMoney;
    uint256 public supportMoney;
    //uint256 public duration; //持续时间 秒单位
    uint256 public endTime;

    address[] private investors; //维护所有参与人的结构

    SupportorFundingContract private supportorFundings;

    constructor(
        string memory _projectName,
        uint256 _targetMoney,
        uint256 _supportMoney,
        uint256 _duration,
        address _creator,
        SupportorFundingContract _supportorFundings
    ) {
        // manager = msg.sender;
        manager = _creator;
        projectName = _projectName;
        targetMoney = _targetMoney;
        supportMoney = _supportMoney;
        endTime = block.timestamp + _duration;
        //当前时间+持续时间=终止时间

        //将合约传递给Funding，在构造中接收
        supportorFundings = _supportorFundings;
    }

    //使用一个mapping来判断一个地址是否是投资人，这样可以快速识别是否有投票资格
    mapping(address => bool) private isInvestorMap;

    function invest() external payable {
        require(msg.value == supportMoney);

        investors.push(msg.sender);

        isInvestorMap[msg.sender] = true;

        // 将投资人与当前合约的地址传递到FundingFactory中
        //supportorFundings[msg.sender].push(this);
        supportorFundings.setFunding(msg.sender, address(this));
    }

    //退款函数，由外面（前端）调用
    function refund() external onlyManager {
        for (uint256 i = 0; i < investors.length; i++) {
            (bool ok,) = investors[i].call{value: supportMoney}("");
            require(ok, "refund failed");
        }

        delete investors;
    }

    //产品状态的枚举：0：进行中，1：已批准，2：已完成
    enum RequestStatus {
        Voting,
        Approved,
        Completed
    }

    //定义花费请求，一个请求由项目方发起，由投资人投票
    struct Request {
        string purpose;
        uint256 cost;
        address seller;

        //当前这个请求赞成的投票数量
        uint256 approveCount;
        RequestStatus status;

        //记录投资人对这个请求的投票状态，只有未投票的才能投票，每人仅限一票
        mapping(address => bool) isVotedMap;
    }

    Request[] private allRequests; //所有的花费请求的集合

    function createRequest(string memory _purpose, uint256 _cost, address _seller) external onlyManager {
        Request storage req = allRequests.push();
        req.purpose = _purpose;
        req.cost = _cost;
        req.seller = _seller;
        req.approveCount = 0;
        req.status = RequestStatus.Voting;
    }

    // 1. 检验这个人是否投过票，若未投过，则允许投票，反之退出

    // 2. voteCount数据加1。
    // 3. 将该投票人在investorVotedMap映射中的值设置为true。
    function approveRequest(uint256 i) external {
        //快速识别是否有投票资格
        require(isInvestorMap[msg.sender]);

        //一定要使用storage类型，引用类型，否则无法修改allRequests里面的数据
        Request storage req = allRequests[i];

        //如果已经投过票，直接退出
        require(req.isVotedMap[msg.sender] == false);

        req.approveCount++;

        req.isVotedMap[msg.sender] = true;
    }

    function finalizeRequest(uint256 i) external onlyManager {
        Request storage req = allRequests[i];

        // 0.金额足够，> cost
        require(address(this).balance >= req.cost);

        // 1. 票数过半。
        require(req.approveCount * 2 > investors.length);

        // 2. 执行转账
        (bool ok,) = req.seller.call{value: req.cost}("");
        require(ok, "transfer failed");

        // 3. 更新request的状态
        req.status = RequestStatus.Completed;
    }

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    //s
    function getLeftTime() external view returns (uint256) {
        return endTime - block.timestamp;
    }

    //返回投资人的数量
    function getInvestorsCount() external view returns (uint256) {
        return investors.length;
    }

    //返回当前的所有请求的数量
    function getRequestsCount() external view returns (uint256) {
        return allRequests.length;
    }

    //
    function getRequestByIndex(uint256 i)
        external
        view
        returns (string memory, uint256, address, uint256, RequestStatus)
    {
        Request storage req = allRequests[i];
        return (req.purpose, req.cost, req.seller, req.approveCount, req.status);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getInvestors() external view returns (address[] memory) {
        return investors;
    }
}
