---------------------------------------------------------------------------------
-- Tuki
-- Alberto Vera Espitia
-- GeekBucket 2016
---------------------------------------------------------------------------------

--Include sqlite
local dbManager = {}

	require "sqlite3"
	local path, db

	-- Open metrics.db.  If the file doesn't exist it will be created
	local function openConnection( )
	    path = system.pathForFile("metrics.db", system.DocumentsDirectory)
	    db = sqlite3.open( path )     
	end

    -- Close metrics.db
	local function closeConnection( )
		if db and db:isopen() then
			db:close()
		end     
	end
	 
	-- Handle the applicationExit event to close the db
	local function onSystemEvent( event )
	    if( event.type == "applicationExit" ) then              
	        closeConnection()
	    end
	end

	-- Obtiene los datos de configuracion
	dbManager.getSettings = function()
		local result = {}
		openConnection( )
		for row in db:nrows("SELECT * FROM config;") do
			closeConnection( )
			return  row
		end
		closeConnection( )
		return 1
	end

    -- Actualiza login
    dbManager.clearUser = function(user)
		openConnection( )
        local query = "UPDATE config SET id = 0, name = '', idCommerce = 0, commerce = '', idBranch = 0, branch = ''"
        
        db:exec( query )
		closeConnection( )
	end

    -- Actualiza login
    dbManager.updateUser = function(user)
		openConnection( )
        local query = "UPDATE config SET id = "..user.id..", name = '"..user.name.."', idCommerce = "..user.idCommerce..", commerce = '"..user.comercio.."'"
    
        if user.idBranch then
            query = query .. ", idBranch = "..user.idBranch..", branch = '"..user.branch.."'"
        end
        
        db:exec( query )
		closeConnection( )
	end

	-- Setup squema if it doesn't exist
	dbManager.setupSquema = function()
		openConnection( )
		
		local query = "CREATE TABLE IF NOT EXISTS config (id INTEGER PRIMARY KEY, name TEXT, idCommerce INTEGER, commerce TEXT, idBranch INTEGER, branch TEXT);"
		db:exec( query )
    
        for row in db:nrows("SELECT * FROM config;") do
            closeConnection( )
			do return end
		end
    
        query = "INSERT INTO config VALUES (0, '', 0, '', 0, '');"
        
		db:exec( query )
    
		closeConnection( )
    
        return 1
	end
	
	-- Setup the system listener to catch applicationExit
	Runtime:addEventListener( "system", onSystemEvent )

return dbManager