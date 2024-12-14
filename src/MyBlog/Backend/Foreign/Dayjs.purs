module MyBlog.Backend.Foreign.Dayjs where

import Effect (Effect)

foreign import data Dayjs :: Type

foreign import now :: Effect Dayjs

foreign import format :: Dayjs -> String