use mxml

import structs/HashMap

import tiled/[helpers, properties]

Tile: class {
    id: SizeT
    properties: HashMap<String, String>

    init: func ~fromNode (node: XmlNode) {
        id = node getAttr("id") toInt()
        properties = HashMap<String, String> new()

        _loadStuff(node)
    }

    _loadStuff: func (root: XmlNode) {
        eachChildElem(root, |node|
            match(node getElement()) {
                case "properties" =>
                    readProperties(node, properties)
            }
        )
    }
}
