---------------------------------------------------------------------------------
-- Tuki Monitor
-- Alberto Vera Espitia
-- GeekBucket 2017
---------------------------------------------------------------------------------

-- Mediciones de pantalla
intW = display.contentWidth
intH = display.contentHeight
midW = display.contentCenterX
midH = display.contentCenterY
midWL = midW / 2
midWR = midW + midWL
h = display.topStatusBarContentHeight

-- Colors
cWhite = { 1 }
cBlack = { .2 }
cGray = { .5 }
cGray = { .75 }
cBTur = { 0, .67, .92 }
cBBlu = { .19, 0, .29 }
cBPur = { .26, .05, .38 }
cBPurL = { .66, .47, .92, .5 }
cBPurA = { .78, .66, 1, .3 }
cBgMorA = { .27, 0, .4 }
cBgMorB = { .39, 0, .59 }

-- Fonts
fontLight = 'Muli-Light'
fontRegular = 'Muli-Regular'
fontSemiBold = 'Muli-SemiBold'
fontBold = 'Muli-ExtraBold'

-- Otras
valT = 0
valD = {}
idUser = 0