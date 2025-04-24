# BatteryCare

This repository contains an AutoIt script that automates the launch and battery-saving management of **BatteryCare™ 1.0**, a lightweight tool to optimize battery usage and system performance on Windows laptops.

## 🧰 Features

BatteryCare™ 1.0 provides the following functionality:

- ✅ **Show battery status** with an easy-to-access UI
- ⚡ **Turn on/off Battery Saver mode** on your laptop
- 🚫 **Disable or open unnecessary apps** to preserve battery life
- 🧹 **Delete all temporary data recursively** on the system to clean disk space
- 🧠 **Optimize RAM** to improve performance

## 📁 Files Overview

- `BatteryCare.au3` – Main AutoIt script to launch and interact with BatteryCare
- `_Msgbox.au3` – Custom library for notifications and message boxes
- `Battery_icon.ico` – Application icon
- `fontawesome.ttf` – FontAwesome font used in UI elements
- `Log.txt` – Log file created to track first-time usage
- `StringSize.au3` – Utility for calculating and adjusting string display size
- `TurnON.bat` – Enables battery-saving mode and closes unnecessary programs
- `TurnOFF.bat` – Disables battery-saving mode and reopens essential programs

## 🚀 How It Works

1. Launches BatteryCare from its default installation path.
2. Waits for the system tray icon to become available.
3. Simulates mouse interaction to open the BatteryCare context menu.
4. Opens the main UI, then minimizes it.
5. Runs batch scripts to toggle system settings and clean temporary files.

## 🛠 Requirements

- [AutoIt](https://www.autoitscript.com/site/autoit/) installed
- BatteryCare software
- Windows OS

## 🔧 Setup Instructions

1. **Update Program Paths (if needed):**  
   Adjust the program path if your setup differs.

2. **Compile Script:**  
   Use AutoIt Script Editor or `Aut2Exe` to compile the `.au3` file into an `.exe`.

## ⚠️ Notes
- The batch scripts can be customized further for app control or deeper system tweaks.
