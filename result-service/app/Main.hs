{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

module Main where

import Data.Monoid ((<>))
import Data.Aeson (FromJSON, ToJSON)
import GHC.Generics
import Web.Scotty
import Network.HTTP.Types (status200)

data Benchmark = Benchmark { name :: String, start :: String, end :: String } deriving (Show, Generic)
instance ToJSON Benchmark
instance FromJSON Benchmark

benchmarkA :: Benchmark
benchmarkA = Benchmark { name = "Benchmark A", start = "1", end = "2" }
benchmarkB :: Benchmark
benchmarkB = Benchmark { name = "Benchmark B", start = "1", end = "2" }

allBenchmarks :: [Benchmark]
allBenchmarks = [benchmarkA, benchmarkB]

getBenchmarks :: ActionM ()
getBenchmarks = do
  json allBenchmarks

addBenchmark :: ActionM ()
addBenchmark = do
  name <- param "name" :: ActionM String
  start <- param "start" :: ActionM String
  end <- param "end" :: ActionM String
  status status200

routes :: ScottyM ()
routes = do
  get "/benchmarks" getBenchmarks
  get "/benchmarks/add" addBenchmark

main = do
  putStrLn "Starting Server..."
  scotty 3000 routes
