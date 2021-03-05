const TMath = artifacts.require('TMath');
const BToken = artifacts.require('BToken');
const BFactory = artifacts.require('BFactory');
const BPool = artifacts.require('BPool');

module.exports = async function (deployer, network, accounts) {
    if (network === 'test' || network === 'development' || network === 'coverage') {
        await deployer.deploy(TMath);
    }

    await deployer.deploy(BPool)

    await deployer.deploy(BFactory, BPool.address, '0x0000000000000000000000000000000000000000');

    console.log(BFactory.address)
};
