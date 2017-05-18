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
local scene = composer.newScene()


-- Variables
local bullets = {}

---------------------------------------------------------------------------------
-- EVENTOS
---------------------------------------------------------------------------------

-------------------------------------
-- Drag time line
-- @param event objeto evento
------------------------------------
function dragLine( event )
    local t = event.target
    if event.phase == "began" then
        -- Init variables
        t.isFocus = true
        t.xStart = t.x
        t.eStart = event.x
    elseif t.isFocus then
        if event.phase == "moved" then
            -- Then drag
            local newX = (t.xStart - (t.eStart - event.x))
            if newX < t.limX1 then
                t.x = t.limX1
            elseif newX > t.limX2 then
                t.x = t.limX2
            else
                t.x = newX
            end
        elseif event.phase == "ended" or event.phase == "cancelled" then
            -- We end the movement by removing the focus from the object
            t.isFocus = false
        end

    end
end

---------------------------------------------------------------------------------
-- FUNCIONES
---------------------------------------------------------------------------------

-------------------------------------
-- Crea grafica de resultados
-- @param data datos para el chart
-- @param size tamaño del chart 
------------------------------------
function doGraph(info, data, size)
    
    -- General Variables
    local wC = 640
    local hC = 400
    local initX = 10
    local initY = 0
    info.day = tonumber(info.day)
    info.goal = tonumber(info.goal)
    info.total = tonumber(info.total)
    info.lastDay = tonumber(info.lastDay)
    
    local porcDays = info.day / info.lastDay
    local todayGoal = math.floor(info.goal * porcDays)
    local maxPoints = todayGoal
    if todayGoal < info.total then maxPoints = info.total end
    
    -- Parametros para Escalar 
    if size == 'medium' then
        wC = 320
        hC = 200
    end
    -- Create container
    local graph = display.newContainer( wC+60, hC )
    local bg = display.newRect( 0, 0, wC+60, hC )
    bg:setFillColor( .97 )
    graph:insert( bg )
    
     -- Array dots
    local jumpW = wC / (#data)
    local jumpH = hC / maxPoints
    local dots = {initX, initY}
    local dotsY = {initY}
    local newY = initY
    for z = 1, #data, 1 do 
        newY = newY - (data[z].total*jumpH)
        table.insert( dots, (initX + ( jumpW * z ) ) )
        table.insert( dots, newY )
        table.insert( dotsY, newY )
    end
    -- End Shape
    local endX = dots[#dots-1]
    local endY = dots[#dots]
    table.insert( dots, endX + 20)
    table.insert( dots, endY)
    table.insert( dots, endX + 20)
    table.insert( dots, initY+20)
    table.insert( dots, initX-20)
    table.insert( dots, initY+20)
    table.insert( dots, initX-20)
    table.insert( dots, initY)
    
    -- Make polygon
    local chPol = (hC-(info.total*jumpH))/2
    local polygon = display.newPolygon(0, chPol+10, dots)
    polygon:setFillColor( unpack(cBPurA)  )
    polygon:setStrokeColor( unpack(cBPurL) )
    polygon.strokeWidth = 6
    graph:insert( polygon )
    -- Ajustar graph
    graph.width = polygon.width - 40
    local mwG = graph.width/2
    local mhG = hC/2
    
    -- Make goal
    local fixH = 0
    local hGoal =  mhG - (todayGoal*jumpH)
    if maxPoints > todayGoal then 
        fixH = (hC - (todayGoal*jumpH))/26
    end
    
    local dimens = { (mwG*(-1))/40, (mhG)/40, (mwG)/40, (hGoal)/40 }
    local xdot = (mwG / 15)
    local ydot = (mhG / 15)
    for z = 1, 30, 1 do 
        local minDot = display.newLine( unpack(dimens) )            
        minDot:setStrokeColor( unpack(cBTur) )
        minDot.alpha = .7
        minDot.strokeWidth = 4
        minDot.x = (xdot*(z-1)) - mwG 
        minDot.y = mhG - (ydot*(z-1)) + (fixH*(z-1))
        --minDot.y = (minDot.y + fixH) - minDot.y 
        graph:insert( minDot )
    end 
    polygon:toFront()
    
    -- Make blocks
    graph.width = graph.width + 20
    graph.height = graph.height + 20
    local block1 = display.newRect( (mwG*-1)-10, 0, 20, hC + 20 )
    graph:insert( block1 )
    local block2 = display.newRect( mwG+10, 0, 20, hC + 20 )
    graph:insert( block2 )
    local block3 = display.newRect( 0, (mhG*-1)-10, wC + 20, 20 )
    graph:insert( block3 )
    local block4 = display.newRect( 0, mhG+10, wC + 20, 20 )
    graph:insert( block4 )
    
    -- Make mark
    local sizeMark = 15
    if size == 'medium' then sizeMark = 12 end
    local markC = display.newContainer( sizeMark, hC + 20  )
    markC.x = mwG
    markC.limX1 = mwG * -1
    markC.limX2 = mwG
    graph:insert( markC )
    local bgM = display.newRect( 0, 0, sizeMark, hC )
    bgM.alpha = .01
    markC:insert( bgM )
    local line = display.newRect( 0, 0, 3, hC )
    line:setFillColor( .6 )
    markC:insert( line )
    local mark = display.newCircle(  0, mhG-(info.total*jumpH), sizeMark/2 )
    mark:setFillColor( unpack(cBPur) )
    markC:insert(mark)
    
    -- Listener Touch
    graph:addEventListener( "touch", dragLine )
    
    
    --[[
    
    
    
    
    ]]
    return graph
end

-------------------------------------
-- Crea ficha de resultados
-- @param ScrollView por llenar
------------------------------------
function showResults(data)
    
    grpGraph = display.newGroup()
    screen:insert( grpGraph )
    
    local posY = 180
    
    -- Afiliaciones
    local txtTitleA = display.newText({
        text = data.newUser.total,
        x = midW - 200, y = posY + 60, width = 400,
        font = fontRegular,   
        fontSize = 120, align = "right"
    })
    txtTitleA:setFillColor( unpack(cBlack) )
    grpGraph:insert(txtTitleA)
    
    local txtSubTitleA = display.newText({
        text = 'afiliados',
        x = midW + 210, y = posY + 78, width = 400,
        font = fontRegular,   
        fontSize = 70, align = "left"
    })
    txtSubTitleA:setFillColor( unpack(cBlack) )
    grpGraph:insert(txtSubTitleA)
    
    local txtDateA = display.newText({
        text = data.newUserD[#data.newUserD].dateAction,
        x = midW, y = posY + 150, width = 400,
        font = fontRegular,   
        fontSize = 28, align = "center"
    })
    txtDateA:setFillColor( unpack(cBlack) )
    grpGraph:insert(txtDateA)
    
    local graph = doGraph(data.newUser, data.newUserD, 'large')
    graph:translate(midW,  posY + 380)
    grpGraph:insert(graph)
    
    posY = posY + 700 
    
    -- Visitas
    local txtTitleV = display.newText({
        text = data.points.total,
        x = midWL, y = posY, width = 400,
        font = fontRegular,   
        fontSize = 80, align = "center"
    })
    txtTitleV:setFillColor( unpack(cBlack) )
    grpGraph:insert(txtTitleV)
    
    local txtSubTitleV = display.newText({
        text = 'puntos otorgados',
        x = midWL, y = posY + 55, width = 400,
        font = fontRegular,   
        fontSize = 32, align = "center"
    })
    txtSubTitleV:setFillColor( unpack(cBlack) )
    grpGraph:insert(txtSubTitleV)
    
    local txtDateV = display.newText({
        text = data.pointsD[#data.pointsD].dateAction,
        x = midWL, y = posY + 100, width = 400,
        font = fontRegular,   
        fontSize = 24, align = "center"
    })
    txtDateV:setFillColor( unpack(cBlack) )
    grpGraph:insert(txtDateV)
    
    local graph = doGraph(data.points, data.pointsD, 'medium')
    graph:translate(midWL,  posY + 230)
    grpGraph:insert(graph)
    
    
    -- Redenciones
    local txtTitleR = display.newText({
        text = data.redem.total,
        x = midWR, y = posY, width = 400,
        font = fontRegular,   
        fontSize = 80, align = "center"
    })
    txtTitleR:setFillColor( unpack(cBlack) )
    grpGraph:insert(txtTitleR)
    
    local txtSubTitleR = display.newText({
        text = 'redenciones',
        x = midWR, y = posY + 55, width = 400,
        font = fontRegular,   
        fontSize = 32, align = "center"
    })
    txtSubTitleR:setFillColor( unpack(cBlack) )
    grpGraph:insert(txtSubTitleR)
    
    local txtDateR = display.newText({
        text = data.redemD[#data.redemD].dateAction,
        x = midWR, y = posY + 100, width = 400,
        font = fontRegular,   
        fontSize = 24, align = "center"
    })
    txtDateR:setFillColor( unpack(cBlack) )
    grpGraph:insert(txtDateR)
    
    local graph = doGraph(data.redem, data.redemD, 'medium')
    graph:translate(midWR,  posY + 230)
    grpGraph:insert(graph)
    
    
end


---------------------------------------------------------------------------------
-- DEFAULT METHODS
---------------------------------------------------------------------------------
function scene:create( event )
	screen = self.view
    
    local txtTitle = display.newText({
        text = 'Tuki Monitor',
        x = midW, y = h + 30, width = 300,
        font = fontSemiBold,   
        fontSize = 28, align = "center"
    })
    txtTitle:setFillColor( unpack(cBPur) )
    screen:insert(txtTitle)
    
    local line = display.newRect( midW, h+80, 700, 1 )
    line:setFillColor( .9 )
    screen:insert( line )
    
    local lineSel = display.newRect( midW+40, h+80, 70, 1 )
    lineSel:setFillColor( unpack(cBPur) )
    screen:insert( lineSel )
    
    -- Crear opciones
    local opts = {'Todo', '3M', '1M', '1S'}
    local txtOpts = {}
    for z = 1, #opts, 1 do 
        txtOpts[z] = display.newText({
            text = opts[z],
            x = (midW - 200) + (z*80), y = h + 100, width = 300,
            font = fontSemiBold,   
            fontSize = 20, align = "center"
        })
        txtOpts[z]:setFillColor( unpack(cGray) )
        screen:insert(txtOpts[z])
    end
    txtOpts[3]:setFillColor( unpack(cBlack) )
    
    -- Obtenemos informacion
    RestManager.getData()
    
end	

-- Called immediately after scene has moved onscreen:
function scene:show( event )
    if event.phase == "will" then
    end
end

-- Remove Listener
function scene:hide( event )
    Runtime:removeEventListener( "location", getGPS )
end

-- Remove Listener
function scene:destroy( event )
    Runtime:removeEventListener( "location", getGPS )
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )


return scene