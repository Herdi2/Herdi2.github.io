{-# LANGUAGE OverloadedStrings #-}

import Control.Monad (forM_)
import Data.Aeson
import Data.Maybe (fromJust, fromMaybe)
import Data.Monoid (mappend)
import Debug.Trace (traceM, traceShow)
import Hakyll
import Text.Blaze.Html.Renderer.Pretty (renderHtml)
import Text.Blaze.Html5 ((!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as HA

main :: IO ()
main =
  do
    hakyllWith defaultConfiguration {destinationDirectory = "docs"} $ do
      match "Style.hs" $ do
        route $ setExtension "css"
        compile $ getResourceString >>= withItemBody (unixFilter "runghc" [])

      match "favicon.svg" $ do
        route $ setExtension "ico"
        compile copyFileCompiler

      match "images/*" $ do
        route idRoute
        compile copyFileCompiler

      match "pdfs/*" $ do
        route idRoute
        compile copyFileCompiler

      create ["index.html"] $ do
        route idRoute
        compile $
          makeItem (renderHtml aboutpage)
            >>= relativizeUrls

      create ["projects.html"] $ do
        route idRoute
        compile $
          do
            projects <- parseProjects
            makeItem (renderHtml $ projectpage projects)
              >>= relativizeUrls

      create ["posts.html"] $ do
        route idRoute
        compile $
          do
            posts <- recentFirst =<< loadAll "posts/*"
            postInfo <- traverse postMetadata posts
            makeItem (renderHtml $ postspage postInfo)
              >>= relativizeUrls

      match "posts/*" $ do
        route $ setExtension "html"
        compile $
          do
            ident <- getUnderlying
            title <- getMetadataField' ident "title"
            date <- getMetadataField' ident "date"
            body <- (H.preEscapedToHtml . itemBody) <$> pandocCompiler
            makeItem (renderHtml (postpage title date body))
              >>= relativizeUrls

data Project = Project {pTitle, pDescription, pUrl :: String, pTags :: [String]} deriving (Show)

instance FromJSON Project where
  parseJSON = withObject "Project" $ \v ->
    Project
      <$> v .: "title"
      <*> v .: "description"
      <*> v .: "url"
      <*> v .: "tags"

parseProjects :: Compiler [Project]
parseProjects =
  unsafeCompiler $
    do
      projects <- eitherDecodeFileStrict "projects.json"
      case projects of
        Left err -> error err
        Right p -> pure p

data Post = Post {poTitle, poDate, poUrl :: String}

postMetadata :: Item String -> Compiler Post
postMetadata post =
  do
    let ident = itemIdentifier post
    url <- getRoute ident
    title <- getMetadataField' ident "title"
    date <- getMetadataField' ident "date"
    return $ Post title date (fromJust url)

stylesheet :: H.Html
stylesheet =
  H.link
    ! (HA.rel "stylesheet")
    ! (HA.type_ "text/css")
    ! (HA.href "/Style.css")

navbar :: H.Html
navbar = H.nav ! HA.class_ "sidebar" $
  do
    H.h3 $ H.b "Herdi"
    H.ul $
      mconcat
        ( H.li
            <$> [ mkLink "/" "about",
                  mkLink "/projects.html" "projects",
                  mkLink "/posts.html" "posts"
                ]
        )

header :: String -> H.Html
header title =
  H.head $ do
    H.title (htxt title)
    H.link ! HA.rel "icon" ! HA.type_ "image/svg+xml" ! HA.sizes "512x512" ! HA.href "./images/favicon.svg"
    stylesheet

aboutpage :: H.Html
aboutpage = H.docTypeHtml $ do
  header "about"
  H.body $ do
    navbar
    H.article $ do
      H.h1 "about"
      H.div ! HA.class_ "button-grid" $ do
        iconLink "https://github.com/Herdi2" "GitHub" "./images/github.svg" 24 24
        iconLink "https://linkedin.com/in/herdi-saleh" "LinkedIn" "./images/linkedin.svg" 24 24
        iconLink "./pdfs/Herdi-Saleh-CV.pdf" "CV" "./images/cv.svg" 24 24
      H.div $ do
        H.p $ do
          htxt "Hello! I'm Herdi. This is my little site, where I show off my projects and (hopefully) write a bit."
          htxt "I am a former student at "
          mkLink "https://www.kth.se/" "KTH"
          htxt " where I recently obtained a Master's degree in Computer Science."
          htxt "My thesis was in compiler verification using translation validation, applied to the C2 JVM JIT compiler."
          htxt "Before that I'd interned at Ericsson, working on a fuzzer for their in-house compiler."
        H.p $ do
          htxt "Although my interests span most of what CS has to offer, I've fallen into functional programming!"
          htxt "In fact, "
          mkLink "https://github.com/Herdi2/my-site" "this site"
          htxt " is fully generated using Haskell."
          htxt "I also wrote my thesis tool, "
          mkLink "https://github.com/Herdi2/C2TranslationValidation" "C2tv"
          htxt ", in Haskell."
          htxt "Even Ericsson had me working on a fuzzer written in Haskell!"
          htxt "It seems the monads are after me..."
      H.figure $
        do
          H.img ! HA.src "./images/Haskell_House.jpg" ! HA.width "600" ! HA.height "418"
          H.figcaption $
            do
              H.em "Haskell's House"
              htxt "by Edward Hopper"

projectpage :: [Project] -> H.Html
projectpage projects = H.docTypeHtml $ do
  header "Projects"
  H.body $ do
    navbar
    H.article $ H.div ! HA.class_ "projects-grid" $ mconcat (map projectitem projects)

projectitem :: Project -> H.Html
projectitem project = do
  H.div $ do
    H.h3 $ mkLink (pUrl project) (pTitle project)
    H.p $ htxt (pDescription project)
    H.div $
      mconcat $
        ((H.span ! HA.class_ "project-tag") . htxt) <$> pTags project

postspage :: [Post] -> H.Html
postspage posts = H.docTypeHtml $ do
  header "Posts"
  H.body $ do
    navbar
    H.article $ H.div ! HA.class_ "projects-grid" $ mconcat (map postitem posts)

postitem :: Post -> H.Html
postitem post = do
  H.div $ do
    H.em $ mkLink (poUrl post) (poTitle post)
    htxt "-"
    htxt (poDate post)

postpage :: String -> String -> H.Html -> H.Html
postpage title date bodyHtml = H.docTypeHtml $ do
  header title
  H.body $ H.main $ do
    navbar
    H.article $ do
      H.h1 (htxt title)
      H.p $ H.em $ htxt date
      H.div bodyHtml

iconLink :: String -> String -> String -> Integer -> Integer -> H.Html
iconLink url linkname imgsrc w h =
  H.div $
    do
      H.img ! HA.src (H.toValue imgsrc) ! HA.width (H.toValue w) ! HA.height (H.toValue h)
      mkLink url linkname

mkLink :: String -> String -> H.Html
mkLink url linkName = H.a ! HA.href (H.toValue url) $ (htxt linkName)

htxt :: String -> H.Html
htxt = H.toHtml
