-- Default settings definitions

-- General Settings

Slash.Settings.Add("language")
Slash.Settings.AddRule("language", Slash.SettingsRules.Language())

-- Video Settings

Slash.Settings.Add("video.ui_scale", 1.5, true)

Slash.Settings.Add("video.color_by_operator", true, true)

Slash.Settings.Add("video.background_brightness", 1, true)

Slash.Settings.Add("video.smooth_timer", false, true)

Slash.Settings.Add("video.menu_theme", "aura")
Slash.Settings.AddRule("video.menu_theme", Slash.SettingsRules.Choices({"aura"}))

-- Audio Settings

Slash.Settings.Add("audio.sound_volume", 75, true)
Slash.Settings.AddRule("audio.sound_volume", Slash.SettingsRules.NumberRange(0, 100))

Slash.Settings.Add("audio.music_volume", 75, true)
Slash.Settings.AddRule("audio.music_volume", Slash.SettingsRules.NumberRange(0, 100))

-- Gameplay Settings

Slash.Settings.Add("gameplay.dice_mode", 2, true)

Slash.Settings.Add("gameplay.auto_aim_on", false, true)

Slash.Settings.Add("gameplay.auto_aim_limit", 45, true)

Slash.Settings.Add("gameplay.swap_mobile_buttons", false, true)