
// third-party
use mxml

// sdk
import structs/[ArrayList, HashMap]
import io/File

// ours
import tiled/[Map, Tile, helpers, Image]

TileSet: class {

    autoExterns := static HashMap<String, String> new()

    map: Map

    // common properties
    name: String
    firstGid, tileWidth, tileHeight: SizeT
    spacing, margin: SizeT
    image: Image // TODO: implement multiple image support?
    terrainTypes := ArrayList<TerrainType> new()

    // non-nil if external
    source: String

    tilesPerRow: SizeT {
        get {
            image width / tileWidth
        }
    }

    tilesPerColumn: SizeT {
        get {
            image height / tileHeight
        }
    }

    // special snowflake tiles, with properties or something
    specialTiles: HashMap<SizeT, Tile>

    init: func ~fromNode (=map, node: XmlNode) {
        firstGid = node getAttr("firstgid") toInt()
        source = node getAttr("source")

        if (!source) {
            image := _findImage(node)
            if (image) {
                ext := autoExterns get(image source)
                if (ext) {
                    source = ext
                }
            }
        }

        tree: XmlNode
        if(source) {
            // read external tileset
            tree = XmlNode new()
            tree loadString(File new(map relativePath(source)) read(), MXML_OPAQUE_CALLBACK)
            node = tree findElement(tree, "tileset")
        }

        _load(node)

        if (source) {
            // clean up
            tree delete()
        }
    }

    init: func ~fromFile (file: File) {
        firstGid = 0

        tree := XmlNode new()
        source := file read()
        tree loadString(source, MXML_OPAQUE_CALLBACK)
        node := tree findElement(tree, "tileset")
        _load(node)
        tree delete()
    }

    _load: func (node: XmlNode) {
        name = node getAttr("name")
        tileWidth = node getAttr("tilewidth") toInt()
        tileHeight = node getAttr("tileheight") toInt()
        spacing = getAttrDefault(node, "spacing", "0") toInt()
        margin = getAttrDefault(node, "margin", "0") toInt()

        if(spacing != 0 || margin != 0) {
            Exception new("spacing and margin not supported yet") throw()
        }

        specialTiles = HashMap<TileId, Tile> new()
        _loadAll(node)
    }

    _findImage: func (root: XmlNode) -> Image {
        result: Image

        eachChildElem(root, |node|
            match (node getElement()) {
                case "image" =>
                    result = Image new(node)
            }
        )

        result
    }

    _loadAll: func (root: XmlNode) {
        eachChildElem(root, |node|
            match(node getElement()) {
                case "image" =>
                    if(image != null) {
                        raise("Multiple images per tileSet aren't supported yet.")
                    }
                    image = Image new(node)
                case "terraintypes" =>
                    _loadTerrainTypes(node)
                case "tile" =>
                    // Tiles that have attributes and/or terrain info have
                    // their own node.
                    tile := Tile new(this, node)
                    specialTiles put(tile id, tile)
            }
        )
    }

    _loadTerrainTypes: func (root: XmlNode) {
        eachChildElem(root, |node|
            match (node getElement()) {
                case "terrain" =>
                    terrainType := TerrainType new(terrainTypes size, node)
                    terrainTypes add(terrainType)
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

    /**
     * @return first terrain type that has name `name`, if found
     */
    findTerrainType: func (name: String) -> TerrainType {
        for (tt in terrainTypes) {
            if (tt name == name) return tt
        }

        null
    }

    getSource: func -> String {
        source ? source : "<unknown>"
    }
}

TerrainType: class {
    index: Int
    name: String
    tile: Int

    init: func (=index, root: XmlNode) {
        _loadStuff(root)
    }

    _loadStuff: func (root: XmlNode) {
        name = root getAttr("name")
        tile = root getAttr("tile") toInt()
    }
}

