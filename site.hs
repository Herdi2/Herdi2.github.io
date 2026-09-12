{-# LANGUAGE OverloadedStrings #-}

import Control.Monad (forM_)
import Data.Monoid (mappend)
import Data.Text.Lazy
import Hakyll
import Text.Blaze.Html5 ((!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as HA
import Text.Blaze.Renderer.Pretty

main :: IO ()
main =
  do
    hakyllWith defaultConfiguration {destinationDirectory = "docs"} $ do
      match "style.css" $ do
        route idRoute
        compile compressCssCompiler

      create ["index.html"] $ do
        route idRoute
        compile $ makeItem (renderMarkup home :: String)

      match "style.hs" $ do
        route $ setExtension "css"
        compile $ getResourceString >>= withItemBody (unixFilter "runghc" [])

      match "Home.md" $ do
        route $ setExtension "html"
        compile $
          pandocCompiler
            >>= applyTemplate
              (renderMarkup home)
              defaultContext
            >>= relativizeUrls

-- Home page
home :: H.Html
home = H.docTypeHtml $ do
  H.head $ do
    H.title "$title$"
    H.link
      ! (HA.rel "stylesheet")
      ! (HA.type_ "text/css")
      ! (HA.href "style.css")
  H.body $ H.main $ "$body$"
