const ldif = require("ldif");
const fs = require("fs");
const objectMapper = require("object-mapper");
const stringify = require('json-stable-stringify');
const map = require("./map");

const yargs = require("yargs/yargs");
const {hideBin} = require("yargs/helpers");
const argv = yargs(hideBin(process.argv)).argv;

const file = ldif.parse(fs.readFileSync(argv.input, 'utf8'));

console.log('[');

let record = file.shift();
do {
    let dest = objectMapper(record.toObject().attributes, map.map);
    process.stdout.write(stringify(dest, {space: argv.space}));
    record = file.shift();
    if(record != null) console.log(',')
} while (record != null)

console.log("\n]");
