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
function doGraph(goal, total, data, size)
    
    -- Variables of size
    local wC = 700
    local hC = 400
    local redW = 1
    local redH = math.floor(total/200)
    
    -- Reducir escala vertical
    if total < 25 then redH = .0625
    elseif total < 50 then redH = .125
    elseif total < 100 then redH = .25
    elseif total < 200 then redH = .5 end
    
    if size == 'medium' then
        wC = 320
        hC = 200
        redW = 2
        redH = redH * 2
    end
    
    -- Variables build
    local iniV = data[1].total
    local endV = data[#data].total
    local jumpPix = math.floor(wC / #data)
    local initX = (math.floor( wC / 2 )) * -1
    local initY = (hC/2)
    
    -- Create container
    local graph = display.newContainer( wC, hC )
    local bg = display.newRect( 0, 0, wC, hC )
    bg:setFillColor( .97 )
    graph:insert( bg )
    
    -- Array dots
    local noD = 0
    local dots = {initX, initY}
    local dotsY = {initY}
    local newY = initY
    for z = 1, #data, 1 do 
        newY = newY - (data[z].total/redH)
        table.insert( dots, (initX + ( jumpPix * z ) ) )
        table.insert( dots, newY )
        table.insert( dotsY, newY )
    end    
    
    for z = 1, #dotsY, 1 do 
    end
    
    
    -- End Shape
    initX = dots[1]
    initY = dots[2]
    endX = dots[#dots-1]
    endY = dots[#dots]
    table.insert( dots, endX + 20)
    table.insert( dots, endY)
    table.insert( dots, endX + 20)
    table.insert( dots, initY + 500)
    table.insert( dots, initX - 20)
    table.insert( dots, initY + 500)
    table.insert( dots, initX - 20)
    table.insert( dots, initY)
    
    -- Make goal
    if tonumber(goal) <= tonumber(total)  then
        local goalY = initY - (goal/redH)
        local goalL = display.newLine( initX, goalY, initX+wC, goalY )
        goalL:setStrokeColor( 1, 0, 0, 1 )
        goalL.strokeWidth = 2
        goalL.alpha = .3
        graph:insert( goalL )
    end
    
    -- Make polygon
    local nendY = endY
    if nendY < 0 then nendY = nendY * -1 end
    local midY = (hC - (initY + nendY)) / 2
    local polygon = display.newPolygon(0, 250 + midY, dots)
    polygon:setFillColor( unpack(cBPurA)  )
    polygon:setStrokeColor( unpack(cBPurL) )
    polygon.strokeWidth = 6
    graph:insert( polygon )
    
    -- Ajust Graph
    local strech = ( wC / 2 ) - endX
    bg.width = bg.width - strech
    graph.width = graph.width - strech + 30
    graph.height = graph.height + 30
    
    -- Make blocks
    local graphM = bg.width/2
    local block1 = display.newRect( (graphM+10)*-1, 0, 20, hC + 30 )
    graph:insert( block1 )
    local block2 = display.newRect( (graphM+10), 0, 20, hC + 30 )
    graph:insert( block2 )
    local block3 = display.newRect( 0, (hC/2)+10, wC + 30, 20 )
    graph:insert( block3 )
    
    -- Make mark
    local sizeMark = 22
    if size == 'medium' then sizeMark = 15 end
    local markC = display.newContainer( sizeMark, hC + 30 )
    markC.x = graphM
    markC.limX1 = graphM * -1
    markC.limX2 = graphM
    graph:insert( markC )
    markC:addEventListener( "touch", dragLine )
    local bgM = display.newRect( 0, 0, sizeMark, hC + 30 )
    bgM.alpha = .01
    markC:insert( bgM )
    local line = display.newRect( 0, 0, 1, hC )
    line:setFillColor( .5 )
    markC:insert( line )
    local mark = display.newCircle(  0, endY, sizeMark/2 )
    mark:setFillColor( unpack(cBPur) )
    markC:insert(mark)
    
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
        text = data.newUserT,
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
    
    local graph = doGraph(data.newUserM, data.newUserT, data.newUserD, 'large')
    graph:translate(midW,  posY + 380)
    grpGraph:insert(graph)
    
    posY = posY + 700 
    
    -- Visitas
    local txtTitleV = display.newText({
        text = data.pointsT,
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
    
    local graph = doGraph(data.pointsM, data.pointsT, data.pointsD, 'medium')
    graph:translate(midWL,  posY + 230)
    grpGraph:insert(graph)
    
    
    -- Redenciones
    local txtTitleR = display.newText({
        text = data.redemT,
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
    
    local graph = doGraph(data.redemM, data.redemT, data.redemD, 'medium')
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