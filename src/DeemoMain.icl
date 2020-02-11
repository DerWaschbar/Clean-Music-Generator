module DeemoMain
import StdEnv

//Custom library imports
import Synthesis.Accesstable, Synthesis.Generate, Synthesis.Wave, Synthesis.Wavetable
import Util.Byte, Util.Constants, Util.ListUtils, Util.Rand, Util.TimeUtils, Util.Pitch, Util.Notation, Util.TypeDefs
import Input.Chunks, Input.ReadFile
import Output.MiddleLayer, Output.Pcm

/*
:: Envelope = { attack :: Beat, decay :: Beat, sustain :: Real, release :: Real}
:: SynthProfile = { type :: Wave, env :: Envelope}
SquareProfile :: SynthProfile
SquareProfile = {type = Square, env = {attack=(1.0/32.0), decay=(1.0/64.0), sustain = 0.2, release = 0.25}}
*/


FurElise :: (Melody,Melody,TimeSignature,Tempo)
FurElise = (RightHand, LeftHand, {barVal = 3,noteVal = 8}, 120.00)

RightHand :: Melody
RightHand = [
                On (genNote("E5",1,16)), On (genNote("D#5",1,16)),
                On (genNote("E5",1,16)), On (genNote("D#5",1,16)), On (genNote("E5",1,16)), On (genNote("B4",1,16)), On (genNote("D5",1,16)), On (genNote("C5",1,16)),
                On (genNote("A4",1,8)), Off {p=1, q=16}, On (genNote("C4",1,16)), On (genNote("E4",1,16)), On (genNote("A4",1,16)),
                On (genNote("B4",1,8)), Off {p=1, q=16}, On (genNote("E4",1,16)), On (genNote("G#4",1,16)), On (genNote("B4",1,16)),
                On (genNote("C5",1,8)), Off {p=1, q=16}, On (genNote("E4",1,16)), On (genNote("E5",1,16)), On (genNote("D#5",1,16)),
                //halfway point
                On (genNote("E5",1,16)), On (genNote("D#5",1,16)), On (genNote("E5",1,16)), On (genNote("B4",1,16)), On (genNote("D5",1,16)), On (genNote("C5",1,16)),
                On (genNote("A4",1,8)), Off {p=1, q=16}, On (genNote("C4",1,16)), On (genNote("E4",1,16)), On (genNote("A4",1,16)),
                On (genNote("B4",1,8)), Off {p=1, q=16}, On (genNote("E4",1,16)), On (genNote("C5",1,16)), On (genNote("B4",1,16)),
                On (genNote("A4",3,8))
            ]

LeftHand :: Melody
LeftHand = [
                Off {p=1,q=8},
                Off {p=3,q=8},
                On (genNote("A2",1,16)), On (genNote("E3",1,16)), On (genNote("A3",1,16)), Off {p=1,q=16}, Off {p=1,q=8},
                On (genNote("E2",1,16)), On (genNote("E3",1,16)), On (genNote("G#3",1,16)), Off {p=1,q=16}, Off {p=1,q=8},
                On (genNote("A2",1,16)), On (genNote("E3",1,16)), On (genNote("A3",1,16)), Off {p=1,q=16}, Off {p=1,q=8},
                //halfway point
                Off {p=3,q=8},
                On (genNote("A2",1,16)), On (genNote("E3",1,16)), On (genNote("A3",1,16)), Off {p=1,q=16}, Off {p=1,q=8},
                On (genNote("E2",1,16)), On (genNote("E3",1,16)), On (genNote("G#3",1,16)), Off {p=1,q=16}, Off {p=1,q=8},
                On (genNote("A2",1,16)), On (genNote("E3",1,16)), On (genNote("A3",1,16)), Off {p=1,q=16}, Off {p=1,q=8}
           ]

generateSong :: (Melody,Melody,TimeSignature,Tempo) -> [Real]
generateSong (rh, lh, ts, tmp) = map (\x = x* 0.5) (sumAll[rhGenerated,lhGenerated])
where
    renderNote :: Wave (Next, TimeSignature, Tempo) -> [Real]
    renderNote wavetype ((On {note = n, duration = d}),ts, tmp) = generate wavetype freq dur
        where
        freq = convStrToFreq  n
        dur = noteToSamples d ts tmp
    renderNote _ ((Off d), ts, tmp) = generate Silence 420.420 dur
        where
            dur = noteToSamples d ts tmp

    rhGenerated = flatten [renderNote Square (aNote, ts, tmp)\\aNote<-rh]
    lhGenerated = flatten [renderNote Sine (aNote, ts, tmp)\\aNote<-lh]

checkLengths :: (Melody,Melody,TimeSignature,Tempo) -> Bool
checkLengths (a,b,_,_) = getMelodyLength a == getMelodyLength b

gimmeLength :: (Melody,Melody,TimeSignature,Tempo) -> Beat
gimmeLength (a,_,_,_) = getMelodyLength a

rawRender ::[Real]
rawRender = generateSong FurElise

extendedRender :: [Real]
extendedRender = rawRender ++ listSilence
where
    dur = noteToSamples {p=3,q=8} {barVal = 3,noteVal = 8} 120.00
    listSilence = repeatn dur 0.00

fakeDelay :: [Real]
fakeDelay = map (\sample = sample * 0.5) (shiftLeft extendedRender (-1 * dur))
where
    dur = noteToSamples {p=1,q=128} {barVal = 3,noteVal = 8} 120.00

fakeReverb :: [Real]
fakeReverb = map (\sample = sample * 0.2) (shiftLeft extendedRender (-1 * dur))
where
    dur = noteToSamples {p=1,q=8} {barVal = 3,noteVal = 8} 120.00

fakeReverb2 :: [Real]
fakeReverb2 = map (\sample = sample * 0.04) (shiftLeft extendedRender (-1 * dur))
where
    dur = noteToSamples {p=1,q=4} {barVal = 3,noteVal = 8} 120.00


reverbRender :: [Real]
reverbRender = sumAll [extendedRender,fakeReverb]


newParams8 :: PcmWavParams
newParams8 = {numChannels = 1, numBlocks = FurEliseSamples, samplingRate = 44100, bytesPerSample = 1}

newParams16 :: PcmWavParams
newParams16 = {numChannels = 1, numBlocks = FurEliseSamples, samplingRate = 44100, bytesPerSample = 2}

newParams32 :: PcmWavParams
newParams32 = {numChannels = 1, numBlocks = FurEliseSamples, samplingRate = 44100, bytesPerSample = 4}


FurEliseLength :: Beat
FurEliseLength = gimmeLength FurElise

FurEliseSamples :: Int
FurEliseSamples = (noteToSamples {p=3,q=8} {barVal = 3,noteVal = 8} 120.00) + (noteToSamples FurEliseLength {barVal = 3,noteVal = 8} 120.00)

newData8 :: [Char]
newData8 = transform_one_channel extendedRender 1.0 Eight

newData16 :: [Char]
newData16 = transform_one_channel extendedRender 1.0 Sixteen

newData32 :: [Char]
newData32 = transform_one_channel extendedRender 1.0 ThirtyTwo

extraData32 :: [Char]
extraData32 = transform_one_channel reverbRender 1.0 ThirtyTwo

wavTest :: !*World -> *World
wavTest w
  #! (_, f, w) = fopen "test10_new.wav" FWriteData w
  #! f = writePcmWav newParams32 extraData32 f
  #! (_, w) = fclose f w
  = w
//Start = FurEliseLength
//Start = FurEliseSamples
//Start = checkLengths FurElise
//Start = generateSong FurElise
//Start = 1
//Start = rawRender
Start w = wavTest w
