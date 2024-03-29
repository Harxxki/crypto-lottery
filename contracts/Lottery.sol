pragma solidity ^0.5.0;

// TODO 賞金用と購入用を分けてお財布を管理する

contract LotteryContract {
    
    address payable seller;
    uint price = 0.05 ether;
    uint prize = 0.1 ether;
    struct Lottery {
        uint16 lotteryNumber;
        bool isSold;
        bool isWon;
        address purchaser;
    }
    Lottery[] lotteryCollection;

    event Buy(address indexed _purcheser, uint _lotteryNumber);
    event Win(address indexed _purcheser, uint _lotteryNumber);
    event Reject(address indexed _purcheser, uint _lotteryNumber);
    
    constructor () public {
        seller = msg.sender;
    }
    
    modifier onlySeller {
        require(msg.sender == seller);
        _;
    }
    
    modifier onlyPurchaser(uint _lotteryNumber) {
        require(lotteryCollection[_lotteryNumber].purchaser == msg.sender);
        _;
    }

    modifier onlyNotSoldOut {
        bool isSoldOut = true;
        for (uint i = 0; i < lotteryCollection.length; i++){
            if (!lotteryCollection[i].isSold){
                isSoldOut = false;
                break;
            }
        }
        require(!isSoldOut);
        _;
    }
    
    function createLottery(uint _number, uint _winNumber) public onlySeller {
        require(_winNumber <= _number);
        for(uint16 i = 0; i < _number; i++){ lotteryCollection.push(Lottery(i, false, false, address(0))); }
        uint _counter = 0;
        uint _randNonce = 0;
        uint _rand;
        while (_counter < _winNumber) {
            _rand = randMod(_randNonce, _number);
            _randNonce++;
            if (lotteryCollection[_rand].isWon == false){
                lotteryCollection[_rand].isWon = true;
                _counter++;
            }
        }
    }
    
    function buy(uint _randNonce) public payable onlyNotSoldOut returns(uint) {
        uint _lotteryNumber;
        do{
            _lotteryNumber = randMod(_randNonce, lotteryCollection.length); 
        } while (lotteryCollection[_lotteryNumber].isSold);
        lotteryCollection[_lotteryNumber].isSold = true;
        lotteryCollection[_lotteryNumber].purchaser = msg.sender;
        emit Buy(msg.sender, _lotteryNumber);
        // seller.transfer(msg.value);
        return _lotteryNumber;
    }
  
    function check(uint _lotteryNumber) public onlyPurchaser(_lotteryNumber) payable {
        if (lotteryCollection[_lotteryNumber].isWon) {
            msg.sender.transfer(prize);
            emit Win(msg.sender, _lotteryNumber);
        } else {
            emit Reject(msg.sender, _lotteryNumber);
        }
    }
    
    function randMod(uint _randNonce, uint _modulus) internal view returns(uint) {
        return uint(keccak256(abi.encode(now, msg.sender, _randNonce))) % _modulus;
    }
    
}