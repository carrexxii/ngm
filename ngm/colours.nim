# This file is a part of NGM. Copyright (C) 2025 carrexxii.
# It is distributed under the terms of the GNU Affero General Public License, Version 3.0.
# For a copy, see the LICENSE file or <https://www.gnu.org/licenses/>.

import common
from std/strutils import to_hex

type # [r, g, b, a] / 0xRRGGBBAA
    ColourF32* = distinct array[4, float32]
    ColourU8*  = distinct array[4, uint8]

    AColour* = ColourF32 | ColourU8

    Colour* = ColourU8

func `[]`*(c: ColourF32; i: int): float32 = array[4, float32](c)[i]
func `[]`*(c: ColourU8; i: int): uint8    = array[4, uint8](c)[i]
func `[]=`*(c: var ColourF32; i: int; val: float32) = array[4, float32](c)[i] = val
func `[]=`*(c: var ColourU8; i: int; val: uint8)    = array[4, uint8](c)[i] = val

const VectorFields = ["rgba"]
type Swizzleable = AColour
include swizzle

{.push inline.}

converter to_colouru8*(arr: array[4, uint8]): ColourU8     = ColourU8  arr
converter to_colourf32*(arr: array[4, float32]): ColourF32 = ColourF32 arr

converter to_colourf32*(c: ColourU8): ColourF32 =
    [(float32 c.r) / 255,
     (float32 c.g) / 255,
     (float32 c.b) / 255,
     (float32 c.a) / 255]
converter to_colouru8*(c: ColourF32): ColourU8 =
    [uint8(c.r * 255),
     uint8(c.g * 255),
     uint8(c.b * 255),
     uint8(c.a * 255)]

func to_uint32*(c: ColourU8): uint32 =
    ((uint32 c.r) shl 24) or
    ((uint32 c.g) shl 16) or
    ((uint32 c.b) shl 8 ) or uint32 c.a
func to_uint32*(c: ColourF32): uint32 = to_uint32 to_colouru8 c

func colour*(r, g, b: uint8; a = 255'u8): ColourU8   = [r, g, b, a]
func colour*(r, g, b: float32; a = 1'f32): ColourF32 = [r, g, b, a]

proc colour*(hex: uint32): ColourU8 =
    [cast[uint8](hex shr 24),
     cast[uint8](hex shr 16),
     cast[uint8](hex shr 8 ),
     cast[uint8](hex shr 0 )]
proc colour*(hex: SomeInteger): ColourU8 = colour uint32 hex
converter uint32_to_colour*(n: uint32): ColourU8 = colour n

func `$`*(c: ColourU8): string = &"0x{to_hex c.r}{to_hex c.g}{to_hex c.b}{to_hex c.a}"
func `$`*(c: ColourF32): string =
    let c = to_colouru8 c
    $c

func repr*(c: ColourU8): string  = &"ColourU8(r: {c.r}, g: {c.g}, b: {c.b}, a: {c.a})"
func repr*(c: ColourF32): string = &"ColourF32(r: {c.r:.2f}, g: {c.g:.2f}, b: {c.b:.2f}, a: {c.a:.2f})"

func `==`*(c1, c2: AColour): bool   = (c1.r == c2.r) and (c1.g == c2.g) and (c1.b == c2.b) and (c1.a == c2.a)
func `=~`*(c1, c2: ColourF32): bool = (c1.r =~ c2.r) and (c1.g =~ c2.g) and (c1.b =~ c2.b) and (c1.a =~ c2.a)

func `*`*(c: ColourU8; s: float32): ColourU8 =
    [uint8((s * float32 c.r).clamp(0, 255)),
     uint8((s * float32 c.g).clamp(0, 255)),
     uint8((s * float32 c.b).clamp(0, 255)),
     uint8((s * float32 c.a).clamp(0, 255))]
func `*`*(s: float32; c: ColourU8): ColourU8 = c * s

func with_alpha*(c: ColourU8; a: uint8): ColourU8 =
    result = c
    result[3] = a # TODO: swizzle

{.pop.}

# https://xkcd.com/color/rgb/
const
    Black*    = colour 0x000000FF
    White*    = colour 0xFFFFFFFF
    OffWhite* = colour 0xFFFFE4FF

    Gray*       = colour 0x929591FF
    LightGray*  = colour 0xD8DCD6FF
    MediumGray* = colour 0x7D7F7CFF
    DarkGray*   = colour 0x363737FF
    PaleGray*   = colour 0xFDFDFEFF
    BlueGray*   = colour 0x607C8EFF
    GreenGray*  = colour 0x77926FFF
    PurpleGray* = colour 0x887191FF
    PinkGray*   = colour 0xC88D94FF
    BrownGray*  = colour 0x7F7053FF
    SteelGray*  = colour 0x6F828AFF
    TealGray*   = colour 0x719F91FF

    Slate*      = colour 0x516572FF
    SlateBlue*  = colour 0x5B7C99FF
    SlateGreen* = colour 0x658D6DFF

    Red*       = colour 0xE50000FF
    LightRed*  = colour 0xFF474CFF
    DarkRed*   = colour 0x840000FF
    DeepRed*   = colour 0x9A0200FF
    BrightRed* = colour 0xFF000DFF
    PaleRed*   = colour 0xD9544DFF
    DullRed*   = colour 0xBB3F3FFF
    NeonRed*   = colour 0xFF073AFF

    Maroon*      = colour 0x650021FF
    LightMaroon* = colour 0xA24857FF
    DarkMaroon*  = colour 0x3C0008FF

    Burgundy*      = colour 0x610023FF
    LightBurgundy* = colour 0xA8415BFF

    Pink*          = colour 0xFF81C0FF
    VeryLightPink* = colour 0xFFF4F2FF
    LightPink*     = colour 0xFFD1DFFF
    MediumPink*    = colour 0xF36196FF
    DarkPink*      = colour 0xCB416BFF
    DeepPink*      = colour 0xCB0162FF
    BrightPink*    = colour 0xFE01B1FF
    PalePink*      = colour 0xFFCFDCFF
    DullPink*      = colour 0xD5869DFF
    NeonPink*      = colour 0xFE019AFF

    Magenta*       = colour 0xC20078FF
    LightMagenta*  = colour 0xFA5FF7FF
    DarkMagenta*   = colour 0x960056FF
    DeepMagenta*   = colour 0xA0025CFF
    BrightMagenta* = colour 0xFF08E8FF
    PaleMagenta*   = colour 0xD767ADFF

    Mauve*       = colour 0xAE7181FF
    LightMauve*  = colour 0xC292A1FF
    DarkMauve*   = colour 0x874C62FF
    PaleMauve*   = colour 0xFED0FCFF

    Salmon*      = colour 0xFF796CFF
    LightSalmon* = colour 0xFEA993FF
    DarkSalmon*  = colour 0xC85A53FF
    PaleSalmon*  = colour 0xFFB19AFF

    Lilac*       = colour 0xCEA2FDFF
    LightLilac*  = colour 0xEDC8FFFF
    BrightLilac* = colour 0xC95EFBFF
    DarkLilac*   = colour 0x9C6DA5FF
    DeepLilac*   = colour 0x966EBDFF
    PaleLilac*   = colour 0xE4CBFFFF

    Rose*        = colour 0xCF6275FF
    LightRose*   = colour 0xFCC5CBFF
    DarkRose*    = colour 0xB5485DFF
    DeepRose*    = colour 0xC74767FF
    PaleRose*    = colour 0xFDC1C5FF

    Fuchsia*     = colour 0xED0DD9FF
    DarkFuchsia* = colour 0x9D0759FF

    Orange*       = colour 0xF97306FF
    LightOrange*  = colour 0xFDAA48FF
    DarkOrange*   = colour 0xC65102FF
    DeepOrange*   = colour 0xDC4D01FF
    BrightOrange* = colour 0xFF5B00FF
    PaleOrange*   = colour 0xFFA756FF
    DullOrange*   = colour 0xD8863BFF

    Peach*      = colour 0xFFB07CFF
    LightPeach* = colour 0xFFD8B1FF
    DarkPeach*  = colour 0xDE7E5DFF
    PalePeach*  = colour 0xFFE5ADFF

    Coral*     = colour 0xFC5A50FF
    DarkCoral* = colour 0xCF524EFF

    Blue*          = colour 0x0343DFFF
    VeryLightBlue* = colour 0xD5FFFFFF
    VeryDarkBlue*  = colour 0x000133FF
    LightBlue*     = colour 0x95D0FCFF
    MediumBlue*    = colour 0x2C6FBBFF
    DarkBlue*      = colour 0x00035BFF
    DeepBlue*      = colour 0x040273FF
    BrightBlue*    = colour 0x0165FCFF
    PaleBlue*      = colour 0xD0FEFEFF
    VeryPaleBlue*  = colour 0xD6FFFEFF
    DullBlue*      = colour 0x49759CFF
    NeonBlue*      = colour 0x04D9FFFF
    RoyalBlue*     = colour 0x0504AAFF

    Cyan*       = colour 0x00FFFFFF
    LightCyan*  = colour 0xACFFFCFF
    DarkCyan*   = colour 0x0A888AFF
    BrightCyan* = colour 0x41FDFEFF
    PaleCyan*   = colour 0xB7FFFAFF

    Teal*       = colour 0x029386FF
    LightTeal*  = colour 0x90E4C1FF
    DarkTeal*   = colour 0x014D4EFF
    DeepTeal*   = colour 0x00555AFF
    BrightTeal* = colour 0x01F9C6FF
    PaleTeal*   = colour 0x82CBB2FF
    DullTeal*   = colour 0x5F9E8FFF

    Turquoise*       = colour 0x06C2ACFF
    LightTurquoise*  = colour 0x7EF4CCFF
    DarkTurquoise*   = colour 0x045C5AFF
    DeepTurquoise*   = colour 0x017374FF
    BrightTurquoise* = colour 0x0FFEF9FF
    PaleTurquoise*   = colour 0xA5FBD5FF

    Aqua*       = colour 0x13EAC9FF
    LightAqua*  = colour 0x8CFFDBFF
    BrightAqua* = colour 0x0BF9EAFF
    DarkAqua*   = colour 0x05696BFF
    DeepAqua*   = colour 0x08787FFF
    PaleAqua*   = colour 0xB8FFEBFF

    Green*          = colour 0x15B01AFF
    VeryLightGreen* = colour 0xD1FFBDFF
    LightGreen*     = colour 0x96F97BFF
    MediumGreen*    = colour 0x39AD48FF
    DarkGreen*      = colour 0x033500FF
    VeryDarkGreen*  = colour 0x062E03FF
    DeepGreen*      = colour 0x02590FFF
    BrightGreen*    = colour 0x01FF07FF
    PaleGreen*      = colour 0xC7FDB5FF
    VeryPaleGreen*  = colour 0xCFFDBCFF
    DullGreen*      = colour 0x74A662FF
    NeonGreen*      = colour 0x0CFF0CFF

    Olive*       = colour 0x6E750EFF
    LightOlive*  = colour 0xACBF69FF
    DarkOlive*   = colour 0x373E02FF
    BrightOlive* = colour 0x9CBB04FF
    PaleOlive*   = colour 0xB9CC81FF

    Lime*        = colour 0xAAFF32FF
    LightLime*   = colour 0xAEFD6CFF
    DarkLime*    = colour 0x84B701FF
    BrightLime*  = colour 0x87FD05FF
    PaleLime*    = colour 0xBEFD73FF

    Mint*        = colour 0x9FFEB0FF
    LightMint*   = colour 0xB6FFBBFF
    DarkMint*    = colour 0x48C072FF

    Seafoam*      = colour 0x80F9ADFF
    LightSeafoam* = colour 0xA0FEBFFF
    DarkSeafoam*  = colour 0x1FB57AFF

    Sage*      = colour 0x87AE73FF
    LightSage* = colour 0xBCECACFF
    DarkSage*  = colour 0x598556FF

    Purple*         = colour 0x7E1E9CFF
    LightPurple*    = colour 0xBF77F6FF
    MediumPurple*   = colour 0x9E43A2FF
    DarkPurple*     = colour 0x35063EFF
    VeryDarkPurple* = colour 0x2A0134FF
    DeepPurple*     = colour 0x36013FFF
    BrightPurple*   = colour 0xBE03FDFF
    PalePurple*     = colour 0xB790D4FF
    DullPurple*     = colour 0x84597EFF
    NeonPurple*     = colour 0xBC13FEFF
    RoyalPurple*    = colour 0x4B006EFF

    Violet*       = colour 0x9A0EEAFF
    LightViolet*  = colour 0xD6B4FCFF
    DarkViolet*   = colour 0x34013FFF
    DeepViolet*   = colour 0x490648FF
    BrightViolet* = colour 0xAD0AFDFF
    PaleViolet*   = colour 0xCEAEFAFF

    Lavender*       = colour 0xC79FEFFF
    LightLavender*  = colour 0xDFC5FEFF
    DarkLavender*   = colour 0x856798FF
    DeepLavender*   = colour 0x8D5EB7FF
    BrightLavender* = colour 0xC760FFFF
    PaleLavender*   = colour 0xEECFFEFF

    Periwinkle*      = colour 0x8E82FEFF
    LightPeriwinkle* = colour 0xC1C6FCFF
    DarkPeriwinkle*  = colour 0x665FD1FF

    Indigo*      = colour 0x380282FF
    LightIndigo* = colour 0x6D5ACFFF
    DarkIndigo*  = colour 0x1F0954FF

    Plum*      = colour 0x580F41FF
    LightPlum* = colour 0x9D5783FF
    DarkPlum*  = colour 0x3F012CFF

    Yellow*       = colour 0xFFFF14FF
    LightYellow*  = colour 0xFFFE7AFF
    DarkYellow*   = colour 0xD5B60AFF
    BrightYellow* = colour 0xFFFD01FF
    PaleYellow*   = colour 0xFFFF84FF
    DullYellow*   = colour 0xEEDC5BFF
    NeonYellow*   = colour 0xCFFF04FF

    Tan*      = colour 0xD1B26FFF
    LightTan* = colour 0xFBEEACFF
    DarkTan*  = colour 0xAF884AFF

    Gold*      = colour 0xDBB40CFF
    LightGold* = colour 0xFDDC5CFF
    DarkGold*  = colour 0xB59410FF
    PaleGold*  = colour 0xFDDE6CFF

    Brown*          = colour 0x653700FF
    VeryLightBrown* = colour 0xD3B683FF
    LightBrown*     = colour 0xAD8150FF
    MediumBrown*    = colour 0x7F5112FF
    DarkBrown*      = colour 0x341C02FF
    VeryDarkBrown*  = colour 0x1D0200FF
    PaleBrown*      = colour 0xB1916EFF
    DullBrown*      = colour 0x876E4BFF

    Beige*      = colour 0xE6DAA6FF
    LightBeige* = colour 0xFFFEB6FF
    DarkBeige*  = colour 0xAC9362FF

    Khaki*      = colour 0xAAA662FF
    LightKhaki* = colour 0xE6F2A2FF
    DarkKhaki*  = colour 0x9B8F55FF

    Taupe*      = colour 0xB9A281FF
    DarkTaupe*  = colour 0x7F684EFF

    Cream*      = colour 0xFFFFC2FF
    DarkCream*  = colour 0xFFF39AFF

    PastelGreen*  = colour 0xB0FF9DFF
    PastelBlue*   = colour 0xA2BFFEFF
    PastelPurple* = colour 0xCAA0FFFF
    PastelPink*   = colour 0xFFBACDFF
    PastelYellow* = colour 0xFFFE71FF
    PastelOrange* = colour 0xFF964FFF
    PastelRed*    = colour 0xDB5856FF

    Sand*         = colour 0xE2CA76FF
    Puce*         = colour 0xA57E52FF
    OliveDrab*    = colour 0x6F7632FF
    Moss*         = colour 0x769958FF
    Grass*        = colour 0x5CAC2DFF
    Terracotta*   = colour 0xCA6641FF
    Sienna*       = colour 0xA9561EFF
    BurntSienna*  = colour 0xB04E0FFF
    Chocolate*    = colour 0x3D1C02FF
    Tangerine*    = colour 0xFF9408FF
    Raspberry*    = colour 0xB00149FF
    Orchid*       = colour 0xC875C4FF
    Emerald*      = colour 0x01A049FF
    Jade*         = colour 0x1FA774FF
    Clay*         = colour 0xB66A50FF
    Mud*          = colour 0x735C12FF
    Mahogany*     = colour 0x4A0100FF
    Wine*         = colour 0x80013FFF
    Evergreen*    = colour 0x05472AFF
    Denim*        = colour 0x3B638CFF
    Umber*        = colour 0xB26400FF
    Avocado*      = colour 0x90B134FF
    Ultramarine*  = colour 0x2000B1FF
    Apricot*      = colour 0xFFB16DFF
    Cerise*       = colour 0xDE0C62FF
    Blush*        = colour 0xF29E8EFF
    Steel*        = colour 0x738595FF
    Marigold*     = colour 0xFCC006FF
    Bordeaux*     = colour 0x7B002CFF
    Pistachio*    = colour 0xC0FA8BFF
    Dirt*         = colour 0x8A6E45FF
    Bronze*       = colour 0xA87900FF
    Pine*         = colour 0x2B5D34FF
    Russet*       = colour 0xA13905FF
    Vermillion*   = colour 0xF4320CFF
    Amber*        = colour 0xFEB308FF
    Silver*       = colour 0xC5C9C7FF
    Melon*        = colour 0xFF7855FF
    Cranberry*    = colour 0x9E003AFF
    Ecru*         = colour 0xFEFFCAFF
    Mocha*        = colour 0x9D7651FF
    Coffee*       = colour 0xA6814CFF
    Sepia*        = colour 0x985E2BFF
    Marine*       = colour 0x042E60FF
    Camel*        = colour 0xC69F59FF
    Sandstone*    = colour 0xC9AE74FF
    Maize*        = colour 0xF4D054FF
    Barney*       = colour 0xAC1DB8FF
    Adobe*        = colour 0xBD6C48FF
    Ivory*        = colour 0xFFFFCBFF
    Copper*       = colour 0xB66325FF
    Strawberry*   = colour 0xFB2943FF
    Celery*       = colour 0xC1FD95FF
    Celadon*      = colour 0xBEFDB7FF
    Auburn*       = colour 0x9A3001FF
    Mulberry*     = colour 0x920A4EFF
    Watermelon*   = colour 0xFD4659FF
    Wheat*        = colour 0xFBDD7EFF
    Drab*         = colour 0x828344FF
    Cherry*       = colour 0xCF0234FF
    Gunmetal*     = colour 0x536267FF
    Caramel*      = colour 0xAF6F09FF
    Blueberry*    = colour 0x464196FF
    Asparagus*    = colour 0x77AB56FF
    Earth*        = colour 0xA2653EFF
    Stone*        = colour 0xADA587FF
    Pea*          = colour 0xA4BF20FF
    Chestnut*     = colour 0x742802FF
    Amethyst*     = colour 0x9B5FC0FF
    Fawn*         = colour 0xCFAF7BFF
    Buff*         = colour 0xFEF69EFF
    Sea*          = colour 0x3C9992FF
    Tomato*       = colour 0xEF4026FF
    Banana*       = colour 0xFFFF7EFF
    Sandy*        = colour 0xF1DA7AFF
    Pear*         = colour 0xCBF85FFF
    Iris*         = colour 0x6258C4FF
    Seaweed*      = colour 0x18D17BFF
    Kiwi*         = colour 0x9CEF43FF
    Dusk*         = colour 0x4E5481FF
    Apple*        = colour 0x6ECB3CFF
    Merlot*       = colour 0x730039FF
    Bubblegum*    = colour 0xFF6CB5FF
    Shamrock*     = colour 0x01B44CFF
    Mango*        = colour 0xFFA62BFF
    Heather*      = colour 0xA484ACFF
    Spearmint*    = colour 0x1EF876FF
    Viridian*     = colour 0x1E9167FF
    Wisteria*     = colour 0xA87DC2FF
    Velvet*       = colour 0x750851FF
    Sunflower*    = colour 0xFFC512FF
    Leaf*         = colour 0x71AA34FF
    Butter*       = colour 0xFFFF81FF
    Saffron*      = colour 0xFEB209FF
    Putty*        = colour 0xBEAE8AFF
    Ruby*         = colour 0xCA0147FF
    Dandelion*    = colour 0xFEDF08FF
    Claret*       = colour 0x680018FF
    Rosa*         = colour 0xFE86A4FF
    Algae*        = colour 0x54AC68FF
    Ice*          = colour 0xD6FFFAFF
    Grapefruit*   = colour 0xFD5956FF
    Carmine*      = colour 0x9D0216FF
    Mushroom*     = colour 0xBA9E88FF
    Canary*       = colour 0xFDFF63FF
    Hazel*        = colour 0x8E7618FF
    Leather*      = colour 0xAC7434FF
    Topaz*        = colour 0x13BBAFFF
    Straw*        = colour 0xFCF679FF
    Parchment*    = colour 0xFEFCAFFF
    Sapphire*     = colour 0x2138ABFF
    Fern*         = colour 0x63A950FF
    Cocoa*        = colour 0x875F42FF
    Cinnamon*     = colour 0xAC4F06FF
    Squash*       = colour 0xF2AB15FF
    Toupe*        = colour 0xC7AC7DFF
    Butterscotch* = colour 0xFDB147FF
    Lichen*       = colour 0x8FB67BFF
    Azul*         = colour 0x1D5DECFF
    Manilla*      = colour 0xFFFA86FF
    Custard*      = colour 0xFFFD78FF
    Desert*       = colour 0xCCAD60FF
    Spruce*       = colour 0x0A5F38FF
    Cement*       = colour 0xA5A391FF
    Brick*        = colour 0x8F1402FF
    Charcoal*     = colour 0x343837FF
    Crimson*      = colour 0x8C000FFF
    Scarlet*      = colour 0xBE0119FF
    HotPink*      = colour 0xFF028DFF
    NavyBlue*     = colour 0x001146FF
    Cerulean*     = colour 0x0485D1FF
    Azure*        = colour 0x069AF3FF
    Cobalt*       = colour 0x1E488FFF
    Chartreuse*   = colour 0xC1F80AFF
    Eggplant*     = colour 0x380835FF
    Grape*        = colour 0x6C3461FF
    Aubergine*    = colour 0x3D0734FF
    Mustard*      = colour 0xCEB301FF
    Ochre*        = colour 0xBF9005FF
