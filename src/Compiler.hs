{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Compiler
  ( CompilationState (..),
    DocumentState (..),
  )
where

import qualified Data.Map as M
import Data.Map (Map)

import Control.Lens.TH (makeLenses)

import Control.Monad.Trans.State.Lazy (StateT)
import Control.Monad.Trans.Except (ExceptT)

import Parser (PathKind, Identifier (..), StringLiteral (..))

data CompilationState = CompilationState
  { _file :: String,
    _pwd :: String,
    _kind :: PathKind
  }
  deriving (Show)

data DocumentState = DocumentState
  { _variableMap :: Map Identifier StringLiteral,
    _stack :: [String],
    _hasClass :: Bool,
    _initialized :: Bool,
    _compilation :: CompilationState
  }
  deriving (Show)

makeLenses ''CompilationState
makeLenses ''DocumentState

-- | Custom StateT with support for error-handling
type CompileT e s m = StateT s (ExceptT e m)
