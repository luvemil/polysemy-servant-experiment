module Lib where


import qualified Network.Wai.Handler.Warp as Warp
import Control.Monad.Trans.Reader (ReaderT, runReaderT, ask)

import Data.IORef
import Control.Monad.IO.Class

import Servers.Pure (app)
import Servers.InMemory (runApp)
import Effects.Storage

pureMain :: IO ()
pureMain = Warp.run 9000 app

ioMain :: IO ()
ioMain = do
    ioRef <- newIORef M.empty
    Warp.run 9000 $ runApp ioRef