/* eslint-disable import/no-extraneous-dependencies */
/* eslint-disable camelcase */
require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');

let INFURA_PROJECT_ID;
let MNEMONIC;
let GAS_PRICE;

function getConfigs() {
    const INFURA_PROJECT_IDfn = process.env.INFURA_PROJECT_ID;
    const MNEMONICfn = process.env.MNEMONIC || '';
    const GAS_PRICEfn = process.env.GAS_PRICE || 150000000000; // 150GWei


    if (!INFURA_PROJECT_IDfn || !MNEMONICfn) {
        throw new Error('Wrong configs');
    }

    return [INFURA_PROJECT_IDfn, MNEMONICfn, GAS_PRICEfn];
}

if (process.env.NODE_ENV !== 'test') {
    [INFURA_PROJECT_ID, MNEMONIC, GAS_PRICE] = getConfigs();
}

module.exports = {
    networks: {
        development: {
            provider: () => new HDWalletProvider({
                mnemonic: MNEMONIC,
                providerOrUrl: 'http://localhost:8545',
            }),
            network_id: '*', // Any network (default: none)
            gas: 10000000,
            gasPrice: GAS_PRICE,
        },
        coverage: {
            host: 'localhost',
            network_id: '*',
            port: 8555,
            gas: 0xfffffffffff,
            gasPrice: 0x01,
        },
        rinkeby: {
            provider: () => new HDWalletProvider({
                mnemonic: MNEMONIC,
                providerOrUrl: `https://rinkeby.infura.io/v3/${INFURA_PROJECT_ID}`,
            }),
            network_id: 4,
            gas: 10000000,
            gasPrice: GAS_PRICE,
            skipDryRun: true,
        },
        kovan: {
            provider: () => new HDWalletProvider({
                mnemonic: MNEMONIC,
                providerOrUrl: `https://kovan.infura.io/v3/${INFURA_PROJECT_ID}`,
            }),
            network_id: 42,
            gas: 10000000,
            gasPrice: GAS_PRICE,
            skipDryRun: true,
        },
        goerli: {
            provider: () => new HDWalletProvider({
                mnemonic: MNEMONIC,
                providerOrUrl: `https://goerli.infura.io/v3/${INFURA_PROJECT_ID}`,
            }),
            network_id: 5,
            gas: 10000000,
            gasPrice: GAS_PRICE,
            skipDryRun: true,
        },
        mainnet: {
            provider: () => new HDWalletProvider({
                mnemonic: MNEMONIC,
                providerOrUrl: `https://mainnet.infura.io/v3/${INFURA_PROJECT_ID}`,
            }),
            network_id: 1,
            gas: 10000000,
            gasPrice: GAS_PRICE,
            timeoutBlocks: 200,
        },
    },
    // Configure your compilers
    compilers: {
        solc: {
            version: '0.7.4',
            settings: {
                // See the solidity docs for advice about optimization and evmVersion
                optimizer: {
                    enabled: true,
                    runs: 100,
                },
                // evmVersion: 'byzantium',
            },
        },
    },
    plugins: ['truffle-contract-size', 'truffle-plugin-verify'],
    api_keys: {
        etherscan: process.env.ETHERSCAN_API_ID,
    },
};
