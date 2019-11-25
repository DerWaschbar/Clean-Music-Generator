implementation module Input.readFile

import StdEnv
import StdFile
import StdMaybe
import Input.chunks
	
:: HeaderInfo = 
	{
		format :: Int,
		division:: Int
	}

:: TrackInfo :== [Message]

:: Message = 
	{
		deltaTime :: Int,
		event :: Event
	}

:: Channel :== Int

:: Frequency :== Real

::Event = NoteOn Channel Frequency| NoteOff Channel Frequency


:: Info = 
	{
		headerInfo :: HeaderInfo,
		trackInfo :: [TrackInfo]
	}

process :: [Char] -> Info
process l
	|length l > 14 && isHeader (take 4 l) = 
		{ 
			headerInfo = processHeader (drop 8 l), 
			trackInfo = processTrack (drop 14 l)
		}
	= abort "not enough information"

processHeader :: [Char] -> HeaderInfo
processHeader l = 
	{
		format = calcFormat (take 2 l),
		division = calcDivision (take 2(drop 4 l))
	}

processTrack :: [Char] -> [TrackInfo]
processTrack [] = []
processTrack l 
	//4bytes:type of chunk(mtrk)
	|isTrack l = processTrackBody (drop 4 l)
	= processTrackBody l

processTrackBody :: [Char] -> [TrackInfo]
processTrackBody l
	//4 bytes for length information
	#! chunkLen = trackChunkLen l
	#! chunkBody = drop 4 l
	//delete delta time info bytes
	#! nextChunk = drop chunkLen chunkBody 
	= [processMessage 0 chunkBody: processTrack nextChunk]
	
processMessage :: Int [Char] -> TrackInfo
processMessage lastEventLen [] = []
processMessage lastEventLen l 
	#! (result,deltaLen) =  deltaTime l
	#! chunkbody = drop deltaLen l
	#! eventLen = eventLen lastEventLen chunkbody
	= case processEvent chunkbody of 
		Just correctEvent -> [{
			deltaTime = result,
			event = correctEvent
			}: processMessage eventLen (drop eventLen chunkbody)]
		Nothing -> processMessage eventLen (drop eventLen chunkbody)

processEvent :: [Char] -> Maybe Event
processEvent [c:cs] 
	|isNoteOn c = Just(NoteOn (getChannel c) (getFrequency c))
	|isNoteOff c = Just(NoteOff (getChannel c) (getFrequency c))
	= Nothing

eventLen:: Int [Char]->Int
eventLen lastLen l
	#! n1 = firstHalfStatus (hd l)
	#! n2 = secondHalfStatus (hd l)
	//meta events -- status byte, type byte, length byte
	|n1 >= 15 && n2 == 15 = toInt(l !! 2) + 3
	//system exclusive events -- status byte, length byte
	|n1 >= 15 && n2 >=0 && n2 <= 7 = toInt(l !! 1) + 2
	//midi events
	|n1 == 12 || n1 == 13 = 2
	|(n1 >= 8 && n1 <= 11) || n1 == 14 = 3
	|n1 < 8 = lastLen - 1
	= abort (toString n2)

readBytes :: *File -> ([Char], *File)
readBytes oldF 
	#! (b, c, newF) = freadc oldF
	|not b = ([], newF)
	#! (l, f) = readBytes newF
	= ([c:l], f)

read :: !*World -> (*World, Info)
read oldW
	#! (b, oldF, newW) = fopen "simple.mid" FReadData oldW
	|not b = (newW, abort"can not open file")
	#! (l, newF) = readBytes oldF
	#! (b, newW2) = fclose newF newW
	= (newW2, process l)
		
Start w = read w