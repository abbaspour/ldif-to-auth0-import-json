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
    //console.log(JSON.stringify(record.toObject().attributes, null, '  '));
    let dest = objectMapper(record.toObject().attributes, map.map);
    //console.log(JSON.stringify(dest));
    //process.stdout.write(JSON.stringify(dest, Object.keys(dest).sort(), argv.space));
    process.stdout.write(stringify(dest, {space: argv.space}));
    record = file.shift();
    if(record != null)
        console.log(',')
} while (record != null)

console.log("\n]");
