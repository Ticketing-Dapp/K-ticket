const Register = artifacts.require("RegisterConcert");

contract('Register', async(accounts) => {
    var registerInstance;

    beforeEach(async function() {
        registerInstance = await Register.new();

    })
    var defaultSender = accounts[0];
    describe('RegisterTest', function(){
        it('register concert test', async function(){  
            //setting ConcertInfo
            await registerInstance.setConcertInfo("EXO", 2, 2021, 9, 10, 19, 30);
            let value = await registerInstance.getConcertInfo.call();
            assert.equal("EXO", value[0], "Not equal");
            assert.equal("2", value[1].toString(), "Not equal");
            assert.equal("2021", value[2].toString(), "Not equal");
            assert.equal("9", value[3].toString(), "Not equal");
            assert.equal("10", value[4].toString(), "Not equal");
            assert.equal("19", value[5].toString(), "Not equal");
            assert.equal("30", value[6].toString(), "Not equal");

            //create Tickets
            await registerInstance.setTicketsTest(2, 100000, 70000, 50000, defaultSender);
            let valu = await registerInstance.getTickets.call(defaultSender);
            console.log(valu);
            
        })
        
    })
});