module MyBlog.Backend.API.Server.Utils where

import Prelude

import Control.Monad.Cont (ContT)
import Effect.Exception as Exn
import HTTPurple as HTTPurple
import Run (Run)
import Run.Except (EXCEPT)
import Run.Except as Except
import Type.Row (type (+))

type ServerHandler r a = ContT HTTPurple.Response (Run r) a

type ErrorType = Exn.Error

raise :: forall r a. String -> Run (EXCEPT ErrorType + r) a
raise = Except.throw <<< Exn.error
