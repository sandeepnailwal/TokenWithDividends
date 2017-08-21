pragma solidity ^0.4.11;

import './MERC20.sol';
import './SafeMath.sol';

contract token is ERC20 {
    
    using SafeMath for uint256;
    
    uint public _totalSupply=0;
    mapping (address => uint256) balances;
    
    string public constant symbol = "MAAR";
    string public constant name = "Maarifa Token";
    uint8 public constant decimals = 18;
    bool public saleOn = false;
    // per ether rate of your token
    uint256 public constant RATE = 500;
    
    address public owner;
    
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
        
        uint256 tokens = msg.value.mul(RATE);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        _totalSupply = _totalSupply.add(tokens);
        owner.transfer(msg.value);
    }

    function totalSupply() constant returns (uint totalsupply){
        return _totalSupply;
    }
    function balanceOf(address _owner) constant returns (uint balance){
        return balances[_owner];
    }
    function transfer(address _to, uint _value) returns (bool success){
        require(
            balances[msg.sender]>=_value 
            && _value > 0);
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender,_to,_value);
            return true;
    }
    function transferFrom(address _from, address _to, uint _value) returns (bool success){
        require(
            allowed[_from][msg.sender]>= _value
            && balances[_from] >= _value
            && _value >0 
            );
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
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
    
}
