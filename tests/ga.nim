# import std/strutils, ngm
# from std/strformat import `&`

# let
#     x = 2'e1
#     y = 4'e2
#     z = 6'e0

# echo &"Testing PGA with blades {{{AllBlades.join \", \"}}} and basis vectors {{{FullBasis.join \", \"}}}"

# assert &"{x}, {y}, {z}" == "2.0e1, 4.0e2, 6.0e0"
# assert &"{1'e1}, {2'e2}" == "1.0e1, 2.0e2"
# assert &"{5'e12}" == "5.0e12"

# assert 1'e1 + 1'e1 == 2'e1
# assert 2'e1 + 4'e1 == 6'e1
# assert 3'e2 + 4'e2 == 7'e2
# assert 1'e0 + 1'e1                == vector(1, 1, 0)
# assert 2'e0 + 43'e1 + 4'e2        == vector(2, 43, 4)
# assert 1'e1 + 3'e12               == multivector(x = 1, xy = 3)
# assert 1'e2 + 2'e2 + 3'e0 + 5'e12 == multivector(y = 3, w = 3, xy = 5)

# echo 1'e1 * 1'e1
# echo 1'e0 * 1'e0

# # echo 1'e123 + 3'e1 + 5'e0
# # echo 1'e20 + 3'e01

