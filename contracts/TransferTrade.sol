pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "./Information.sol";
import "./RegisterConcert.sol";

contract TransferTrade is Information{

    mapping(address => Information.Ticket) public TicketStore; // 1인 1티켓
    mapping(address => Information.Ticket) public TransferTicketStore; // 양도 거래 중인 ticket

    // 상수
    uint256 constant internal TICKET_PRICE = 5 * 10 ** 15;

    // 변수
    address payable public transferee;
    Information.Ticket public ticket;

    /** 디폴트 티켓 생성
    Seat public defaultSeat = Seat("VIP", 30, TICKET_PRICE);
    Date public defaultDate = Date(2021, 6, 18);
    Time public defaultTime = Time(18, 0);
    ConcertInfo public defaultConcertInfo = ConcertInfo("ohmygirl", defaultDate, defaultTime);
    Ticket public defaultTicket = Ticket(defaultConcertInfo, defaultSeat, false);

    address defaultAddr = 0x1c049AC608CB6B8B748Ed0449B9d592b9CDe2314;
    */

    // 생성자
    constructor() public payable {
        transferee = payable(msg.sender);
    }

    /**
    * @dev Ticket 가져오기
    * @param register 공연 등록자의 지갑 주소를 알면 티켓을 찾아올 수 있다.
    * Seat (_type, _number) : 티켓을 특정하기 위해 Seat 구조체의 변수 내용을 파라미터로 받는다.
    * @return Ticket을 반환한다.
    */
    function getTicket(address register, string memory _type, uint8 _number) public returns (Information.Ticket memory){
        Information.Ticket[] memory temp = Information.MyConcerts[register];
        uint8 _concertTheater = temp[0].concertInfo.concertTheater;
        uint8 vipN = Information.vipNum[_concertTheater];
        uint8 rN = Information.rNum[_concertTheater];
        uint8 aN = Information.aNum[_concertTheater];
        
        if(stringCompare(_type, "VIP")){
            return temp[_number];
        }
        if(stringCompare(_type, "R")){
            return temp[_number + vipN];
        }
        if(stringCompare(_type, "A")){
            return temp[_number + vipN + rN];
        }
    }

    /**
    * @dev 변화된 티켓을 공연 등록자의 티켓 매핑에 반영
    *      양도거래 혹은 티켓구매를 통해 소유주가 변한 티켓을 매핑에 반영한다.
    * @param register 공연 등록자의 지갑 주소를 알면 티켓을 찾아올 수 있다.
    * Seat (_type, _number) : 티켓을 특정하기 위해 Seat 구조체의 변수 내용을 파라미터로 받는다.
    */
    function setTicket(address register, string memory _type, uint8 _number) public{
        Information.Ticket[] memory temp = Information.MyConcerts[register];
        uint16 index;
        uint8 _concertTheater = temp[0].concertInfo.concertTheater;
        uint8 vipN = Information.vipNum[_concertTheater];
        uint8 rN = Information.rNum[_concertTheater];
        uint8 aN = Information.aNum[_concertTheater];
        if(stringCompare(_type, "VIP")){
            index = _number;
        }
        if(stringCompare(_type, "R")){
            index = _number + vipN;
        }
        if(stringCompare(_type, "A")){
            index = _number + vipN + rN;
        }
        temp[index] = ticket;
    }

    /**
    * @dev 티켓 구매 처리 함수
    *      아직 구매가 완료되지 않은 티켓에 대해서 공연 등록자에게 돈을 지불하고, 티켓의 주인을 티켓 구매자로 변경한다.
    * @param register 공연 등록자의 지갑 주소를 알면 티켓을 찾아올 수 있다.
    * Seat (_type, _number) : 티켓을 특정하기 위해 Seat 구조체의 변수 내용을 파라미터로 받는다.
    */
    function buyTicket(address register, string memory _type, uint8 _number) public payable {
        ticket = getTicket(register, _type, _number);
        require(ticket.isSold == false, "Ticket is already sold.");
        pay();
        TicketStore[msg.sender] = ticket;
        setTicket(register, _type, _number);
    }

    /**
    * @dev 양도 신청 처리 함수
    *      양도 거래가 신청된 티켓에 대해서 양도인에게 돈을 지불하고, 티켓의 주인을 양수인으로 변경한다.
    * @param register 공연 등록자의 티켓 관리 매핑 MyConcerts에 반영하기 위해서 사용
    * @param trader 양도인에게 돈을 지불하고, 양도인의 티켓 매핑을 삭제하기 위해서 사용 
    * Seat (_type, _number) : 티켓을 특정하기 위해 Seat 구조체의 변수 내용을 파라미터로 받는다.
    */
    function transferTicket(address register, address trader, string memory _type, uint8 _number) public payable returns (bool){
        ticket = getTicket(trader, _type, _number);
        require(ticket.isTransferred == false, "Already ticket is transferred");
        //TransferTicketStore[trader] = ticket; 양도인이 글을 올렸을 때 해야 함
        transferPay();
        delete TransferTicketStore[trader];
        delete TransferTicketStore[transferee];
        delete TicketStore[trader];
        TicketStore[transferee] = ticket;
        setTicket(register, _type, _number);
        return true;
    }

    /**
    * @dev 티켓을 구매자의 계좌에서 티켓 가격을 받아 공연등록자에게 송금한다.
    *      같은 티켓이 판매되지 않도록 isSold 값을 true로 변경하고, 티켓 소유자를 변경한다.
    */
    function pay() public payable {
        // 현재 가나슈를 실행중이 아니라서 ticket info의 owner 정보가 없어서 주석처리함
        require(msg.value == ticket.seat.ticketPrice, "Not enough ETH");
        ticket.isSold = true;
        ticket.ticketOwner.transfer(ticket.seat.ticketPrice);
        ticket.ticketOwner = payable(msg.sender);
    }

    /**
    * @dev 양수인의 계좌에서 티켓 가격을 받아 양도인에게 송금한다.
    *      양도거래가 진행되는 상태이므로, isTransferred를 true로 변경하여 양도거래가 중복되지 않도록 한다.
    *      양도거래 진행 중이므로 TransferTicketStore에 추가한다.
    */
    function transferPay() public payable {
        // 현재 가나슈를 실행중이 아니라서 ticket info의 owner 정보가 없어서 주석처리함
        require(msg.value == ticket.seat.ticketPrice, "Not enough ETH");
        ticket.isTransferred = true;
        TransferTicketStore[msg.sender] = ticket;
        ticket.ticketOwner.transfer(ticket.seat.ticketPrice);
        ticket.ticketOwner = transferee;
    }

    /**
    * @dev 두 문자열이 일치하는지 비교하기 위한 함수
    */
    function stringCompare(string memory _string1, string memory _string2) public view returns (bool) {
        return (keccak256(abi.encodePacked((_string1))) == keccak256(abi.encodePacked((_string2))));
    }

    /** 
    * @dev 마이페이지에서 소유하고 있는 티켓을 보여준다.
    * @return 콘서트정보와 좌석정보를 반환한다.
    */ 
    function getMyTicket() public returns (string memory, uint8, uint16, uint8, uint8, uint8, uint8, string memory, uint32, uint32){
        Information.Ticket memory myticket = TicketStore[msg.sender];
        require(myticket.seat.seatNumber != 0, "empty");
        
        return (myticket.concertInfo.concertName, myticket.concertInfo.concertTheater, myticket.concertInfo.date.year,
        myticket.concertInfo.date.month, myticket.concertInfo.date.day, myticket.concertInfo.time.hour, myticket.concertInfo.time.minute,
        myticket.seat.typeOfSeat, myticket.seat.seatNumber, myticket.seat.ticketPrice);
    }

    /** 
    * @dev 마이페이지에서 양도거래 중인 티켓을 보여준다.
    * @return 콘서트정보와 좌석정보를  반환한다.
    */ 
    function getMyTransferringTicket() public returns (string memory, uint8, uint16, uint8, uint8, uint8, uint8, string memory, uint32, uint32){
        Information.Ticket memory myticket = TransferTicketStore[msg.sender];
        require(myticket.seat.seatNumber != 0, "empty");
        
        return (myticket.concertInfo.concertName, myticket.concertInfo.concertTheater, myticket.concertInfo.date.year,
        myticket.concertInfo.date.month, myticket.concertInfo.date.day, myticket.concertInfo.time.hour, myticket.concertInfo.time.minute,
        myticket.seat.typeOfSeat, myticket.seat.seatNumber, myticket.seat.ticketPrice);
    }
}

 