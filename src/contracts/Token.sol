pragma solidity ^0.4.15;

//import "./Ownable.sol";
import "./SafeMath.sol";

contract Ownable {
  address public owner;

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

contract ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
	uint256 public totalSupply;

    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Token is Ownable {
    using SafeMath for uint256;

    //ERC20
    string public name = "Propthereum";
    string public symbol = "PTC";
    uint8 public decimals;
    uint256 public totalSupply;

    //ICO
    //State values
    uint256 public ethRaised;
    
    uint256[7] public saleStageStartDates = [1510272000,1511136000,1511222400,1511827200,1512432000,1513036800,1513641600];

    //The prices for each stage. The number of tokens a user will receive for 1ETH.
    uint16[6] public tokens = [1800,1650,1500,1450,1425,1400];

    // This creates an array with all balances
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) public allowed;

    address public constant WITHDRAW_ADDRESS = 0x00bcd5e9679b654db151c62b1f5669231f2aa8dcb9;

    function Token() public {
		owner = msg.sender;
        decimals = 18;
        totalSupply = 360000000;
		balances[owner] = totalSupply * 10 ** 18;
	}

    function balanceOf(address who) public constant returns (uint256) {
        return balances[who];
    }

	function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]);

        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(_from,_to, _value);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
		require(_spender != address(0));
        require(allowed[msg.sender][_spender] == 0 || _amount == 0);

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
		require(_owner != address(0));
        return allowed[_owner][_spender];
    }

    //ICO
    function getPreSaleStart() public constant returns (uint256) {
        return saleStageStartDates[0];
    }

    function getPreSaleEnd() public constant returns (uint256) {
        return saleStageStartDates[1];
    }

    function getSaleStart() public constant returns (uint256) {
        return saleStageStartDates[2];
    }

    function getSaleEnd() public constant returns (uint256) {
        return saleStageStartDates[6];
    }

    function inSalePeriod() public constant returns (bool) {
        return (now >= getSaleStart() && now <= getSaleEnd());
    }

    function() public payable {
        buyTokens();
    }

    function buyTokens() public payable {
        require(msg.value > 0);
        require(inSalePeriod() == true);
        require(msg.sender != address(0));

        uint index = getStage();
        uint256 amount = tokens[index];
        amount = amount.mul(msg.value);
        balances[msg.sender] = balances[msg.sender].add(amount);

        ethRaised = ethRaised.add(msg.value);
    }

    function transferEth() public onlyOwner {
        require(now > getSaleEnd() + 1 days);
        WITHDRAW_ADDRESS.transfer(this.balance);
    }

    function burn() public {
        require(now > getSaleEnd() + 1 days);
        //Burn outstanding
        totalSupply = totalSupply.sub(balances[owner]);
        balances[owner] = 0;
    }

    function getStage() public constant returns (uint256) {
        for (uint8 i = 1; i < saleStageStartDates.length; i++) {
            if (now < saleStageStartDates[i]) {
                return i - 1;
            }
        }

        return saleStageStartDates.length - 1;
    }

    event TokenPurchase(address indexed _purchaser, uint256 _value, uint256 _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Withdraw(address indexed _owner, uint256 _value);
}