module MyBlog.Backend.API.Effect.DB where

import Prelude

import MyBlog.Backend.Types (PostId, PostInfo)
import Run (Run)
import Run as Run
import Type.Proxy (Proxy(..))
import Type.Row (type (+))

data Db a
  = InsertPost String String (PostId -> a)
  | ListPosts (Array PostInfo -> a)

derive instance Functor Db

type DB r = (db :: Db | r)

_db :: Proxy "db"
_db = Proxy

interpret :: forall r a. (Db ~> Run r) -> Run (DB + r) a -> Run r a
interpret handler = Run.interpret (Run.on _db handler Run.send)

insertPost :: forall r. String -> String -> Run (DB + r) PostId
insertPost title body = Run.lift _db $ InsertPost title body identity

listPosts :: forall r. Run (DB + r) (Array PostInfo)
listPosts = Run.lift _db $ ListPosts identity

