const Trade = artifacts.require("TransferTrade");

contract('Trade', async(accounts) => {

    var tradeInstance;

    var defaultSender = accounts[0]; // 콘서트 등록자
    var buyer = accounts[1]; // 콘서트 구매자
    var transferee = accounts[2]; // 양수인
    let n = 10 ** 10;

    before(async function() {
        tradeInstance = await Trade.new();
    })
    
    describe('Trade', function(){

        before(async function() {
            await tradeInstance.setConcertInfo("EXO", 2, 2021, 9, 10, 19, 30, {from : defaultSender});
            await tradeInstance.setTickets(2, 10*n, 7*n, 5*n, {from : defaultSender});
        })


        it('trade ticket test', async function(){
            // buyer가 티켓을 하나 구매한다.
            
            await tradeInstance.buyTicket(defaultSender, 1, 2, {from: buyer, value: 7*n});
            //await tradeInstance.getTicket(defaultSender, 1, 2);
            //console.log(returnValue);
            // buyer가 티켓을 양도거래 한다고 신청한다. => 이거 함수 하나 만들어야 함.
            await tradeInstance.registerPost({from: buyer});
            // trader가 그 티켓을 양도받는다.
            await tradeInstance.transferTicket(buyer, {from: transferee, value: 7*n});
            // 해당 티켓의 주인이 잘 변했는지 확인한다. => getMyTicket
            let ticketValue = await tradeInstance.getMyTicket.call({from : transferee});
            console.log(ticketValue);

        })
        
    })
});