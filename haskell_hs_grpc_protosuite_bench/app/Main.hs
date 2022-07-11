{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}

module Main where

import           Control.Concurrent (getNumCapabilities)
import           HsGrpc.Server

import           Helloworld
import qualified Proto.Helloworld   as P

handlers :: [ServiceHandler]
handlers = [unary (GRPC :: GRPC P.Greeter "sayHello") handleSayHello]

handleSayHello :: UnaryHandler HelloRequest HelloReply
handleSayHello _ HelloRequest{..} = pure $ HelloReply helloRequestRequest
{-# INLINE handleSayHello #-}

main :: IO ()
main = do
  n <- getNumCapabilities
  let opts = defaultServerOpts{ serverHost = "0.0.0.0"
                              , serverPort = 50051
                              , serverParallelism = n
                              }
  runServer opts handlers
