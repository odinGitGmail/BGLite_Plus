local _, ns = ...

local function RegisterSlash()
    SlashCmdList["BGLitePlus"] = function(msg)
        msg = strtrim(msg or ""):lower()
        if msg == "hope" or msg == "心愿" then
            if BG.BGP_OpenHopeTab then
                BG.BGP_OpenHopeTab()
            end
            return
        end
        if msg == "hope debug" or msg == "debug hope" or msg == "心愿 debug" then
            if BG.BGP_HopeDebug then
                BG.BGP_HopeDebug()
            else
                print("|cff00BFFF<BGLite Plus>|r 调试函数未加载，请 /reload")
            end
            return
        end
        if msg == "hope rebuild" or msg == "心愿 rebuild" then
            if BG.BGP_ForceRebuildHope then
                BG.BGP_ForceRebuildHope()
            end
            return
        end
        if msg == "ro" or msg == "角色" then
            if BG.SetFBCD then
                BG.SetFBCD(nil, nil, true)
            end
            return
        end
        print("|cff00BFFF<BGLite Plus>|r 命令：/bgp hope 打开心愿，/bgp hope debug 调试，/bgp ro 打开角色总览")
    end
    SLASH_BGLitePlus1 = "/bgp"
    SLASH_BGLitePlus2 = "/bgph"
end

RegisterSlash()
ns.RunWhenReady(RegisterSlash)
