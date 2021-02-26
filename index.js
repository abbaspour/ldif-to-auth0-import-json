const ldif = require("ldif");
const fs = require("fs");
const objectMapper = require("object-mapper");
const stringify = require('json-stable-stringify');
const map = require("./map").map;

const yargs = require("yargs/yargs");
const {hideBin} = require("yargs/helpers");
const argv = yargs(hideBin(process.argv)).argv;

const file = ldif.parse(fs.readFileSync(argv.input, 'utf8'));

const generator = function* () {
    let r = file.shift();
    while (r != null) {
        yield r.toObject().attributes;
        r = file.shift();
    }
}();

function writeNextBatch(generator, filename, max_size) {
    const stream = fs.createWriteStream(filename);

    stream.write("[\n");
    let fileSize = 4;

    let record = generator.next();
    while (!record.done && fileSize < max_size) {
        const dest = objectMapper(record.value, map);
        const entry = stringify(dest, {space: argv.space});
        fileSize += (entry.length + 1);
        stream.write(entry);
        record = generator.next();
        if (!record.done && fileSize < max_size) {
            fileSize++;
            stream.write(",\n");
        }
    }
    console.error(fileSize);

    stream.write("\n]\n");
    stream.end();

    return record.done;
}

const zeroPad = (num, places) => String(num).padStart(places, '0')
const outputFileName = (prefix, index) => prefix + '_' + zeroPad(index, 5) + ".json"

let fileIndex = 1;
let done = true;

do {
    done = writeNextBatch(generator, outputFileName(argv.output, fileIndex++), parseInt(argv.size, 10) * 1024);
} while (!done)
