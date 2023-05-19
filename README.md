# Game Manager

This is a game manager script written in PowerShell designed to manage various gaming and application processes. It's designed to streamline your gaming experience and enhance the performance of your games. 

## Prerequisites

This script requires administrative privileges to run. If you don't have administrative privileges, the script will automatically detect and request them.

## Usage

To start, simply run `start.bat`.

## Files

The game manager uses two text files to manage applications and games: `applications.txt` and `games.txt`. These files should contain the names of `.exe` files that the manager should track. 

For example:

Discord

Firefox

vbnet

Any applications listed in `applications.txt` will be subject to the auto-kill and restart features of the manager.

Similarly, `games.txt` should contain the names of game `.exe` files. 

## AutoHotKey Support

If you use AutoHotKey scripts for certain games, you can place those scripts in the `ahk` folder. The game manager will look for a subfolder that matches the name of the game (as listed in `games.txt`). If it finds a matching `.ahk` file, it will run the script while the game is running and stop the script when the game closes.

## Additional Features

The game manager has several additional features:

* **Process Priority Management**: The game manager can elevate the priority of a game process to High, potentially improving performance.
* **Ad Blocking**: The manager can block ads from GameRanger, providing a cleaner gaming experience.
* **Volume Management**: If you prefer a certain volume level for your game, the game manager can set the system volume to that level while the game is running, and revert it back to the previous level once the game is closed.
