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
local lineSel
local idxGraph = 3
local txt = {}
local graphs = {}
local graphsD = {}
local txtOpts = {}

---------------------------------------------------------------------------------
-- EVENTOS
---------------------------------------------------------------------------------

-------------------------------------
-- Drag time line
-- @param event objeto evento
------------------------------------
function dragLine( event )
    local t = event.target.markC
    if event.phase == "began" then
        -- Init variables
        t.isFocus = true
    elseif t.isFocus then
        if event.phase == "moved" then
            -- Move Dot
            moveDot(t, event.x, event.target.x)
        elseif event.phase == "ended" or event.phase == "cancelled" then
            -- We end the movement by removing the focus from the object
            moveDot(t, event.x, event.target.x)
            t.isFocus = false
        end
    end
end

-------------------------------------
-- Cambiar 
-- @param event objeto evento
------------------------------------
function tapBgSel( event )
    local t = event.target
    if not(idxGraph == t.idx) then
        -- Move element
        idxGraph = t.idx
        transition.to( lineSel, { x = t.x, time = 300 })
        for z = 1, #txtOpts, 1 do 
            txtOpts[z]:setFillColor( unpack(cGray) )
        end
        txtOpts[t.idx]:setFillColor( unpack(cBlack) )
        
        -- Clear components
        txt['TitleA']:setFillColor( unpack(cBlack) )
        txt['txtDateA']:setFillColor( unpack(cBlack) )
        txt['TitleV']:setFillColor( unpack(cBlack) )
        txt['DateV']:setFillColor( unpack(cBlack) )
        txt['TitleR']:setFillColor( unpack(cBlack) )
        txt['DateR']:setFillColor( unpack(cBlack) )
        transition.to( grpGraph, { alpha = 0, time = 300 })
        
        -- Mostrar information
        if graphsD[idxGraph] then
            print('showResults')
            showResults()
        else
            print('getData')
            RestManager.getData('1M')
        end
    end
    return true
end

---------------------------------------------------------------------------------
-- FUNCIONES
---------------------------------------------------------------------------------

-------------------------------------
-- Cambia la posicion del marcados
-- @param t arreglo de posiciones
-- @param x1 posicion evento
-- @param x2 posicion target
------------------------------------
function moveDot(t, x1, x2)
     -- Drag
    local currentX = x1 - x2
    if t.xMin > currentX then
        t.x = t.xMin
    elseif t.xMax < currentX then
        t.x = t.xMax
    else
        t.x = currentX
    end

    -- Posc Dot
    poscX = math.floor(t.x + t.xMax)
    if poscX < 1 then
        txt[t.txtTitle].text = 0
        txt[t.txtDate].text = t.toDots[1].dateA .. " 00:00hrs"
        t.dot.y = t.toDots[1].posY - t.yMax
    elseif poscX > #t.toDots then
        txt[t.txtTitle].text = t.toDots[#t.toDots].total
        txt[t.txtDate].text = t.toDots[#t.toDots].dateA
        t.dot.y = t.toDots[#t.toDots].posY - t.yMax
    else
        txt[t.txtTitle].text = t.toDots[poscX].total
        txt[t.txtDate].text = t.toDots[poscX].dateA
        t.dot.y = t.toDots[poscX].posY - t.yMax
    end
    
    -- Change color text
    if t.dateBase == txt[t.txtDate].text then
        txt[t.txtTitle]:setFillColor( unpack(cBlack) )
        txt[t.txtDate]:setFillColor( unpack(cBlack) )
    else
        txt[t.txtTitle]:setFillColor( unpack(cBPur) )
        txt[t.txtDate]:setFillColor( unpack(cBPur) )
    end
end

-------------------------------------
-- Crea grafica de resultados
-- @param data datos para el chart
-- @param size tamaño del chart 
------------------------------------
function doGraph(info, data, size, txtTitle, txtDate)
    
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
    bg:setFillColor( .95 )
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
    
    -- Crear posiciones en Y
    local nextX, midX, jumpY, noX, dateA
    local lastX = 0
    local lastT = 0
    local toDots = {}
    for z = 1, #data, 1 do 
        nextX = math.floor(( jumpW * z ))
        midX = math.floor((nextX - lastX) / 2) + lastX
        noX =  nextX - lastX
        jumpY = math.floor(dotsY[z+1] - dotsY[z]) /noX
        lastT = lastT + data[z].total
        dateA = data[z].dateAction

        local count = 0
        for y = lastX, nextX, 1 do 
            count = count + 1
            toDots[y] = {}
            toDots[y].total = lastT
            toDots[y].dateA = dateA
            toDots[y].posY = math.floor(count * jumpY) + dotsY[z]
        end
        lastX = nextX + 1
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
    graph.markC = display.newContainer( sizeMark, hC + 20  )
    graph.markC.x = mwG
    graph.markC.xMin = mwG * -1
    graph.markC.xMax = mwG
    graph.markC.yMax = mhG * -1
    graph.markC.toDots = toDots
    graph.markC.limX1 = mwG * -1
    graph.markC.limX2 = mwG
    graph.markC.txtTitle = txtTitle
    graph.markC.txtDate = txtDate
    graph.markC.dateBase = data[#data].dateAction
    graph:insert( graph.markC )
    local bgM = display.newRect( 0, 0, sizeMark, hC )
    bgM.alpha = .01
    graph.markC:insert( bgM )
    local line = display.newRect( 0, 0, 3, hC )
    line:setFillColor( .6 )
    graph.markC:insert( line )
    graph.markC.dot = display.newCircle(  0, mhG-(info.total*jumpH), sizeMark/2 )
    graph.markC.dot:setFillColor( unpack(cBPur) )
    graph.markC:insert(graph.markC.dot)
    
    -- Agregar info
    txt[txtTitle].text = info.total
    txt[txtDate].text = data[#data].dateAction
    
    -- Listener Touch
    graph:addEventListener( "touch", dragLine )
    
    return graph
end

-------------------------------------
-- Crea grafica de resultados
-- @param data datos para el chart
-- @param size tamaño del chart 
------------------------------------
function doGoalGraph(info, data, size, txtTitle, txtDate)
    
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
    bg:setFillColor( .95 )
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
    
    -- Crear posiciones en Y
    local nextX, midX, jumpY, noX, dateA
    local lastX = 0
    local lastT = 0
    local toDots = {}
    for z = 1, #data, 1 do 
        nextX = math.floor(( jumpW * z ))
        midX = math.floor((nextX - lastX) / 2) + lastX
        noX =  nextX - lastX
        jumpY = math.floor(dotsY[z+1] - dotsY[z]) /noX
        lastT = lastT + data[z].total
        dateA = data[z].dateAction

        local count = 0
        for y = lastX, nextX, 1 do 
            count = count + 1
            toDots[y] = {}
            toDots[y].total = lastT
            toDots[y].dateA = dateA
            toDots[y].posY = math.floor(count * jumpY) + dotsY[z]
        end
        lastX = nextX + 1
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
    graph.markC = display.newContainer( sizeMark, hC + 20  )
    graph.markC.x = mwG
    graph.markC.xMin = mwG * -1
    graph.markC.xMax = mwG
    graph.markC.yMax = mhG * -1
    graph.markC.toDots = toDots
    graph.markC.limX1 = mwG * -1
    graph.markC.limX2 = mwG
    graph.markC.txtTitle = txtTitle
    graph.markC.txtDate = txtDate
    graph.markC.dateBase = data[#data].dateAction
    graph:insert( graph.markC )
    local bgM = display.newRect( 0, 0, sizeMark, hC )
    bgM.alpha = .01
    graph.markC:insert( bgM )
    local line = display.newRect( 0, 0, 3, hC )
    line:setFillColor( .6 )
    graph.markC:insert( line )
    graph.markC.dot = display.newCircle(  0, mhG-(info.total*jumpH), sizeMark/2 )
    graph.markC.dot:setFillColor( unpack(cBPur) )
    graph.markC:insert(graph.markC.dot)
    
    -- Agregar info
    txt[txtTitle].text = info.total
    txt[txtDate].text = data[#data].dateAction
    
    -- Listener Touch
    graph:addEventListener( "touch", dragLine )
    
    return graph
end

-------------------------------------
-- Crea ficha de resultados
-- @param ScrollView por llenar
------------------------------------
function showResults(dataWS)
    if not(graphsD[idxGraph]) then
        graphsD[idxGraph] = dataWS
    end
    local data = graphsD[idxGraph]
    
    local posY = 180
    
    for z = 1, #data, 1 do 
        if graphs[z] then
            graphs[z]:removeEventListener( "touch", dragLine )
            graphs[z]:removeSelf()
            graphs[z] = nil
        end
    end
    
    graphs[1] = doGraph(data.newUser, data.newUserD, 'large', 'TitleA', 'txtDateA')
    graphs[1]:translate(midW,  posY + 380)
    grpGraph:insert(graphs[1])
    
    posY = posY + 700 
    
    graphs[2] = doGraph(data.points, data.pointsD, 'medium', 'TitleV', 'DateV')
    graphs[2]:translate(midWL,  posY + 230)
    grpGraph:insert(graphs[2])
    
    
    graphs[3] = doGraph(data.redem, data.redemD, 'medium', 'TitleR', 'DateR')
    graphs[3]:translate(midWR,  posY + 230)
    grpGraph:insert(graphs[3])
    
    transition.to( grpGraph, { alpha = 1, time = 1000 })
    
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
    
    lineSel = display.newRect( midW+60, h+80, 100, 1 )
    lineSel:setFillColor( unpack(cBPur) )
    screen:insert( lineSel )
    
    -- Crear opciones
    local opts = {'Todo', '3M', '1M', '1S'}
    for z = 1, #opts, 1 do 
    
        local bgSel = display.newRect( (midW - 300) + (z*120), h + 100, 100, 30 )
        bgSel.idx = z
        screen:insert( bgSel )
        bgSel:addEventListener( "tap", tapBgSel )
        
        txtOpts[z] = display.newText({
            text = opts[z],
            x = (midW - 300) + (z*120), y = h + 100, width = 300,
            font = fontSemiBold,   
            fontSize = 20, align = "center"
        })
        txtOpts[z]:setFillColor( unpack(cGray) )
        screen:insert(txtOpts[z])
    end
    txtOpts[3]:setFillColor( unpack(cBlack) )
    
    grpGraph = display.newGroup()
    grpGraph.alpha = 0
    screen:insert( grpGraph )
    
    local posY = 180
    
    -- Afiliaciones
    txt.TitleA = display.newText({
        text = '',
        x = midW - 200, y = posY + 60, width = 400,
        font = fontRegular,   
        fontSize = 120, align = "right"
    })
    txt.TitleA:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.TitleA)
    
    txt.SubTitleA = display.newText({
        text = 'afiliados',
        x = midW + 210, y = posY + 78, width = 400,
        font = fontRegular,   
        fontSize = 70, align = "left"
    })
    txt.SubTitleA:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.SubTitleA)
    
    txt.txtDateA = display.newText({
        text = '',
        x = midW, y = posY + 150, width = 400,
        font = fontRegular,   
        fontSize = 28, align = "center"
    })
    txt.txtDateA:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.txtDateA)
    
    posY = posY + 700 
    
    -- Visitas
    txt.TitleV = display.newText({
        text = '',
        x = midWL, y = posY, width = 400,
        font = fontRegular,   
        fontSize = 80, align = "center"
    })
    txt.TitleV:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.TitleV)
    
    txtSubTitleV = display.newText({
        text = 'puntos otorgados',
        x = midWL, y = posY + 55, width = 400,
        font = fontRegular,   
        fontSize = 32, align = "center"
    })
    txtSubTitleV:setFillColor( unpack(cBlack) )
    grpGraph:insert(txtSubTitleV)
    
    txt.DateV = display.newText({
        text = '',
        x = midWL, y = posY + 100, width = 400,
        font = fontRegular,   
        fontSize = 24, align = "center"
    })
    txt.DateV:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.DateV)    
    
    -- Redenciones
    txt.TitleR = display.newText({
        text = '',
        x = midWR, y = posY, width = 400,
        font = fontRegular,   
        fontSize = 80, align = "center"
    })
    txt.TitleR:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.TitleR)
    
    txt.SubTitleR = display.newText({
        text = 'redenciones',
        x = midWR, y = posY + 55, width = 400,
        font = fontRegular,   
        fontSize = 32, align = "center"
    })
    txt.SubTitleR:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.SubTitleR)
    
    txt.DateR = display.newText({
        text = '',
        x = midWR, y = posY + 100, width = 400,
        font = fontRegular,   
        fontSize = 24, align = "center"
    })
    txt.DateR:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.DateR)
    
    -- Obtenemos informacion
    RestManager.getData('1M')
    
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