-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
-- shifty - dynamic tagging library
local shifty = require("shifty")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/shikamaru/.config/awesome/themes/shikamaru/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
browser = "firefox"
mail = "urxvtc -e mutt"
mpdclient = "urxvtc -e ncmpcpp"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

--{{{ SHIFTY: configured tags
shifty.config.tags = {
    dev = {
        layout = awful.layout.suit.fair,
        mwfact=0.60,
        exclusive = false,
        position = 1,
        init = true,
        screen = 1,
        slave = true
    } ,
     im = {
         layout = awful.layout.suit.fair,
         exclusive = false,
         position = 2,
         init = true,
         screen = 1
     },
    web = {
        layout = awful.layout.suit.tile.bottom,
        mwfact=0.65,
        exclusive = true ,
        solitary = true ,
        position = 3,
        spawn = browser  } ,
   mail = {
       layout = awful.layout.suit.tile,
       mwfact=0.55,
       exclusive = false,
       solitary = false,
       position = 4,
       spawn = mail,
       slave = true
   } ,
  media = {
      layout = awful.layout.suit.float,
      exclusive = false,
      solitary = false,
      position = 8,
      spawn = mpdclient
  } ,
 office = {
     layout = awful.layout.suit.tile,
     position = 9
 } ,
}
--}}}

--{{{ SHIFTY: application matching rules
-- order here matters, early rules will be applied first
shifty.config.apps = {
         { match = { "Chromium","uzbl","Firefox","Midori","Iceweasel"      } , tag = "web"    } ,
         { match = { "mutt", ".*Evolution"                                 } , tag = "mail"   } ,
         { match = { "pcmanfm"                                             } , slave = true   } ,
         { match = { "OpenOffice.*", "LibreOffice.*", "okular", "epdfview", ".*Microsoft Word" } , tag = "office" } ,
         { match = { "Mplayer.*","gimp","smplayer"         } , tag = "media", nopopup = true, } ,
         { match = { "MPlayer",                                            } , float = true   } ,
         { match = { terminal                      } , honorsizehints = false, slave = true   } ,
    {
        match = {""},
        buttons = awful.util.table.join(
            awful.button({}, 1, function (c) client.focus = c; c:raise() end),
            awful.button({modkey}, 1, function(c)
                client.focus = c
                c:raise()
                awful.mouse.client.move(c)
                end),
            awful.button({modkey}, 3, awful.mouse.client.resize)
            )
    },
}
--}}}

--{{{ SHIFTY: default tag creation rules
-- parameter description
--  * floatBars : if floating clients should always have a titlebar
--  * guess_name : wether shifty should try and guess tag names when creating new (unconfigured) tags
--  * guess_position: as above, but for position parameter
--  * run : function to exec when shifty creates a new tag
--  * remember_index: ?
--  * all other parameters (e.g. layout, mwfact) follow awesome's tag API
shifty.config.defaults={  
  layout = awful.layout.suit.tile.bottom, 
  ncol = 1, 
  mwfact = 0.60,
  floatBars=true,
  guess_name=true,
  guess_position=true,
--  run = function(tag) 
--    local stitle = "Shifty Created: "
--    stitle = stitle .. (awful.tag.getproperty(tag,"position") or shifty.tag2index(mouse.screen,tag))
--    stitle = stitle .. " : "..tag.name
--    naughty.notify({ text = stitle })
--  end,
}
--}}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- {{{ Widgets
-- {{{ Separators
myspacer         = wibox.widget.textbox()
myseparator      = wibox.widget.textbox()
myspacer:set_text(" ")
myseparator:set_text("|")
-- }}}
-- {{{ CPU
-- Icon
mycpuicon        = wibox.widget.imagebox()
mycpuicon:set_image(beautiful.widget_cpu)
-- Initialize
mycpuwidget        = awful.widget.graph()
mythermalwidget    = wibox.widget.textbox()
-- Properties
mycpuwidget:set_width(50)
mycpuwidget:set_height(16)
mycpuwidget:set_max_value(1)
mycpuwidget:set_background_color(beautiful.fg_off_widget)
mycpuwidget:set_border_color(beautiful.border_widget)
mycpuwidget:set_color({
    type = "linear",
        from = { 0, 0 },
        to = { 0, 16 },
        stops = {
            { 0, theme.fg_end_widget },
            { 0.5, theme.fg_center_widget },
            { 1, theme.fg_widget }
        }
    })
--awful.widget.layout.margins[mycpuwidget.widget] = { top = 1 }
-- Register
vicious.register(mycpuwidget, vicious.widgets.cpu, "$1")
vicious.register(mythermalwidget, vicious.widgets.thermal, "$1°C", 19, "thermal_zone0")
-- }}}
-- {{{ Mem
-- Icon
mymemicon       = wibox.widget.imagebox()
mymemicon:set_image(beautiful.widget_mem)
-- Initialize widget
mymemwidget     = awful.widget.progressbar()
-- Progressbar properties
mymemwidget:set_width(8)
mymemwidget:set_height(16)
mymemwidget:set_vertical(true)
mymemwidget:set_background_color(beautiful.fg_off_widget)
mymemwidget:set_border_color(nil)
mymemwidget:set_color({
    type = "linear",
        from = { 0, 0 },
        to = { 0, 16 },
        stops = {
            { 0, theme.fg_end_widget },
            { 0.5, theme.fg_center_widget },
            { 1, theme.fg_widget }
        }
    })
--awful.widget.layout.margins[mymemwidget.widget] = { top = 1 }
-- Register widget
vicious.register(mymemwidget, vicious.widgets.mem, "$1", 13)
-- }}}
-- {{{ Battery
-- Widget icon
mybaticon       = wibox.widget.imagebox()
mybaticon:set_image(beautiful.widget_bat)
-- Initialize widget
mybatwidget     = wibox.widget.textbox()
-- Register widget
vicious.register(mybatwidget, vicious.widgets.bat, "$1$2%", 61, "BAT0")
-- }}}
-- {{{ Network usage statistics
-- Widget icons
myneticon         = wibox.widget.imagebox()
myneticonup       = wibox.widget.imagebox()
myneticon:set_image(beautiful.widget_net)
myneticonup:set_image(beautiful.widget_netup)
-- Initialize widgets
mynetwidget       = wibox.widget.textbox()
mynetfiwidget     = wibox.widget.textbox()
-- Register ethernet widget
vicious.register(mynetwidget, vicious.widgets.net,
    '<span color="'.. beautiful.fg_netdn_widget ..'">${eth1 down_kb}</span> <span color="'
    .. beautiful.fg_netup_widget ..'">${eth1 up_kb}</span>', 3)
-- Avoid buggy numbers for widgets
vicious.cache(vicious.widgets.net)
-- Register wireless widget
vicious.register(mynetfiwidget, vicious.widgets.net,
    '<span color="'.. beautiful.fg_netdn_widget ..'">${wlan1 down_kb}</span> <span color="'
    .. beautiful.fg_netup_widget ..'">${wlan1 up_kb}</span>', 3)
-- }}}
-- }}}
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    w = { myneticon, mynetfiwidget, myneticonup,
    myneticon, mynetwidget, myneticonup,
    mybaticon, mybatwidget,
    mymemicon, mymemwidget,
    mycpuicon, mythermalwidget, mycpuwidget,
    mytextclock, mylayoutbox[s]
    }
    for i,v in ipairs(w) do
        right_layout:add(myspacer)
        right_layout:add(v)
    end

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

--{{{ SHIFTY: initialize shifty
-- the assignment of shifty.taglist must always be after its actually
-- initialized with awful.widget.taglist.new()
shifty.taglist = mytaglist
shifty.init()
--}}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    -- Shifty: keybindings specific to shifty
    awful.key({modkey, "Shift"}, "d", shifty.del), -- delete a tag
    awful.key({modkey, "Shift"}, "b", shifty.send_prev), -- client to prev tag
    awful.key({modkey         }, "b", shifty.send_next), -- client to next tag
    awful.key({modkey, "Control"},
              "b",
              function()
                  local t = awful.tag.selected()
                  local s = awful.util.cycle(screen.count(), awful.tag.getscreen(t) + 1)
                  awful.tag.history.restore()
                  t = shifty.tagtoscr(s, t)
                  awful.tag.viewonly(t)
              end),
    awful.key({modkey}, "a", shifty.add), -- creat a new tag
    awful.key({modkey, "Shift"}, "n", shifty.rename), -- rename a tag
    awful.key({modkey, "Shift"}, "a", -- nopopup new tag
    function()
        shifty.add({nopopup = true})
    end),

    awful.key({ modkey,           }, "t",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "s",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "t", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "s", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "t", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "s", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Shift" }, "h", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "r",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "c",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "c",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "r",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "c",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "r",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "e",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "k",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "l",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey, "Shift"   }, "v",      function (c) shifty.create_titlebar(c) awful.titlebar(c) c.border_width = 1 end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- SHIFTY: assign client keys to shifty for use in
-- match() function(manage hook)
shifty.config.clientkeys = clientkeys
shifty.config.modkey = modkey

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, (shifty.config.maxtags or 9) do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                      awful.tag.viewonly(shifty.getpos(i))
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      awful.tag.viewtoggle(shifty.getpos(i))
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local t = shifty.getpos(i)
                          awful.client.movetotag(t)
                          awful.tag.viewonly(t)
                       end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          awful.client.toggletag(shifty.getpos(i))
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
-- vim: set ft=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent nu:
