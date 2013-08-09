use mxml

import structs/HashMap

import tiled/[Map, helpers, properties, data, Tile]

Layer: class {
    name: String
    opacity: Float
    visible: Bool

    data: TileId*

    properties: HashMap<String, String>

    init: func ~fromNode (map: Map, node: XmlNode) {
        name = node getAttr("name")
        opacity = getAttrDefault(node, "opacity", "1") toFloat()
        visible = getAttrDefault(node, "visible", "1") == "1"
        properties = HashMap<String, String> new()
        data = gc_malloc(map width * map height * TileId size)

        _loadStuff(node)
    }

    _loadStuff: func (root: XmlNode) {
        eachChildElem(root, |node|
            match(node getElement()) {
                case "properties" =>
                    readProperties(node, properties)
                case "data" =>
                    readData(this, node)
                case =>
                    "Ignoring <%s> for now ..." printfln(node getElement())
            }
        )
    }
}
