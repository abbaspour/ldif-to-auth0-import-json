const ldif = require("ldif");
const fs = require("fs");
const objectMapper = require("object-mapper");
const stringify = require('json-stable-stringify');

const yargs = require("yargs/yargs");
const {hideBin} = require("yargs/helpers");
const argv = yargs(hideBin(process.argv)).argv;
const map = require("./" + argv.map).map;

const file = ldif.parse(fs.readFileSync(argv.input, 'utf8'));

const generator = function* () {
    let r = file.shift();
    while (r != null) {
        yield r.toObject().attributes;
        r = file.shift();
    }
}();

const is_empty_salt = (o) => Object.keys(o.custom_password_hash.salt).length === 0;

function writeNextBatch(generator, filename, max_size) {
    const stream = fs.createWriteStream(filename);
    let first = true;
    let fileSize = 3;

    let record = generator.next();
    while (!record.done && fileSize < max_size) {
        const dest = objectMapper(record.value, map);
        if(is_empty_salt(dest)) delete dest.custom_password_hash.salt;
        const entry = stringify(dest, {space: argv.space});
        fileSize += (entry.length + 2);
        stream.write(first ? "[\n" : ",\n");
        stream.write(entry);
        first = false;
        record = generator.next();
    }
    //console.error(fileSize);

    stream.write(first ? '' : "\n]\n");
    stream.end();

    return record.done;
}

const zeroPad = (num, places) => String(num).padStart(places, '0')
const outputFileName = (prefix, index) => prefix + '_' + zeroPad(index, 5) + ".json"

let fileIndex = 1;
let done = true;

do {
    done = writeNextBatch(generator, outputFileName(argv.output, fileIndex++), parseInt(argv.size, 10) * 1000);
    if (argv.progress) process.stdout.write('.');
} while (!done)

if (argv.progress) process.stdout.write('\n');