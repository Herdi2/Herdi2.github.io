{-# LANGUAGE OverloadedStrings #-}

import Clay

css :: Css
css =
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

main :: IO ()
main = putCss css
