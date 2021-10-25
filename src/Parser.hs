{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Parser
  ( parseEscapeSequence,
    parseIdentifier,
    parseFString,
    parseStringLiteral,
    parseStringComponent,
  )
where

import Control.Monad
import Data.Text
import Data.Void
import Text.Megaparsec.Char
    ( char, alphaNumChar, alphaNumChar, char, letterChar )
import Text.Megaparsec
import qualified Text.Megaparsec.Char as C
import qualified Text.Megaparsec.Char.Lexer as L

-- | The core spec types
newtype Identifier = Identifier {toStr :: String}
    deriving (Show)
newtype CharEscape = CharEscape {getChar :: Char}
    deriving (Show)
newtype FString = FString {identifier :: Identifier}
    deriving (Show)
newtype StringLiteral = StringLiteral {text :: String}
    deriving (Show)
data Variable = Variable {identifier :: Identifier, value :: StringLiteral}
    deriving (Show)

-- | Abstractions
data StringComponent = Literal String | VariableReplacement FString | EscapeSequence CharEscape
    deriving (Show)

-- | The parser type.
type Parser = Parsec Void Text

-- | Parsers

-- | '\' - Character Escaping
parseEscapeSequence :: Parser CharEscape
parseEscapeSequence = do
    void  $ single '\\'
    char <- L.charLiteral
    pure CharEscape{getChar=char}

-- | Identifier
parseIdentifier :: Parser Identifier
parseIdentifier = do
    ident <- (:) <$> letterChar <*> many alphaNumChar
    pure Identifier{toStr=ident}

-- | '$' - FString
parseFString :: Parser FString
parseFString = do
    void $ single '$'
    ident <- parseIdentifier
    pure FString{identifier=ident}

-- | StringLiteral
-- | '\"' <inner> '\"'
parseStringLiteral :: Parser StringLiteral
parseStringLiteral = do
    x <- char '"' >> manyTill L.charLiteral (char '"')
    pure StringLiteral {text=x}

-- | String Components
parseStringComponent :: Parser StringComponent
parseStringComponent = choice
    [ EscapeSequence <$> parseEscapeSequence,
      VariableReplacement <$> parseFString,
      Literal <$> parseWord
    ]

reservedSymbols :: Parser ()
reservedSymbols = try $ choice [
        void parseEscapeSequence,
        void parseFString
    ]

parseWord :: Parser String
parseWord = someTill L.charLiteral $ choice [
        reservedSymbols,
        void $ char ' ',
        eof
    ]

-- | Keywords
-- | `out` `var`

-- | Pragmas
-- | `include` `import` `class`
