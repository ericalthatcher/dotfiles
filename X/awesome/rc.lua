-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load Debian menu entries
require("debian.menu")

-- Widgets
require("vicious")

-- Awesompd
require("awesompd/awesompd")

-- Menubar
require("menubar")




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
    awesome.add_signal("debug::error", function (err)
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

-- Transparency
awful.util.spawn_with_shell("xcompmgr -cF &")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/current_theme/theme.lua")

theme.wallpaper_cmd = { "awsetbg /home/zach/dotfiles/X/awesome/themes/dust/background.jpg" }

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
  -- names  = { "1", "2", "3", "4", "5", "6", "7", "8", "Code" },
  names = { "☭", "⌥", "✇", "⌤", "☼", "⌘" },
  layout = { layouts[2], layouts[5], layouts[5], layouts[5], layouts[5],
             layouts[5]
}}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end

-- }}}

-- {{{ Menu

-- Menubar
menubar.cache_entries = true
menubar.app_folders = { "/usr/share/applications/" }
menubar.show_categories = true   -- Change to false if you want only programs to appear in the menu
menubar.set_icon_theme("theme name")

mediamenu = {
  { "ncmpcpp", terminal .. " -e ncmpcpp" },
  { "vlc", "vlc" },
  { "picard", "picard" },
  { "clementine", "clementine" },
  { "ario", "ario" },
  { "sonata", "sonata" },
}

mythememenu = {}

function theme_load(theme)
   local cfg_path = awful.util.getdir("config")

   -- Create a symlink from the given theme to /home/user/.config/awesome/current_theme
   awful.util.spawn("ln -sfn " .. cfg_path .. "/themes/" .. theme .. " " .. cfg_path .. "/current_theme")
   awesome.restart()
end

function theme_menu()
   -- List your theme files and feed the menu table
   local cmd = "ls -1 " .. awful.util.getdir("config") .. "/themes/"
   local f = io.popen(cmd)

   for l in f:lines() do
    local item = { l, function () theme_load(l) end }
    table.insert(mythememenu, item)
   end

   f:close()
end

-- Generate your table at startup or restart
theme_menu()


-- Modify your awesome menu to add your theme sub-menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "themes", mythememenu },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

systemmenu = {
  { "run_xrandr", "xrandr --output DVI-I-1 --mode 1920x1080 --pos 0x0 --output DVI-I-2 --pos 1920x0 --mode 1440x900" },
  { "lock", "xscreensaver-command -lock" }
}

mymainmenu = awful.menu({ items = { 
                                    { "system", systemmenu },
                                    { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "terminal", terminal },
                                    { "internet", "chromium" },
                                    { "files", "thunar" },
                                    { "media", mediamenu }
                                  }
                        })

--mytitlebar = titlebar({ position = "top" })
--mytitlebartitle = widget({ type = "textbox", name = "mytitlebartitle" })
--mytitlebar:widgets({ mytitlebartitle })
---- Get the focused client
--c = client.focus
---- Set a titlebar on it
--c.titlebar = mytitlebar
--mytitlebartitle.text = c.name



mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox

-- Music Widget
musicwidget = awesompd:create() -- Create awesompd widget
musicwidget.font = "Liberation Mono" -- Set widget font 
musicwidget.scrolling = true -- If true, the text in the widget will be scrolled
musicwidget.output_size = 30 -- Set the size of widget in symbols
musicwidget.update_interval = 10 -- Set the update interval in seconds
-- Set the folder where icons are located (change username to your login name)
musicwidget.path_to_icons = "/home/zach/.config/awesome/awesompd/icons" 
-- Set the default music format for Jamendo streams. You can change
-- this option on the fly in awesompd itself.
-- possible formats: awesompd.FORMAT_MP3, awesompd.FORMAT_OGG
musicwidget.jamendo_format = awesompd.FORMAT_MP3
-- If true, song notifications for Jamendo tracks and local tracks will also contain
-- album cover image.
musicwidget.show_album_cover = true
-- Specify how big in pixels should an album cover be. Maximum value
-- is 100.
musicwidget.album_cover_size = 50
-- This option is necessary if you want the album covers to be shown
-- for your local tracks.
musicwidget.mpd_config = "/home/zach/.mpdconf"
-- Specify the browser you use so awesompd can open links from
-- Jamendo in it.
musicwidget.browser = "firefox"
-- Specify decorators on the left and the right side of the
-- widget. Or just leave empty strings if you decorate the widget
-- from outside.
musicwidget.ldecorator = " "
musicwidget.rdecorator = " "
-- Set all the servers to work with (here can be any servers you use)
musicwidget.servers = { { server = "localhost", port = 6600 } }
-- Set the buttons of the widget
musicwidget:register_buttons({ { "", awesompd.MOUSE_LEFT, musicwidget:command_toggle() },
                    { "Control", awesompd.MOUSE_SCROLL_UP, musicwidget:command_prev_track() },
              { "Control", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_next_track() },
              { "", awesompd.MOUSE_SCROLL_UP, musicwidget:command_volume_up() },
              { "", awesompd.MOUSE_SCROLL_DOWN, musicwidget:command_volume_down() },
              { "", awesompd.MOUSE_RIGHT, musicwidget:command_show_menu() },
                                { "", "XF86AudioLowerVolume", musicwidget:command_volume_down() },
                                { "", "XF86AudioRaiseVolume", musicwidget:command_volume_up() },
                                { modkey, "Pause", musicwidget:command_playpause() } })
musicwidget:run() -- After all configuration is done, run the widget


 --  Network usage widget
 -- Initialize widget
netwidget = widget({ type = "textbox" })
 -- Register widget
vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${eth0 down_kb}</span> <span color="#7F9F7F">${eth0 up_kb}</span>', 3)

-- Initialize widget
memwidget = awful.widget.progressbar()
-- Progressbar properties
memwidget:set_width(8)
memwidget:set_height(18)
memwidget:set_vertical(true)
memwidget:set_background_color("#494B4F")
memwidget:set_border_color(nil)
memwidget:set_color("#AECF96")
memwidget:set_gradient_colors({ "#AECF96", "#88A175", "#FF5656" })
-- Register widget
vicious.register(memwidget, vicious.widgets.mem, "$1", 13)

-- Initialize widget
cpuwidget = awful.widget.graph()
-- Graph properties
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color("#FF5656")
cpuwidget:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
-- Register widget
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")


-- Initialize widget
-- mpdwidget = widget({ type = "textbox" })
-- -- Register widget
-- vicious.register(mpdwidget, vicious.widgets.mpd,
--     function (widget, args)
--         if args["{state}"] == "Stop" then 
--             return " - "
--         else 
--             return args["{Artist}"]..' - '.. args["{Title}"]
--         end
--     end, 10)


mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

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
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
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
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        memwidget,
        netwidget,
        cpuwidget,
--        mpdwidget,
        musicwidget.widget,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Zach's additions
    awful.key({ modkey }, "b", function ()
      mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),
    awful.key({ modkey }, "s", function () menubar.show() end),
    -- Focus and movement
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "h",
        function ()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "l",
        function ()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "h", function () awful.client.swap.bydirection("left")    end),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.bydirection("down")    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.bydirection("up")      end),
    awful.key({ modkey, "Shift"   }, "l", function () awful.client.swap.bydirection("right")   end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
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
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    -- awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    -- awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    -- awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    -- awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    -- awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),
    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)

)

clientkeys = awful.util.table.join(
    -- Zach's additions
    awful.key({ modkey, "Shift" }, "t", function (c)
      if   c.titlebar then awful.titlebar.remove(c)
      else awful.titlebar.add(c, { modkey = modkey }) end
    end),
 
    -- Standard
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "F12",    function () awful.util.spawn("xscreensaver-command -lock") end),
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

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
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

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     size_hints = false,
                     buttons = clientbuttons } },
    -- Classes to float
    { rule = { class = "Xmessage"           }, properties = { floating = true } },
    { rule = { class = "Xmessage"           }, properties = { floating = true } },
    { rule = { class = "Qmessage"           }, properties = { floating = true } },
    { rule = { class = "MPlayer"            }, properties = { floating = true } },
    { rule = { class = "pinentry"           }, properties = { floating = true } },
    { rule = { class = "gimp"               }, properties = { floating = true } },
    { rule = { class = "vlc"                }, properties = { floating = true } },

    -- Classes to sink
    { rule = { class = "OpenOffice.org 3.2" }, properties = { floating = false } },

    -- Default tag for classses
    { rule = { class = "VirtualBox"                          }, properties = { tag = tags[1][6] } },


    --{ rule = { class = "Thunar" },
    --  properties = { floating = true },
    --  callback = awful.titlebar.add },
    --{ rule = { class = "Sonata" },
    --  properties = { floating = true },
    --  callback = awful.titlebar.add },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
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
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
