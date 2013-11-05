
// third
use mxml

// sdk
import structs/[List, HashMap]
import text/StringTokenizer

// ours
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

    terrainTopRight    := -1
    terrainTopLeft     := -1
    terrainBottomLeft  := -1
    terrainBottomRight := -1

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

        _loadTerrainInfo(root)
    }

    _loadTerrainInfo: func (root: XmlNode) {
        terrainInfo := getAttrDefault(root, "terrain", "-1,-1,-1,-1")

        tokens := terrainInfo split(",")

        if (tokens size < 4) raise("Invalid terrain format, needs 4 numbers")
        terrainTopRight    = tokens[0] toInt()
        terrainTopLeft     = tokens[1] toInt()
        terrainBottomLeft  = tokens[2] toInt()
        terrainBottomRight = tokens[3] toInt()
    }

    getPosition: func -> Position {
        tileSet getTilePosition(id)
    }
}

