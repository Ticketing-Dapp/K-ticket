const Register = artifacts.require("RegisterConcert");

contract('Register', function(accounts){
    let register;

    beforeEach(async () => {
        register = await Register.new();

    })

    describe('RegisterTest', function(){
        it('register concert test', async()=>{
            await register.setConcertInfo('EXO', 2, 2021, 9, 10, 19, 30);
            let value = await register.getConcertInfo();
            assert.equal("EXO", value, "Not equal");
        })
    })
});