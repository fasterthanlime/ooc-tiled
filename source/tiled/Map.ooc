import io/File
import structs/[HashMap, ArrayList]

use mxml

import tiled/[helpers, TileSet, Layer, Tile]

/**
 * A Tiled map
 */
Map: class {
    tree: XmlNode

    version: String
    orientation: String
    width, height: SizeT
    tileWidth, tileHeight: SizeT

    // TODO: background color, etc.

    tileSets := HashMap<String, TileSet> new()
    layers := HashMap<String, Layer> new()

    init: func ~withFile (file: File) {
        tree = XmlNode new()
        tree loadString(file read(), MXML_OPAQUE_CALLBACK)

        _loadMap(tree findElement(tree, "map"))
    }

    cleanup: func {
        tree delete()
    }

    /**
     * Get the tileSet that contains our tile. *did* will be cleaned (it's a "dirty id"!)
     * from flipping data.
     * @return null if no tileSet could be found or if the tile id is 0.
     */
    getTileSet: func (did: TileId) -> TileSet {
        cid := cleanTileId(did)
        if(cid == 0) return null
        best: TileSet = null

        iter := tileSets iterator()
        while(iter hasNext?()) {
            ts := iter next()
            if(ts firstGid > cid) {
                break
            }
            best = ts
        }
        best
    }

    getTile: func (did: TileId) -> Tile {
        tileSet := getTileSet(did)
        if(tileSet == null) {
            return null
        }
        tileSet getTile(did)
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
                    ts := TileSet new(node)
                    tileSets put(ts name, ts)
                case "layer" =>
                    layer := Layer new(this, node)
                    layers put(layer name, layer)
                case =>
                    "Ignoring <%s> for now ..." printfln(node getElement())
            }
        )
    }
}
