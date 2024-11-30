-- Custom nvim-cmp source for Conventional Commits.

local conventionalgc = {}

local registered = false

local find_git_root = function()
	local git_dir = vim.fn.finddir(".git", ".;")
	if git_dir == "" then
		return ""
	else
		return vim.fn.fnamemodify(git_dir, ":h:h")
	end
end

local find_file_in_git_repo = function()
	local git_root = find_git_root()
	if not git_root then
		print("No Git repo found")
		return ""
	end

	local pattern = string.format("%s/**/%s*.%s", git_root, "git-scopes", "json")
	local founded_files = vim.fn.glob(pattern, true, true)
	if #founded_files <= 0 then
		print("No git-scopes.json file found")
		return ""
	else
		return founded_files[1]
	end
end

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
		return { "f", "d", "s", "r", "p", "t", "b", "c", "m", "(", "!" }
	end

	source.get_keyword_pattern = function()
		-- Add dot to existing keyword characters (\k).
		return [[\%(\k\|\.\)\+]]
	end

	source.complete = function(self, request, callback)
		--[[ local input = string.sub(request.context.cursor_before_line, request.offset - 1)
		local col = request.context.cursor.col
		local previous_charater = input:sub(col - 1, col - 1) ]]
		local full_line = request.context.cursor_before_line
		local should_complete = false
		local first_char = full_line:sub(1, 1)
		local activate_chars =
			{ f = true, d = true, s = true, r = true, p = true, t = true, b = true, c = true, m = true }
		if activate_chars[first_char] then
			should_complete = true
		end

		local col = request.context.cursor.col
		local previous_charater = full_line:sub(col - 1, col - 1)
		if previous_charater == "(" then
			should_complete = true
		elseif previous_charater == "!" then
			vim.notify = require("notify")
			vim.notify("Add 'BREAKING-CHANGES: <explanition>' to the footer.", vim.log.levels.WARN, {
				title = "BREAKING CHANGES indicator founded" --[[ , render = "wrapped-compact" ]],
			})
		end
		if not should_complete then
			callback({ isIncomplete = true })
		end

		if previous_charater == "(" then
			local git_scopes_file = vim.fn.expand(find_file_in_git_repo())
			if vim.fn.filereadable(git_scopes_file) == 0 then
				return
			end
			local scopes = vim.fn.json_decode(vim.fn.readfile(git_scopes_file))
			local items = {}
			for _, scope in ipairs(scopes) do
				table.insert(items, { label = scope, documentation = "Git repo scope." })
			end
			callback({ items = items, isIncomplete = true })
		elseif vim.startswith(full_line, "f") then
			local items = {
				{ label = "feat", documentation = "A new feature" },
				{ label = "fix", documentation = "A bug fix" },
			}
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(full_line, "d") then
			local items = { { label = "docs", documentation = "Documentation only changes" } }
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(full_line, "s") then
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
		elseif vim.startswith(full_line, "r") then
			local items = {
				{ label = "refactor", documentation = "A code change that neither fixes a bug nor adds a feature" },
				{ label = "revert", documentation = "Reverts a previous commit" },
			}
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(full_line, "p") then
			local items = { { label = "perf", documentation = "A code change that improves performance" } }
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(full_line, "t") then
			local items = { { label = "test", documentation = "Adding missing tests or correcting existing tests" } }
			callback({
				items = items,
				isIncomplete = true,
			})
		elseif vim.startswith(full_line, "b") then
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
		elseif vim.startswith(full_line, "c") then
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
		elseif vim.startswith(full_line, "m") then
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
