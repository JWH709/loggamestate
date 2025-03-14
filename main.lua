local mod_id = "log_game_state"

-- Get Libraries
local socket = require("mods.loggamestate.libs.luasocket.src.socket")
local http = require("mods.loggamestate.libs.luasocket.src.http")
local json = require("mods.loggamestate.libs.dkjson")
local ltn12 = require("mods.loggamestate.libs.luasocket.src.ltn12")

-- Logger
local logging = require("logging")
local logger = logging.getLogger(mod_id)

-- Console
local console = require("console")

-- Function to extract game state (reduced version)
local function getGameState()
    if not G or not G.GAME then 
        logger:error("G or G.GAME is nil! Returning empty game state.")
        return {} 
    end

    -- Extract only essential game data to simplify debugging
    local gameState = {
        money = G.GAME.money or 0,
        blind_level = G.GAME.blind_level or 0,
        hands = G.GAME.hands or {},
        deck = G.deck and { size = #G.deck.cards } or {}
    }

    return gameState
end

-- Function to send game state to Express server
local function sendGameStateToServer()
    local gameState = getGameState()

    -- Encode game state as JSON
    local jsonData, err = json.encode(gameState, { indent = true, exception = function() return "<cycle>" end })
    if not jsonData then
        logger:error("Failed to encode game state: " .. tostring(err))
        return false
    end

    -- Log formatted JSON data before sending
    logger:info("Formatted JSON Data:\n" .. jsonData)

    local url = "http://localhost:3000/game-state"
    local headers = {
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["Content-Length"] = tostring(#jsonData)
    }

    -- HTTP Response Storage
    local response_body = {}

    -- Send HTTP Request
    local response, status, response_headers = http.request {
        url = url,
        method = "POST",
        headers = headers,
        source = ltn12.source.string(jsonData),
        sink = ltn12.sink.table(response_body)
    }

    -- Log HTTP Response
    local responseText = table.concat(response_body)
    logger:info("HTTP Status: " .. tostring(status))
    logger:info("Server Response: " .. responseText)

    return true
end

-- Register command for logging game state
local function on_enable()
    console:registerCommand(
        "logGameState",
        sendGameStateToServer,
        "Logs the current game state and sends it to the Express server",
        function() return {} end,
        "logGameState"
    )
    logger:info("logGameState command registered")
end

-- Remove command on disable
local function on_disable()
    console:removeCommand("logGameState")
    logger:info("logGameState command removed")
end

return {
    on_enable = on_enable,
    on_disable = on_disable
}
