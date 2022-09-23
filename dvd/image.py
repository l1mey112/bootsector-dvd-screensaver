import numpy as np
from PIL import Image
import sys
from bitarray import bitarray
import math

# I HATE PYTHON BRUH
# IT FUCKING SUCKS FOR LOW LEVEL STUFF

def eprint(a):
	sys.stderr.write(f"{a}\n")

im = Image.open('dvdlogo-04.png').convert("RGBA")

x, y = im.size

eprint(f"old image dimensions = ({x}, {y})")

r = 2.9
x = int(x / r)
y = int(y / r)

eprint(f"new image dimensions = ({x}, {y})")

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
		# eprint(f"{bit_array.nbytes}")
	else:
		bit_array.append(int(alphab[b] > 100))

eprint(f"{bit_array.__len__()} in bits")
eprint(f"index by {math.ceil(x / 8)} for each x scanline")
eprint(f"height of {a} bytes")

sys.stdout.buffer.write(bit_array.tobytes())