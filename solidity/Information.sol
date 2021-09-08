pragma solidity >=0.8.7<0.9.0;
pragma experimental ABIEncoderV2;

contract Information {

    struct Ticket {
        ConcertInfo concertInfo;
        Seat seat;
        bool isTransferred; // 양도거래가 가능할 때 false, 양도거래가 이미 진행되고 있을 때 true
        bool isSold;
        address ticketOwner;
    }

    struct ConcertInfo {
        string concertName;
        uint8 concertTheater;
        Date date;
        Time time;
    }

    struct Seat {
        string typeOfSeat;
        uint32 seatNumber;
        uint32 ticketPrice;
    }

    struct Date {
        uint16 year;
        uint8 month;
        uint8 day;
    }

    struct Time {
        uint8 hour;
        uint8 minute;
    }

    struct Theater{
        uint8 vipNum;
        uint8 rNum;
        uint8 aNum;
    }

    Theater one = Theater(3,5,7);
    Theater two = Theater(3,5,4);
    Theater three = Theater(4,6,8);
    
    Theater[] public theaters = [one, two, three];

    
}