import io/File
import structs/[HashMap, ArrayList]

use mxml

import tiled/[helpers, Tileset, Layer, Tile]

Map: class {
    tree: XmlNode

    version: String
    orientation: String
    width, height: SizeT
    tileWidth, tileHeight: SizeT
//    backgroundColor: ... // TODO

    tilesets := HashMap<String, Tileset> new()
    layers := HashMap<String, Layer> new()

    init: func ~withFile (file: File) {
        tree = XmlNode new()
        tree loadString(file read(), MXML_OPAQUE_CALLBACK)

        _loadMap(tree findElement(tree, "map"))
    }

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
                    ts := Tileset new(node)
                    tilesets put(ts name, ts)
                case "layer" =>
                    layer := Layer new(this, node)
                    layers put(layer name, layer)
                case =>
                    "Ignoring <%s> for now ..." printfln(node getElement())
            }
        )
    }

    cleanup: func {
        tree delete()
    }

    /** get the tileset that contains our tile. *did* will be cleaned (it's a "dirty id"!)
        from flipping data. Returns null if no tileset could be found or if the tile id is 0. */
    getTileset: func (did: TileId) -> Tileset {
        cid := cleanTileId(did)
        if(cid == 0) return null
        best: Tileset = null

        iter := tilesets iterator()
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
        tileset := getTileset(did)
        if(tileset == null) {
            return null
        }
        tileset getTile(did)
    }
}
