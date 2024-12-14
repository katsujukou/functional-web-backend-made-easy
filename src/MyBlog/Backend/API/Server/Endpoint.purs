module MyBlog.Backend.API.Server.Endpoint where

import Prelude hiding ((/))

import Data.Either (note)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import MyBlog.Backend.Types (PostId, parsePostId, printPostId)
import Routing.Duplex (RouteDuplex', as, prefix, root, segment)
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))

data Endpoint
  = Posts
  | Post PostId

derive instance Eq Endpoint
derive instance Ord Endpoint
derive instance Generic Endpoint _
instance Show Endpoint where
  show = genericShow

endpoint :: RouteDuplex' Endpoint
endpoint = root $ prefix "api" $ sum
  { "Posts": "posts" / noArgs
  , "Post": "posts" / postId segment
  }
  where
  postId = as printPostId (note "Not a valid post id" <<< parsePostId)
