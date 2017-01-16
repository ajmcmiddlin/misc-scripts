#!/usr/bin/env stack
-- stack --install-ghc runghc --package turtle

{-# LANGUAGE OverloadedStrings #-}

import           Turtle                 as T

data Fail = NoArgs

main :: IO ()
main = sh $ do
  args <- liftIO arguments
  case args of
    (x:_) -> doIt . fromText $ x
    _     -> liftIO $ whoopsie NoArgs

doIt :: T.FilePath -> Shell ()
doIt fp = do
  path <- ls fp
  True <- testdir path
  (liftIO . putStrLn . show) path
  pure ()

whoopsie :: Fail -> IO ()
whoopsie NoArgs = putStrLn "Expecting album dir as argument"
