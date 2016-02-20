local base = require("skl.base")
local response = {
    version = CONFIG.shiori.version,
    name = CONFIG.shiori.name,
    craftman = CONFIG.shiori.craftman,
    craftmanw = CONFIG.shiori.craftmanw
}
response["sakura.recommendsites"] = base.urlList(CONFIG.shiori.recommendSites)
response["sakura.portalsites"] = base.urlList(CONFIG.shiori.portalSites)
return response