local interface = peripheral.wrap("minecraft:chest_3")
local pretty = require "cc.pretty"

local storages = {}
for _, inv in ipairs({ peripheral.find("inventory") }) do
    if (peripheral.getName(inv) ~= peripheral.getName(interface)) and (peripheral.getName(inv) ~= "right") then
        table.insert(storages, inv)
    end
end

local function depositItems()
    for slot, item in pairs(interface.list()) do
        local remaining = item.count
        for _, storage in ipairs(storages) do
            if remaining > 0 then
                local transferred = interface.pushItems(peripheral.getName(storage), slot)
                remaining = remaining - transferred
            else
                break
            end
        end
    end
    start()
end
-------------------------------------------------------------------------------
local function sortStorage()
    for i = #storages, 1, -1 do
        local Rstorage = storages[i]
        local s = #Rstorage.list()
        local ss = #storages
        for slot, item in pairs(Rstorage.list()) do
            for j, storage in ipairs(storages) do
                term.clear()
                print("outer: " .. ss- i .. "/".. ss)
                print("middle: " .. slot .. "/".. s)
                print("inner: " .. j .. "/".. ss)
                Rstorage.pushItems(peripheral.getName(storage), slot)
                if not Rstorage.getItemDetail(slot) then
                    print("slot is empty")
                    break
                end
            end
        end
    end    
    start()
end


----------------------------------------
local function withdrawItems(input)
    local targetName = nil
    local targetCount = nil

    -- Parsing input
    local inputParts = {}
    for part in string.gmatch(input, "%S+") do
        table.insert(inputParts, part)
    end

    -- Check if it's a mod item search with '@' or a string-based search
    if inputParts[1]:sub(1, 1) == "@" then
        targetName = inputParts[1]:sub(2) -- Remove '@'
        targetCount = tonumber(inputParts[2]) or math.huge -- If no count is specified, withdraw all
    else
        targetName = inputParts[1]
        targetCount = tonumber(inputParts[2]) or math.huge
    end

    -- Find all matching items in the storages and sum quantities
    local matchingItems = {}
    local totalQuantity = 0
    for _, storage in ipairs(storages) do
        for slot, item in pairs(storage.list()) do
            if string.match(item.name, targetName) then
                totalQuantity = totalQuantity + item.count
                matchingItems[#matchingItems + 1] = {slot = slot, name = item.name, count = item.count, storage = storage}
            end
        end
    end

    -- If no matching items are found
    if totalQuantity == 0 then
        print("No items found matching: " .. targetName)
        return
    end

    -- Show the matching items with their total quantity
    print("Total matching items found: " .. totalQuantity)
    print("Matching items:")
    local uniqueItems = {}
    
    -- List unique items only
    for _, item in ipairs(matchingItems) do
        if not uniqueItems[item.name] then
            uniqueItems[item.name] = 0
        end
        uniqueItems[item.name] = uniqueItems[item.name] + item.count
    end

    -- Display the unique items
    local index = 1
    local itemChoices = {}
    for name, total in pairs(uniqueItems) do
        print(string.format("[%d] %s x%d", index, name, total))
        itemChoices[index] = name
        index = index + 1
    end

    -- Ask the user to choose which item to withdraw
    print("Enter the number of the item you want to withdraw:")
    local itemSelection = tonumber(io.read())

    -- If the input is invalid
    if not itemSelection or not itemChoices[itemSelection] then
        print("Invalid selection.")
        return
    end

    -- Get the selected item and its quantity
    local selectedItemName = itemChoices[itemSelection]
    print("You selected: " .. selectedItemName)

    -- Ask for the quantity to withdraw
    print("How many would you like to withdraw?")
    local withdrawAmount = tonumber(io.read()) or totalQuantity
    withdrawAmount = math.min(withdrawAmount, totalQuantity)

    -- Withdraw the selected item
    local withdrawn = 0
    for _, item in ipairs(matchingItems) do
        if item.name == selectedItemName and withdrawn < withdrawAmount then
            local available = item.count
            local amountToWithdraw = math.min(available, withdrawAmount - withdrawn)
            item.storage.pushItems(peripheral.getName(interface), item.slot, amountToWithdraw)
            withdrawn = withdrawn + amountToWithdraw
            print("Withdrew " .. amountToWithdraw .. " of " .. selectedItemName)
        end
    end

    -- Final message
    print("Total withdrawn: " .. withdrawn .. " of " .. selectedItemName)
    start() -- Restart process if needed
end

----------------------------------------
local function countSlots()
    local usedSlots = 0
    local emptySlots = 0

    -- Iterate through all slots and count used and empty slots
    for _, storage in ipairs(storages) do
        usedSlots = usedSlots + #storage.list()
        emptySlots = emptySlots + storage.size() - #storage.list()
    end

    print("Used slots: " .. usedSlots)
    print("Empty slots: " .. emptySlots)
    read()
    start()
end


local function withdrawItemsE(input)
    local targetName, targetCount
    local inputParts = {}
    for part in string.gmatch(input, "%S+") do
        table.insert(inputParts, part)
    end
    
    targetName = inputParts[1]:sub(1, 1) == "@" and inputParts[1]:sub(2) or inputParts[1]
    targetCount = tonumber(inputParts[2]) or math.huge
    
    local matchingItems, totalQuantity = {}, 0
    for _, storage in ipairs(storages) do
        for slot, item in pairs(storage.list()) do
            if string.match(item.name, targetName) then
                totalQuantity = totalQuantity + item.count
                table.insert(matchingItems, {slot = slot, name = item.name, count = item.count, storage = storage})
            end
        end
    end
    
    if totalQuantity == 0 then
        print("No items found matching: " .. targetName)
        return
    end
    
    local uniqueItems, itemChoices, index = {}, {}, 1
    for _, item in ipairs(matchingItems) do
        uniqueItems[item.name] = (uniqueItems[item.name] or 0) + item.count
    end
    
    for name, total in pairs(uniqueItems) do
        table.insert(itemChoices, {name = name, total = total})
    end
    
    local scrollPos, pageSize, selectedIndex = 1, 10, 1
    
    local function displayItems()
        term.clear()
        print("Total matching items found: " .. totalQuantity)
        for i = scrollPos, math.min(scrollPos + pageSize - 1, #itemChoices) do
            if i == selectedIndex then
                term.setBackgroundColor(colors.gray)
                term.setTextColor(colors.white)
            else
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
            end
            print(string.format("[%d] %s x%d", i, itemChoices[i].name, itemChoices[i].total))
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
        end
        print("Use UP/DOWN to scroll, ENTER to select")
    end
    
    displayItems()
    
    local selectedItem = nil
    while true do
        local event, key = os.pullEvent("key")
        if key == keys.up and selectedIndex > 1 then
            selectedIndex = selectedIndex - 1
            if selectedIndex < scrollPos then
                scrollPos = scrollPos - 1
            end
            displayItems()
        elseif key == keys.down and selectedIndex < #itemChoices then
            selectedIndex = selectedIndex + 1
            if selectedIndex > scrollPos + pageSize - 1 then
                scrollPos = scrollPos + 1
            end
            displayItems()
        elseif key == keys.enter then
            selectedItem = itemChoices[selectedIndex]
            print("You selected: " .. selectedItem.name)
            break
        end
    end
    
    if not selectedItem then
        print("Error: No item selected.")
        error("How tf did you manage to do this?")
        return
    end
    
    print("How many would you like to withdraw?")
    local withdrawAmount = tonumber(io.read()) or totalQuantity
    withdrawAmount = math.min(withdrawAmount, totalQuantity)
    
    local withdrawn = 0
    for _, item in ipairs(matchingItems) do
        if item.name == selectedItem.name and withdrawn < withdrawAmount then
            local amountToWithdraw = math.min(item.count, withdrawAmount - withdrawn)
            item.storage.pushItems(peripheral.getName(interface), item.slot, amountToWithdraw)
            withdrawn = withdrawn + amountToWithdraw
            print("Withdrew " .. amountToWithdraw .. " of " .. selectedItem.name)
        end
    end
    
    print("Total withdrawn: " .. withdrawn .. " of " .. selectedItem.name)
    start()
end


-- CUSTOM CRAFT
-- make a crafting grid and when clicked on a slot itll ask the item when done click submit to craft and return the outputs!

local noobInputs = {"11","22","33","44","55","a","sort","deposit","withdraw","capacity check","experimental withdraw","Sort","Deposit","Withdraw","Capacity check","Experimental Withdraw"}
local colorsList = {
    colors.white, colors.orange, colors.magenta, colors.lightBlue, 
    colors.yellow, colors.lime, colors.pink, colors.gray, 
    colors.lightGray, colors.cyan, colors.purple, colors.blue, 
    colors.brown, colors.green, colors.red,
}


local colorMode = false

function start()
    term.setCursorPos(1, 1)
    term.clear()

    if colorMode then
        term.setTextColor(colorsList[math.random(#colorsList)])
    end

    print("[1] Sort")
    print("[2] Deposit")
    print("[3] Withdraw")
    print("[4] Capacity check")
    print("[5] Experimental Withdraw")
    print(">")
    local i = read()
    if i == "1" then
        sortStorage()
    elseif i == "2" then
        depositItems()
    elseif i == "3" then
        withdrawItems(read())
    elseif i == "4" then
        countSlots()
    elseif i == "5" then
        withdrawItemsE(read())
    elseif i == "awesome" then
        colorMode = not colorMode
        print("AWESOME!!!!")
        read()
        start()
    else
        start()
    end
end

start()


--wget https://raw.githubusercontent.com/SquidDev-CC/mbs/master/mbs.lua mbs
--mbs install
--reboot