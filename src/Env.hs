module Env where

import Effects.Storage
import Control.Monad.Trans.Reader (ReaderT, runReaderT, ask)

import Data.IORef
import Control.Monad.IO.Class

data Env = Env
    { storageIORef :: IORef InMemStorage
    }

type App = ReaderT Env IO