{-# LANGUAGE OverloadedStrings #-}

import Clay

css :: Css
css =
  do
    body
      ? do
        background (parse "#1A1A1A")
        color white
        display flex
        lineHeight (unitless 1.4)
        maxWidth (px 600)
        margin (px 30) auto (px 30) auto
        fontFamily ["EB Garamond", "Garamond"] [serif]
        fontSize (px 17)
    ".projects-grid" ? do
      display grid
      gridGap (px 16)
    ".project-card" ? do
      display block
      textDecoration none
      color inherit
      border (px 1) solid white
      borderRadius (px 30) (px 30) (px 30) (px 30)
      paddingTop (px 2)
      paddingBottom (px 2)
      paddingLeft (px 8)
      paddingRight (px 8)
      transition "all" (sec 0.1) ease (sec 0)
    ".project-card" # hover ? do
      background (parse "#2A2A2A")
      borderColor (parse "#888888")
      transform (translateY (px (-2)))
    ".project-tags" ? do
      paddingBottom (px 8)
      paddingLeft (px 8)
    ".project-card-tag" ? do
      display inlineBlock
      color inherit
      borderRadius (px 30) (px 30) (px 30) (px 30)
      padding (px 2) (px 8) (px 2) (px 8)
      border (px 1) solid (parse "#888888")
      fontSize (px 13)
      whiteSpace nowrap

main :: IO ()
main = putCss css
