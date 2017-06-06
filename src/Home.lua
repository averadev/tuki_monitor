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
local DBManager = require('src.DBManager')
local RestManager = require( "src.RestManager" )

-- Grupos y Contenedores
local screen, grpMain
local scene = composer.newScene()

-- Variables
local lineSel, iconCheck, bgShadow, txtTitle
local idxGraph = 3
local txt = {}
local graphs = {}
local graphsD = {}
local txtOpts = {}
local idBranch = 0
local range = '1M'

---------------------------------------------------------------------------------
-- EVENTOS
---------------------------------------------------------------------------------

-------------------------------------
-- Show Menu
-- @param event objeto evento
------------------------------------
function showMenu( event )
    -- Crear sombra
    if bgShadow then
        bgShadow:removeSelf()
        bgShadow = nil
    end
    bgShadow = display.newRect( midW, h, intW, intH - h )
    bgShadow.anchorY = 0
    bgShadow.alpha = 0
    bgShadow:addEventListener( "tap", hideMenu )
    bgShadow:setFillColor( 0 )
    grpMain:insert( bgShadow )
    
    -- Transicion
    newY = intH * .1
    transition.to( grpMain, { x = 380, y = newY, xScale = .8, yScale = .8,  time = 300 })
    transition.to( bgShadow, { alpha = .1,  time = 300 })
end

-------------------------------------
-- Show Menu
-- @param event objeto evento
------------------------------------
function hideMenu( event )
    if bgShadow then
        transition.to( bgShadow, { alpha = 0,  time = 300, onComplete = function() 
            if bgShadow then
                bgShadow:removeSelf()
                bgShadow = nil
            end
        end})
    end
    transition.to( grpMain, { x = 0, y = 0, xScale = 1, yScale = 1,  time = 300 })
    return true
end

-------------------------------------
-- Change branch
-- @param event objeto evento
------------------------------------
function changeBranch( event )
    if bgShadow then
        local t = event.target
        if not(iconCheck.y == t.y) then
            iconCheck.y = t.y
            idBranch = t.idBranch
            txtTitle.text = t.title
            
            -- Eliminamos datos
            if graphsD then
                graphsD = nil
                graphsD = {}
            end
            -- Clear components
            txt['TitleA']:setFillColor( unpack(cBlack) )
            txt['txtDateA']:setFillColor( unpack(cBlack) )
            txt['TitleV']:setFillColor( unpack(cBlack) )
            txt['DateV']:setFillColor( unpack(cBlack) )
            txt['TitleR']:setFillColor( unpack(cBlack) )
            txt['DateR']:setFillColor( unpack(cBlack) )
            transition.to( grpGraph, { alpha = 0, time = 300 })
            -- Actualizamos graficas
            timer.performWithDelay( 400, function() 
                if idBranch == 0 then
                    RestManager.getData(range)
                else
                    RestManager.getDataBranch(range, idBranch)
                end
            end)
        end
        hideMenu()
    end
end

-------------------------------------
-- Change branch
-- @param event objeto evento
------------------------------------
function closeSession( event )
    if bgShadow then
        DBManager.clearUser()
        composer.removeScene( "src.Login" )
        composer.gotoScene("src.Login", { effect = "fade", time = 500 })
    end
end

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
            showResults()
        else
            range = t.type
            if idBranch == 0 then
                RestManager.getData(range)
            else
                RestManager.getDataBranch(range, idBranch)
            end
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
    local wC = 690
    local hC = 400
    local initX = 10
    local initY = 0
    
    -- Parametros para Escalar 
    if size == 'medium' then
        wC = 320
        hC = 200
    end
    if intH < 1200 then hC = hC *.9 end
    
    -- Create container
    local graph = display.newContainer( wC+60, hC )
    local bg = display.newRect( 0, 0, wC+60, hC )
    bg:setFillColor( .95 )
    graph:insert( bg )
    
    -- Cancel by not data
    if #data == 0 or info.total == 0 then
        txt[txtTitle].text = 0
        txt[txtDate].text = 'No existen datos por graficar'
        return graph
    end
    
    -- Calculos
    info.total = tonumber(info.total)
    local todayGoal = 0
    local maxPoints = 0
    if info.goal then
        info.day = tonumber(info.day)
        info.goal = tonumber(info.goal)
        info.lastDay = tonumber(info.lastDay)
        
        local porcDays = info.day / info.lastDay
        todayGoal = math.floor(info.goal * porcDays)
        maxPoints = todayGoal
        if todayGoal < info.total then maxPoints = info.total end
    else
        todayGoal = info.total
        maxPoints = todayGoal
    end
    
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
    if info.goal then
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
    end
    
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
    
    -- Ajustar Y
    local posY = 180
    if intH < 1200 then posY = 115 end
    local addY = 0
    if intH > 1280 then 
        addY = (intH - 1280) / 3 
        posY = posY + addY
    end
    
    for z = 1, #graphs, 1 do 
        if graphs[z] then
            graphs[z]:removeEventListener( "touch", dragLine )
            graphs[z]:removeSelf()
            graphs[z] = nil
        end
    end
    
    graphs[1] = doGraph(data.newUser, data.newUserD, 'large', 'TitleA', 'txtDateA')
    graphs[1]:translate(midW,  posY + 380)
    grpGraph:insert(graphs[1])
    
    posY = posY + 670 + addY
    if intH < 1200 then posY = posY - 105 end
    
    graphs[2] = doGraph(data.points, data.pointsD, 'medium', 'TitleV', 'DateV')
    graphs[2]:translate(midWL,  posY + 230)
    grpGraph:insert(graphs[2])
    
    
    graphs[3] = doGraph(data.redem, data.redemD, 'medium', 'TitleR', 'DateR')
    graphs[3]:translate(midWR,  posY + 230)
    grpGraph:insert(graphs[3])
    
    transition.to( grpGraph, { alpha = 1, time = 1000 })
end

-------------------------------------
-- Listar Sucursales en el menu
-- @param commerce Comercio
-- @param items Sucursales
------------------------------------
function showBranchs(commerce, items)
    
    local bg = display.newRect( 200, 300, 400, 80 )
    bg.alpha = .01
    bg.idBranch = 0
    bg.title = commerce
    bg:addEventListener( "tap", changeBranch )
    screen:insert( bg )
    
    iconCheck = display.newImage("img/iconCheck.png")
    iconCheck:translate( 40, 300 )
    screen:insert( iconCheck )
    
    local txtComercio = display.newText({
        text = commerce,
        x = 200, y = 300, width = 260,
        font = fontBold,   
        fontSize = 32, align = "left"
    })
    txtComercio:setFillColor( .2 )
    screen:insert(txtComercio)
    
    local menuY = 300
    if (false) then
        for z = 1, #items, 1 do 
            menuY = menuY + 100

            local ln = display.newLine( 0, menuY - 50, 400, menuY - 50 )
            ln:setStrokeColor( .2 )
            ln.alpha = .5
            ln.strokeWidth = 2
            screen:insert(ln)

            local bg = display.newRect( 200, menuY, 400, 80 )
            bg.alpha = .01
            bg.idBranch = items[z].id
            bg.title = items[z].name
            bg:addEventListener( "tap", changeBranch )
            screen:insert( bg )

            local txtComercio = display.newText({
                text = items[z].name,
                x = 200, y = menuY, width = 260,
                font = fontSemiBold,   
                fontSize = 28, align = "left"
            })
            txtComercio:setFillColor( .2 )
            screen:insert(txtComercio)
        end
    end
    -- Cerrar Session
    local bg = display.newRect( 200, intH - 50, 400, 80 )
    bg.alpha = .01
    bg:addEventListener( "tap", closeSession )
    screen:insert( bg )
    
    local iconSession = display.newImage("img/iconSession.png")
    iconSession:translate( 40, intH - 50 )
    screen:insert( iconSession )
    
    local txtSession = display.newText({
        text = 'Cerrar Sessión',
        x = 200, y = intH - 50, width = 240,
        font = fontSemiBold,   
        fontSize = 28, align = "left"
    })
    txtSession:setFillColor( .2 )
    screen:insert(txtSession)
    
    -- Pasamos al frente
    grpMain:toFront()
end


---------------------------------------------------------------------------------
-- DEFAULT METHODS
---------------------------------------------------------------------------------
function scene:create( event )
	screen = self.view
    
    local reducF = 1
    if intH < 1200 then
        reducF = .7
    end
    
    local bgMenu = display.newRect( midW, h, intW, intH )
    bgMenu.anchorY = 0
    bgMenu:setFillColor( {
        type = 'gradient',
        color1 = { .77, .66, .83 }, 
        color2 = { .86, .86, .86 },
        direction = "bottom"
    } )
    screen:insert( bgMenu )
    
    local logoWhiteMin = display.newImage("img/logoWhiteMin.png")
    logoWhiteMin:translate( 180, 130 )
    screen:insert( logoWhiteMin )
    
    grpMain = display.newGroup()
    screen:insert( grpMain )
    
    local bgMain = display.newRect( midW, h, intW, intH - h )
    bgMain.anchorY = 0
    bgMain:setFillColor( 1 )
    grpMain:insert( bgMain )
    
    local iconMenu = display.newImage("img/iconMenu.png")
    iconMenu:translate( 55, 60 )
    iconMenu:addEventListener( "tap", showMenu )
    grpMain:insert( iconMenu )
    
    dbConfig = DBManager.getSettings()
    txtTitle = display.newText({
        text = dbConfig.commerce,
        x = midW, y = h + 30, width = 600,
        font = fontBold,   
        fontSize = 32, align = "center"
    })
    txtTitle:setFillColor( unpack(cBPur) )
    grpMain:insert(txtTitle)
    
    local line = display.newRect( midW, h+80, 700, 1 )
    line:setFillColor( .9 )
    grpMain:insert( line )
    
    lineSel = display.newRect( midW+60, h+80, 100, 1 )
    lineSel:setFillColor( unpack(cBPur) )
    grpMain:insert( lineSel )
    
    -- Crear opciones
    local opts = {'Todo', '3M', '1M', '1S'}
    for z = 1, #opts, 1 do 
    
        local bgSel = display.newRect( (midW - 300) + (z*120), h + 100, 100, 30 )
        bgSel.idx = z
        bgSel.type = opts[z]
        grpMain:insert( bgSel )
        bgSel:addEventListener( "tap", tapBgSel )
        
        txtOpts[z] = display.newText({
            text = opts[z],
            x = (midW - 300) + (z*120), y = h + 100, width = 300,
            font = fontSemiBold,   
            fontSize = 20, align = "center"
        })
        txtOpts[z]:setFillColor( unpack(cGray) )
        grpMain:insert(txtOpts[z])
    end
    txtOpts[3]:setFillColor( unpack(cBlack) )
    
    grpGraph = display.newGroup()
    grpGraph.alpha = 0
    grpMain:insert( grpGraph )
    
    local addY = 0
    if intH > 1280 then
        addY = (intH - 1280) / 3
    end
    
    local posY = 180 + addY
    
    -- Afiliaciones
    txt.TitleA = display.newText({
        text = '',
        x = midW - 200, y = posY + 60, width = 400,
        font = fontRegular,   
        fontSize = 120 * reducF, align = "right"
    })
    txt.TitleA:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.TitleA)
    
    txt.SubTitleA = display.newText({
        text = 'afiliados',
        x = midW + 210, y = posY + 78, width = 400,
        font = fontRegular,   
        fontSize = 70 * reducF, align = "left"
    })
    txt.SubTitleA:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.SubTitleA)
    
    txt.txtDateA = display.newText({
        text = '',
        x = midW, y = posY + 150, width = 400,
        font = fontRegular,   
        fontSize = 28 * reducF, align = "center"
    })
    txt.txtDateA:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.txtDateA)
    
    posY = posY + 670 + addY 
    
    -- Visitas
    txt.TitleV = display.newText({
        text = '',
        x = midWL, y = posY, width = 400,
        font = fontRegular,   
        fontSize = 80 * reducF, align = "center"
    })
    txt.TitleV:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.TitleV)
    
    txt.txtSubTitleV = display.newText({
        text = 'puntos otorgados',
        x = midWL, y = posY + 55, width = 400,
        font = fontRegular,   
        fontSize = 32 * reducF, align = "center"
    })
    txt.txtSubTitleV:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.txtSubTitleV)
    
    txt.DateV = display.newText({
        text = '',
        x = midWL, y = posY + 100, width = 400,
        font = fontRegular,   
        fontSize = 24 * reducF, align = "center"
    })
    txt.DateV:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.DateV)    
    
    -- Redenciones
    txt.TitleR = display.newText({
        text = '',
        x = midWR, y = posY, width = 400,
        font = fontRegular,   
        fontSize = 80 * reducF, align = "center"
    })
    txt.TitleR:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.TitleR)
    
    txt.SubTitleR = display.newText({
        text = 'redenciones',
        x = midWR, y = posY + 55, width = 400,
        font = fontRegular,   
        fontSize = 32 * reducF, align = "center"
    })
    txt.SubTitleR:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.SubTitleR)
    
    txt.DateR = display.newText({
        text = '',
        x = midWR, y = posY + 100, width = 400,
        font = fontRegular,   
        fontSize = 24 * reducF, align = "center"
    })
    txt.DateR:setFillColor( unpack(cBlack) )
    grpGraph:insert(txt.DateR)
    
    print(intH)
    if intH < 1200 then
        txt.TitleA.y = txt.TitleA.y - 20
        txt.SubTitleA.y = txt.SubTitleA.y - 20
        txt.txtDateA.y = txt.txtDateA.y - 40
        
        txt.TitleV.y = txt.TitleV.y - 120
        txt.txtSubTitleV.y = txt.txtSubTitleV.y - 135
        txt.DateV.y = txt.DateV.y - 152
        
        txt.TitleR.y = txt.TitleR.y - 120
        txt.SubTitleR.y = txt.SubTitleR.y - 135
        txt.DateR.y = txt.DateR.y - 152
        
        local ajustY = intH - 1024
        grpGraph.y = ajustY/4
    end
    
    -- Obtenemos informacion
    RestManager.getBranchs()
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