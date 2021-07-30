pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

contract Information {

    struct Ticket {
        ConcertInfo concertInfo;
        Seat seat;
        bool isTransferred; // 양도거래가 가능할 때 false, 양도거래가 이미 진행되고 있을 때 true
    }

    struct ConcertInfo {
        string concertName;
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

}