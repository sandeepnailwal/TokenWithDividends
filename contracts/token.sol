pragma solidity ^0.4.11;

import './MERC20.sol';
import './SafeMath.sol';

contract token is ERC20 {
    
    using SafeMath for uint256;
    
    struct account{
        uint256 balance;
        uint256 lastDividentPaid;
    }
    uint public _totalSupply=0;
    mapping (address => account) accounts;
    
    string public constant symbol = "MAAR";
    string public constant name = "Maarifa Token";
    uint8 public constant decimals = 18;
    
    //PENDING FEATURES - Sales on off, Change rates
    bool public saleOn = false;
    // per ether rate of your token
    uint256 public constant RATE = 5;
    
    address public owner;
    //to avoid rounding off errors
    const uint pointMultiplier = 10e18;
    uint256 totalDividentPoints;
    uint256 unclaimedDividends;
    
    mapping(address => mapping(address => uint256)) allowed;
    
    function () payable {
        createTokens();
    }
    
    function token() {
        owner = msg.sender;
    }
    
    function toggleSaleStatus(){
        require(msg.sender == owner);
        saleOn = !saleOn;
    }
    
    function createTokens() payable {
        require(msg.value > 0);
        require(saleOn == true);        
        uint256 tokens = msg.value.mul(RATE);
        accounts[msg.sender].balance = accounts[msg.sender].balance.add(tokens);
        _totalSupply = _totalSupply.add(tokens);
        owner.transfer(msg.value);
    }

    function totalSupply() constant returns (uint totalsupply){
        return _totalSupply;
    }
    function balanceOf(address _owner) constant returns (uint balance){
        return accounts[_owner].balance;
    }
    function transfer(address _to, uint _value) returns (bool success){
        require(
            accounts[msg.sender].balance>=_value 
            && _value > 0);
            accounts[msg.sender].balance = accounts[msg.sender].balance.sub(_value);
            accounts[_to].balance = accounts[_to].balance.add(_value);
            Transfer(msg.sender,_to,_value);
            return true;
    }
    function transferFrom(address _from, address _to, uint _value) returns (bool success){
        require(
            allowed[_from][msg.sender]>= _value
            && accounts[_from].balance >= _value
            && _value >0 
            );
            accounts[_from].balance = accounts[_from].balance.sub(_value);
            accounts[_to].balance = accounts[_to].balance.add(_value);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
            Transfer(_from, _to, _value);
            return true;
            
    }
    function approve(address _spender, uint _value) returns (bool success){
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) constant returns (uint remaining){
        return allowed[_owner][_spender];
    }
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
    function dividendOwing(address account) internal returns(uint256){
        var newDividendPoints = totalDividendPoints - accounts[account].lastDividendPoints;
        return (accounts[account].balance*newDividendPoints)/pointMultiplier;
    }
    
    modifier updateAccount(address account) {
        var owing = dividendsOwing(accounts);
        if(owing > 0) {
            unclaimedDividends -=owing;
            accounts[account].balance += owing;
            accounts[account].lastDividendPoints = totalDividendPoints;
        }
        _;
    }
    
    function disburse(uint amount){
        totalDividendPoints += (amount * pointsMultiplier/totalSupply);
        totalSupply += amount;
        unclaimedDividends += amount;
    }
    
}
