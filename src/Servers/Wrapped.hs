-- | Wraps the Servant server defined in Servers.InMemory in an App

{-# LANGUAGE DeriveGeneric, TemplateHaskell, OverloadedStrings, RecordWildCards #-}

module Servers.Wrapped where

import Servers.InMemory
import Env
import Servant.Server
import Servers.API
import Control.Monad.Trans.Reader (ReaderT, runReaderT, ask)

server :: App (Server PostAPI)
server = do
    Env {..} <- ask
    pure $ makeServer storageIORef

app :: App Application
app = server >>= \s -> pure $ serve postAPI s