-- The Slash Game API
Slash = {}

require "slash.log"
require "slash.assets"
require "slash.network"
require "slash.game"
require "slash.entities"
require "slash.gamemode"
require "slash.settings"
require "slash.localization"
require "slash.scenes"
require "slash.mod"

function Slash.IsHost()
    return (not Slash.Network.IsConnected()) or Slash.Network.IsHosting()
end