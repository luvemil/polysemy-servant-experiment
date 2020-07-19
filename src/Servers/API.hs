{-# LANGUAGE DeriveGeneric, TemplateHaskell, OverloadedStrings, RecordWildCards #-}

module Servers.API where

import Data.Text
import qualified Data.Map as M
import Servant.API (Get, Capture, ReqBody, PutCreated, NoContent(..), JSON, (:>), (:<|>)(..))
import Data.Proxy
import Data.Functor


-- | Define the API
type PostAPI =
         "post" :> Get '[JSON] (M.Map Text Post)
    :<|> "post" :> Capture "postId" Text :> Get '[JSON] (Maybe Post)
    :<|> "post" :> Capture "postId" Text
                :> ReqBody '[JSON] Post
                :> PutCreated '[JSON] NoContent

postAPI :: Proxy PostAPI
postAPI = Proxy