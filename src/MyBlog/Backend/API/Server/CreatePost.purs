module MyBlog.Backend.API.Server.CreatePost where

import Prelude

import Control.Monad.Trans.Class (lift)
import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Record as CAR
import MyBlog.Backend.API.Effect.DB (DB)
import MyBlog.Backend.API.Effect.DB as DB
import MyBlog.Backend.API.Effect.Log (LOG)
import MyBlog.Backend.API.Effect.Log as Log
import MyBlog.Backend.API.Server.Utils (ServerHandler)
import MyBlog.Backend.Types (PostId)
import MyBlog.Backend.Types as T
import Type.Row (type (+))

type Input =
  { title :: String
  , body :: String
  }

input :: CA.JsonCodec Input
input = CA.object "CreatePostInput" $
  CAR.record
    { title: CA.string
    , body: CA.string
    }

type Output =
  { postId :: PostId
  }

output :: CA.JsonCodec Output
output = CA.object "CreatePostOutput" $
  CAR.record
    { postId: T.postId
    }

handler :: forall r. Input -> ServerHandler (LOG + DB + r) Output
handler { title, body } = do
  lift $ Log.info "I'll create new post."
  postId <- lift $ DB.insertPost title body
  pure { postId }

