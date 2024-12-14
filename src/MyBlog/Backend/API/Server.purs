module MyBlog.Backend.API.Server where

import Prelude

import Data.Argonaut.Core (stringify)
import Data.Argonaut.Parser as J
import Data.Bifunctor (lmap)
import Data.Codec.Argonaut as CA
import HTTPurple (Method(..))
import HTTPurple as HTTPurple
import MyBlog.Backend.API.Effect.DB (DB)
import MyBlog.Backend.API.Effect.Log (LOG)
import MyBlog.Backend.API.Server.CreatePost as CreatePost
import MyBlog.Backend.API.Server.Endpoint (Endpoint(..))
import MyBlog.Backend.API.Server.ListPosts as ListPosts
import MyBlog.Backend.API.Server.Utils (ErrorType)
import Run (AFF, Run, EFFECT)
import Run.Except (EXCEPT)
import Type.Row (type (+))

type ServerEffects r = (DB + LOG + EXCEPT ErrorType + EFFECT + AFF + r)

router :: HTTPurple.Request Endpoint -> Run (ServerEffects ()) HTTPurple.Response
router { method, route, body } = HTTPurple.usingCont case method, route of
  HTTPurple.Post, Posts -> do
    HTTPurple.fromJson (decoder CreatePost.input) body
      >>= CreatePost.handler
      >>= (HTTPurple.toJson (encoder CreatePost.output) >>> HTTPurple.ok)

  Get, Posts -> do
    ListPosts.handler
      >>= (HTTPurple.toJson (encoder ListPosts.output) >>> HTTPurple.ok)

  _, _ -> HTTPurple.notFound

decoder :: forall a. CA.JsonCodec a -> HTTPurple.JsonDecoder String a
decoder codec = HTTPurple.JsonDecoder (J.jsonParser >=> CA.decode codec >>> lmap CA.printJsonDecodeError)

encoder :: forall a. CA.JsonCodec a -> HTTPurple.JsonEncoder a
encoder codec = HTTPurple.JsonEncoder (CA.encode codec >>> stringify)

