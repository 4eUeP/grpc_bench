{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Control.Concurrent      (getNumCapabilities)
import           Data.ProtoLens          (defMessage)
import           HsGrpc.Server
import           Lens.Micro
import qualified Proto.Helloworld        as P
import qualified Proto.Helloworld_Fields as P

handlers :: [ServiceHandler]
handlers = [unary (GRPC :: GRPC P.Greeter "sayHello") handleSayHello]

handleSayHello :: UnaryHandler P.HelloRequest P.HelloReply
handleSayHello _ req = pure $ defMessage & P.response .~ (req ^. P.request)
{-# INLINE handleSayHello #-}

main :: IO ()
main = do
  n <- getNumCapabilities
  let opts = defaultServerOpts{ serverHost = "0.0.0.0"
                              , serverPort = 50051
                              , serverParallelism = n
                              }
  runServer opts handlers
