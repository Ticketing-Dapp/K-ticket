pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "./Information.sol";

contract RegisterConcert{
    mapping(address => Information.ConcertInfo[]) public MyConcerts; /** 공연등록자 mypage에서 보여줄 때 사용 */
    mapping(Information.ConcertInfo => Information.Ticket[]) public ConcertTicket; 
    Information.Ticket[] Tickets;
    Information.Date public date;
    Information.Time public time;
    Information.ConcertInfo public concertInfo;
    bool[] public sell;

    /**
    * @dev 입력받은 콘서트 정보를 설정한다.
    *      UI에서 받은 데이터로 ConcertInfo 구조체를 생성하고 Concerts 매핑에 추가한다.
    */
    function setConcertInfo(string _concertName, uint8 _concertTheater, uint16 _year, uint8 _month, uint8 _day, uint8 _hour, uint8 _minute) public {
        date = Information.Date(_year, _month, _day);
        time = Information.Time(_hour, _minute);
        concertInfo = Information.ConcertInfo(_concertName, _concertTheater, date, time);
        MyConcerts[msg.sender].push(concertInfo);
    }

    /**
    * @dev 입력받은 티켓 정보를 설정한다.
    *      UI에서 받은 데이터와 setConcertInfo()로 생성한 ConcertInfo 구조체로 Ticket 구조체를 만들고 Tickets 배열을 생성한다.
    */
    function setTickets(uint32 _vipPrice,uint32 _rPrice,uint32 _aPrice) public{
        Information.Theater _theater = Information.theaters[concertInfo.concertTheater];

        for(uint i = 0; i < _theater.vipNum; i++){
            Information.Seat seat = Information.Seat("VIP", i, _vipPrice);
            Tickets[i] = Information.Ticket(concertInfo, seat, false, false, msg.sender);
        }
        for(uint i = _theater.vipNum; i < _theater.rNum + _theater.vipNum; i++){
            Information.Seat seat = Information.Seat("R", i, _rPrice);
            Tickets[i] = Information.Ticket(concertInfo, seat, false, false, msg.sender);
        }
        for(uint i = _theater.rNum + _theater.vipNum; i < _theater.aNum  + _theater.rNum + _theater.vipNum; i++){
            Information.Seat seat = Information.Seat("A", i, _aPrice);
            Tickets[i] = Information.Ticket(concertInfo, seat, false, false, msg.sender);
        }

        ConcertTicket[concertInfo] = Tickets;
        
    }

    /**
    * @dev 티켓의 판매 여부를 확인할 수 있는 함수
    *      UI에서 입력받은 concertInfo를 이용하여 티켓별로 판매되었으면 true, 판매되지 않았으면 false 값을 가지는 bool 배열을 생성한다.
    * @return  판매 여부가 저장된 bool 배열을 반환한다.
    */
    function getConcertTicket(string _concertName, uint8 _concertTheater, uint16 _year, uint8 _month, uint8 _day, uint8 _hour, uint8 _minute) public returns (bool[]){
        date = Information.Date(_year, _month, _day);
        time = Information.Time(_hour, _minute);
        concertInfo = Information.ConcertInfo(_concertName, _concertTheater, date, time);
        Information.Ticket[] _tickets = ConcertTicket[concertInfo];
        
        uint16 length = Information.theaters[_concertTheater].vipNum + Information.theaters[_concertTheater].rNum + Information.theaters[_concertTheater].aNum; 
        sell = new bool[length];
        for(uint i = 0; i < length; i++){
            if (_tickets[i].isSold){/**이미 팔렸으면 true */
                sell[i] = false;     
            }else{
                sell[i] = true;
            }
        }
        return sell;
    }
}