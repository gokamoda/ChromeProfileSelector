
local MODAL_KEYS = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
                    "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P",
                    "A", "S", "D", "F", "G", "H", "J", "K", "L",
                    "Z", "X", "C", "V", "B", "N", "M"}

local CHROME_PROFILES = {
    -- {"Profile Dir", "Display Name"}
    -- Change Display Name to whatever you want to show up on the icon
    -- Then reorder the list in the order you want the icons to appear
    {"Profile 1", "Work"},
    {"Profile 2", "Private"},
}


hs.urlevent.httpCallback = function(scheme, host, params, fullURL)
    previousWindow = hs.window.frontmostWindow()

    local screen = hs.screen.mainScreen():frame()
    local boxBorder = 10
    local iconSize = 96
    local iconMargin = 25


    numProfiles = #CHROME_PROFILES

    if numProfiles > 0 then
        local appIcons = {}
        local appNames = {}
        local backgrounds = {}
        local modalDirector = hs.hotkey.modal.new()
        local x = screen.x + (screen.w / 2) - (numProfiles * iconSize / 2)
        local y = screen.y + (screen.h / 2) - (iconSize / 2)
        local box = hs.drawing.rectangle(hs.geometry.rect(x - boxBorder, y - boxBorder, (numProfiles * iconSize) + (boxBorder * 2), iconSize + (boxBorder * 4)))
        box:setFillColor({["red"]=0,["blue"]=0,["green"]=0,["alpha"]=0.8}):setFill(true):show()
        box:setRoundedRectRadii(10, 10)

        for _, scr in pairs(hs.screen.allScreens()) do
            local scrFrame = scr:fullFrame()
            local bg = hs.drawing.rectangle(hs.geometry.rect(scrFrame.x, scrFrame.y, scrFrame.w, scrFrame.h))
            bg:setFillColor({["red"]=0,["blue"]=0,["green"]=0,["alpha"]=0.2}):setFill(true):show()
            bg:setClickCallback(function() chromeProfile() end)
            table.insert(backgrounds, bg)
            box:orderAbove(bg)
        end
        

        function chromeProfile(profile, url)
            if (profile and url) then
                hs.task.new("/usr/bin/open", nil, { "-n",
                                                    "-a", "Google Chrome",
                                                    "--args",
                                                    "--profile-directory="..profile,
                                                    url }):start()
            end
            for _, icon in pairs(appIcons) do
                icon:delete()
            end
            for _, name in pairs(appNames) do
                name:delete()
            end
            for _, bg in pairs(backgrounds) do
                bg:delete()
            end
            box:delete()
            modalDirector:exit()
            if not(profile and url) then
                previousWindow:focus()
            end
        end

        for num, profile in pairs(CHROME_PROFILES) do
            print(profile[1])
            local appImg = hs.image.imageFromPath("~/Library/Application Support/Google/Chrome/"..profile[1].."/Google Profile Picture.png")
            local appIcon = hs.drawing.image(hs.geometry.size(iconSize-iconMargin, iconSize-iconMargin), appImg)
            if appIcon then
                local appName = hs.drawing.text(hs.geometry.size(iconSize, boxBorder*2), MODAL_KEYS[num].." "..profile[2])
                table.insert(appIcons, appIcon)
                table.insert(appNames, appName)

                appIcon:setTopLeft(hs.geometry.point(x + ((num - 1) * iconSize) + iconMargin/2, y + iconMargin/2))
                appIcon:setClickCallback(function() chromeProfile(profile[1], fullURL) end)
                appIcon:orderAbove(box)
                appIcon:show()

                appName:setTopLeft(hs.geometry.point(x + ((num - 1) * iconSize), y + iconSize))
                appName:setTextStyle({["size"]=10,["color"]={["red"]=1,["blue"]=1,["green"]=1,["alpha"]=1},["alignment"]="center",["lineBreak"]="truncateMiddle"})
                appName:orderAbove(box)
                appName:show()

                modalDirector:bind({}, MODAL_KEYS[num], function() chromeProfile(profile[1], fullURL) end)
            end

        end 
        modalDirector:bind({}, "Escape", chromeProfile)
        modalDirector:enter()
    end
end
hs.urlevent.setDefaultHandler('http')