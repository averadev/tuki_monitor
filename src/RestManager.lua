---------------------------------------------------------------------------------
-- Tuki Monitor
-- Alberto Vera Espitia
-- GeekBucket 2017
---------------------------------------------------------------------------------

--Include sqlite
local RestManager = {}

	local mime = require("mime")
	local json = require("json")
	local crypto = require("crypto")
    local DBManager = require('src.DBManager')

    --local site = "http://localhost/tuki_ws/"
    local site = "http://tukicard.com/metrics_ws/"
	--local site = "http://mytuki.com/api/"

	function urlencode(str)
          if (str) then
              str = string.gsub (str, "\n", "\r\n")
              str = string.gsub (str, "([^%w ])",
              function ( c ) return string.format ("%%%02X", string.byte( c )) end)
              str = string.gsub (str, " ", "%%20")
          end
          return str    
    end

    --------------------------------4-----
    -- Test connection
    ------------------------------------
    RestManager.networkConnection = function()
        local netConn = require('socket').connect('www.google.com', 80)
        if netConn == nil then
            return false
        end
        netConn:close()
        return true
    end

    RestManager.verifyUser = function(email, pass)
        local url = site.."monitor/verifyUser/format/json/email/"..urlencode(email).."/pass/"..urlencode(pass)
        print(url)
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
                if data.success then
                    DBManager.updateUser(data.user)
                    toHome()
                else
                    showMsg("El usuario o password es incorrecto")
                end
            end
            return true
        end
        -- Do request
        network.request( url, "GET", callback )
	end

    RestManager.getBranchs = function()
        local dbConfig = DBManager.getSettings()
		local url = site.."monitor/getBranchs/format/json/idCommerce/"..dbConfig.idCommerce
        
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
                if data.success then
                    showBranchs(dbConfig, data.items)
                end
            end
            return true
        end
        -- Do request
        network.request( url, "GET", callback )
	end
    
    RestManager.getData = function(range)
        local dbConfig = DBManager.getSettings()	
		local url = site.."monitor/getData/format/json/idCommerce/"..dbConfig.idCommerce.."/range/"..range
        print(url)
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
                if data.success then
                    showResults(data)
                end
            end
            return true
        end
        -- Do request
        network.request( url, "GET", callback )
	end
    
    RestManager.getDataBranch = function(range, idBranch)
        local dbConfig = DBManager.getSettings()	
		local url = site.."monitor/getData/format/json/idCommerce/"..dbConfig.idCommerce.."/idBranch/"..idBranch.."/range/"..range
        print(url)
        local function callback(event)
            if ( event.isError ) then
            else
                local data = json.decode(event.response)
                if data.success then
                    showResults(data)
                end
            end
            return true
        end
        -- Do request
        network.request( url, "GET", callback )
	end
	
	
return RestManager