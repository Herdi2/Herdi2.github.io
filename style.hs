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
      border (px 1) solid white
      padding (px 2) (px 2) (px 2) (px 2)

main :: IO ()
main = putCss css
