-- | Defines the Servant Server using an in memory implementation of the Storage

{-# LANGUAGE DeriveGeneric, TemplateHaskell, OverloadedStrings, RecordWildCards #-}

module Servers.InMemory where

import Data.Aeson
import Data.Text
import qualified Data.Map as M
import Polysemy
import Polysemy.State
import GHC.Generics
import Servant.API (Get, Capture, ReqBody, PutCreated, NoContent(..), JSON, (:>), (:<|>)(..))
import Servant.Server
import Data.Proxy
import Data.Functor
import qualified Network.Wai.Handler.Warp as Warp
import Control.Monad.Trans.Reader (ReaderT, runReaderT, ask)

import Data.IORef
import Control.Monad.IO.Class

import Servers.API
import Effects.Storage


-- | Build handlers for the API
makeServer :: IORef InMemStorage -> Server PostAPI
makeServer ioRef =
         fetchAllHandler
    :<|> fetchHandler
    :<|> insertHandler
    where
        fetchAllHandler =
              liftIO
            . runM
            . runStateIORef ioRef
            . runStorageToState
            $ getAllPosts
        fetchHandler =
              liftIO
            . runM
            . runStateIORef ioRef
            . runStorageToState
            . getPost
        insertHandler uuid post =
              liftIO
            . runM
            . runStateIORef ioRef
            . runStorageToState
            $ (putPost uuid post)
            $> NoContent


runApp :: IORef InMemStorage -> Application
runApp ioRef = serve postAPI $ makeServer ioRef