use tiled

import io/File

import tiled/[Map, Tile, helpers]

main: func {
    file := File new("outdoor.tmx")
    map := Map new(file)
    tile := map getTile(18)
    p := tile getPosition()
    "x:%d y:%d" printfln(p x, p y)
}
