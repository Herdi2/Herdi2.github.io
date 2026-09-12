--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import Clay
import Control.Monad (forM_)
import Data.Monoid (mappend)
import Data.Text.Lazy
import Hakyll
import qualified Text.Blaze.Html5 as H
import Text.Blaze.Renderer.Pretty

main :: IO ()
main =
  do
    writeFile "style.css" (unpack $ render css)
    hakyllWith defaultConfiguration {destinationDirectory = "docs"} $ do
      match "style.css" $ do
        route idRoute
        compile compressCssCompiler

      create ["index.html"] $ do
        route idRoute
        compile $ makeItem (renderMarkup home :: String)

home :: H.Html
home = H.docTypeHtml $ do
  H.head $ do
    H.title "Herdi"
  H.body $ do
    H.h1 "Herdi Saleh"
    H.p "This is a site"
    H.p "more text"

css :: Css
css =
  do
    background (parse "#1A1A1A")
