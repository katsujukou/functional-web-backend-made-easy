module MyBlog.Backend.Foreign.Pg
  ( Pool
  , PoolClient
  , PoolOptions
  , SQLValue
  , class ToSQLValue
  , connect
  , createPool
  , end
  , query
  , release
  , sqlNull
  , toSQLValue
  , withConnection
  ) where

import Prelude

import Control.Monad.Except (runExcept)
import Data.Either (either, hush)
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Effect.Uncurried (EffectFn1, EffectFn3, runEffectFn1, runEffectFn3)
import Foreign (Foreign)
import Foreign as F
import Foreign.Object (Object)
import Foreign.Object as Object
import Promise (Promise)
import Promise.Aff (toAffE)
import Unsafe.Coerce (unsafeCoerce)

foreign import data Pool :: Type

type PoolOptions =
  { connectionString :: String
  }

foreign import createPool :: PoolOptions -> Effect Pool

foreign import data PoolClient :: Type

foreign import connectImpl :: EffectFn1 Pool (Promise PoolClient)

connect :: Pool -> Aff PoolClient
connect = toAffE <<< runEffectFn1 connectImpl

foreign import endImpl :: EffectFn1 Pool (Promise Unit)

end :: Pool -> Aff Unit
end = runEffectFn1 endImpl >>> toAffE

foreign import releaseImpl :: EffectFn1 PoolClient Unit

release :: PoolClient -> Effect Unit
release = runEffectFn1 releaseImpl

withConnection :: forall a. Pool -> (PoolClient -> Aff a) -> Aff a
withConnection pool m = do
  conn <- liftAff $ connect pool
  res <- Aff.attempt (m conn) <* liftEffect (release conn)
  res # either Aff.throwError pure

foreign import data SQLValue :: Type

class ToSQLValue a where
  toSQLValue :: a -> SQLValue

unsafeSQLValue :: forall a. a -> SQLValue
unsafeSQLValue = unsafeCoerce

instance ToSQLValue String where
  toSQLValue = unsafeSQLValue

instance ToSQLValue Char where
  toSQLValue = unsafeSQLValue

instance ToSQLValue Int where
  toSQLValue = unsafeSQLValue

instance ToSQLValue Number where
  toSQLValue = unsafeSQLValue

instance ToSQLValue Boolean where
  toSQLValue = unsafeSQLValue

foreign import sqlNull :: SQLValue

instance ToSQLValue a => ToSQLValue (Maybe a) where
  toSQLValue = case _ of
    Nothing -> sqlNull
    Just a -> toSQLValue a

type QueryResult =
  { rows :: Array Foreign
  , command :: String
  , rowCount :: Maybe Int
  }

foreign import queryImpl
  :: EffectFn3
       PoolClient
       String
       (Array SQLValue)
       (Promise (Object Foreign))

query :: PoolClient -> String -> Array SQLValue -> Aff QueryResult
query conn sql values = do
  res <- toAffE $ runEffectFn3 queryImpl conn sql values

  let
    rows = Object.lookup "rows" res # maybe [] readForeignArray
    rowCount = Object.lookup "rowCount" res >>= readInt
    command = Object.lookup "command" res >>= readString # fromMaybe ""

  pure { rows, rowCount, command }

  where
  readInt :: Foreign -> Maybe Int
  readInt = F.readInt >>> runExcept >>> hush

  readString :: Foreign -> Maybe String
  readString = F.readString >>> runExcept >>> hush

  readForeignArray :: Foreign -> Array Foreign
  readForeignArray = F.readArray >>> runExcept >>> either (const []) identity