const Trade = artifacts.require("TransferTrade");

contract('Trade', async(accounts) => {

    var tradeInstance;

    var defaultSender = accounts[0]; // 콘서트 등록자
    var buyer = accounts[1]; // 콘서트 구매자
    var transferee = accounts[2]; // 양수인

    before(async function() {
        tradeInstance = await Trade.new();
    })
    
    describe('Trade', function(){

        before(async function() {
            await tradeInstance.setDate(2021, 9, 10);
            await tradeInstance.setTime(19, 30);
            await tradeInstance.setConcertInfo("EXO", 2, {from : defaultSender});
            await tradeInstance.setTicketsTest(2, 100000, 70000, 50000, defaultSender);
        })
        // it('get ticket test', async function(){
        //     await tradeInstance.getTicket(defaultSender, 1, 1);
        //     let value = await tradeInstance.getTicketTest.call();
        //     console.log(value);
            
        // })
        // it('buy ticket test', async function(){
        //     let TicketPrice = 5 * 10 ** 15;
        //     await tradeInstance.buyTicketTest(defaultSender, 1, 2, buyer, {from: defaultSender, value: TicketPrice});
        //     //await tradeInstance.getTicket(defaultSender, 1, 2);
        //     //console.log(returnValue);

        //     let value2 = await tradeInstance.getTicketTest.call();
        //     console.log(value2[0], value2[1]);
        //     let boolValue = await tradeInstance.getConcertTicketTest.call(defaultSender);
        //     console.log(boolValue);

        // })

        it('trade ticket test', async function(){
            // buyer가 티켓을 하나 구매한다.
            let TicketPrice = 5 * 10 ** 15;
            await tradeInstance.buyTicketTest(defaultSender, 1, 2, buyer, {from: defaultSender, value: TicketPrice});
            //await tradeInstance.getTicket(defaultSender, 1, 2);
            //console.log(returnValue);
            // buyer가 티켓을 양도거래 한다고 신청한다. => 이거 함수 하나 만들어야 함.
            await tradeInstance.registerPostTest(buyer);
            // trader가 그 티켓을 양도받는다.
            await tradeInstance.transferTicketTest(buyer, transferee, {from: transferee, value: TicketPrice});
            // 해당 티켓의 주인이 잘 변했는지 확인한다. => getMyTicket
            let ticketValue = await tradeInstance.getMyTicketTest.call(transferee);
            console.log(ticketValue);

        })
        
    })
});