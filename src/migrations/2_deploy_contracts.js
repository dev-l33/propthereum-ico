var SafeMath = artifacts.require("./SafeMath.sol");
var Ownable = artifacts.require("./Ownable.sol");
//var ERC20 = artifacts.require("./ERC20.sol");
var Token = artifacts.require("./Token.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, Ownable);
  deployer.deploy(Ownable);
  //deployer.deploy(ERC20);
  //deployer.deploy(Token);
  //deployer.link(Token, Ownable);
  //deployer.deploy(ERC20);
  // deployer.link(Ownable, Token);
  deployer.deploy(Token);
};