// Defining bytecode and abi from original contract on mainnet to ensure bytecode matches and it produces the same pair code hash
const { bytecode, abi } = require('../deployments/mainnet/Employees.json')

module.exports = async function ({ ethers, getNamedAccounts, deployments, getChainId }) {
  const { deploy } = deployments

  const { deployer, dev } = await getNamedAccounts()

  console.log('[deployer]', deployer);
  console.log('[dev]', dev);
  const feedAddress = '0x8A753747A1Fa494EC906cE90E9f37563A8AF630e';
  await deploy('Employees', {
    // contract: {
    //   abi,
    //   bytecode,
    // },
    from: deployer,
    args: [feedAddress],
    log: true,
    deterministicDeployment: false,
  })
}

module.exports.tags = ["Employees"]
