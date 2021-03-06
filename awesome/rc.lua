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

-- Vicious widget library
require("vicious")

--------------------------------- {{{ Error handling

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

---------------------------------- }}}

---------------------------------- {{{ Variable definitions

home = os.getenv("HOME")
conf = home .. "/.config/awesome"
themes = conf .. "/themes"
active_theme = themes .. "/chalk"

beautiful.init(active_theme .. "/theme.lua")

terminal = "urxvtc"
terminal_tmux = terminal .. " -e tmux"
editor = os.getenv("EDITOR") or "vim"
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
    awful.layout.suit.floating,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}

---------------------------------- }}}

---------------------------------- {{{ Tags

-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "main", "www", "todo", 4, 5, 6, 7 }, s,
                        { layouts[1], layouts[11], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] })
end

---------------------------------- }}}

---------------------------------- {{{ Menu

-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = 
  { 
    { "awesome", myawesomemenu, beautiful.awesome_icon },
    { "Debian", debian.menu.Debian_menu.Debian },
    { "open terminal", terminal_tmux }
  }
})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
---------------------------------- }}}

---------------------------------- {{{ Wibox
red = "<span color='#F05178'>"
blue = "<span color='#97A4F7'>"
grey = "<span color='#444444'>"
white = "<span color='" .. beautiful.fg_widget .. "'>"
endspan = "</span>"

-- TIME
time_widget = widget({ type = "textbox" })
vicious.register(time_widget, vicious.widgets.date, 
                 white .. "%b %d, %R " .. endspan, 
                 60)

-- SYSTRAY
-- systray_widget = widget({ type = "systray" })

-- BATTERY
battery_widget = widget({ type = "textbox" })
vicious.register(battery_widget, vicious.widgets.bat, 
  function (widget, args)
    local percent = args[2]
    local state = args[1]
    if (percent <= 20) then
      if (percent % 5 == 0 or percent < 5) then
        naughty.notify({
          title = "Battery Low",
          text = red .. percent .. "% remaining" .. endspan,
          timeout = 5,
          fg = "#e3e3e3",
          bg = "#252525"
        })
      end
      return red .. percent .. state .. endspan
    elseif (state == "+") then
      return blue .. percent .. state .. endspan
    else 
      return white .. percent .. state .. endspan
    end
  end,
  60, "BAT0")

-- SEPARATOR
separator = widget({ type = "textbox" })
separator.text = " <span color='" .. beautiful.fg_focus .. "'>| </span>"

-- WIFI
wifi_widget = widget({ type = "textbox" })
vicious.register(wifi_widget, vicious.widgets.wifi,
                 "<span color='" .. beautiful.fg_widget .. "'>" ..
                 "${ssid}</span>", 
                 60, "wlan0")

-- VOLUME
volume_widget = widget({ type = "textbox" })
vicious.register(volume_widget, vicious.widgets.volume,
  function (widget, args)
    if (args[2] ~= "♩" ) then
      return white .. "Vol " .. endspan .. blue .. args[1] .. endspan
    else
      return white .. "Vol " .. endspan .. blue .. "mute" .. endspan
    end
  end, 5, 
  "Master")

taglist_separator = widget({ type = "textbox" })
taglist_separator.text = "| "


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
    mytasklist[s] = awful.widget.tasklist(
      function(c)
        local text, bg, status_image, icon = 
        awful.widget.tasklist.label.currenttags(c, s)
        -- return nil for the icon because we don't want to display one
        return text, bg, status_image, nil
      end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            --mylauncher,
            mytaglist[s],
            mypromptbox[s],
            taglist_separator,
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        time_widget,
        separator,
        battery_widget,
        separator,
        wifi_widget,
        separator,
        volume_widget,
        taglist_separator,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end

---------------------------------- }}}

---------------------------------- {{{ Mouse bindings

root.buttons(awful.util.table.join(
    -- right click to view menu
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    -- scroll to cycle between tags
    --awful.button({ }, 4, awful.tag.viewnext),
    --awful.button({ }, 5, awful.tag.viewprev)
))

---------------------------------- }}}

---------------------------------- {{{ Key bindings

globalkeys = awful.util.table.join(
    -- cycle through tags
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j",   function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k",   function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j",   function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k",   function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u",   awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab", 
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
        --function ()
        --    awful.client.focus.history.previous()
        --    if client.focus then
        --        client.focus:raise()
        --    end
        --end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal_tmux) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    --awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
    --awful.key({ modkey },             "r", 
              --function ()
                --awful.util.spawn("dmenu_run -i -p 'Run command:' -nb '" .. 
                --beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal .. 
                --"' -sb '" .. beautiful.bg_focus .. 
                --"' -sf '" .. beautiful.fg_focus .. "'") 
             --end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
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
--------------------------------- }}}

--------------------------------- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons, 
                     size_hints_honor = false } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { name = "chromium" },
      properties = { border_width = 0 } },

    -- miscellaneous window rules (e.g. random windows I want to float)
    { rule = { name = "chip8" },
      properties = { floating = true } },

    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
---------------------------------- }}}

---------------------------------- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Uncomment to Enable sloppy focus
    --[[
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)
    --]]

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
---------------------------------- }}}

---------------------------------- {{{ Autostart

function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
    findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

-- systray volume control
--run_once("pnmixer")

-- custom keybindings
run_once("xmodmap ~/.Xmodmap")

-- touchpad configuration
run_once("synclient TapButton1=0")
run_once("synclient HorizTwoFingerScroll=1")
run_once("synclient VertTwoFingerScroll=1")
run_once("syndaemon -i 0.5 -d")

-- turn on the urxvt server daemon
run_once("urxvtd")

---------------------------------- }}}
