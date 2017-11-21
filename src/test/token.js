const ICO = artifacts.require("Token");
//const assertJump = require("./assertJump.js");
const tokenName = 'P';
const decimalUnits = 18;
const tokenSymbol = 'P';

const durationTime = 28; //4 weeks

const timeController = (() => {
  
    const addSeconds = (seconds) => new Promise((resolve, reject) =>
      web3.currentProvider.sendAsync({
        jsonrpc: "2.0",
        method: "evm_increaseTime",
        params: [seconds],
        id: new Date().getTime()
      }, (error, result) => error ? reject(error) : resolve(result.result)));
  
    const addDays = (days) => addSeconds(days * 24 * 60 * 60);
  
    const currentTimestamp = () => web3.eth.getBlock(web3.eth.blockNumber).timestamp;
  
    return {
      addSeconds,
      addDays,
      currentTimestamp
    };
  })();
  
async function advanceToBlock(number) {
  await timeController.addDays(number);
}

contract('Propthereum Token', function(accounts) {
  beforeEach(async function () {
    this.token = await Token.new(accounts[0]);
  });

  it("should have symbol PTC", async function () {
    const actual = await this.token.symbol();
    assert.equal(actual, tokenSymbol, "Symbol should be PTC");
  });

  it("should have name Propthereum", async function () {
    const actual = await this.token.name();
    assert.equal(actual, tokenName, "Name should be Propthereum");
  });

  it("should put 360,000,000 PTC to supply and in the first account", async function () {
    const balance = await this.token.balanceOf(accounts[0]);
    const supply = await this.token.totalSupply();
    assert.equal(balance.valueOf(), 500000000 * 10 ** 18, "First account (owner) balance must be 500000000000000");
    assert.equal(supply.valueOf(), 500000000, "Supply must be 500000000");
  });

  // it('should not allow buy before the sale', async function () {
  //   advanceToBlock(-durationTime);
  //   try {
  //     await this.token.sendTransaction({value: web3.toWei(1, 'ether'), from: accounts[1]});
  //     //var num = tokensPerEther * 1.3 * 10 ** 18;
  //     const balance = await this.token.balanceOf(accounts[1]).valueOf();
  //     assert.equal(balance, 4000, 'Buyer one token balance mismatch');

  //   } catch (error) {
  //     return assertJump(error);
  //   }
  //   assert.fail('should have thrown before');
  // });

  it("should get sale start", async function () {
    const expected = 1512086400;
    const balance = await this.token.getSaleStart();
    assert.equal(balance.valueOf(), expected, "Date should be 1512086400");
  });

  it("should get first stage date", async function () {
    const expected = 1512086400;
    const balance = await this.token.saleStageStartDates(0);
    assert.equal(balance.valueOf(), expected, "Date should be 1512086400");
  });

  it("should get second stage date", async function () {
    const expected = 1514764800;
    const balance = await this.token.saleStageStartDates(1);
    assert.equal(balance.valueOf(), expected, "Date should be 1514764800");
  });

  it("should get third stage date", async function () {
    const expected = 1515369600;
    const balance = await this.token.saleStageStartDates(2);
    assert.equal(balance.valueOf(), expected, "Date should be 1515369600");
  });

  it("should get fourth stage date", async function () {
    const expected = 1515974400;
    const balance = await this.token.saleStageStartDates(3);
    assert.equal(balance.valueOf(), expected, "Date should be 1515974400");
  });

  it("should get fifth stage date", async function () {
    const expected = 1516579200;
    const balance = await this.token.saleStageStartDates(4);
    assert.equal(balance.valueOf(), expected, "Date should be 1516579200");
  });

  it("should get sale end", async function () {
    const expected = 1517183999;
    const balance = await this.token.getSaleEnd();
    assert.equal(balance.valueOf(), expected, "Date should be 1517183999");
  });

  it("should get current stage", async function () {
    const expected = 0;
    const actual = await this.token.getStage();
    assert.equal(actual.valueOf(), expected, "Index should be 0");
  });

  it("should get stage 1", async function () {
    const currentTimestamp = () => web3.eth.getBlock(web3.eth.blockNumber).timestamp;
    //console.log(currentTimestamp());
    advanceToBlock(30);

    const expected = 1;
    const actual = await this.token.getStage();
    assert.equal(actual.valueOf(), expected, "Index should be 1");
  });
});