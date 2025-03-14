local buttons = {}
Button = {}
Button.__index = Button

function Button.new()
    local self = setmetatable({}, Button)
    local tsx, tsy = 0, 0
    
    self.screen = nil
    self.color = colors.green
    self.clickColor = colors.gray
    self.textColor = colors.black
    self.text = ""
    self.clicked = false
    self.w = nil
    self.action = function() end

    local posX = 0
    local posY = 0

    local sizeX = 0
    local sizeY = 0

    function self:initialize()
        table.insert(buttons, self)
    end

    function self:getBounds()
        return posX, posY, sizeX + posX, sizeY + posY
    end

    function self:setScreen(screen)
        self.screen = screen
        tsx, tsy = term.getSize() 
    end

    function self:size(x, y)
        sizeX = x
        sizeY = y
    end
    
    function self:position(x, y)
        posX = x
        posY = y
    end

    function self:scaleSize(x, y)
        sizeX = tsx * x
        sizeY = tsy * y
    end

    function self:scalePosition(x, y)
        posX = tsx * x
        posY = tsy * y
    end

    function self:draw()
        if not self.screen then
            print("Error: Screen is not set!")
            return
        end
        posX = math.floor(posX)
        posY = math.floor(posY)
        sizeX = math.floor(sizeX)
        sizeY = math.floor(sizeY)
        if not self.w then
            self.w = window.create(self.screen, posX, posY, sizeX, sizeY)
        end
        if self.clicked then
            self.w.setBackgroundColour(self.clickColor)
        else
            self.w.setBackgroundColour(self.color)
        end
        self.w.setTextColour(self.textColor)
        self.w.clear()
        local textLength = #self.text
        local startX = math.max(1, math.floor((sizeX - textLength) / 2) + 1)
        self.w.setCursorPos(startX, math.floor(sizeY / 2)) -- Centered vertically
        self.w.write(self.text)
        self.w.redraw()
    end

    return self
end

local function listenForClicks()
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        for _, btn in pairs(buttons) do
            local sx, sy, ex, ey = btn:getBounds()
            if x >= sx and x < ex and y >= sy and y < ey then
                btn.clicked = true
                btn:draw()
                sleep(0.1)
                btn.clicked = false
                btn:draw()
                btn.action()
            end
        end
    end
end

-- Example usage
local redButton = Button.new()
redButton:setScreen(term.current())
redButton:scaleSize(0.5, 0.5)
redButton:scalePosition(0.4, 0.4)
redButton.text = "Hello World!"
redButton.color = colors.red
redButton.textColor = colors.white
redButton:draw()
redButton:initialize()
redButton.clickColor = colors.green

local bluButton = Button.new()
bluButton:setScreen(term.current())
bluButton:size(10, 5)
bluButton:position(2, 2)
bluButton.text = "sad ):"
bluButton.color = colors.blue
bluButton.textColor = colors.pink
bluButton:draw()
bluButton:initialize()


local function test()
    print("aAAAAAAAAAAAAAAAAAA")
end

bluButton.action = test


listenForClicks()




-- C:\Users\drls1\AppData\Roaming\CraftOS-PC\computer\0


