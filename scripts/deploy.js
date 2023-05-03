const main = async () => {
  const domainContractFactory = await hre.ethers.getContractFactory('Domains');
  const domainContract = await domainContractFactory.deploy("card");
  await domainContract.deployed();

  console.log("Contract deployed to:", domainContract.address);

  // // CHANGE THIS DOMAIN TO SOMETHING ELSE! I don't want to see OpenSea full of tobis lol
  // let txn = await domainContract.register("tobi",  {value: hre.ethers.utils.parseEther('0.5')});
  // await txn.wait();
  // console.log("Minted domain tobi.card");

  // txn = await domainContract.setRecord("tobi", "Tobi official domain");
  // await txn.wait();
  // console.log("Set record for tobi.card");

  // const address = await domainContract.getAddress("tobi");
  // console.log("Owner of domain tobi:", address);

  const balance = await hre.ethers.provider.getBalance(domainContract.address);
  console.log("Contract balance:", hre.ethers.utils.formatEther(balance));
}

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();