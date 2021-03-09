const TMath = artifacts.require('TMath');
const BToken = artifacts.require('BToken');
const BFactory = artifacts.require('BFactory');
const BPool = artifacts.require('BPool');
const ExchangeProxyMock = artifacts.require('ExchangeProxyMock');

module.exports = async function (deployer, network, accounts) {
    if (network === 'test' || network === 'development' || network === 'coverage') {
        await deployer.deploy(TMath);
        await deployer.deploy(ExchangeProxyMock);
    }

    await deployer.deploy(BPool)

    // TODO - this should set the ExchangeProxy address from an .env
    await deployer.deploy(BFactory, BPool.address, '0x0000000000000000000000000000000000000000');
};
