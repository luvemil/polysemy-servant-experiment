{-# LANGUAGE DeriveGeneric, OverloadedStrings   #-}
{-# LANGUAGE TypeOperators, DataKinds   #-}

module Lib where


import qualified Network.Wai.Handler.Warp      as Warp

import           Data.IORef
import           Control.Monad.IO.Class

import           Servers.Pure                   ( app )
import           Servers.InMemory               ( runApp )
import qualified Servers.Wrapped               as Wrapped
import           Effects.Storage

import qualified Data.Map                      as M
import           Control.Monad.Trans.Reader     ( ReaderT
                                                , runReaderT
                                                , ask
                                                )
import           GHC.Generics
import           Options.Generic

import           Env

data Mode = Pure | Ref | Read
    deriving (Generic, Show)

data Config = Config
    { mode :: Maybe Text <?> "One of: pure, io, reader"
    } deriving (Generic, Show)

instance ParseRecord Config

getMode :: Maybe Text -> Mode
getMode (Just "io"    ) = Ref
getMode (Just "reader") = Read
getMode _               = Pure

printMode :: Mode -> String
printMode Pure = "pure"
printMode Ref  = "io"
printMode Read = "reader"

pureMain :: IO ()
pureMain = Warp.run 9000 app

ioMain :: IO ()
ioMain = do
    ioRef <- newIORef M.empty
    Warp.run 9000 $ runApp ioRef

envMain :: IO ()
envMain = do
    ioRef <- newIORef M.empty
    app   <- runReaderT Wrapped.app (Env ioRef)
    Warp.run 9000 app

main :: IO ()
main = do
    c :: Config <- getRecord "Config"
    let Config modeMaybe = c
    let mode             = getMode $ unHelpful modeMaybe
    putStrLn $ "Running in mode: " ++ printMode mode
    case mode of
        Pure -> pureMain
        Ref  -> ioMain
        Read -> envMain
