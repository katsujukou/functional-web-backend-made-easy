module MyBlog.Backend.API where

import Prelude

import Data.Either (Either(..), either)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console as Console
import Effect.Exception as Exn
import Fmt as Fmt
import HTTPurple (ServerM, internalServerError)
import HTTPurple as HTTPurple
import MyBlog.Backend.API.Effect.DB as DB
import MyBlog.Backend.API.Effect.Log (LOG, LogLevel)
import MyBlog.Backend.API.Effect.Log as Log
import MyBlog.Backend.API.Server (ServerEffects)
import MyBlog.Backend.API.Server as Server
import MyBlog.Backend.API.Server.Endpoint (endpoint)
import MyBlog.Backend.API.Server.Utils (ErrorType, raise)
import MyBlog.Backend.DB as Backend.DB
import MyBlog.Backend.Foreign.Dayjs as Dayjs
import MyBlog.Backend.Foreign.Pg as Pg
import Run (AFF, Run, EFFECT)
import Run as Run
import Run.Except (EXCEPT)
import Run.Except as Except
import Type.Row (type (+))

start :: Pg.Pool -> LogLevel -> ServerM
start pool minLevel = HTTPurple.serve { port: 3000 }
  { route: endpoint
  , router
  }
  where
  router req = do
    Pg.withConnection pool \conn -> do
      Server.router req
        # runEffects minLevel conn
        >>= either onPanic pure

  onPanic err = do
    liftEffect $ Console.error $ "[ERROR]" <> Exn.message err
    internalServerError "システムエラーが発生しました"

runEffects :: forall a. Log.LogLevel -> Pg.PoolClient -> Run (ServerEffects ()) a -> Aff (Either ErrorType a)
runEffects minLevel conn m = m
  # DB.interpret (dbNodePgHandler conn)
  # Log.interpret (logTerminalHandler minLevel)
  # Except.runExcept
  # Run.runBaseAff'

dbNodePgHandler :: forall r. Pg.PoolClient -> DB.Db ~> Run (LOG + AFF + EFFECT + EXCEPT ErrorType + r)
dbNodePgHandler conn = case _ of
  DB.InsertPost title body reply -> do
    res <- Run.liftAff $ Backend.DB.insertPost conn title body
    case res of
      Right postId -> pure $ reply postId
      Left err -> do
        raise $ Fmt.fmt @"An error has occurred during executing query: {msg}" { msg: Exn.message err }

  DB.ListPosts reply -> do
    posts <- Run.liftAff $ Backend.DB.listPosts conn
    pure $ reply posts

logTerminalHandler :: forall r. Log.LogLevel -> Log.Log ~> Run (AFF + EFFECT + r)
logTerminalHandler minLevel = case _ of
  Log.Log level msg next -> do
    -- ログレベルが設定値以上の高さのときのみログに吐く
    when (level >= minLevel) do
      msg' <- mkLogMessage level msg
      Run.liftEffect $ Console.log msg'

    pure next
  where
  mkLogMessage :: Log.LogLevel -> String -> Run _ String
  mkLogMessage level msg = do
    dt <- Run.liftEffect $ Dayjs.now
    pure $
      Fmt.fmt @"[{level} - {dt}] {msg}"
        { dt: Dayjs.format dt
        , level: show level
        , msg
        }
