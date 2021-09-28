const Register = artifacts.require("RegisterConcert");
const Trade = artifacts.require("TransferTrade");

contract('Trade', async(accounts) => {
    var registerInstance;
    var tradeInstance;

    var defaultSender = accounts[0]; // 콘서트 등록자

    before(async function() {
        console.log("good1");
        registerInstance = await Register.new();
        tradeInstance = await Trade.new();
    })
    
    describe('Trade', function(){

        beforeEach(async function() {
            console.log("good2");
            await registerInstance.setConcertInfo("EXO", 2, 2021, 9, 10, 19, 30);
            await registerInstance.setTicketsTest(2, 100000, 70000, 50000, defaultSender);
        })
        it('get ticket test', async function(){
            console.log(defaultSender);
            await tradeInstance.getTicketTest(defaultSender, "R", 1);
            // let value = await tradeInstance.getTicketTest.call(defaultSender, "R", 1);
            // console.log(value);
            // assert.equal("EXO", value[0], "Not equal");
            // assert.equal("R", value[1], "Not equal");
            // assert.equal("1", value[2].toString(), "Not equal");
            // assert.equal("70000", value[3].toString(), "Not equal");
            // assert.equal(false, value[4], "Not equal");
            // assert.equal(false, value[5], "Not equal");
        })
        
    })
});