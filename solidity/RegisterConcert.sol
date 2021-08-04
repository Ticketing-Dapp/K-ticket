pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./Information.sol";

contract RegisterConcert{
    mapping(Information.ConcertInfo => address) public Concerts;
    Information.Ticket[][] Tickets;
    Information.Date public date;
    Information.Time public time;
    Information.ConcertInfo public concertInfo;

    /**
     * @dev 입력받은 콘서트 정보를 설정한다.
            UI에서 받은 데이터로 ConcertInfo 구조체를 생성하고 Concerts 매핑에 추가한다.
     */
    function setConcertInfo(string _concertName, uint16 _year, uint8 _month, uint8 _day, uint8 _hour, uint8 _minute) public {
        date = Information.Date(_year, _month, _day);
        time = Information.Time(_hour, _minute);
        concertInfo = Information.ConcertInfo(_concertName, date, time);
        Concerts[concertInfo] = msg.sender;
    }

    /**
     * @dev 입력받은 티켓 정보를 설정한다.
            UI에서 받은 데이터와 setConcertInfo()로 생성한 ConcertInfo 구조체로 Ticket 구조체를 만들고 Tickets 배열을 생성한다.
     */
    function setTickets(uint8 _number, uint32 _vipPrice,uint32 _rPrice,uint32 _aPrice) public{
        Information.Theater theater = Information.theaters[_number];

        for(uint i = 0; i < theater.vipNum; i++){
            Information.Seat seat = Information.Seat("VIP", i, _vipPrice);
            Tickets[0][i] = Information.Ticket(concertInfo, seat, false);
        }
        for(uint i = 0; i < theater.rNum; i++){
            Information.Seat seat = Information.Seat("R", i, _rPrice);
            Tickets[1][i] = Information.Ticket(concertInfo, seat, false);
        }
        for(uint i = 0; i < theater.aNum; i++){
            Information.Seat seat = Information.Seat("A", i, _aPrice);
            Tickets[2][i] = Information.Ticket(concertInfo, seat, false);
        }
        
    }

}