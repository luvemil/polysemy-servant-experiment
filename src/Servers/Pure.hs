-- | Defines the Servant Server using the dummy implementation of the Storage

{-# LANGUAGE DeriveGeneric, TemplateHaskell, OverloadedStrings, RecordWildCards #-}

module Servers.Pure where

import Data.Aeson
import Data.Text
import qualified Data.Map as M
import Polysemy
import Servant.API (Get, Capture, ReqBody, PutCreated, NoContent(..), JSON, (:>), (:<|>)(..))
import Servant.Server
import Data.Functor

import Servers.API
import Effects.Storage

-- | Build handlers for the API
server :: Server PostAPI
server =
         fetchAllHandler
    :<|> fetchHandler
    :<|> insertHandler
    where
        runner = runM . runStorage
        fetchAllHandler = runner getAllPosts
        fetchHandler = runner . getPost
        insertHandler uuid post = runner (putPost uuid post) $> NoContent


app :: Application
app = serve postAPI server