
// third-party
use mxml

// sdk
import structs/HashMap, io/File

// ours
import tiled/[Map, Tile, helpers, Image]

TileSet: class {

    map: Map

    // common properties
    name: String
    firstGid, tileWidth, tileHeight: SizeT
    spacing, margin: SizeT
    image: Image // TODO: implement multiple image support?

    tilesPerRow: SizeT {
        get {
            image width / tileWidth
        }
    }

    // special snowflake tiles, with properties or something
    specialTiles: HashMap<SizeT, Tile>

    init: func ~fromNode (=map, node: XmlNode) {
        firstGid = node getAttr("firstgid") toInt()
        source := node getAttr("source")

        tree: XmlNode
        if(source) {
            // read external tileset
            tree = XmlNode new()
            tree loadString(File new(map relativePath(source)) read(), MXML_OPAQUE_CALLBACK)
            node = tree findElement(tree, "tileset")
        }

        name = node getAttr("name")
        tileWidth = node getAttr("tilewidth") toInt()
        tileHeight = node getAttr("tileheight") toInt()
        spacing = getAttrDefault(node, "spacing", "0") toInt()
        margin = getAttrDefault(node, "margin", "0") toInt()

        if(spacing != 0 || margin != 0) {
            Exception new("spacing and margin not supported yet") throw()
        }

        specialTiles = HashMap<TileId, Tile> new()
        _loadTiles(node)

        if (source) {
            // clean up
            tree delete()
        }
    }

    _loadTiles: func (root: XmlNode) {
        eachChildElem(root, |node|
            match(node getElement()) {
                case "image" =>
                    if(image != null)
                        Exception new("Only one image per tileSet supported yet!") throw()
                    image = Image new(node)
                case "tile" =>
                    // speeeecial tiles!
                    tile := Tile new(this, node)
                    specialTiles put(tile id, tile)
            }
        )
    }

    /** return the tile. id is a global, potentially dirty tile id. */
    getTile: func (did: TileId) -> Tile {
        if(did & FlipFlag ANY) {
            // it's flipped!
            Exception new("Flippy no-no-supporty yet.") throw()
        } else {
            getLocalTile(did - firstGid)
        }
    }

    getLocalTile: func (lid: TileId) -> Tile {
        // lazily create tile if it isn't 'special'
        if(!specialTiles contains?(lid)) {
            specialTiles put(lid, Tile new(this, lid))
        }
        specialTiles get(lid)
    }

    /** @return (row, column) */
    getTileRowColumn: func (lid: TileId) -> (SizeT, SizeT) {
        (lid / tilesPerRow, lid % tilesPerRow)
    }

    /** @return (x, y) */
    getTilePosition: func (lid: TileId) -> Position {
        (row, column) := getTileRowColumn(lid)
        Position new(column * tileWidth, row * tileHeight) // TODO: spacing etc
    }
}

