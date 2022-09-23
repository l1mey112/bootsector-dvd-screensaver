import os

fn main(){
	bytes := os.read_bytes('dvd/rawdvdbytes') or {
		os.read_bytes('rawdvdbytes')?
	}
	// println(bytes)

	mut p := 0
	for y := 0 ; y < 10 ; y++ {
		for x := 0 ; x < 23 ; x++ {
			st := if bytes[p] > 100 { "aa" } else { " " }
			print(st)
			p++
		}
		println("")
	}
}