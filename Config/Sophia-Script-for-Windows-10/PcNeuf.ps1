﻿Set-Location($env:dirscript)
.\Sophia.ps1 -Functions CreateRestorePoint, "DiagTrackService -Disable", "DiagnosticDataLevel -Minimal", "FeedbackFrequency -Never", "SigninInfo -Disable", "WindowsWelcomeExperience -Hide", "SettingsSuggestedContent -Hide", "AppsSilentInstalling -Disable", "WhatsNewInWindows -Disable", "AdvertisingID -Disable", "TailoredExperiences -Disable", "BingSearch -Disable", "OpenFileExplorerTo -ThisPC", "CortanaButton -Hide", "OneDriveFileExplorerAd -Hide", "FileExplorerRibbon -Expanded", "3DObjects -Hide", "TaskViewButton -Hide", "PeopleTaskbar -Hide", "TaskbarSearch -SearchIcon", "MeetNow -Hide", "NewsInterests -Disable", "UnpinTaskbarShortcuts -Shortcuts Edge, Store, Mail", "TaskManagerWindow -Expanded", "FirstLogonAnimation -Disable", "ShortcutsSuffix -Disable", "PrtScnSnippingTool -Enable", "OneDrive -Uninstall", "UninstallPCHealthCheck", "NetworkProtection -Enable", "PUAppsDetection -Enable", "DefenderSandbox -Enable", "DismissMSAccount", "DismissSmartScreenFilter", "PinToStart -Tiles ControlPanel, DevicesPrinters", "CortanaAutostart -Disable"