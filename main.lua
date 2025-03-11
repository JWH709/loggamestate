local mod_id = "log_game_state"

-- Get Libs
local socket = require("mods.loggamestate.libs.luasocket.src.socket")
local http = require("mods.loggamestate.libs.luasocket.src.http")
local json = require("mods.loggamestate.libs.dkjson")

-- Logger
local logging = require("logging")
local logger = logging.getLogger(mod_id)

-- Console
local console = require("console")

-- Function to get actual game state
local function getGameState()
    if not G then return {} end -- If G doesn't exist, return an empty table

    return {
        money = G.GAME and G.GAME.money or 0,  -- Player's money
        hands = G.GAME and G.GAME.hands or 0,  -- Remaining hands
        discards = G.GAME and G.GAME.discards or 0, -- Remaining discards
        blind_level = G.GAME and G.GAME.blind_level or 0, -- Blind level
        current_jokers = G.jokers or {}, -- List of active jokers
        deck = G.deck and {size = #G.deck.cards} or {}, -- Deck info
        active_cards = G.play and {size = #G.play.cards} or {}, -- Current play area
    }
end

-- Function to send game state to Express server using LuaSocket
local function sendGameStateToServer()
    local gameState = getGameState()

    -- Encode to JSON safely
    local jsonData, err = json.encode(gameState, { exception = function() return "<cycle>" end })
    
    if not jsonData then
        logger:error("Failed to encode game state: " .. tostring(err))
        return false
    end

    -- Set up the request
    local url = "http://localhost:3000/game-state"
    local response_body = {}

    local request_body = jsonData
    local headers = {
        ["Content-Type"] = "application/json",
        ["Content-Length"] = tostring(#request_body),
    }

    logger:info("Sending game state to: " .. url)

    -- Perform HTTP POST request
    local result, code, response_headers, status = http.request {
        url = url,
        method = "POST",
        headers = headers,
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response_body),
    }

    -- Log response details
    if result then
        logger:info("Server response: " .. table.concat(response_body))
    else
        logger:error("HTTP request failed: " .. tostring(code))
    end

    return result
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

