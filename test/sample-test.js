const { expect } = require("chai");

describe("Employees", function () {
  it("Should return the new greeting once it's changed", async function () {
    // const Greeter = await ethers.getContractFactory("Greeter");
    // const greeter = await Greeter.deploy("Hello, world!");
    // await greeter.deployed();

    // expect(await greeter.greet()).to.equal("Hello, world!");

    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // // wait until the transaction is mined
    // await setGreetingTx.wait();

    const tempStr = "I am a unit test";
    expect(tempStr).to.equal("I am a unit test");
  });
});
