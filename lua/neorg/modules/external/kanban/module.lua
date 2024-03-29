require("neorg.modules.base")
local numbers = {
    winnrs = {
        undone = nil,
        done = nil,
        pending = nil,
        uncertain = nil,
        urgent = nil,
        recurring = nil,
        on_hold = nil,
        cancelled = nil,
    },
    bufnrs = {
        undone = nil,
        done = nil,
        pending = nil,
        uncertain = nil,
        urgent = nil,
        recurring = nil,
        on_hold = nil,
        cancelled = nil,
    },
}

local ns = vim.api.nvim_create_namespace("neorg-kanban")

local module = neorg.modules.create("external.kanban")

module.setup = function()
    return {
        success = true,
        requires = {
            "core.neorgcmd",
            "core.gtd.queries",
        },
    }
end

module.private = {
    highlights = {
        ["undone"] = "@neorg.todo_items.undone.1",
        ["done"] = "@neorg.todo_items.done.1",
        ["pending"] = "@neorg.todo_items.pending.1",
        ["cancelled"] = "@neorg.todo_items.cancelled.1",
        ["uncertain"] = "@neorg.todo_items.uncertain.1",
        ["urgent"] = "@neorg.todo_items.urgent.1",
        ["recurring"] = "@neorg.todo_items.recurring.1",
        ["on_hold"] = "@neorg.todo_items.on_hold.1",
    },
    titles = {
        ["undone"] = "Undone",
        ["done"] = "Done",
        ["pending"] = "Pending",
        ["cancelled"] = "Cancelled",
        ["uncertain"] = "Uncertain",
        ["urgent"] = "Urgent",
        ["recurring"] = "Recurring",
        ["on_hold"] = "On Hold",
    },
    is_open = false,
    get_state_tasks = function()
        local tasks_raw = module.required["core.gtd.queries"].get("tasks")
        tasks_raw = module.required["core.gtd.queries"].add_metadata(tasks_raw, "task")
        return module.required["core.gtd.queries"].sort_by("state", tasks_raw)
    end,
    open = function()
        if module.private.is_open then
            return
        end
        local state_tasks = module.private.get_state_tasks()
        local non_empty_states = {}
        for _, state in ipairs(module.config.public.task_states) do
            if state_tasks[state] and state_tasks[state] ~= {} then
                table.insert(non_empty_states, state)
            end
        end
        local width = vim.api.nvim_win_get_width(0)
        local height = vim.api.nvim_win_get_height(0)
        local single_width = math.floor((width - (#non_empty_states * 2)) / #non_empty_states)

        for i, state in ipairs(non_empty_states) do
            numbers.bufnrs[state] = vim.api.nvim_create_buf(false, true)
            local lines = {
                " " .. module.private.titles[state] .. " (" .. #state_tasks[state] .. ")",
            }
            for _, task in ipairs(state_tasks[state] or {}) do
                table.insert(lines, "- " .. task.content)
            end
            vim.keymap.set("n", "q", function()
                module.private.close()
            end, {
                buffer = numbers.bufnrs[state],
            })
            vim.api.nvim_buf_set_lines(numbers.bufnrs[state], 0, -1, false, lines)
            vim.api.nvim_buf_set_option(numbers.bufnrs[state], "modifiable", false)
            vim.api.nvim_open_win(numbers.bufnrs[state], false, {
                relative = "win",
                win = 0,
                width = single_width,
                height = math.floor(height * 0.8),
                col = (single_width + 2) * (i - 1),
                row = math.floor(height * 0.1),
                border = {
                    "╭",
                    "─",
                    "╮",
                    "│",
                    "╯",
                    "─",
                    "╰",
                    "│",
                },

                style = "minimal",
            })
            vim.api.nvim_buf_add_highlight(numbers.bufnrs[state], ns, module.private.highlights[state], 0, 0, -1)
        end
        module.private.is_open = true
    end,
    close = function()
        if not module.private.is_open then
            return
        end
        for _, state in ipairs(module.config.public.task_states) do
            if numbers.winnrs[state] then
                vim.api.nvim_win_close(numbers.winnrs[state], true)
                numbers.winnrs[state] = nil
            end
            if numbers.bufnrs[state] then
                vim.api.nvim_buf_delete(numbers.bufnrs[state], { force = true })
                numbers.bufnrs[state] = nil
            end
        end
        module.private.is_open = false
    end,
    toggle = function()
        if module.private.is_open then
            module.private.close()
        else
            module.private.open()
        end
    end,
}

module.config.public = {
    task_states = {
        "undone",
        "done",
        "pending",
        "cancelled",
        "uncertain",
        "urgent",
        "recurring",
        "on_hold",
    },
}

module.public = {}

module.load = function()
    module.required["core.neorgcmd"].add_commands_from_table({
        kanban = {
            min_args = 1,
            max_args = 1,
            subcommands = {
                toggle = {
                    args = 0,
                    name = "kanban.toggle",
                    callback = module.private.toggle,
                },
                open = {
                    args = 0,
                    name = "kanban.open",
                    callback = module.private.open,
                },
                close = {
                    args = 0,
                    name = "kanban.close",
                    callback = module.private.close,
                },
            },
        },
    })
end

module.on_event = function(event)
    if vim.tbl_contains({ "core.keybinds", "core.neorgcmd" }, event.split_type[1]) then
        if event.split_type[2] == "kanban.toggle" then
            module.private.toggle()
        elseif event.split_type[2] == "kanban.open" then
            module.private.open()
        elseif event.split_type[2] == "kanban.close" then
            module.private.close()
        end
    end
end

module.events.subscribed = {
    ["core.neorgcmd"] = {
        ["kanban.toggle"] = true,
        ["kanban.open"] = true,
        ["kanban.close"] = true,
    },
}

return module
