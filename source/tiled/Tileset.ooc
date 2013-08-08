use mxml

import structs/HashMap

import tiled/[Tile, helpers, Image]

Tileset: class {
    name: String
    tileWidth, tileHeight: SizeT
    spacing, margin: SizeT

    image: Image // TODO: support for one image for now

    // special snowflake tiles, with properties or something
    specialTiles: HashMap<SizeT, Tile>

    init: func ~fromNode (node: XmlNode) {
        name = node getAttr("name")
        tileWidth = node getAttr("tilewidth") toInt()
        tileHeight = node getAttr("tileheight") toInt()
        spacing = getAttrDefault(node, "spacing", "0") toInt()
        margin = getAttrDefault(node, "margin", "0") toInt()

        if(node getAttr("source") != null) { // TODO
            Exception new("Can't read external tilesets yet!") throw()
        }

        specialTiles = HashMap<SizeT, Tile> new()
        _loadTiles(node)
    }

    _loadTiles: func (root: XmlNode) {
        eachChildElem(root, |node|
            match(node getElement()) {
                case "image" =>
                    if(image != null)
                        Exception new("Only one image per tileset supported yet!") throw()
                    image = Image new(node)
                case "tile" =>
                    // speeeecial tiles!
                    tile := Tile new(node)
                    specialTiles put(tile id, tile)
            }
        )
    }
}
