-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

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
local tyrannical = require("tyrannical")
local vicious = require("vicious")
local viciouscontrib = require("vicious.contrib")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
--local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

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
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
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
awful.layout.layouts = {
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
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
  local instance = nil

  return function ()
    if instance and instance.wibox.visible then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({ theme = { width = 250 } })
    end
  end
end
-- }}}

--{{{ TYRANNICAL: configured tags
tyrannical.settings.default_layout =  awful.layout.suit.tile.fair
tyrannical.settings.master_width_factor = 0.66

-- tags
tyrannical.tags = {
  {
    name = "dev",
    init = true,
    exclusive = false,
    screen = {1,2},
    layout = awful.layout.suit.fair,
    selected    = true,
--    slave = true
  } ,
  {
    name = "im",
    init = true,
    exclusive = false,
    screen = {1,2},
    layout = awful.layout.suit.fair,
  } ,
  {
    name = "web",
    init = true,
    exclusive = true ,
    screen = screen.count()>1 and 2 or 1,
    layout = awful.layout.suit.tile.bottom,
--    solitary = true ,
    exec_once = {browser},
    class = {
      "Chromium","Firefox-esr","firefox","Midori","Iceweasel"
    }
  } ,
  {
    name = "mail",
    init = false,
    exclusive = false,
    screen = 1,
    layout = awful.layout.suit.tile,
    exec_once = {mail},
--    solitary = false,
--    slave = true
    class = {
      "mutt", ".*Evolution"
    }
  } ,
  {
    name = "media",
    init = false,
    exclusive = false,
    screen = 1,
--    solitary = false,
    layout = awful.layout.suit.float,
    exec_once = {mpdclient},
    class = {
      "Mplayer.*","gimp","smplayer","vlc"
    }
  } ,
  {
    name = "office",
    init = false,
    exclusive = false,
    layout = awful.layout.suit.tile,
    class = {
      "LibreOffice.*", "okular", "epdfview", ".*Microsoft Word"
    }
  }
}
-- Ignore the tag "exclusive" property for the following clients (matched by classes)
tyrannical.properties.intrusive = {
  "ksnapshot"     , "pinentry"       , "gtksu"     , "kcalc"        , "xcalc"               ,
  "feh"           , "Gradient editor", "About KDE" , "Paste Special", "Background color"    ,
  "kcolorchooser" , "plasmoidviewer" , "Xephyr"    , "kruler"       , "plasmaengineexplorer",
}
--}}}

-- Ignore the tiled layout for the matching clients
tyrannical.properties.floating = {
  "MPlayer"      , "pinentry"        , "ksnapshot"  , "pinentry"     , "gtksu"          ,
  "xine"         , "feh"             , "kmix"       , "kcalc"        , "xcalc"          ,
  "yakuake"      , "Select Color$"   , "kruler"     , "kcolorchooser", "Paste Special"  ,
  "New Form"     , "Insert Picture"  , "kcharselect", "mythfrontend" , "plasmoidviewer"
}

-- Make the matching clients (by classes) on top of the default layout
tyrannical.properties.ontop = {
  "Xephyr"       , "ksnapshot"       , "kruler"
}

-- Force the matching clients (by classes) to be centered on the screen on init
tyrannical.properties.centered = {
  "kcalc"
}

-- Do not honor size hints request for those classes
tyrannical.properties.size_hints_honor = { xterm = false, URxvt = false, aterm = false, sauer_client = false, mythfrontend  = false}

-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after =  { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
                  --{ "Debian", debian.menu.Debian_menu.Debian },
                  menu_terminal,
                }
    })
end


mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- {{{ Widgets
-- {{{ Separators
myspacer         = wibox.widget.textbox()
myseparator      = wibox.widget.textbox()
myspacer:set_text(" ")
myseparator:set_text("|")
-- }}}
-- {{{ GPU
-- Icon
mygpuicon = wibox.widget.imagebox()
mygpuicon:set_image(beautiful.widget_gpu)
-- Initialize
mygpuwidget = wibox.widget.graph()
mythermalgpuwidget = wibox.widget.textbox()
-- Properties
mygpuwidget:set_width(25)
mygpuwidget:set_height(16)
mygpuwidget:set_max_value(1)
mygpuwidget:set_background_color(beautiful.fg_off_widget)
mygpuwidget:set_border_color(beautiful.border_widget)
mygpuwidget:set_color({
    type = "linear",
        from = { 0, 0 },
        to = { 0, 16 },
        stops = {
            { 0, theme.fg_end_widget },
            { 0.5, theme.fg_center_widget },
            { 1, theme.fg_widget }
        }
    })
vicious.register(mygpuwidget, viciouscontrib.amdgpu, "${gpu_usage}", 1, "card0")
vicious.register(mythermalgpuwidget, vicious.widgets.thermal, "$1°C", 11, { "hwmon3", "hwmon" })
-- {{{ GPU Mem
-- Initialize widget
mygpumemwidget = wibox.widget.progressbar()
-- Progressbar properties
mygpumemcontainer     = wibox.widget {
    {
        max_value = 1,
        border_color = nil,
        background_color = theme.fg_off_widget,
        widget = mygpumemwidget,
        color = { type = "linear",
            from = { 16, 0 },
            to = { 0, 0 },
            stops = {
                { 0, theme.fg_end_widget },
                { 0.5, theme.fg_center_widget },
                { 1, theme.fg_widget }
            }
        }
    },
    forced_height = 16,
    forced_width = 8,
    direction = 'east',
    layout = wibox.container.rotate,
}
-- Register widget
vicious.register(mygpumemwidget, viciouscontrib.amdgpu, "${mem_usage}", 17, "card0")
-- }}}
-- }}}
-- {{{ CPU
-- Icon
mycpuicon        = wibox.widget.imagebox()
mycpuicon:set_image(beautiful.widget_cpu)
-- Initialize
mycpuwidget        = wibox.widget.graph()
mythermalwidget    = wibox.widget.textbox()
-- Properties
mycpuwidget:set_width(25)
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
vicious.register(mythermalwidget, vicious.widgets.hwmontemp,
    function(widget, args)
        return("%.0f°C"):format(args[1])
    end, 19, { "k10temp", 1 })
-- }}}
-- {{{ Mem
-- Icon
mymemicon       = wibox.widget.imagebox()
mymemicon:set_image(beautiful.widget_mem)
-- Initialize widget
mymemwidget = wibox.widget.progressbar()
-- Progressbar properties
mymemcontainer     = wibox.widget {
    {
        max_value = 1,
        border_color = nil,
        background_color = theme.fg_off_widget,
        widget = mymemwidget,
        color = { type = "linear",
            from = { 16, 0 },
            to = { 0, 0 },
            stops = {
                { 0, theme.fg_end_widget },
                { 0.5, theme.fg_center_widget },
                { 1, theme.fg_widget }
            }
        }
    },
    forced_height = 16,
    forced_width = 8,
    direction = 'east',
    layout = wibox.container.rotate,
}
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
    '<span color="'.. beautiful.fg_netdn_widget ..'">${enp5s0 down_kb}</span> <span color="'
    .. beautiful.fg_netup_widget ..'">${enp5s0 up_kb}</span>', 3)
-- Avoid buggy numbers for widgets
vicious.cache(vicious.widgets.net)
-- Register wireless widget
vicious.register(mynetfiwidget, vicious.widgets.net,
    '<span color="'.. beautiful.fg_netdn_widget ..'">${wlp6s0 down_kb}</span> <span color="'
    .. beautiful.fg_netup_widget ..'">${wlp6s0 up_kb}</span>', 3)
-- }}}
-- }}}
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            myneticon, myspacer, mynetfiwidget, myspacer, myneticonup, myspacer,
            myneticon, myspacer, mynetwidget, myspacer, myneticonup, myspacer,
            mybaticon, myspacer, mybatwidget, myspacer,
            mymemicon, myspacer, mymemcontainer, myspacer, mygpumemcontainer, myspacer,
            mygpuicon, myspacer, mythermalgpuwidget, myspacer, mygpuwidget, myspacer,
            mycpuicon, myspacer, mythermalwidget, myspacer, mycpuwidget, myspacer,
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
-- @DOC_ROOT_BUTTONS@
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
-- @DOC_GLOBAL_KEYBINDINGS@
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "h",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    -- Shifty: keybindings specific to shifty
    --awful.key({modkey, "Shift"}, "d", shifty.del), -- delete a tag
    --awful.key({modkey, "Shift"}, "b", shifty.send_prev), -- client to prev tag
    --awful.key({modkey         }, "b", shifty.send_next), -- client to next tag
    --awful.key({modkey, "Control"},
    --            "b",
    --            function()
    --                local t = awful.tag.selected()
    --                local s = awful.util.cycle(screen.count(), awful.tag.getscreen(t) + 1)
    --                awful.tag.history.restore()
    --                t = shifty.tagtoscr(s, t)
    --                awful.tag.viewonly(t)
    --            end),
    --  awful.key({modkey}, "a", shifty.add), -- creat a new tag
    --  awful.key({modkey, "Shift"}, "n", shifty.rename), -- rename a tag
    --  awful.key({modkey, "Shift"}, "a", -- nopopup new tag
    --  function()
    --      shifty.add({nopopup = true})
    --  end),
    awful.key({ modkey,           }, "t",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "s",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "t", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "s", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "t", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "s", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "h", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "r",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "c",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "c",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "r",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "c",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "r",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
      {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
      {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "e",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
      {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "l",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    --awful.key({ modkey, "Shift"   }, "v",      function (c) shifty.create_titlebar(c) awful.titlebar(c) c.border_width = 1 end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
-- vim: set ft=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent nu:
