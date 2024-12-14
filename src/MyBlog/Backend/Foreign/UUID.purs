module MyBlog.Backend.Foreign.UUID where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Fmt as Fmt

newtype UUID = UUID String

derive instance Eq UUID
derive instance Ord UUID

instance Show UUID where
  show (UUID v) = Fmt.fmt @"(UUID {v})" { v }

foreign import genUUID :: Effect UUID

toString :: UUID -> String
toString (UUID v) = v

foreign import validateImpl :: String -> Boolean

fromString :: String -> Maybe UUID
fromString v
  | validateImpl v = Just (UUID v)
  | otherwise = Nothing