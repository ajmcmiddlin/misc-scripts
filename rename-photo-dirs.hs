#!/usr/bin/env stack
-- stack --install-ghc runghc --package turtle

{-# LANGUAGE OverloadedStrings #-}

import Turtle

main = doIt

doIt :: IO ()
doIt = do
  dirs <- join $ fold (ls "..") filterDirs
  sequence $ fmap (putStrLn . show) dirs
  return ()

filterDirs :: Fold Turtle.FilePath (IO [Turtle.FilePath])
filterDirs = Fold addIfDir (return []) id
  where addIfDir dirs fp = do
          isDir <- testdir fp
          if isDir then fmap (fp :) dirs else dirs
