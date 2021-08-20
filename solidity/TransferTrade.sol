pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./Information.sol";
import "./RegisterConcert.sol";

contract TransferTrade {

    mapping(address => Information.Ticket[]) public TicketStore;

    // 상수
    uint256 constant internal TICKET_PRICE = 5 * 10 ** 15;

    // 변수
    address payable public transferee;
    Information.Ticket public ticket;

    // 디폴트 티켓 생성
    Seat public defaultSeat = Seat("VIP", 30, TICKET_PRICE);
    Date public defaultDate = Date(2021, 6, 18);
    Time public defaultTime = Time(18, 0);
    ConcertInfo public defaultConcertInfo = ConcertInfo("오마이걸", defaultDate, defaultTime);
    Ticket public defaultTicket = Ticket(defaultConcertInfo, defaultSeat, false);

    address defaultAddr = 0x1c049AC608CB6B8B748Ed0449B9d592b9CDe2314;

    // 이벤트
    event GetMyTransferringTicket(string concertName, string day, string time, string typeOfSeat, uint32 seatNumber, uint32 ticketPrice);
    event GetMyTicket(string concertName, string day, string time, string typeOfSeat, uint32 seatNumber, uint32 ticketPrice);
    event FinishPay(address transferee);
    event GetDefaultTicket(string concertName, string day, string time, Seat defaultSeat, uint32 ticketPrice, address owner);

    // 생성자
    constructor() public payable {
        transferee = msg.sender;
    }

    /**
    * @dev Ticket 가져오기
    * @param _concertInfo
    * @param Seat (_type, _number)
    *        티켓을 특정하기 위해 concertInfo와 Seat 구조체의 변수 내용을 파라미터로 받는다.
    * @return Ticket을 반환한다.
    */
    function getTicket(Information.ConcertInfo _concertInfo, string _type, uint8 _number) public returns (Ticket){
        temp = RegisterConcert.ConcertTickets[_concertInfo];
        
        if(stringCompare(_type, "VIP")){
            return temp[_number];
        }
        if(stringCompare(_type, "R")){
            return temp[_number + Information.theaters[_concertInfo.concertTheater].vipNum];
        }
        if(stringCompare(_type, "A")){
            return temp[_number + Information.theaters[_concertInfo.concertTheater].vipNum + Information.theaters[_concertInfo.concertTheater].rNum];
        }

    }

    /**
    * @dev 변화된 티켓을 매핑에 반영
    *      양도거래 혹은 티켓구매를 통해 소유주가 변한 티켓을 매핑에 반영한다.
    * @param _concertInfo
    * @param Seat (_type, _number)
    *        티켓을 특정하기 위해 concertInfo와 Seat 구조체의 변수 내용을 파라미터로 받는다.
    */
    function setTicket(Information.ConcertInfo _concertInfo, string _type, uint8 _number) public{
        temp = RegisterConcert.ConcertTickets[_concertInfo];
        uint16 index;
        
        if(stringCompare(_type, "VIP")){
            index = _number;
        }
        if(stringCompare(_type, "R")){
            index = _number + Information.theaters[_concertInfo.concertTheater].vipNum;
        }
        if(stringCompare(_type, "A")){
            index = _number + Information.theaters[_concertInfo.concertTheater].vipNum + Information.theaters[_concertInfo.concertTheater].rNum;
        }
        temp[index] = ticket;
    }

    /**
    * @dev 티켓 구매 처리 함수
    *      아직 구매가 완료되지 않은 티켓에 대해서 공연 등록자에게 돈을 지불하고, 티켓의 주인을 티켓 구매자로 변경한다.
    * @param concertInfo _concertName, _concertTheater, Date(_year, _month, _day), Time(_hour, _minute)
    * @param Seat (_type, _number)
             티켓을 특정하기 위해 concertInfo와 Seat 구조체의 변수 내용을 파라미터로 받는다.
    */
    function buyTicket(string _concertName, uint8 _concertTheater, uint16 _year, uint8 _month, uint8 _day, uint8 _hour, uint8 _minute, string _type, uint8 _number) public payable {
        date = Information.Date(_year, _month, _day);
        time = Information.Time(_hour, _minute);
        concertInfo = Information.ConcertInfo(_concertName, _concertTheater, date, time);

        ticket = getTicket(concertInfo, _type, _number);
        require(ticket.isSold == false, "Ticket is already sold.");
        pay(ticket);
        TicketStore[msg.sender].push(ticket);
        setTicket(concertInfo, _type, _number);
    }

    /**
    * @dev 양도 신청 처리 함수
    *      양도 거래가 신청된 티켓에 대해서 양도인에게 돈을 지불하고, 티켓의 주인을 양수인으로 변경한다.
    *      이때, 양도인이 여러 개의 티켓을 가지고 있을 수 있으므로, 양도 거래가 완료된 티켓을 제외한 다른 티켓들은 소유주가 변하지 않도록 한다.
    * @param concertInfo _concertName, _concertTheater, Date(_year, _month, _day), Time(_hour, _minute)
    * @param Seat (_type, _number)
             티켓을 특정하기 위해 concertInfo와 Seat 구조체의 변수 내용을 파라미터로 받는다.
    */
    function transferApplication(string _concertName, uint8 _concertTheater, uint16 _year, uint8 _month, uint8 _day, uint8 _hour, uint8 _minute, string _type, uint8 _number) public payable returns (bool){
        date = Information.Date(_year, _month, _day);
        time = Information.Time(_hour, _minute);
        concertInfo = Information.ConcertInfo(_concertName, _concertTheater, date, time);

        ticket = getTicket(concertInfo, _type, _number);
        require(ticket.isTransferred == false, "Already ticket is transferred");
        address oldOwner = ticket.ticketOwner;
        Ticket[] oldTicket = TicketStore[oldOwner];
        Ticket[] newTicket;
        for(uint i = 0; i < oldTicket.lenght; i++){
            if(ticketCompare(oldTicket[i], ticket) == false){
                newTicket.push(oldTicket[i]);
            }
        }
        transferPay(ticket);
        TicketStore[oldOwner] = newTicket;
        TicketStore[transferee].push(ticket);
        setTicket(concertInfo, _type, _number);
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
        ticket.ticketOwner = msg.sender;
    }

    /**
    * @dev 양수인의 계좌에서 티켓 가격을 받아 양도인에게 송금한다.
    *      양도거래가 진행되는 상태이므로, isTransferred를 true로 변경하여 양도거래가 중복되지 않도록 한다.
    */
    function transferPay() public payable {
        // 현재 가나슈를 실행중이 아니라서 ticket info의 owner 정보가 없어서 주석처리함
        require(msg.value == ticket.seat.ticketPrice, "Not enough ETH");
        ticket.isTransferred = true;
        ticket.ticketOwner.transfer(ticket.seat.ticketPrice);
        ticket.ticketOwner = transferee;
    }

    /**
    * @dev 두 문자열이 일치하는지 비교하기 위한 함수
    */
    function stringCompare(string _string1, string _string2) public returns (bool) {
        return (keccak256(_string1) == keccak256(_string2));
    }

    /**
    * @dev 두 ticket이 일치하는지 비교하기 위한 함수
    *      티켓이 일치하는지 확인하기 위해서는 ConcertInfo와 Seat 구조체의 변수 값들을 모두 확인해야 한다.
    */
    function ticketCompare(Information.Ticket _ticket1, Information.Ticket _ticket2) public returns (bool){
        if(stringCompare(_ticket1.concertInfo.concertName, _ticket2.concertInfo.concertName) == false){
            return false;
        }
        if(_ticket1.concertInfo.concertTheater != _ticket2.concertInfo.concertTheater){
            return false;
        }
        if(_ticket1.concertInfo.date.year != _ticket2.concertInfo.date.year ){
            return false;
        }
        if(_ticket1.concertInfo.date.month != _ticket2.concertInfo.date.month ){
            return false;
        }
        if(_ticket1.concertInfo.date.day != _ticket2.concertInfo.date.day ){
            return false;
        }
        if(_ticket1.concertInfo.time.hour != _ticket2.concertInfo.time.hour){
            return false;
        }
        if(_ticket1.concertInfo.time.minute != _ticket2.concertInfo.time.minute ){
            return false;
        }
        if(stringCompare(_ticket1.seat.typeOfSeat, _ticket2.seat.typeOfSeat) == false){
            return false;
        }
        if(_ticket1.seat.seatNumber != _ticket2.seat.seatNumber){
            return false;
        }
        if(_ticket1.seat.ticketPrice != _ticket2.seat.ticketPrice){
            return false;
        }
        return true;
    }
}

/**
    ... 수정해서 써야 하는 함수들

    // @dev 마이페이지에서 진행중인 양도거래 티켓을 보여준다.
    //      (지불이 끝나야 거래 성사가 되는 것이기 때문에, 이는 양도인에게만 보여주면 된다.)
    // @return 콘서트 이름을 반환한다. (이는 테스트를 위한 용도이다.)
    //
    function getMyTransferringTicket() public returns (string memory){
        Ticket[] ticketList = TicketStore[msg.sender];
        Ticket[] transferredTicket;
        for(uint i=0; i<TicketList.length; i++){
            // 양도거래 글이 작성되었다는 것을 isTransferred라는 함수로 알 수 없음.
            if(ticketList[i].isTransferred == true){
                transferredTicket.push(ticketList[i]);
            }
        }
        // 티켓을 어떻게 넘겨줄 수 있을까?
        // 양도거래 티켓이 여러 개면 어떻게 넘겨줄 수 있는지 모르겠다.

        string memory name = defaultTicket.concertName;
        return name;
    }

    //
    // @dev 마이페이지에서 소유하고 있는 티켓을 보여준다.
    // @return 콘서트 이름과 현재 티켓 소유주를 반환한다. (이는 테스트를 위한 용도이다.)
    // 
    function getMyTicket() public returns (string memory, address){
        require(msg.sender == defaultTicket.owner, "You aren't owner.. So it's impossible confirm.");
        emit GetMyTicket(defaultTicket.concertName, defaultTicket.day, defaultTicket.time, defaultTicket.seat.typeOfSeat, defaultTicket.seat.seatNumber, defaultTicket.ticketPrice);
        string memory name = defaultTicket.concertName;
        address ownerAddress = defaultTicket.owner;
        return (name, ownerAddress);
    }
*/
/**
    ... 현재 쓰지 않는 함수들
    
    // @dev 티켓 구매시 구매자의 주소에 티켓을 매핑하는 함수 - pay 함수 아직 사용 안 함
    // @param t : 구매하고자 하는 티켓
    // @param addr : 구매자
    //
    function setter(Ticket t, address addr) public {
        TicketStore[addr] = t;
    }

    // @dev 이미 거래중인 티켓인 경우
    function alreadyTransferringTicket() internal returns (bool result){
        return false;
    }

    // @dev 양도거래가 끝난 티켓의 정보를 수정한다.
    function changeTicketInfo() public returns (address) {
        // owner change
        // 현재 가나슈를 실행중이 아니라서 ticket info의 owner 정보가 없어서 주석처리함
        defaultTicket.owner = transferee;
        return defaultTicket.owner;
    }
*/    
