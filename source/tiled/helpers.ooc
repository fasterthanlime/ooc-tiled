use mxml

/** call a function for each child element node of `root` */
eachChildElem: func (root: XmlNode, callback: Func (XmlNode)) {
    node := root getFirstChild()
    while(node != null) {
        if(node getType() == XmlNodeType ELEMENT) {
            callback(node)
        }
        node = node getNextSibling()
    }
}

/** get an attribute with a default value */
getAttrDefault: func (node: XmlNode, name: String, def: String) -> String {
    value := node getAttr(name)
    if(value == null)
        return def;
    else
        return value;
}

Position: class {
    x, y: SizeT

    init: func(=x, =y) {}
}

