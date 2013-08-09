use mxml

import structs/HashMap

import tiled/[helpers, properties, Tileset]

TileId: cover from UInt // TODO: should be UInt32, but that annoys rock

FlipFlag: enum {
    HORIZONTALLY = 0x80000000 // 32nd bit
    VERTICALLY = 0x40000000 // 31st bit
    DIAGONALLY = 0x20000000 // TODO: is that correct? that's the 30th bit
    ANY = 0xc0000000 // bit 32 + 31?
}

cleanTileId: func (did: TileId) -> TileId {
    did & ~(FlipFlag ANY)
}

Tile: class {
    id: TileId
    tileset: Tileset
    properties: HashMap<String, String>

    init: func ~fromId (=tileset, =id) {
        properties = HashMap<String, String> new()
    }

    init: func ~fromNode (tileset: Tileset, node: XmlNode) {
        init(tileset, node getAttr("id") toInt())
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

    getPosition: func -> Position {
        tileset getTilePosition(id)
    }
}

