{-# LANGUAGE OverloadedStrings #-}

import Control.Monad (forM_)
import Data.Aeson
import Data.Maybe (fromMaybe)
import Data.Monoid (mappend)
import Debug.Trace (traceM, traceShow)
import Hakyll
import Text.Blaze.Html5 ((!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as HA
import Text.Blaze.Renderer.Pretty

main :: IO ()
main =
  do
    hakyllWith defaultConfiguration {destinationDirectory = "docs"} $ do
      match "style.hs" $ do
        route $ setExtension "css"
        compile $ getResourceString >>= withItemBody (unixFilter "runghc" [])

      match "images/*" $ do
        route idRoute
        compile copyFileCompiler

      match "pdfs/*" $ do
        route idRoute
        compile copyFileCompiler

      create ["index.html"] $ do
        route idRoute
        compile $
          do
            posts <- recentFirst =<< loadAll "posts/*"
            postHtmls <- traverse postToBulletHtml posts
            projectHtmls <- parseProjects
            makeItem (renderMarkup (homeHTML projectHtmls postHtmls)) >>= relativizeUrls

      match "posts/*" $ do
        route $ setExtension "html"
        compile $
          do
            ident <- getUnderlying
            title <- getMetadataField' ident "title"
            date <- getMetadataField' ident "date"
            body <- (H.preEscapedToHtml . itemBody) <$> pandocCompiler
            makeItem (renderMarkup (postHTML title date body)) >>= relativizeUrls

data Project = Project {pTitle, pDescription, pUrl :: String, pTags :: [String]} deriving (Show)

instance FromJSON Project where
  parseJSON = withObject "Project" $ \v ->
    Project
      <$> v .: "title"
      <*> v .: "description"
      <*> v .: "url"
      <*> v .: "tags"

parseProjects :: Compiler H.Html
parseProjects =
  unsafeCompiler $
    do
      projects <- eitherDecodeFileStrict "projects.json"
      case projects of
        Left err -> error err
        Right p ->
          pure $ projectsGrid p

projectCard :: Project -> H.Html
projectCard p =
  H.a ! HA.class_ "project-card" ! HA.href (H.toValue (pUrl p)) $ do
    H.h3 $ htxt (pTitle p)
    H.p $ htxt (pDescription p)

projectsGrid :: [Project] -> H.Html
projectsGrid ps = H.div ! HA.class_ "projects-grid" $ mconcat (map projectCard ps)

postToBulletHtml :: Item String -> Compiler H.Html
postToBulletHtml post = do
  let ident = itemIdentifier post
  mUrl <- getRoute ident
  title <- getMetadataField' ident "title"
  date <- getMetadataField' ident "date"
  let url = maybe "#" toUrl mUrl
  pure $ H.li $ do
    H.a ! HA.href (H.toValue url) $ H.toHtml title
    htxt (" - " <> date)

postHTML :: String -> String -> H.Html -> H.Html
postHTML title date bodyHtml = H.docTypeHtml $ do
  H.head $ do
    H.title (htxt title)
    stylesheet
  H.body $ H.main $ do
    H.h1 (htxt title)
    H.p $ H.em $ htxt date
    H.div bodyHtml

-- Home page
homeHTML :: H.Html -> [H.Html] -> H.Html
homeHTML projects posts = H.docTypeHtml $ do
  H.head $ do
    H.title "Herdi's Home"
    stylesheet
  H.body $
    H.main $
      do
        H.h1 "Herdi Saleh"
        H.p $ do
          H.a ! HA.target "_blank" ! HA.href "https://github.com/Herdi2" $
            H.img ! HA.src "./images/github.svg" ! HA.width "24" ! HA.height "24"
          H.a ! HA.target "_blank" ! HA.href "https://linkedin.com/in/herdi-saleh" $
            H.img ! HA.src "./images/linkedin.svg" ! HA.width "24" ! HA.height "24"
        H.p $ do
          htxt "Hello, I'm Herdi! This is my site, powered by Haskell (woaw)."
          htxt "You may find my CV"
          mkLink "./pdfs/Herdi-Saleh-CV.pdf" "here"
          htxt "."
        H.h3 "Projects"
        projects
        H.h3 "Posts"
        H.ul $ mconcat posts
        H.figure $
          do
            H.img ! HA.src "./images/Haskell_House.jpg" ! HA.width "600" ! HA.height "418"
            H.figcaption $
              do
                H.em "Haskell's House"
                htxt "by Edward Hopper"

stylesheet :: H.Html
stylesheet =
  H.link
    ! (HA.rel "stylesheet")
    ! (HA.type_ "text/css")
    ! (HA.href "/style.css")

mkLink :: H.AttributeValue -> String -> H.Html
mkLink url linkName = H.a ! HA.href url $ (htxt linkName)

htxt :: String -> H.Html
htxt = H.toHtml
