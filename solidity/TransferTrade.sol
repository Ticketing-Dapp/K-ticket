pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

contract TransferTrade {

    mapping(address => Ticket) public TicketStore;

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

    // 상수
    uint256 constant internal TICKET_PRICE = 5 * 10 ** 15;

    // 변수
    address payable public transferee;

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
    * @dev 티켓 구매 설정
    * @param t : 구매하고자 하는 티켓
    * @param addr : 구매자
     */
    function setter(Ticket t, address addr) public {
        TicketStore[addr] = t;
    }

    /**
    * @dev DefaultTicket 가져오기
    */
    function getDefaultTicket() public {
        emit GetDefaultTicket(defaultTicket.concertName, defaultTicket.day, defaultTicket.time, defaultTicket.seat, defaultTicket.ticketPrice, defaultTicket.owner);
    }

    /**
    * @dev 양도 신청 처리 함수
    */
    function transferApplication() public payable returns (bool){
        // alreadyTransferringTicket을 확인, 임시로 데모를 위해 require만을 사용하여 거래가 진행중인지 확인한다.
        require(defaultTicket.isTransferred == false, "Already ticket is transferred");

        // pay
        pay();

        // changeTicketInfo
        changeTicketInfo();

        return true;
    }

    /**
    * @dev 이미 거래중인 티켓인 경우
    */
    function alreadyTransferringTicket() internal returns (bool result){
        return false;
    }

    /**
    * @dev 양수인의 계좌에서 티켓 가격을 받아 양도인에게 송금한다.
    */
    function pay() public payable {
        // 현재 가나슈를 실행중이 아니라서 ticket info의 owner 정보가 없어서 주석처리함
        require(msg.value == TICKET_PRICE, "Not enough ETH");

        defaultTicket.isTransferred = true; // 지불을 진행할 수 있는 상태이기 때문에, 양도거래 진행 중임을 표시한다.
        defaultTicket.owner.transfer(TICKET_PRICE);
        emit FinishPay(transferee);
    }

    /**
    * @dev 양도거래가 끝난 티켓의 정보를 수정한다.
    */
    function changeTicketInfo() public returns (address) {
        // owner change
        // 현재 가나슈를 실행중이 아니라서 ticket info의 owner 정보가 없어서 주석처리함
        defaultTicket.owner = transferee;
        return defaultTicket.owner;
    }

    /**
    * @dev 마이페이지에서 진행중인 양도거래 티켓을 보여준다.
    *      (지불이 끝나야 거래 성사가 되는 것이기 때문에, 이는 양도인에게만 보여주면 된다.)
    * @return 콘서트 이름을 반환한다. (이는 테스트를 위한 용도이다.)
    */
    function getMyTransferringTicket() public returns (string memory){
        require(defaultTicket.isTransferred == false, "Ticket trade is completed.");
        emit GetMyTransferringTicket(defaultTicket.concertName, defaultTicket.day, defaultTicket.time, defaultTicket.seat.typeOfSeat, defaultTicket.seat.seatNumber, defaultTicket.ticketPrice);
        string memory name = defaultTicket.concertName;
        return name;
    }

    /**
    * @dev 마이페이지에서 소유하고 있는 티켓을 보여준다.
    * @return 콘서트 이름과 현재 티켓 소유주를 반환한다. (이는 테스트를 위한 용도이다.)
    * 
    */
    function getMyTicket() public returns (string memory, address){
        require(msg.sender == defaultTicket.owner, "You aren't owner.. So it's impossible confirm.");
        emit GetMyTicket(defaultTicket.concertName, defaultTicket.day, defaultTicket.time, defaultTicket.seat.typeOfSeat, defaultTicket.seat.seatNumber, defaultTicket.ticketPrice);
        string memory name = defaultTicket.concertName;
        address ownerAddress = defaultTicket.owner;
        return (name, ownerAddress);
    }
}