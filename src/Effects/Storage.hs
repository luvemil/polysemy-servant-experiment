{-# LANGUAGE DeriveGeneric, TemplateHaskell, OverloadedStrings, RecordWildCards #-}

module Effects.Storage where

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

-- | Define the data. Let's make it almost non trivial
data Post = Post
    { title :: Text
    , uuid :: Text
    , content :: Text
    , tags :: [Text]
    } deriving (Generic)

instance ToJSON Post
instance FromJSON Post

-- | Define a storage
data Storage m a where
    GetAllPosts :: Storage m (M.Map Text Post)
    GetPost :: Text -> Storage m (Maybe Post)
    PutPost :: Text -> Post -> Storage m ()

makeSem ''Storage

-- | Make a dummy post
dummy :: Post
dummy = Post "title" "dummy" "content" []

-- | Implement a dummy storage
runStorage :: Sem (Storage ': r) a -> Sem r a
runStorage = interpret $ \case
    GetAllPosts           -> pure $ M.singleton "dummy" dummy
    GetPost uuid          -> pure $ Just dummy
    PutPost uuid post     -> pure ()

type InMemStorage = M.Map Text Post

-- | Implement in memory storage
runStorageToState
    :: Member (State InMemStorage) r => Sem (Storage ': r) a -> Sem r a
runStorageToState = interpret $ \case
    GetAllPosts       -> gets Prelude.id
    GetPost uuid      -> gets (\m -> M.lookup uuid m)
    PutPost uuid post -> modify (\m -> M.insert uuid post m) $> ()

-- | Define the API
type PostAPI =
         "post" :> Get '[JSON] (M.Map Text Post)
    :<|> "post" :> Capture "postId" Text :> Get '[JSON] (Maybe Post)
    :<|> "post" :> Capture "postId" Text
                :> ReqBody '[JSON] Post
                :> PutCreated '[JSON] NoContent