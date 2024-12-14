module MyBlog.Backend.API.Effect.Log where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Run (Run)
import Run as Run
import Type.Proxy (Proxy(..))
import Type.Row (type (+))

data LogLevel = Debug | Info | Warn | Error

derive instance Eq LogLevel
derive instance Ord LogLevel
derive instance Generic LogLevel _
instance Show LogLevel where
  show = genericShow

data Log a = Log LogLevel String a

derive instance Functor Log

type LOG r = (log :: Log | r)

_log :: Proxy "log"
_log = Proxy

interpret :: forall r a. (Log ~> Run r) -> Run (LOG + r) a -> Run r a
interpret handler = Run.interpret (Run.on _log handler Run.send)

log :: forall r. LogLevel -> String -> Run (LOG + r) Unit
log level msg = Run.lift _log $ Log level msg unit

debug :: forall r. String -> Run (LOG + r) Unit
debug = log Debug

info :: forall r. String -> Run (LOG + r) Unit
info = log Info

warn :: forall r. String -> Run (LOG + r) Unit
warn = log Warn

error :: forall r. String -> Run (LOG + r) Unit
error = log Error