import os

fn main() {
	bytes := os.read_bytes('dvd/rawdvdbytes') or { os.read_bytes('rawdvdbytes')? }
	// println(bytes)

	for y := 0; y < 28; y++ {
		mut p := y * 8
		for x := 0; x < 8; x++ {
			mut b := bytes[p]
			for a := 0; a < 8; a++ {
				if b & 1 != 0 {
					print('#')
				} else {
					print(' ')
				}
				b <<= 1
			}
			p++
		}
		println('')
	}
}
