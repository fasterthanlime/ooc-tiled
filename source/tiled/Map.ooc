
// sdk
import io/File
import structs/[HashMap, ArrayList]

// third-party
use mxml

// ours
import tiled/[helpers, TileSet, Layer, Tile, ObjectGroup]

/**
 * A Tiled map
 */
Map: class {

    version: String
    orientation: String
    width, height: SizeT
    tileWidth, tileHeight: SizeT

    // TODO: background color, etc.

    tileSets := ArrayList<TileSet> new()
    mapLayers := ArrayList<MapLayer> new()

    mapFile: File

    init: func (=mapFile) {
        tree := XmlNode new()
        tree loadString(mapFile read(), MXML_OPAQUE_CALLBACK)

        _loadMap(tree findElement(tree, "map"))
        tree delete()
    }

    /**
     * Get the tileSet that contains our tile. *did* will be cleaned (it's a
     * "dirty id"!) from flipping data.
     * @return null if no tileSet could be found or if the tile id is 0.
     */
    getTileSet: func (did: TileId) -> TileSet {
        cid := cleanTileId(did)
        if(cid == 0) return null

        best: TileSet = null

        for (tileSet in tileSets) {
            if(tileSet firstGid > cid) {
               break
            }
            best = tileSet
        }
        best
    }

    /**
     * Given a tile id, return the associated Tile object
     */
    getTile: func (did: TileId) -> Tile {
        tileSet := getTileSet(did)
        if(tileSet) {
            return tileSet getTile(did)
        }
        null
    }

    /**
     * Given a path relative to the map's path,
     * will return a File corresponding to the actual
     * file.
     */
    relativePath: func (relativePath: String) -> String {
        f := File new(mapFile, "..", relativePath)
        f getReducedPath() // resolves '..' and stuff
    }

    // private stuff

    _loadMap: func (node: XmlNode) {
        version = node getAttr("version")
        orientation = node getAttr("orientation")
        width = node getAttr("width") toInt()
        height = node getAttr("height") toInt()
        tileWidth = node getAttr("tilewidth") toInt()
        tileHeight = node getAttr("tileheight") toInt()

        _loadChildren(node)
    }

    _loadChildren: func (root: XmlNode) {
        eachChildElem(root, |node|
            match(node getElement()) {
                case "tileset" =>
                    tileSet := TileSet new(this, node)
                    tileSets add(tileSet)
                case "layer" =>
                    layer := Layer new(this, node)
                    mapLayers add(layer)
                case "objectgroup" =>
                    objectGroup := ObjectGroup new(this, node)
                    mapLayers add(objectGroup)
                case =>
                    "Ignoring <%s> for now ..." printfln(node getElement())
            }
        )

        // order tileSets by gid
    }
}

MapLayer: abstract class {

    // common properties
    map: Map
    name: String

    init: func (=map, node: XmlNode) {
        name = node getAttr("name")
    }

}

