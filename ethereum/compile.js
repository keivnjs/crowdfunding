const path = require('path');
const fs = require('fs-extra');
const solc = require('solc');

const buildPath = path.resolve(__dirname, 'build');

// Delete current build folder
fs.removeSync(buildPath);

const crowdfundingPath = path.resolve(__dirname, 'contracts', 'Campaign.sol');
const source = fs.readFileSync(crowdfundingPath, 'utf8');

const input = {
  language: 'Solidity',
  sources: {},
  settings: {
    metadata: {
      useLiteralContent: true,
    },
    outputSelection: {
      '*': {
        '*': ['*'],
      },
    },
  },
};

input.sources['Campaign.sol'] = {
  content: source,
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));
const contracts = output.contracts['Campaign.sol'];

// Create build folder
fs.ensureDirSync(buildPath);

for (let contract in contracts) {
  if (contracts.hasOwnProperty(contract)) {
    fs.outputJsonSync(
      path.resolve(buildPath, `${contract}.json`),
      contracts[contract]
    );
  }
}
