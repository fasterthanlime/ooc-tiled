use mxml

import structs/HashMap

import tiled/[helpers, properties, data]

Layer: class {
    name: String
    opacity: Float
    visible: Bool

    data: Int*

    properties: HashMap<String, String>

    init: func ~fromNode (node: XmlNode, width, height: SizeT) {
        name = node getAttr("name")
        opacity = getAttrDefault(node, "opacity", "1") toFloat()
        visible = getAttrDefault(node, "visible", "1") == "1"
        properties = HashMap<String, String> new()

        // initialize our buffer
        data = gc_malloc(32 * width * height) // always an array of 32bit unsigned integers

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
