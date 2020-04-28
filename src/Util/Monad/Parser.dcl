definition module Util.Monad.Parser

import StdMaybe
import Util.Byte
import Util.Monad
import Util.Monad.Result

:: Parser a

instance Monad Parser

// Runs the parser to get the result
parse :: !(Parser a) ![Char] -> Result a


// Stop parsing and report an error
fail :: !String -> Parser a

// The parser p <|> q first applies p.
// If it succeeds, the value of p is returned.
// If p fails, parser q is tried.
(<|>) infixl 3 :: !(Parser a) (Parser a) -> Parser a

// The parser p <?> str behaves as parser p,
// but whenever the parser p fails, it replaces the error with str
(<?>) infix 0 :: !(Parser a) String -> Parser a


// optional p tries to apply the parser p.
// It will parse p or Nothing.
// It only fails if p fails after consuming input.
// On success result of p is returned inside of Just,
// on failure Nothing is returned.
optional :: !(Parser a) -> Parser (Maybe a)

// between open close p parses open, followed by p and close.
// Returns the value returned by p.
between :: !(Parser open) !(Parser close) !(Parser a) -> Parser a

// choice ps tries to apply the parsers in the list ps in order,
// until one of them succeeds.
// Returns the value of the succeeding parser.
choice :: [Parser a] -> Parser a

// many p applies the parser p zero or more times
// and returns a list of the values returned by p.
many :: (Parser a) -> Parser [a]

// some p applies the parser p one or more times
// and returns a list of the values returned by p.
some :: !(Parser a) -> Parser [a]


// This parser only succeeds at the end of input.
eof :: Parser ()

// Parse and return a single character.
anyChar :: Parser Char

// The parser satisfy f succeeds for any character
// for which the supplied function f returns True.
satisfy :: !(Char -> Bool) -> Parser Char

// char c only matches the single character c.
char :: !Char -> Parser Char

// string str only matches the string str.
string :: !String -> Parser String


// takeP n parses n characters
takeP :: !Int -> Parser [Char]


// int s e b parses a binary integer
// with s signedness, e endianness and b bytes
int :: !Signedness !Endianness !Int -> Parser Int
