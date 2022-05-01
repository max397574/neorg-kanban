# Neorg Kanban

Neorg Kanban is a neorg module that will allow you to display your gtd tasks in kanban-like floating windows.

![kanban](https://user-images.githubusercontent.com/81827001/166137546-a9db04fb-23b0-463c-bfb9-c0ad376aaf82.png)

You can use load this module by putting
```lua
["external.kanban"] = {},
```
into your setup.
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
