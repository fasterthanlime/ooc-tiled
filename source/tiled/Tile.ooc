use mxml

import structs/HashMap

import tiled/[helpers, properties, TileSet]

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
    tileSet: TileSet
    properties: HashMap<String, String>

    init: func ~fromId (=tileSet, =id) {
        properties = HashMap<String, String> new()
    }

    init: func ~fromNode (tileSet: TileSet, node: XmlNode) {
        init(tileSet, node getAttr("id") toInt())
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
        tileSet getTilePosition(id)
    }
}

