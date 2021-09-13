const Register = artifacts.require("RegisterConcert");

contract('Register', async(accounts) => {
    var registerInstance;

    beforeEach(async function() {
        registerInstance = await Register.new();

    })

    describe('RegisterTest', function(){
        it('register concert test', async function(){
            await registerInstance.setConcertInfo("EXO", 2, 2021, 9, 10, 19, 30);
            let value = await registerInstance.getConcertInfo.call();
            console.log(value);
            assert.equal("EXO", value, "Not equal");
        })
    })
});