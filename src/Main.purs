module Main where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class.Console as Console
import Foreign.Object as Object
import MyBlog.Backend.API as API
import MyBlog.Backend.API.Effect.Log (LogLevel(..))
import MyBlog.Backend.Foreign.Pg as Pg
import Node.EventEmitter (on_)
import Node.Process as Process

main :: Effect Unit
main = do
  { logLevel, pool } <- setup
  closeCb <- API.start pool logLevel

  Process.process # on_ Process.beforeExitH \_ -> do
    closeCb do
      launchAff_ $ Pg.end pool

  where
  setup = do
    env <- Process.getEnv
    databaseUrl <- case Object.lookup "DATABASE_URL" env of
      Nothing -> Console.error "You must set DATABASE_URL environemt variable."
        *> Process.exit
      Just databaseUrl -> pure databaseUrl

    pool <- Pg.createPool { connectionString: databaseUrl }

    let
      logLevel = case Object.lookup "LOG_LEVEL" env of
        Just "Error" -> Error
        Just "Warn" -> Warn
        Just "Info" -> Info
        _ -> Debug

    pure { logLevel, pool }
