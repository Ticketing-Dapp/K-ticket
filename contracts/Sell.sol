// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Sell{
    
    struct ticketInfo{
        uint256 price;
        address payable owner;
        bool isSold;
        bool isTransferred;
    }
    
    //mapping(address => bytes32[]) registerTicket;
    //mapping(address => bytes32[]) buyerTicket;
    mapping(bytes32 => ticketInfo) ticket;
    
    uint256[] theater =  [4, 5, 6];
    
    /**
    * @dev 입력받은 콘서트 정보로 hash 값을 만든다.
    * @return  생성된 hash 값을 반환한다.
    */
    function getHash(uint256 _concert, uint256 _number) public pure returns(bytes32) {
        string memory concert = uint2str(_concert);
        string memory number = uint2str(_number);
        string memory tmp = concat(concert, number);
        bytes32 hashResult = keccak256(abi.encodePacked(tmp));
        return hashResult;
    }
    
    /**
    * @dev 입력받은 콘서트 정보로 hash값을 만들어 ticket 매핑에 추가한다. 
    */
    function registerConcert(uint256 _concert, uint256 _number, uint256 _vipPrice, uint256 _rPrice, uint256 _aPrice) public {
        for(uint i=0; i<_number; i++){
            bytes32 hash = getHash(_concert, i);
            //registerTicket[msg.sender].push(hash);
            
            if(i<theater[0]){
                ticket[hash] = ticketInfo(_vipPrice, payable(msg.sender), false, false);
            }
            else if(i<theater[1]){
                ticket[hash] = ticketInfo(_rPrice, payable(msg.sender), false, false);
            }
            else{
                ticket[hash] = ticketInfo(_aPrice, payable(msg.sender), false, false);
            }
        }
        
    }
    
    /**
    * @dev 입력받은 인자에 해당하는 티켓을 구매한다.
    */
    function buyTicket(uint256 _concert, uint256 _number) public payable {
        bytes32 hash = getHash(_concert, _number);
        require(ticket[hash].isSold == false, "already sold");
        require((msg.sender).balance > ticket[hash].price, "no money");
        ticket[hash].owner.transfer(ticket[hash].price);
        ticket[hash].owner = payable(msg.sender);
        ticket[hash].isSold = true;
        //buyerTicket[msg.sender].push(hash);
    }
    
    /**
    * @dev 입력받은 인자에 해당하는 티켓을 양도거래한다.
    */
    function transferTicket(uint256 _concert, uint256 _number) public payable{
        bytes32 hash = getHash(_concert, _number);
        require(ticket[hash].isTransferred == false, "already transferred");
        ticket[hash].isTransferred = true;
        ticket[hash].owner.transfer(ticket[hash].price);
        ticket[hash].owner = payable(msg.sender);
        //buyerTicket[msg.sender].push(hash);
        ticket[hash].isTransferred = false;
    }
    
    /**
    * @dev 양도 거래할 티켓의 가격을 변경한다.
    */
    function changePrice(uint256 _concert, uint256 _number, uint256 _price) public {
        bytes32 hash = getHash(_concert, _number);
        require(ticket[hash].owner == msg.sender, "not owner");
        require(ticket[hash].price >= _price, "invalid price");
        ticket[hash].price = _price;
    }
    
    /**
    * @dev 입력받은 티켓이 본인 것인지 확인한다.
    * @return  본인 것이 맞다면 true.
    */
    function checkMyTicket(uint256 _concert, uint256 _number) public view returns(bool) {
        bytes32 hash = getHash(_concert, _number);
        require(ticket[hash].owner == msg.sender, "not owner");
        return true;
    }
    
    /**
    * @dev 입력받은 콘서트의 판매 현황을 확인한다.
    * @return  판매되었다면 false, 그렇지 않으면 true.
    */
    function checkMyConcert(uint256 _concert, uint256 _number) public view returns(bool[] memory) {
        bool[] memory result = new bool[](_number);
        for(uint i=0; i<_number; i++){
            bytes32 hash = getHash(_concert, i);
            if(ticket[hash].isSold){
                result[i] = false; // you can't buy
            }
            else{
                result[i] = true; // you can buy
            }
        }
        return result;
    }
    
    // uint to string
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
    
    // string concat
    function concat(string memory _base, string memory _value) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for(i=0; i<_baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for(i=0; i<_valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }
}