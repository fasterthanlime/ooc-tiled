use mxml

import tiled/Layer

readCSV: func (layer: Layer, data: String) {
    current := Buffer new()
    iter := data iterator()
    i := 0
    while (true) {
        chr := iter next()
        if (chr == ',' || !iter hasNext?()) {
            // next value!
            value := current toString() toInt()
            layer data[i] = value
            i += 1

            if (!iter hasNext?()) break

            current = Buffer new() // TODO?
        } else if (chr whitespace?()) {
            // ignore!
        } else {
            // must be a number
            current append(chr)
        }
    }
    "Read %d tiles." printfln(i+1)
}

readData: func (layer: Layer, node: XmlNode) {
    encoding := node getAttr("encoding")
    match (encoding) {
        case "csv" =>
            readCSV(layer, node getOpaque())
        case =>
            Exception new("Encoding `%s` not yet supported" format(encoding)) throw()
    }
}
