# Neorg Kanban

## This currently doesn't work since the gtd module is being reworked

Neorg Kanban is a neorg module that will allow you to display your gtd tasks in kanban-like floating windows.

![kanban](https://user-images.githubusercontent.com/81827001/166137546-a9db04fb-23b0-463c-bfb9-c0ad376aaf82.png)

## 📦 Setup
You can use load this module by putting
```lua
["external.kanban"] = {},
```
into your setup.

## 🔧 Configuration
You can configure which types of tasks to display with the `task_states` field in the config.

The default values look like this:
```lua
{
    task_states = {
        "undone",
        "done",
        "pending",
        "cancelled",
        "uncertain",
        "urgent",
        "recurring",
        "on_hold",
    }
}
```

## ⚙ Usage
This module provides three commands:
- `Neorg kanban open`
- `Neorg kanban close`
- `Neorg kanban toggle`

They allow you to open, close and toggle the kanban board.
