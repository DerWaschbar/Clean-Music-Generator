module maintest

import StdEnv
import StdFile
import Util.Byte
import Util.ListUtils
import Input.ReadFile
// import Input.SoundFont.Parse
import Input.Wav.Parse
import Output.Pcm
import Output.MiddleLayer
import Synthesis.Wavetable
import Synthesis.Generate
import Synthesis.Wave


// wavTest :: !*World -> *World
// wavTest w
//   #! (_, f, w) = fopen "test.wav" FWriteData w
//   #! data = transform16 (wavetable 0.5) 0.5
//   #! f = writePcmWav
//       { numChannels    = 1
//       , numBlocks      = (length data / 1)
//       , samplingRate   = 44100
//       , bytesPerSample = 2
//       } data f
//   #! (_, w) = fclose f w
//   = w


// Start w = wavTest w

// Start = generate Sawtooth 420.420 2205


// read :: !*World -> (*World, [Note])
// read oldW
// 	#! (b, oldF, newW) = fopen "Input/MIDI/simple.mid" FReadData oldW
// 	|not b = (newW, abort"can not open file")
// 	#! (l, newF) = readBytes oldF
// 	#! (b, newW2) = fclose newF newW
// 	= (newW2, readFile l)
		
//Start w = read w

// parseSF :: !*World -> (!Result Pdta, !*World)
// parseSF w
//   #! (b, f, w) =
//       fopen "../test_files/input/soundfont/STR_Ensemble.sf2" FReadData w
//   | not b = abort "File not found"
//   #! (bs, f) = readBytes f
//   #! (_, w) = fclose f w
//   = ((\t. t.pdta) <$> parseSoundFont bs, w) 

// Start w = parseSF w

// parseTestWav :: !*World -> (!Result Wav, !*World)
// parseTestWav w
//   #! (b, f, w) = fopen "test.wav" FReadData w
//   | not b = abort "File not found"
//   #! (bs, f) = readBytes f
//   #! (_, w) = fclose f w
//   = (parseWav bs, w) 

//Start w = parseTestWav w 

//import synthesis.Wave, synthesis.Generate


