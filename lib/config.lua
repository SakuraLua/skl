return {
	logFile = "lua.log", -- 日志文件
	logOnlyError = false, -- 只记录错误
    debugMenuKey = "f6", -- 调试菜单
    restartKey = "f7", -- 重新加載辭書
    debugMenuShow = true, -- 允许在主菜单中展示调试菜单
	msgBoxWhenError = true, -- 错误时弹框
    mobDebug = false, -- 允许 mobDebug
    dictDir = "dict", -- 默认辞书目录，相对 ghost 目录
    dictExt = "sdc", -- 辞书文件扩展名
    language = "chs", -- 辞书语言（chs/cht）；若设为 ch 则都会转换。
    saveDataFile = "profile/sklsave.table", -- savedata 名字
    shiori = {
        sender = SKL_PRODUCT_NAME .. "/" .. SKL_PRODUCT_VERSION,
        version = SKL_PRODUCT_VERSION,
        name = "SKL",
        craftman = "Thousandsmoe",
        craftmanw = "青石千梦",
        recommendSites = {
            {"一本魔法书", "http://www.abookofmagic.com"}
        },
        portalSites = {
            {"+ 一本魔法书 +", "http://www.abookofmagic.com"}
        }
    },
    saori = {
        -- ChConverter = {
        --    path = "skl/saori/ChConverter.dll",
        --    preload = true
        -- }
    },
	defaultSaveData = {
		
	}
}