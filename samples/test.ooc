use tiled

import io/File

import tiled/Map

main: func {
    file := File new("outdoor.tmx")
    map := Map new(file)

}
