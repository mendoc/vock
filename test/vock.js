const Vock = artifacts.require("Vock");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Vock", function (/* accounts */) {
  it("should assert true", async function () {
    await Vock.deployed();
    return assert.isTrue(true);
  });
});
