var
    red   = Colour [255'u8, 0, 0, 255]
    green = Colour [0'u8, 255, 0, 255]
    blue  = Colour [0'u8, 0, 255, 255]

    redf   = ColourF32 [1f, 0, 0, 1]
    greenf = ColourF32 [0f, 1, 0, 1]
    bluef  = ColourF32 [0f, 0, 1, 1]

test "Stringify":
    check:
        $red   == "0xFF0000FF"
        $green == "0x00FF00FF"
        $blue  == "0x0000FFFF"

        $redf   == "0xFF0000FF"
        $greenf == "0x00FF00FF"
        $bluef  == "0x0000FFFF"

        red.repr   == "ColourU8(r: 255, g: 0, b: 0, a: 255)"
        green.repr == "ColourU8(r: 0, g: 255, b: 0, a: 255)"
        blue.repr  == "ColourU8(r: 0, g: 0, b: 255, a: 255)"

        redf.repr   == "ColourF32(r: 1.00, g: 0.00, b: 0.00, a: 1.00)"
        greenf.repr == "ColourF32(r: 0.00, g: 1.00, b: 0.00, a: 1.00)"
        bluef.repr  == "ColourF32(r: 0.00, g: 0.00, b: 1.00, a: 1.00)"

test "Conversions":
    check:
        colour(0x04030201) == [4'u8, 3, 2, 1]
        colour(0x0F000F00) == [0xF'u8, 0, 0xF, 0]
        colour(0x0F0F0000) == [0xF'u8, 0xF, 0, 0]

    check:
        red   == colour 0xFF0000FF'u32
        green == colour 0x00FF00FF'u32
        blue  == colour 0x0000FFFF'u32

    check:
        red   == colour to_uint32 red
        green == colour to_uint32 green
        blue  == colour to_uint32 blue
