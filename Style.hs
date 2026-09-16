{-# LANGUAGE OverloadedStrings #-}

import Clay
import Prelude hiding (rem)

backgroundcolor :: Color
backgroundcolor = "#1A1A1A"

navbarcolor :: Color
navbarcolor = "#101010"

linkcolor :: Color
linkcolor = "#8d84bb"

navbarSize :: Size LengthUnit
navbarSize = vw 10

css :: Css
css =
  do
    body
      ? do
        background backgroundcolor
        color white
        fontFamily ["EB Garamond", "Garamond"] [serif]
        fontSize (px 17)
    "a" ? do
      color linkcolor
    "a" # hover ? do
      color backgroundcolor
      backgroundColor linkcolor

    ".sidebar" ? do
      width navbarSize
      background navbarcolor
      position absolute
      top (px 0)
      bottom (px 0)
      "ul" ? do
        paddingLeft (vw 0)
        listStyle none outside none

    "article" ? do
      marginLeft navbarSize
      padding (rem 2) (rem 4) (rem 4) (rem 4)
      background backgroundcolor

    ".projects-grid" ? do
      display grid
      gridGap (rem 1)

    ".project-tag" ? do
      display inlineBlock
      color inherit
      borderRadius (px 30) (px 30) (px 30) (px 30)
      padding (px 2) (px 8) (px 2) (px 8)
      border (px 1) solid (parse "#888888")
      fontSize (px 13)
      whiteSpace nowrap

    ".button-grid" ? do
      display grid
      gridGap (rem 1)
      width maxContent
      gridTemplateColumns [fr 1, fr 1, fr 1]

main :: IO ()
main = putCss css
