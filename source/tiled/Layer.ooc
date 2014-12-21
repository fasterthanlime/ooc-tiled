
// sdk
import structs/HashMap

// third-party
use mxml

// ours
import tiled/[Map, helpers, properties, data, Tile]

/**
 * A tile layer
 */
Layer: class extends MapLayer {

    // common properties
    opacity: Float
    visible: Bool
    width, height: Int

    // custom properties
    properties := HashMap<String, String> new()

    // all tiles
    data: TileId*

    /**
     * Create a new layer - called internally
     */
    init: func (.map, node: XmlNode) {
        super(map, node)
        opacity = getAttrDefault(node, "opacity", "1") toFloat()
        visible = getAttrDefault(node, "visible", "1") == "1"
        width  = getAttrDefault(node, "width", "0") toInt()
        height = getAttrDefault(node, "height", "0") toInt()
        data = gc_malloc(map width * map height * TileId size)

        _loadStuff(node)
    }

    /**
     * Iterate through each tile, call f with column, row, and
     * a reference to the tile.
     */
    each: func (f: Func (Int, Int, Tile)) {
        for (y in 0..map height) {
            for (x in 0..map width) {
                lid := y * map width + x
                tile := map getTile(data[lid])
                if (tile) {
                    f(x, y, tile)
                }
            }
        }
    }

    /**
     * @return the first tile in this layer, or null if it's empty
     */
    first: func -> Tile {
        for (y in 0..map height) {
            for (x in 0..map width) {
                lid := y * map width + x
                tile := map getTile(data[lid])
                if (tile) return tile
            }
        }
        null
    }

    // private stuff

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

    getTileID: func (index: Int) -> TileId {
        data[index]
    }

}
