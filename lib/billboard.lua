--- Billboard class.

local Billboard = {}
Billboard.__index = Billboard
-- TODO either register more fonts here
-- or create a pull request so we can work with norns fonts
-- without magic numbers
Billboard.FONTS = {CTRL_D_10_REGULAR = 28, CTRL_D_10_BOLD = 27}

local function calculate_line_height(self)
    return math.ceil(self.font_size_ * self.line_height_)
end

local function calculate_line_height_multiple(self, i)
    return math.ceil(calculate_line_height(self) * i)
end

local function check_bold(self, line_num)
    if tab.contains(self.bold_lines_, line_num) then
        screen.font_face(self.bold_font_)
    else
        screen.font_face(self.font_)
    end
end

function Billboard.new(x, y, w, h, text_x, text_y, len, bg, fg, font, bold_font, font_size, align, line_height)
    local b = {}
    local x_margin = 8
    local y_margin = 12
    b.x_ = x or 1 + x_margin
    b.y_ = y or 1 + x_margin
    b.w_ = w or (127 - y_margin)
    b.h_ = h or (63 - y_margin)
    b.text_x_ = text_x or math.ceil(b.x_ + (b.w_ / 2))
    b.text_y_ = text_y or math.ceil(b.y_ + (b.h_ / 2))
    b.message_ = ""
    b.do_display_ = false
    b.display_length_ = len or 0.6
    b.bg_ = bg or 0
    b.fg_ = fg or 14
    b.curfg_ = b.fg_
    b.active_ = false
    b.font_ = font or Billboard.FONTS.CTRL_D_10_REGULAR
    b.bold_font_ = bold_font or Billboard.FONTS.CTRL_D_10_BOLD
    b.font_size_ = font_size or 10
    b.align_ = align or "center"
    b.line_height_ = line_height or 1.6
    b.bold_lines_ = {}

    local function display_callback()
        b.do_display_ = false
        b.message_ = ""
        b.curfg_ = b.fg_
    end
    b.on_display_ = metro.init(display_callback, b.display_length_, 1)

    local function start_callback()
        b.active_ = true
    end
    b.on_start_ = metro.init(start_callback, 1, 1)
    b.on_start_:start()

    setmetatable(b, Billboard)
    return b
end

function Billboard:set_font(font_num)
    self.font_ = font_num
end

function Billboard:set_bold_font(bold_font_num)
    self.bold_font_ = bold_font_num
end

function Billboard:set_font_size(font_size)
    self.font_size_ = font_size
end

function Billboard:bold_line(line_num)
    table.insert(self.bold_lines_, line_num)
end

function Billboard:display_param(param_name, param_value, do_bold_value)
    local bold = do_bold_value or true
    self:display({param_name, param_value})
    if bold then
        self:bold_line(2)
    end
end

function Billboard:display(new_message)
    if self.active_ then
        if type(new_message) == "string" then
            local txt = new_message
            new_message = {}
            table.insert(new_message, txt)
        end
        self.message_ = new_message
        self.curfg_ = self.fg_
        self.do_display_ = true
        self.on_display_:start()
    end
end

function Billboard:draw()
    if self.message_ and self.active_ and self.do_display_ then
        -- draw bg
        screen.level(self.bg_)
        screen.rect(self.x_, self.y_, self.w_, self.h_)
        screen.fill()

        -- draw border
        screen.level(self.curfg_)
        screen.rect(self.x_, self.y_, self.w_, self.h_)
        screen.stroke()

        -- draw message
        screen.level(self.curfg_)
        screen.move(self.text_x_, self.text_y_)

        screen.font_size(self.font_size_)

        for i, msg in ipairs(self.message_) do
            check_bold(self, i)
            screen.text_center(msg)
            screen.move(self.text_x_, self.text_y_ + calculate_line_height_multiple(self, i))
            -- if self.align_ == "center" then
            -- else
            --     screen.text(msg)
            -- end
        end

        -- fade out
        if self.curfg_ > 0 then
            self.curfg_ = self.curfg_ - 1
        end
    end
end

return Billboard
