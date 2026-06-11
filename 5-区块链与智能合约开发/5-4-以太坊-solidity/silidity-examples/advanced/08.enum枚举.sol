// 测试命令: forge test --match-path "test/basic/Basic08Enum.t.sol" -vv
pragma solidity ^0.8.26;

contract Test {
   
    enum WeekDays {
        Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    }
    
    WeekDays currentDay;
    WeekDays defaultday = WeekDays.Sunday;
    
    function setDay(WeekDays _day) public {
        currentDay = _day;
    }
    
    function getDay() public view returns(WeekDays) {
        //return uint256(currentDay);
        return currentDay;
    }
    
    function getDefaultDay() public view returns(uint256) {
        return uint256(defaultday);   
    }
}