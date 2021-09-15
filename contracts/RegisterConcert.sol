pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "./Information.sol";

contract RegisterConcert is Information{
    /**
    * 공연등록자 mypage에서 보여줄 때 사용
    * 공연 등록은 한 개로 제한한다.
    */
    
    Information.Ticket[] public Tickets;
    Information.Date public date;
    Information.Time public time;
    Information.ConcertInfo public concertInfo;

    event settingConcertInfo(string concertName);
    event checkConcertInfo(string concertName);
    event checkTicketCreate(string concertName);
    event checkSetTicket(string concertName);
    

    /**
    * @dev 입력받은 콘서트 정보를 설정한다.
    *      UI에서 받은 데이터로 ConcertInfo 구조체를 생성한다.
    */
    function setConcertInfo(string memory _concertName, uint8 _concertTheater, uint16 _year, uint8 _month, uint8 _day, uint8 _hour, uint8 _minute) public {
        date = Information.Date(_year, _month, _day);
        time = Information.Time(_hour, _minute);
        concertInfo = Information.ConcertInfo(_concertName, _concertTheater, date, time);
        emit settingConcertInfo(_concertName);
    }

    /**
    * @dev 입력받은 티켓 정보를 설정한다.
    *      UI에서 받은 데이터와 setConcertInfo()로 생성한 ConcertInfo 구조체로 Ticket 구조체를 만들고 Tickets 배열을 생성한다.
    *      그리고 이를 공연등록자가 관리할 수 있도록 MyConcerts 매핑에 추가한다.
    */
    function setTickets(uint8 _concertTheater, uint32 _vipPrice, uint32 _rPrice, uint32 _aPrice) public{
        uint8 vipN = Information.vipNum[_concertTheater];
        uint8 rN = Information.rNum[_concertTheater];
        uint8 aN = Information.aNum[_concertTheater];
        
        for(uint32 i = 0; i < vipN; i++){
            Information.Seat memory seat = Information.Seat("VIP", i, _vipPrice);
            Tickets.push(Information.Ticket(concertInfo, seat, false, false, payable(msg.sender)));
        }
        for(uint32 i = vipN; i < rN + vipN; i++){
            Information.Seat memory seat = Information.Seat("R", i, _rPrice);
            Tickets.push(Information.Ticket(concertInfo, seat, false, false, payable(msg.sender)));
        }
        for(uint32 i = rN + vipN; i < aN  + rN + vipN; i++){
            Information.Seat memory seat = Information.Seat("A", i, _aPrice);
            Tickets.push(Information.Ticket(concertInfo, seat, false, false, payable(msg.sender)));
        }

        Information.MyConcerts[msg.sender] = Tickets;
        
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
        uint8 vipN = Information.vipNum[_concertTheater];
        uint8 rN = Information.rNum[_concertTheater];
        uint8 aN = Information.aNum[_concertTheater];
        uint16 length = vipN + rN + aN; 
        bool[] memory sell = new bool[](length);
        for(uint i = 0; i < length; i++){
            if (_tickets[i].isSold){/**이미 팔렸으면 true */
                sell[i] = false;     
            }else{
                sell[i] = true;
            }
        }
        return sell;
    }
    
    /**
    * @dev Test 용 
    */
    function getConcertInfo() public returns (string memory, uint8, uint16, uint8, uint8, uint8, uint8){
        emit checkConcertInfo(concertInfo.concertName);
        return (concertInfo.concertName, concertInfo.concertTheater, 
                concertInfo.date.year, concertInfo.date.month, concertInfo.date.day,
                concertInfo.time.hour, concertInfo.time.minute);
    }

    function getTickets(address _sender) public returns (string memory, string memory, uint32, uint32, bool, bool, string memory, string memory, uint32, uint32, bool, bool){
        Information.Ticket[] memory t = MyConcerts[_sender];
        uint256 len = t.length-1;
        emit checkTicketCreate(t[0].concertInfo.concertName);
        return (t[0].concertInfo.concertName, 
                t[0].seat.typeOfSeat, t[0].seat.seatNumber, t[0].seat.ticketPrice, 
                t[0].isTransferred, t[0].isSold, t[len].concertInfo.concertName, 
                t[len].seat.typeOfSeat, t[len].seat.seatNumber, t[len].seat.ticketPrice, 
                t[len].isTransferred, t[len].isSold);
    }

    function getConcertTicketTest(address _sender) public returns (bool[] memory){
        Information.Ticket[] memory _tickets = MyConcerts[_sender];
        uint8 _concertTheater = _tickets[0].concertInfo.concertTheater;
        uint8 vipN = Information.vipNum[_concertTheater];
        uint8 rN = Information.rNum[_concertTheater];
        uint8 aN = Information.aNum[_concertTheater];
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
        uint8 vipN = Information.vipNum[_concertTheater];
        uint8 rN = Information.rNum[_concertTheater];
        uint8 aN = Information.aNum[_concertTheater];
        emit checkSetTicket(concertInfo.concertName);
        for(uint32 i = 0; i < vipN; i++){
            Information.Seat memory seat = Information.Seat("VIP", i, _vipPrice);
            Tickets.push(Information.Ticket(concertInfo, seat, false, false, _sender));
        }
        for(uint32 i = vipN; i < rN + vipN; i++){
            Information.Seat memory seat = Information.Seat("R", i, _rPrice);
            Tickets.push(Information.Ticket(concertInfo, seat, false, false, _sender));
        }
        for(uint32 i = rN + vipN; i < aN  + rN + vipN; i++){
            Information.Seat memory seat = Information.Seat("A", i, _aPrice);
            Tickets.push(Information.Ticket(concertInfo, seat, false, false, _sender));
        }

        MyConcerts[_sender] = Tickets;
        
    }

}