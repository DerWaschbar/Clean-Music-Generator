definition module util.Monad.Parser

import util.Monad
import util.Monad.Result

:: Parser a

instance Monad Parser

parse :: !(Parser a) ![Char] -> Result a

fail :: String -> Parser a
(<|>) infixl 3 :: !(Parser a) (Parser a) -> Parser a

eof     :: Parser ()
anyChar :: Parser Char
char    :: !Char   -> Parser Char
string  :: !String -> Parser String

takeP :: !Int -> Parser [Char]

uintBE :: !Int -> Parser Int
uintLE :: !Int -> Parser Int
