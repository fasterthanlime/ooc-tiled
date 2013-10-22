
// sdk
import structs/[ArrayList, HashMap]

// third-party
use mxml

// ours
import tiled/[helpers]

/**
 * An object group
 */
ObjectGroup: class {

    // common properties
    name: String
    width: Int
    height: Int

    // custom properties
    properties := HashMap<String, String> new()
    objects := ArrayList<>

    /**
     * Create a new object group - called internally
     */
    init: func ~fromNode (=map, node: XmlNode) {
        name = node getAttr("name")
        width = node getAttr("width") toInt()
        height = node getAttr("height") toInt()

        _loadStuff(node)
    }

    // private stuff

    _loadStuff: func (root: XmlNode) {
        eachChildElem(root, |node|
            match(node getElement()) {
                case "properties" =>
                    readProperties(node, properties)
                case "object" =>
                    _readObject(this, node)
                case =>
                    "Ignoring <%s> for now ..." printfln(node getElement())
            }
        )
    }

    _readObject: func (node: XmlNode) {

    }

}

/**
 * A Tiled object
 */
TObject: class {

    // common properties
    name: String
    type: String // empty if no type
    x, y: Int
    width, height: Int
    shape: TShape

}

/**
 * The shape of a tiled object
 */
TShape: class {

    // the object this shape refers to
    object: TObject

    init: func (=object) 

}

/**
 * A rectangle
 */
TRectangle: class {

    // uses parent width/height
    init: func (.object) { super(object) }

}

/**
 * An ellipse
 */
TEllipse: class {

    // uses parent width/height
    init: func (.object) { super(object) }

}

/**
 * A shape that is defined by a list of points
 */
TPointsShape: abstract class extends TShape {

    points := ArrayList<Position> new()

    init: func (.object, node: XmlNode) {
        super(object)
        // TODO: load points
    }

}

/**
 * A polygon
 */
TPolygon: class extends TPointsShape {

    init: func (.object, node: XmlNode) {
        super(object, node)
    }

}

/**
 * A polyline
 */
TPolyLine: class extends TPointsShape {

    init: func (.object, node: XmlNode) {
        super(object, node)
    }

}

