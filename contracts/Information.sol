// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7<0.9.0;
pragma experimental ABIEncoderV2;

/**
 * contract file에서 사용할 구조체 정의
 */

library Information {
    /**
     * @dev 티켓 정보를 담은 구조체
     */
    struct Ticket {
        ConcertInfo concertInfo;
        Seat seat;
        bool isTransferred; // 양도거래가 가능할 때 false, 양도거래가 이미 진행되고 있을 때 true
        bool isSold;
        address payable ticketOwner;
    }
    /**
     * @dev 콘서트 정보를 담은 구조체
     */
    struct ConcertInfo {
        address concertRegister;
        string concertName;
        uint8 concertTheater;
        Date date;
        Time time;
    }
    /**
     * @dev 좌석 정보를 담은 구조체
     */
    struct Seat {
        uint8 typeOfSeat;
        uint32 seatNumber;
        uint256 ticketPrice;
    }
    /**
     * @dev 날짜 정보를 담은 구조체
     */
    struct Date {
        uint16 year;
        uint8 month;
        uint8 day;
    }
    /**
     * @dev 시간 정보를 담은 구조체
     */
    struct Time {
        uint8 hour;
        uint8 minute;
    }
    
}