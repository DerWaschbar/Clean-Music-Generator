module maintest

import StdEnv
import StdFile
import Util.Byte
import Input.ReadFile
import Input.SoundFont.Parse
import Input.Wav.Parse
import Output.Pcm
import Output.MiddleLayer
import Synthesis.Wavetable

wavTest :: !*World -> *World
wavTest w
  #! (_, f, w) = fopen "test.wav" FWriteData w
  #! data = transform (wavetable 0.5) 0.5
  #! f = writePcmWav
      { numChannels    = 1
      , numBlocks      = length data
      , samplingRate   = 44100
      , bytesPerSample = 1
      } data f
  #! (_, w) = fclose f w
  = w

//Start w = wavTest w

read :: !*World -> (*World, [Note])
read oldW
	#! (b, oldF, newW) = fopen "Input/MIDI/simple.mid" FReadData oldW
	|not b = (newW, abort"can not open file")
	#! (l, newF) = readBytes oldF
	#! (b, newW2) = fclose newF newW
	= (newW2, readFile l)
		
//Start w = read w

//Start = parseSoundFont (fromString "RIFF\0\2\0\0sfbk")

parseTestWav :: !*World -> (!Result Wav, !*World)
parseTestWav w
  #! (b, f, w) = fopen "test.wav" FReadData w
  | not b = abort "File not found"
  #! (bs, f) = readBytes f
  #! (_, w) = fclose f w
  = (parseWav bs, w) 

//Start w = parseTestWav w 

//import synthesis.Wave, synthesis.Generate

//Start = generate Sawtooth
