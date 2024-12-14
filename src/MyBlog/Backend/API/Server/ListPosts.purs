module MyBlog.Backend.API.Server.ListPosts where

import Prelude

import Control.Monad.Trans.Class (lift)
import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Record as CAR
import MyBlog.Backend.API.Effect.DB (DB)
import MyBlog.Backend.API.Effect.DB as DB
import MyBlog.Backend.API.Effect.Log (LOG)
import MyBlog.Backend.API.Effect.Log as Log
import MyBlog.Backend.API.Server.Utils (ServerHandler)
import MyBlog.Backend.Types (PostInfo, postInfo)
import Type.Row (type (+))

type Output =
  { posts :: Array PostInfo
  }

output :: CA.JsonCodec Output
output = CA.object "ListPostsOutput" $
  CAR.record
    { posts: CA.array postInfo }

handler :: forall r. ServerHandler (LOG + DB + r) Output
handler = do
  lift $ Log.info "I'll list posts."
  posts <- lift DB.listPosts
  pure { posts }