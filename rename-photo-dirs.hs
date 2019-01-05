#!/usr/bin/env stack
-- stack --install-ghc runghc --package turtle

{-# LANGUAGE TupleSections #-}
{-# LANGUAGE OverloadedStrings #-}

import Data.Text (pack, unpack)
import Data.Time.Clock
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
  dir <- ls fp
  True <- testdir dir
  liftIO . putStr $ "Processing " ++ show dir ++ ": "
  (f, t) <- earliestFileDate dir
  if f /= ""
    then liftIO . putStrLn . (++ " (" ++ show f ++ ")") . unpack $ prettyDay t
    else liftIO . putStrLn $ "No files"

earliestFileDate :: T.FilePath -> Shell (T.FilePath, UTCTime)
earliestFileDate f = foldIO (ls f) $ FoldM earlier (fmap ("",) date) pure
  where earlier x@(f', t) f'' = do
          isFile <- testfile f''
          newTime <- datefile f''
          if isFile && newTime < t
            then return (f'', newTime)
            else return x

prettyDay :: UTCTime -> Text
prettyDay = pack . show . utctDay

whoopsie :: Fail -> IO ()
whoopsie NoArgs = putStrLn "Expecting album dir as argument"
