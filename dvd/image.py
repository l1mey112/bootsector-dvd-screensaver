import numpy as np
from PIL import Image
import sys
from bitarray import bitarray
import math

# I HATE PYTHON BRUH
# IT FUCKING SUCKS FOR LOW LEVEL STUFF

def printdef(a):
	sys.stderr.write(f"{a} ")

im = Image.open('dvdlogo-04.png').convert("RGBA")

x, y = im.size

# printdef(f"old image dimensions = ({x}, {y})")

r = 2.53
x = int(x / r)
y = int(y / r)

# printdef(f"new image dimensions = ({x}, {y})")

im = im.resize((x, y))

# im.show()

_, _, _, a = im.split()

alpha = np.array(a.tobytes())

alphab = bytes(alpha)

bit_array = bitarray()
bit_array.setall(0)

a = 0
for b in range(0, alphab.__len__()):
	if b % x == 0:
		if b != 0:
			for _a in range(0, bit_array.padbits):
				bit_array.append(0)
		a += 1
		# printdef(f"{bit_array.nbytes}")
	else:
		bit_array.append(int(alphab[b] > 100))

# printdef(f"{bit_array.__len__()} in bits")
ner = int(math.ceil(x / 8))
printdef(f"-DSCANLINE_BYTE_LEN={ner}")
printdef(f"-DIMAGE_SCANLINE_AMT={int(round(int(a) / int(2)))}")
printdef(f"-DIMAGE_RECT_WIDTH={int(round(int(ner) / int(2)))}")

sys.stdout.buffer.write(bit_array.tobytes())