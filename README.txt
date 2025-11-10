# Inviter3k

Lightweight World of Warcraft addon for creating, managing, and quickly inviting saved groups of BattleTags. Provides an easy GUI, slash commands, and a toggleable minimap button for fast in‑game access.

---

## Features
- Create, rename, and delete named groups  
- Add and remove members from groups (BattleTags)  
- Invite an entire saved group from the GUI or with a slash command  
- Scrollable Groups and Members panes 
- Minimap launcher via LibDataBroker + LibDBIcon  
- Simple, robust slash command interface for quick chat control

---

## Installation
1. Download or receive the zip file.
2. Place the `Inviter3k` folder into your World of Warcraft AddOns directory:
   - Example (Retail): `.../World of Warcraft/_retail_/Interface/AddOns/Inviter3k`  
3. Ensure required libraries are installed and enabled:
   - `LibDataBroker-1.1`  
   - `LibDBIcon-1.0`  
4. Enable the addon in the in‑game AddOns menu or restart the game.  
5. The addon creates saved variables on first load.

---

## Usage

### GUI
- Toggle main window: `/inviter3k` or `/i3k`  
- Left pane — Groups: New, Rename, Delete  
- Right pane — Members: edit box + Add, Remove Selected, Invite Group  
- Select a group on the left to view and manage its members on the right

### Slash commands
- `/inviter3khelp` or `/i3khelp` — Show help and command usage  
- `/inviter3k` or `/i3k` — Toggle the main GUI  
- `/invite3k` or `/i3kinvite` — Invite the currently selected group (when GUI open)  
- `/invite3k <group>` — Invite a specific saved group by name or unique prefix (case-insensitive)  
  - Examples: `/invite3k Raiders`, `/invite3k raid` (if unique)  
- `/i3ktoggle` or `/inviter3ktoggle` — Toggle minimap icon; accepts optional argument: `show` / `hide`  
  - Examples: `/i3ktoggle`, `/i3ktoggle hide`, `/i3ktoggle show`

Notes:
- Running `/invite3k` with no argument will invite the group currently selected in the GUI (if any). If no group is selected and no argument is given, the command lists available groups and usage.  
- Group matching is case-insensitive and accepts unique prefixes. If multiple groups share the same prefix, supply a more specific name or select the group in the GUI.

---

## Examples
- Invite the group named "Raiders":
  - `/invite3k Raiders`  
- Invite the currently selected group in the GUI:
  - `/invite3k`  
- Toggle minimap icon:
  - `/i3ktoggle hide`

---

## Troubleshooting
- Minimap icon missing: verify LibDataBroker and LibDBIcon are installed and enabled.  
- Very long group names can change layout; shorten names or resize the window.

---


## License

MIT License

Copyright (c) 2025 Nicilix

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---
