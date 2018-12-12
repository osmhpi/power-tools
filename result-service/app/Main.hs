{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Main where

import Data.Monoid ((<>))
import Data.Maybe
import Control.Monad
import Control.Monad.Trans
import Data.Aeson (FromJSON, ToJSON, encode, decode)
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Lazy.Char8 as Char8
import qualified Data.ByteString.Internal as BS
import GHC.Generics
import Web.Scotty
import Network.HTTP.Types (status200)

data Benchmark = Benchmark { name :: String, start :: String, end :: String } deriving (Show, Generic)
instance ToJSON Benchmark
instance FromJSON Benchmark

benchmarksFile :: FilePath
benchmarksFile = "benchmarks.log"

saveBenchmark :: Benchmark -> IO ()
saveBenchmark benchmark = do
  B.appendFile benchmarksFile $ B.snoc (encode benchmark) (BS.c2w '\n')

loadBenchmarks :: IO Char8.ByteString
loadBenchmarks = do B.readFile benchmarksFile

decodeBenchmark :: [Char8.ByteString] -> [Benchmark]
decodeBenchmark input = catMaybes (map decode input)

getBenchmarks :: ActionM ()
getBenchmarks = do
  content <- liftIO loadBenchmarks
  let entries = Char8.lines content
  json $ decodeBenchmark entries

addBenchmark :: ActionM ()
addBenchmark = do
  name <- param "name" :: ActionM String
  start <- param "start" :: ActionM String
  end <- param "end" :: ActionM String
  liftIO $ saveBenchmark Benchmark { name = name, start = start, end = end }
  status status200

routes :: ScottyM ()
routes = do
  get "/benchmarks" getBenchmarks
  get "/benchmarks/add" addBenchmark

main = do
  putStrLn "Starting Server..."
  scotty 3000 routes
