implementation module synthesis.Wave
import StdEnv
import util.Constants
import synthesis.Accesstable
import synthesis.Wavetable
import util.ListUtils


sineTable :== (wavetable 1.0)


// takes harmonics and amplitudes as parameter and generates wave
wave :: [Real] [Real] -> [Real] 
wave h a = sumAll l
where 
    l = (get sineTable h a freq)


