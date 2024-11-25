-- Custom nvim-cmp source for Conventional Commits.

local conventionalgc = {}

local registered = false

conventionalgc.setup = function()
	if registered then
		return
	end
	registered = true

	local has_cmp, cmp = pcall(require, "cmp")

	if not has_cmp then
		return
	end

	local source = {}

	source.new = function()
		return setmetatable({}, { __index = source })
	end

	source.get_trigger_characters = function()
		return { "f", "d", "s", "r", "p", "t", "b", "c", "m" }
	end

	source.get_keyword_pattern = function()
		-- Add dot to existing keyword characters (\k).
		return [[\%(\k\|\.\)\+]]
	end

	source.complete = function(self, request, callback)
		--[[ local input = string.sub(request.context.cursor_before_line, request.offset - 1)
    local prefix = string.sub(request.context.cursor_before_line, 1, request.offset - 1) ]]
		local input = string.sub(request.context.cursor_before_line, request.offset - 1)

		if vim.startswith(input, "f") then
			local items = { { label = "feat" }, { label = "fix" } }
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(input, "d") then
			local items = { { label = "docs" } }
			callback({
				items = items,
				isIncomplete = true,
			})
		else
			callback({ isIncomplete = true })
		end
	end

	cmp.register_source("conventionalgc", source.new())

	cmp.setup.filetype("gitcommit", {
		sources = cmp.config.sources({
			{ name = "luasnip" },
			{ name = "path" },
			{ name = "nvim_lsp" },
			{ name = "conventionalgc" },
		}),
	})
end

return conventionalgc
