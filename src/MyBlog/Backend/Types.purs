module MyBlog.Backend.Types
  ( PostId
  , PostInfo
  , genPostId
  , parsePostId
  , postId
  , postInfo
  , printPostId
  ) where

import Prelude

import Data.Codec.Argonaut as CA
import Data.Codec.Argonaut.Record as CAR
import Data.Maybe (Maybe)
import Effect (Effect)
import Fmt as Fmt
import MyBlog.Backend.Foreign.UUID (UUID(..))
import MyBlog.Backend.Foreign.UUID as UUID
import Safe.Coerce (coerce)

newtype PostId = PostId UUID

derive newtype instance Eq PostId
derive newtype instance Ord PostId
instance Show PostId where
  show (PostId pid) = Fmt.fmt @"(PostId {pid})" { pid: UUID.toString pid }

postId :: CA.JsonCodec PostId
postId = CA.prismaticCodec "PostId" parsePostId printPostId CA.string

genPostId :: Effect PostId
genPostId = PostId <$> UUID.genUUID

parsePostId :: String -> Maybe PostId
parsePostId = UUID.fromString >>> coerce

printPostId :: PostId -> String
printPostId = coerce >>> UUID.toString

type PostInfo =
  { id :: PostId
  , title :: String
  , body :: String
  }

postInfo :: CA.JsonCodec PostInfo
postInfo = CA.object "PostInfo" $
  CAR.record
    { id: postId
    , title: CA.string
    , body: CA.string
    }