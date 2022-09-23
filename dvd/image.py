import numpy as np
from PIL import Image
import sys

im = Image.open('dvdlogo-04.png').convert("RGBA")

x, y = im.size

r = 8
x = int(x / r)
y = int(y / r)

sys.stderr.write(f"image dimensions = ({x}, {y})\n")

im = im.resize((x, y))

# im.show()

_, _, _, a = im.split()

alpha = np.array(a.tobytes())

sys.stdout.buffer.write(bytes(alpha))