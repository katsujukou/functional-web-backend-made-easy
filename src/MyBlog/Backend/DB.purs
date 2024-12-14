module MyBlog.Backend.DB where

import Prelude

import Data.Array (foldM)
import Data.Array as Array
import Data.Codec.Argonaut as CA
import Data.Either (Either(..))
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Effect.Exception as Exn
import MyBlog.Backend.Foreign.Pg (toSQLValue)
import MyBlog.Backend.Foreign.Pg as Pg
import MyBlog.Backend.Types (PostId, PostInfo, genPostId, postInfo, printPostId)
import Unsafe.Coerce (unsafeCoerce)

insertPost :: Pg.PoolClient -> String -> String -> Aff (Either Exn.Error PostId)
insertPost conn title body = do
  postId <- liftEffect $ genPostId
  -- SQLをログに出したりしたい。pg-promiseとか使ったほうがいい？
  res <- Aff.attempt $
    Pg.query conn
      """
        INSERT INTO posts (id, title, body) VALUES ($1, $2, $3);
        """
      [ toSQLValue $ printPostId postId
      , toSQLValue title
      , toSQLValue body
      ]
  pure $ map (const postId) res

listPosts :: Pg.PoolClient -> Aff (Array PostInfo)
listPosts conn = do
  res <- Pg.query conn
    """
    SELECT * FROM posts;
    """
    []
  res.rows #
    foldM
      ( \posts row -> case CA.decode postInfo (unsafeCoerce row) of
          Left err -> do
            Console.warn (CA.printJsonDecodeError err) $> posts
          Right post -> pure $ Array.snoc posts post
      )
      []