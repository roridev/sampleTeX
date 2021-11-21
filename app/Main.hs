{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Lib
import System.Console.CmdArgs
import System.IO
import Prettyprinter
import Prettyprinter.Render.Terminal
import Parser
import System.FilePath

main :: IO ()
main = someFunc

data SampleC = SampleC {files :: [FilePath], engine :: Maybe String}
  deriving (Show, Data, Typeable)

spec =
  SampleC
    { files = def &= args &= typ "FILES",
      engine = def &= help "The LaTeX engine used for PDF compilation"
    }
    &= summary "The SampleTex Compiler"
    &= details
      [ "samplec will compile to TeX by default",
        "",
        "to compile to PDF set your preferred LaTeX engine",
        "and make sure its on %PATH%"
      ]

getKind :: FilePath -> Maybe PathKind
getKind ".sample" = Just SampleTex
getKind ".tex" = Just LaTeX
getKind _ = Nothing

-- | Blocking `getKind` using the IO Monad
-- | Wrote it that way since i could expand `getKind` alone and never mess with this.
getKind' :: FilePath -> IO PathKind
getKind' path = do
    let kind = getKind $ takeExtension path
    case kind of
      Nothing -> error "Unsupported file type."
      Just pk -> pure pk

-- Logging Stuff --
err = generic style stderr
    where style = color Red <> bold

warn = generic style stdout
    where style = color Yellow <> italicized

info = generic style stdout
    where style = color Cyan <> underlined

done = generic style stdout 
    where style = color Green
generic style fd text  = renderIO fd . layoutPretty defaultLayoutOptions $ annotate style text