// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7<0.9.0;
pragma experimental ABIEncoderV2;

import "./Information.sol";

contract TransferTrade{

    mapping(address => Information.Ticket[]) public MyConcerts;
    mapping(address => Information.Ticket) public TicketStore; // 1인 1티켓
    mapping(address => Information.Ticket) public TransferTicketStore; // 양도 거래 중인 ticket

    // 상수
    uint8[] vipNum = [3, 3, 4] ;
    uint8[] rNum = [5, 5, 6];
    uint8[] aNum = [7, 4 ,8];
    uint8 VIP = 0;
    uint8 R = 1;
    uint8 A = 2;
    
    // 변수
    address payable public transferee;
    Information.Ticket public ticket;

    Information.Ticket[] public Tickets;
    Information.Date public date;
    Information.Time public time;
    Information.ConcertInfo public concertInfo;    

    /**
    * @dev 입력받은 콘서트 정보를 설정한다.
    *      UI에서 받은 데이터로 ConcertInfo 구조체를 생성한다.
    */
    function setConcertInfo(string memory _concertName, uint8 _concertTheater) public {
        concertInfo = Information.ConcertInfo(msg.sender, _concertName, _concertTheater, date, time);
    }

    function setDate(uint16 _year, uint8 _month, uint8 _day) public{
        date = Information.Date(_year, _month, _day);   
    }

    function setTime(uint8 _hour, uint8 _minute) public{
        time = Information.Time(_hour, _minute);  
    }

    /**
    * @dev 입력받은 티켓 정보를 설정한다.
    *      UI에서 받은 데이터와 setConcertInfo()로 생성한 ConcertInfo 구조체로 Ticket 구조체를 만들고 Tickets 배열을 생성한다.
    *      그리고 이를 공연등록자가 관리할 수 있도록 MyConcerts 매핑에 추가한다.
    */
    function setTickets(uint8 _concertTheater, uint32 _vipPrice, uint32 _rPrice, uint32 _aPrice) public{
        uint8 vipN = vipNum[_concertTheater];
        uint8 rN = rNum[_concertTheater];
        uint8 aN = aNum[_concertTheater];
        
        for(uint32 i = 0; i < vipN; i++){
            Information.Seat memory seat = Information.Seat(VIP, i, _vipPrice);
            Tickets.push(Information.Ticket(concertInfo, seat, false, false, payable(msg.sender)));
        }
        for(uint32 i = vipN; i < rN + vipN; i++){
            Information.Seat memory seat = Information.Seat(R, i, _rPrice);
            Tickets.push(Information.Ticket(concertInfo, seat, false, false, payable(msg.sender)));
        }
        for(uint32 i = rN + vipN; i < aN  + rN + vipN; i++){
            Information.Seat memory seat = Information.Seat(A, i, _aPrice);
            Tickets.push(Information.Ticket(concertInfo, seat, false, false, payable(msg.sender)));
        }

        MyConcerts[msg.sender] = Tickets;
        
    }

    /**
    * @dev 티켓의 판매 여부를 확인할 수 있도록 UI에 제공하기 위한 함수
    *      공연 등록은 하나밖에 할 수 없기 때문에, 인자로 받는 것 없이 공연 등록자의 주소만 있으면 확인할 수 있다.
    *      UI에서 입력받은 concertInfo를 이용하여 티켓별로 판매되었으면 true, 판매되지 않았으면 false 값을 가지는 bool 배열을 생성한다.
    * @return  판매 여부가 저장된 bool 배열을 반환한다.
    */
    function getConcertTicket() public returns (bool[] memory){
        Information.Ticket[] memory _tickets = MyConcerts[msg.sender];
        uint8 _concertTheater = _tickets[0].concertInfo.concertTheater;
        uint8 vipN = vipNum[_concertTheater];
        uint8 rN = rNum[_concertTheater];
        uint8 aN = aNum[_concertTheater];
        uint16 length = vipN + rN + aN; 
        bool[] memory sell = new bool[](length);
        for(uint i = 0; i < length; i++){
            if (_tickets[i].isSold){/**이미 팔렸으면 true */
                sell[i] = false;     //false - 못사
            }else{
                sell[i] = true;      //true - 살 수 있어
            }
        }
        return sell;
    }  
   
    // 생성자
    constructor() public payable {
        transferee = payable(msg.sender);
    }

    /**
    * @dev Ticket 가져오기
    * @param register 공연 등록자의 지갑 주소를 알면 티켓을 찾아올 수 있다.
    * Seat (_type, _number) : 티켓을 특정하기 위해 Seat 구조체의 변수 내용을 파라미터로 받는다.
    */
    function getTicket(address register, uint8 _type, uint32 _number) public {
        Information.Ticket[] memory temp = MyConcerts[register];
        uint8 _concertTheater = temp[0].concertInfo.concertTheater;
        uint8 vipN = vipNum[_concertTheater];
        uint8 rN = rNum[_concertTheater];
        
        if(_type==VIP){
            ticket = temp[_number];
        }
        else if(_type==R){
            ticket = temp[_number + vipN];
        }
        else if(_type==A){
            ticket = temp[_number + vipN + rN];
        }
    }

    function setTicket(address register, uint8 _type, uint32 _number) public{
        Information.Ticket[] storage temp = MyConcerts[register];
        uint32 index;
        uint8 _concertTheater = temp[0].concertInfo.concertTheater;
        uint8 vipN = vipNum[_concertTheater];
        uint8 rN = rNum[_concertTheater];
        if(_type==VIP){
            index = _number;
        }
        else if(_type==R){
            index = _number + vipN;
        }
        else if(_type==A){
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
    function buyTicket(address register, uint8 _type, uint32 _number) public payable {
        require(ticket.isSold == false, "Ticket is already sold.");
        getTicket(register, _type, _number);
        pay();
        TicketStore[msg.sender] = ticket;
        setTicket(register, _type, _number);
    }

    /**
    * @dev 양도 신청 처리 함수
    *      양도 거래가 신청된 티켓에 대해서 양도인에게 돈을 지불하고, 티켓의 주인을 양수인으로 변경한다.
    * @param trader 양도인에게 돈을 지불하고, 양도인의 티켓 매핑을 삭제하기 위해서 사용
    */
    function transferTicket(address trader) public payable returns (bool){
        // + trader가 글을 올린 상태여야 함.
        require(ticket.isTransferred == false, "Already ticket is transferred");
        ticket = TicketStore[trader];
        transferPay();
        delete TransferTicketStore[trader];
        delete TransferTicketStore[transferee];
        delete TicketStore[trader];
        TicketStore[transferee] = ticket;
        setTicket(ticket.concertInfo.concertRegister, ticket.seat.typeOfSeat, ticket.seat.seatNumber);
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
    * @dev 마이페이지에서 소유하고 있는 티켓을 보여준다.
    * @return 콘서트정보와 좌석정보를 반환한다.
    */ 
    function getMyTicket() public returns (string memory, uint8, uint16, uint8, uint8, uint8, uint8, uint8, uint32, uint32){
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
    function getMyTransferringTicket() public returns (string memory, uint8, uint16, uint8, uint8, uint8, uint8, uint8, uint32, uint32){
        Information.Ticket memory myticket = TransferTicketStore[msg.sender];
        require(myticket.seat.seatNumber != 0, "empty");
        
        return (myticket.concertInfo.concertName, myticket.concertInfo.concertTheater, myticket.concertInfo.date.year,
        myticket.concertInfo.date.month, myticket.concertInfo.date.day, myticket.concertInfo.time.hour, myticket.concertInfo.time.minute,
        myticket.seat.typeOfSeat, myticket.seat.seatNumber, myticket.seat.ticketPrice);
    }

    // buyer가 구매한 티켓을 양도거래 신청을 함.
    function registerPost(address buyer) public {
        TransferTicketStore[buyer] = TicketStore[buyer];
    }


     /**
    * @dev Test 용 
    */
    function getConcertInfo() public returns (string memory, uint8, uint16, uint8, uint8, uint8, uint8){
        return (concertInfo.concertName, concertInfo.concertTheater, 
                concertInfo.date.year, concertInfo.date.month, concertInfo.date.day,
                concertInfo.time.hour, concertInfo.time.minute);
    }

    function getTickets(address _sender) public returns (string memory, uint8, uint32, uint32, bool, bool, string memory, uint8, uint32, uint32, bool, bool){
        Information.Ticket[] memory t = MyConcerts[_sender];
        uint256 len = t.length-1;
        return (t[0].concertInfo.concertName, 
                t[0].seat.typeOfSeat, t[0].seat.seatNumber, t[0].seat.ticketPrice, 
                t[0].isTransferred, t[0].isSold, t[len].concertInfo.concertName, 
                t[len].seat.typeOfSeat, t[len].seat.seatNumber, t[len].seat.ticketPrice, 
                t[len].isTransferred, t[len].isSold);
    }

    function getConcertTicketTest(address _sender) public returns (bool[] memory){
        Information.Ticket[] memory _tickets = MyConcerts[_sender];
        uint8 _concertTheater = _tickets[0].concertInfo.concertTheater;
        uint8 vipN = vipNum[_concertTheater];
        uint8 rN = rNum[_concertTheater];
        uint8 aN = aNum[_concertTheater];
        uint16 length = vipN + rN + aN; bool[] memory sell = new bool[](length);
        for(uint i = 0; i < length; i++){
            if (_tickets[i].isSold){/**이미 팔렸으면 true */
                sell[i] = false;     
            }else{
                sell[i] = true;
            }
        }
        return sell;
    }

    function setTicketsTest(uint8 _concertTheater, uint32 _vipPrice, uint32 _rPrice, uint32 _aPrice, address payable _sender) public{
        uint8 vipN = vipNum[_concertTheater];
        uint8 rN = rNum[_concertTheater];
        uint8 aN = aNum[_concertTheater];
        for(uint32 i = 0; i < vipN; i++){
            Information.Seat memory seat = Information.Seat(VIP, i, _vipPrice);
            Tickets.push(Information.Ticket(concertInfo, seat, false, false, _sender));
        }
        for(uint32 i = vipN; i < rN + vipN; i++){
            Information.Seat memory seat = Information.Seat(R, i, _rPrice);
            Tickets.push(Information.Ticket(concertInfo, seat, false, false, _sender));
        }
        for(uint32 i = rN + vipN; i < aN  + rN + vipN; i++){
           Information. Seat memory seat = Information.Seat(A, i, _aPrice);
            Tickets.push(Information.Ticket(concertInfo, seat, false, false, _sender));
        }

        MyConcerts[_sender] = Tickets;
        
    }
    
    function getTicketTest () public returns (uint8, uint32){
        return (ticket.seat.typeOfSeat, ticket.seat.seatNumber);
    }

    function buyTicketTest (address register, uint8 _type, uint32 _number, address _sender) public payable {
        require(ticket.isSold == false, "Ticket is already sold.");
        getTicket(register, _type, _number);
        payTest(_sender);
        TicketStore[_sender] = ticket;
        setTicket(register, _type, _number);
    }

    function payTest(address _sender) public payable{
        //require(msg.value == ticket.seat.ticketPrice, "Not enough ETH");
        ticket.isSold = true;
        ticket.ticketOwner.transfer(ticket.seat.ticketPrice);
        ticket.ticketOwner = payable(_sender);
    }

    // buyer가 구매한 티켓을 양도거래 신청을 함.
    function registerPostTest(address buyer) public {
        TransferTicketStore[buyer] = TicketStore[buyer];
    }

    function transferTicketTest(address buyer, address trader) public payable returns (bool){
        // buyer : 티켓의 원래 주인, trader : 양수인
        require(ticket.isTransferred == false, "Already ticket is transferred");
        //TransferTicketStore[trader] = ticket; 양도인이 글을 올렸을 때 해야 함
        ticket = TicketStore[buyer];
        transferPayTest(trader);
        delete TransferTicketStore[buyer];
        delete TransferTicketStore[trader];
        delete TicketStore[buyer];
        TicketStore[trader] = ticket;
        setTicket(ticket.concertInfo.concertRegister, ticket.seat.typeOfSeat, ticket.seat.seatNumber);
        return true;
    }

    function transferPayTest(address trader) public payable {
        // 현재 가나슈를 실행중이 아니라서 ticket info의 owner 정보가 없어서 주석처리함
        // require(msg.value == ticket.seat.ticketPrice, "Not enough ETH");
        ticket.isTransferred = true;
        TransferTicketStore[trader] = ticket;
        ticket.ticketOwner.transfer(ticket.seat.ticketPrice);
        ticket.ticketOwner = payable(trader);
    }

    function getMyTicketTest(address trader) public returns (string memory, uint8, uint16, uint8, uint8, uint8, uint8, uint8, uint32, uint32){
        Information.Ticket memory myticket = TicketStore[trader];
        require(myticket.seat.seatNumber != 0, "empty");
        
        return (myticket.concertInfo.concertName, myticket.concertInfo.concertTheater, myticket.concertInfo.date.year,
        myticket.concertInfo.date.month, myticket.concertInfo.date.day, myticket.concertInfo.time.hour, myticket.concertInfo.time.minute,
        myticket.seat.typeOfSeat, myticket.seat.seatNumber, myticket.seat.ticketPrice);
    }

}

 