
// sdk
import structs/[ArrayList, HashMap]
import text/StringTokenizer

// third-party
use mxml

// ours
import tiled/[Map, helpers, properties]

/**
 * An object group
 */
ObjectGroup: class extends MapLayer {

    // common properties
    width: Int
    height: Int

    // custom properties
    properties := HashMap<String, String> new()
    objects := ArrayList<TObject> new()

    /**
     * Create a new object group - called internally
     */
    init: func (.map, node: XmlNode) {
        super(map, node)
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
                    object := TObject new(this, node)
                    objects add(object)
                case =>
                    "Ignoring <%s> for now ..." printfln(node getElement())
            }
        )
    }

}

/**
 * A Tiled object
 */
TObject: class {

    group: ObjectGroup

    // common properties
    name: String
    type: String // empty if no type
    x, y: Int
    width, height: Int
    shape: TShape

    // custom properties
    properties := HashMap<String, String> new()

    init: func (=group, node: XmlNode) {
        name = getAttrDefault(node, "name", "")
        type = getAttrDefault(node, "type", "")
        x = getAttrDefault(node, "x", "0") toInt()
        y = getAttrDefault(node, "y", "0") toInt()
        width = getAttrDefault(node, "width", "0") toInt()
        height = getAttrDefault(node, "height", "0") toInt()

        _loadStuff(node)
    }

    // private stuff

    _loadStuff: func (root: XmlNode) {
        eachChildElem(root, |node|
            match (node getElement()) {
                case "properties" =>
                    readProperties(node, properties)
                case "ellipse" =>
                    shape = TEllipse new(this)
                case "polygon" =>
                    shape = TPolygon new(this, node)
                case "polyline" =>
                    shape = TPolyLine new(this, node)
            }
        )

        if (!shape) {
            // congratulations, it's a rectangle!
            shape = TRectangle new(this)
        }
    }

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
TRectangle: class extends TShape {

    // uses parent width/height
    init: func (.object) { super(object) }

}

/**
 * An ellipse
 */
TEllipse: class extends TShape {

    // uses parent width/height
    init: func (.object) { super(object) }

}

/**
 * A shape that is defined by a list of points
 */
TPointsShape: abstract class extends TShape {

    /** A series of points, relative our object's position */
    points := ArrayList<Position> new()

    init: func (.object, node: XmlNode) {
        super(object)

        tokens := node getAttr("points") split(" ")
        for (token in tokens) {
            coords := token split(",")
            if (coords size < 2) {
                raise("Invalid coordinates list, need two numbers to form a point")
            }

            p := Position new(
                coords[0] toInt(),
                coords[1] toInt()
            )
            points add(p)
        }
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

