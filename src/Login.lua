---------------------------------------------------------------------------------
-- Tuki Monitor
-- Alberto Vera Espitia
-- GeekBucket 2017
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- OBJETOS Y VARIABLES
---------------------------------------------------------------------------------
-- Includes
local widget = require( "widget" )
local composer = require( "composer" )
local Globals = require( "src.Globals" )
local RestManager = require( "src.RestManager" )

-- Grupos y Contenedores
local screen
local grpFields, grpBottom, grpMsg
local scene = composer.newScene()

-- Variables
local isUp = false
local logoWhite, txtSignUser, txtSignPass

---------------------------------------------------------------------------------
-- EVENTOS
---------------------------------------------------------------------------------

-------------------------------------
-- Reubicar elementos
-- @param event objeto evento
------------------------------------
function onTxtFocus(event)
    if ( "began" == event.phase ) then
        if not(isUp) then
            isUp = true
            transition.to( logoWhite, { y = 230, time = 400, transition = easing.outExpo } )
            transition.to( grpFields, { y = 500, time = 400, transition = easing.outExpo } )
            --transition.to( grpBottom, { y = 150, time = 400, transition = easing.outExpo } )
        end
    elseif ( "submitted" == event.phase ) then
        verifyKey()
    end
    return true
end

-------------------------------------
-- Se manda un email a mesa de control
-- @param event objeto evento
------------------------------------
function sendEmail(event)
    system.openURL( "mailto:enlace@tukicard.com?subject=Solicitud%20de%20acceso%20a%20TUKI%20Metrics" )
    return true
end

-------------------------------------
-- Reubicar a posicion original
-- @param event objeto evento
------------------------------------
function backTxtPositions(event)
    native.setKeyboardFocus(nil)
    if isUp then
        isUp = false
        transition.to( logoWhite, { y = midH - 290, time = 400, transition = easing.outExpo } )
        transition.to( grpFields, { y = midH, time = 400, transition = easing.outExpo } )
        --transition.to( grpBottom, { y = midH, time = 400, transition = easing.outExpo } )
    end
    return true
end


---------------------------------------------------------------------------------
-- FUNCIONES
----------------------------------------------------------------------------------------------------------------------
------------------------------------
-- Nuevo Usuario
-- @param item objeto usuario
------------------------------------
function toHome()
    backTxtPositions()
    composer.removeScene( "src.Home" )
    composer.gotoScene("src.Home", { effect = "fade", time = 500 })
    return true
end

-------------------------------------
-- Verificar clave
-- @param event objeto evento
------------------------------------
function verifyKey(event)
    if not (txtSignUser.text == "") and not (txtSignPass.text == "") then
        if RestManager.networkConnection() then
            RestManager.verifyUser(txtSignUser.text, txtSignPass.text)
        else
            showMsg("Asegurese de estar conectado a internet")
        end
    else
        showMsg("Ingrese el usuario y password")
    end
    return true
    --backTxtPositions()
end

-------------------------------------
-- Muestra loading sprite
-- @param isLoading activar/desactivar
------------------------------------
function showMsg(message)
    
    if grpMsg then
        grpMsg:removeSelf()
        grpMsg = nil
    end

    grpMsg = display.newGroup()
    grpMsg.alpha = 0
    screen:insert(grpMsg)

    function setDes(event)
        return true
    end
    local bg = display.newRect( midW, midH, intW, intH )
    bg:addEventListener( 'tap', setDes)
    bg:setFillColor( 0 )
    bg.alpha = .3
    grpMsg:insert(bg)

    local bg = display.newRoundedRect( midW, logoWhite.y, 404, 154, 15 )
    bg:setFillColor( unpack(cBTur) )
    grpMsg:insert(bg)

    local bg = display.newRoundedRect( midW, logoWhite.y, 400, 150, 15 )
    bg:setFillColor( unpack(cWhite) )
    grpMsg:insert(bg)

    local lblMsg = display.newText({
        text = message, 
        x = midW, y = logoWhite.y, width = 380, 
        fontSize = 27, align = "center",
        font = fontSemiBold
    })
    lblMsg:setFillColor( unpack(cBPur) )
    grpMsg:insert(lblMsg)
    
    transition.to( grpMsg, { alpha = 1, time = 400 } )
    transition.to( grpMsg, { alpha = 0, time = 400, delay = 2000 } )
end


---------------------------------------------------------------------------------
-- DEFAULT METHODS
---------------------------------------------------------------------------------
function scene:create( event )
	screen = self.view
    
    local bgScr = display.newRect( 0, h, intW, intH )
    bgScr:setFillColor( {
        type = 'gradient',
        color1 = { unpack(cBgMorA) }, 
        color2 = { unpack(cBgMorB) },
        direction = "bottom"
    } ) 
    bgScr.alpha = .8
    bgScr.anchorY=0
    bgScr.anchorX=0
    bgScr:addEventListener( "tap", backTxtPositions )
    screen:insert(bgScr)
    
    logoWhite = display.newImage("img/logoWhite.png")
    logoWhite:translate( midW, midH - 290 )
    screen:insert( logoWhite )
    
    grpFields = display.newGroup()
    grpFields.y = midH
    screen:insert( grpFields )
    
    local bgUsuario = display.newImage("img/usuario.png")
    bgUsuario:translate( midW, -50 )
    grpFields:insert( bgUsuario )
    
    local bgContrasenia = display.newImage("img/contrasenia.png")
    bgContrasenia:translate( midW, 50 )
    grpFields:insert( bgContrasenia )
    
    -- TextFields Sign In
    txtSignUser = native.newTextField( midW + 20, -50, 400, 45 )
    txtSignUser.size = 25
    txtSignUser.hasBackground = false
    txtSignUser.placeholder = "USUARIO / EMAIL"
    txtSignUser:addEventListener( "userInput", onTxtFocus )
	grpFields:insert(txtSignUser)
    
    -- TextFields Sign In
    txtSignPass = native.newTextField( midW + 20, 50, 400, 45 )
    txtSignPass.size = 25
    txtSignPass.isSecure = true
    txtSignPass.hasBackground = false
    txtSignPass.placeholder = "CLAVE DE ACCESO"
    txtSignPass:addEventListener( "userInput", onTxtFocus )
	grpFields:insert(txtSignPass)
    
    local bgBtn = display.newRoundedRect( midW, 170, 500, 75, 15 )
    bgBtn:setFillColor( unpack(cBTur) ) 
    bgBtn:addEventListener( 'tap', verifyKey)
    grpFields:insert(bgBtn)
    
    local txtBtn = display.newText({
        text = 'INGRESAR',
        x = midW, y = 170, width = 400,
        font = fontBold,   
        fontSize = 32, align = "center"
    })
    txtBtn:setFillColor( unpack(cWhite) )
    grpFields:insert(txtBtn)
    
    
    grpBottom = display.newGroup()
    grpBottom.y = midH
    screen:insert( grpBottom )
    
    local bgBottom = display.newRect( midW, midH - 50, 500, 75 )
    bgBottom.alpha = .01
    bgBottom:addEventListener( 'tap', sendEmail)
    grpBottom:insert(bgBottom)
    
    local txtBottom1 = display.newText({
        text = '¿No cuenta con usuario y password?',
        x = midW - 50, y = midH - 65, width = 420,
        font = fontBold,   
        fontSize = 22, align = "center"
    })
    txtBottom1:setFillColor( unpack(cWhite) )
    grpBottom:insert(txtBottom1)
    
    local txtBottom2 = display.newText({
        text = 'Solicitelo a nuestra Mesa de Control',
        x = midW - 50, y = midH - 35, width = 420,
        font = fontBold,   
        fontSize = 23, align = "center"
    })
    txtBottom2:setFillColor( unpack(cBTur) )
    grpBottom:insert(txtBottom2)
    
    local iconEmail = display.newImage("img/iconEmail.png")
    iconEmail:translate( midW + 200, midH - 50 )
    grpBottom:insert( iconEmail )
    
end	

-- Called immediately after scene has moved onscreen:
function scene:show( event )
    if event.phase == "will" then
    end
end

-- Remove Listener
function scene:hide( event )
    if ( event.phase == "will" ) then
        if txtSignUser then
            txtSignUser:removeSelf()
            txtSignUser = nil
        end
        if txtSignPass then
            txtSignPass:removeSelf()
            txtSignPass = nil
        end
    end
end

-- Remove Listener
function scene:destroy( event )
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


return scene