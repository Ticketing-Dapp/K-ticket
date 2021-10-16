const Sell = artifacts.require("Sell");

contract('Sell', async(accounts) => {

    var sellInstance;

    var defaultSender = accounts[0]; // 콘서트 등록자
    var buyer = accounts[1]; // 콘서트 구매자
    var transferee = accounts[2]; // 양수인
    let n = 10 ** 10;

    before(async function() {
        sellInstance = await Sell.new();
    })
    
    describe('Sell', function(){

        before(async function() {
            await sellInstance.registerConcert(0, 15, 10*n, 7*n, 5*n, {from : defaultSender});         
        })


        it('sell ticket test', async function(){
            // buyer가 티켓을 하나 구매한다.
            
            await sellInstance.buyTicket(0, 6, {from: buyer, value: 7*n});
            let ticketValue = await sellInstance.checkMyTicket.call(0, 6, {from : buyer});
            let concert = await sellInstance.checkMyConcert(0, 15, {from : defaultSender});
            console.log(ticketValue);
            console.log(concert);

            let checkValue1 = await sellInstance.checkMyTicket.call(0, 6, {from : buyer});
            console.log("checkValue : "+checkValue1);
            
            await sellInstance.changePrice.call(0, 6, 5*n, {from : buyer});
            // await sellInstance.changePrice.call(0, 6, 10*n, {from : buyer});
            // await sellInstance.changePrice.call(0, 6, 5*n, {from : defaultSender});
            
        })
        
    })
});