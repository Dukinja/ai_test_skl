debug = true

function love.conf(t)
    t.version = "11.5"                   -- LÖVE version
    t.console = false                     -- Show console for debugging (Windows only)
    t.window.title = "AI Test"
    t.window.icon = nil                  -- Optional icon
    t.window.width = 1280                -- Base width (for fullscreen scaling)
    t.window.height = 720                -- Base height
    t.window.resizable = false
    t.window.vsync = 1                   -- Enable vsync
    t.window.fullscreen = true           -- Fullscreen enabled
    t.window.fullscreentype = "desktop"  -- Use desktop resolution fullscreen
    t.window.msaa = 0                    -- No antialiasing (faster)
    t.window.highdpi = true              -- Use high-DPI if available
end
