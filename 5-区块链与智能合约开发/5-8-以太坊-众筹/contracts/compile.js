const fs = require('fs');
const path = require('path');
const solc = require('solc');

const source = fs.readFileSync(path.join(__dirname, 'Funding.sol'), 'utf8');
const output = solc.compile(source, 1);

if (output.errors) {
  output.errors.forEach((e) => console.warn(e.formattedMessage || e.message));
  if (output.errors.some((e) => e.severity === 'error' || !e.severity)) process.exit(1);
}

const contract = output.contracts[':Funding'];
if (!contract) {
  console.error('Funding contract not found');
  process.exit(1);
}

const abi = JSON.parse(contract.interface);
console.log('OK Funding.sol:Funding');
console.log('abi items:', abi.length);
console.log('bytecode length:', contract.bytecode.length);
