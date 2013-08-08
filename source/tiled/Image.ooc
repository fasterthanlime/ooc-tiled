use mxml

import tiled/[helpers]

Image: class {
    format, source, trans: String
    width, height: SSizeT // for -1 as a "no width/height set" value

    init: func ~fromNode (node: XmlNode) {
        format = getAttrDefault(node, "format", "")
        source = getAttrDefault(node, "source", "")
        trans = getAttrDefault(node, "trans", "")
        width = getAttrDefault(node, "width", "-1") toInt()
        height = getAttrDefault(node, "height", "-1") toInt()
    }
}
