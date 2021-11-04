// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Sell{
    
    struct ticketInfo{
        uint256 price;
        address owner;
        bool isTransferred;
    }
    
    mapping(bytes32 => ticketInfo) ticket;
    
    uint256[] theater =  [4, 5, 6];
    
    /**
    * @dev 입력받은 콘서트 정보로 hash 값을 만든다.
    * @param _concert 공연 번호
    * @param _number 좌석 번호
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
    * @param _concert 공연 번호
    * @param _number 좌석 수
    * @param _vipPrice VIP 좌석의 가격
    * @param _rPrice R 좌석의 가격
    * @param _aPrice A 좌석의 가격
    */
    function registerConcert(uint256 _concert, uint256 _number, uint256 _vipPrice, uint256 _rPrice, uint256 _aPrice) public {
        for(uint i=0; i<_number; i++){
            bytes32 hash = getHash(_concert, i);
            
            if(i<theater[0]){
                ticket[hash] = ticketInfo(_vipPrice, msg.sender, false);
            }
            else if(i<theater[1]){
                ticket[hash] = ticketInfo(_rPrice, msg.sender, false);
            }
            else{
                ticket[hash] = ticketInfo(_aPrice, msg.sender, false);
            }
        }
        
    }
    
    /**
    * @dev 입력받은 인자에 해당하는 티켓을 구매한다.
    * @param _concert 공연 번호
    * @param _number 좌석 번호
    */
    function buyTicket(uint256 _concert, uint256 _number) public {
        bytes32 hash = getHash(_concert, _number);
        ticket[hash].owner = msg.sender;
    }
    
    /**
    * @dev 입력받은 인자에 해당하는 티켓을 양도거래한다.
    * @param _concert 공연 번호
    * @param _number 좌석 수
    */
    function transferTicket(uint256 _concert, uint256 _number) public {
        bytes32 hash = getHash(_concert, _number);
        require(ticket[hash].isTransferred == false, "already transferred");
        ticket[hash].isTransferred = true;
        ticket[hash].owner = msg.sender;
        ticket[hash].isTransferred = false;
    }
    
    /**
    * @dev 양도 거래할 티켓의 가격을 설정한다.
    * @param _concert 공연 번호
    * @param _number 좌석 번호
    * @param _price 설정할 가격
    */
    function setPrice(uint256 _concert, uint256 _number, uint256 _price) public {
        bytes32 hash = getHash(_concert, _number);
        require(ticket[hash].owner == msg.sender, "not owner");
        require(ticket[hash].price >= _price, "invalid price");
        ticket[hash].price = _price;
    }
    
    /**
    * @dev 입력받은 티켓이 본인 것인지 확인한다.
    * @param _concert 공연 번호
    * @param _number 좌석 번호
    * @return  본인 것이 맞다면 true.
    */
    function checkMyTicket(uint256 _concert, uint256 _number) public view returns(bool) {
        bytes32 hash = getHash(_concert, _number);
        require(ticket[hash].owner == msg.sender, "not owner");
        return true;
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