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
			local items = {
				{ label = "feat", documentation = "A new feature" },
				{ label = "fix", documentation = "A bug fix" },
			}
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(input, "d") then
			local items = { { label = "docs", documentation = "Documentation only changes" } }
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(input, "s") then
			local items = {
				{
					label = "style",
					documentation = "Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)",
				},
			}
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(input, "r") then
			local items = {
				{ label = "refactor", documentation = "A code change that neither fixes a bug nor adds a feature" },
				{ label = "revert", documentation = "Reverts a previous commit" },
			}
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(input, "p") then
			local items = { { label = "perf", documentation = "A code change that improves performance" } }
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(input, "t") then
			local items = { { label = "test", documentation = "Adding missing tests or correcting existing tests" } }
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(input, "b") then
			local items = {
				{
					label = "build",
					documentation = "Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)",
				},
			}
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(input, "c") then
			local items = {
				{
					label = "ci",
					documentation = "Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)",
				},
				{ label = "chore", documentation = "Other changes that don't modify src or test files" },
			}
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(input, "m") then
			local items = { { label = "merge", documentation = "Merge commits" } }
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
			{ name = "conventionalgc" },
		}),
	})
end

return conventionalgc
