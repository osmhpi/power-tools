{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Main where

import Data.Monoid ((<>))
import Data.Maybe
import Control.Monad
import Control.Monad.Trans
import Data.Aeson (FromJSON, ToJSON, encode, decode)
import qualified Data.Text as T
import qualified Data.Text.Lazy as L
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Lazy.Char8 as Char8
import qualified Data.ByteString.Internal as BS
import GHC.Generics
import Web.Scotty
import Network.HTTP.Types (status200)
import Network.Socket as S

data Target = Target { name :: String, host :: String, port :: String } deriving (Show, Generic)
instance ToJSON Target
instance FromJSON Target

targetsFile :: FilePath
targetsFile = "targets.json"

saveTarget :: Target -> IO ()
saveTarget target = do
  B.appendFile targetsFile $ B.snoc (encode target) (BS.c2w '\n')

loadTargets :: IO Char8.ByteString
loadTargets = do B.readFile targetsFile

decodeTarget :: [Char8.ByteString] -> [Target]
decodeTarget input = catMaybes (map decode input)

getTargets :: ActionM ()
getTargets = do
  content <- liftIO loadTargets
  let entries = Char8.lines content
  json $ decodeTarget entries

addTarget :: ActionM ()
addTarget = do
  name <- param "name" :: ActionM String
  host <- param "host"
  port <- param "port" :: ActionM String
  liftIO $ saveTarget Target { name = name, host = host, port = port }
  status status200

routes :: ScottyM ()
routes = do
  get "/hosts" getTargets
  get "/hosts/add" addTarget

main = do
  putStrLn "Starting Server..."
  scotty 3000 routes
