use mxml

import structs/HashMap

import tiled/[helpers]

readProperties: func (root: XmlNode, into: HashMap<String, String>) {
    eachChildElem(root, |node|
        if(node getElement() != "property") {
            Exception new("What is this sorcery? Unknown <%s> tag." format(node getElement())) throw()
        } else if(node getAttr("value") == null) {
            // the answer is in the text
            into put(node getAttr("name"), node getOpaque())
        } else {
            into put(node getAttr("name"), node getAttr("value"))
        }
    )
}
