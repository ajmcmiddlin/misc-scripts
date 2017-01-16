#!/usr/bin/env stack
-- stack --install-ghc runghc --package turtle

{-# LANGUAGE OverloadedStrings #-}

import Turtle as T

data Fail = NoArgs

main = do
  args <- arguments
  case args of
    (x:_) -> doIt . fromText $ x
    _     -> whoopsie NoArgs

doIt :: T.FilePath -> IO ()
doIt fp = do
  dirs <- join $ fold (ls fp) filterDirs
  sequence $ fmap (putStrLn . show) dirs
  return ()

filterDirs :: Fold T.FilePath (IO [T.FilePath])
filterDirs = Fold addIfDir (return []) id
  where addIfDir dirs fp = do
          isDir <- testdir fp
          if isDir then fmap (fp :) dirs else dirs

whoopsie :: Fail -> IO ()
whoopsie NoArgs = putStrLn "Expecting album dir as argument"
