-- Author : Tourahi Amine
-- Object   = require "classic"; -- Remove it from here if its erequired in the main.lua
Bonocles = Object:extend("Bonocles")

function Bonocles:new(options)
	self.active = options.active or false
	self.names = {}
	self.listeners = {}
	self.results = {}
	self.metaInfo = {}
	self.printer = options.customPrinter or false
	self.draw_x = options.draw_x or 0
	self.draw_y = options.draw_y or 0
	self.currentColor = 2
	self.printColor = options.printColor or { 1.0, 1.0, 1.0, 1.0 }
	self.debugToggle = options.debugToggle or "0"
	self.consoleToggle = options.consoleToggle or "f1"
	self.watchedFiles = options.watchedFiles or {}
	self.watchedFilesInfo = {}
	self.colorToggle = options.colorToggle or "f2"
	self.restart = options.restart or false
	self.colorPalette = {
		--[[BLACK]]
		{ 0.0, 0.0, 0.0, 1.0 },
		--[[WHITE]]
		{ 1.0, 1.0, 1.0, 1.0 },
		--[[RED]]
		{ 1.0, 0.0, 0.0, 1.0 },
		--[[BLUE]]
		{ 0.0, 0.0, 1.0, 1.0 },
		--[[GREEN]]
		{ 0.0, 1.0, 0.0, 1.0 },
	}
	self.currentColorIndex = 2
	-- Test to make sure that every given file exists
	for i, file in ipairs(self.watchedFiles) do
		local fileInfo = love.filesystem.getInfo(file, fileInfo)
		assert(fileInfo, file .. " must not exist or is in the wrong directory.")
		self.watchedFilesInfo[i] = fileInfo
	end
end

function Bonocles:keypressed(key)
	if key == self.debugToggle then
		self.active = not self.active
	elseif key == self.consoleToggle then
		self:console()
	elseif key == self.colorToggle then
		self:changeColor()
	end
end

function Bonocles:changeColor()
	local nbrColors = #self.colorPalette
	self.currentColorIndex = self.currentColorIndex + 1
	if self.currentColorIndex > nbrColors then
		self.currentColorIndex = 1
	end
	self.printColor = self.colorPalette[self.currentColorIndex]
end

function Bonocles:print(text, IO, option)
	if self.printer and not IO and not option then
		print("[Bonocles]: " .. text)
	elseif self.printer and option then
		print("[Bonocles Options]: " .. text)
	else
		io.write(text)
	end
end

function Bonocles:watch(name, obj)
	if type(obj) == "function" then
		self:print("Watching : " .. name)
		table.insert(self.listeners, obj)
		table.insert(self.names, name)
	else
		error("Obj to watch is not a function." .. "Hint : wrap the obj in an anonymous function then return the object from it.")
	end
end

function Bonocles:update()
	for key, obj in ipairs(self.listeners) do -- Update Objects
		if type(obj) == "function" then
			self.results[key] = obj() or "Error!"
		end
	end
	for i, file in ipairs(self.watchedFiles) do
		local currentFileInfo = love.filesystem.getInfo(file, currentFileInfo)
		if self.watchedFilesInfo[i].modtime ~= currentFileInfo.modtime then
			self.watchedFilesInfo[i] = currentFileInfo
			self:print("Changed file :" .. file)
			if self.restart then
				love.event.quit("restart")
			else
				love.filesystem.load(file)()
			end
		end
	end
end

function Bonocles:draw()
	if self.active then
		love.graphics.setColor(self.printColor)
		local draw_y = self.draw_y
		local draw_x = self.draw_x
		for nameIndice, result in ipairs(self.results) do
			if type(result) == "number" or type(result) == "string" then
				love.graphics.print(self.names[nameIndice] .. " : " .. result, draw_x, (draw_y + 1) * 15)
			elseif type(result) == "table" then
				love.graphics.print(self.names[nameIndice] .. " : Table:", draw_x, (draw_y + 1) * 15)
				draw_y = draw_y + 1
				for i, v in pairs(result) do
					love.graphics.print("      " .. i .. " : " .. v, draw_x, (draw_y + 1) * 15)
					draw_y = draw_y + 1
				end
			end
			draw_y = draw_y + 1
		end
	end
end

function Bonocles:deconstructGlobal(str)
	if string.find(str, "%.") then
		local global = string.match(str, "(%w+)%.")
		local dot = string.find(str, ".", 1, true)
		local property = string.sub(str, dot + 1)
		return {
			isTable = true,
			global = global,
			property = property,
		}
	else
		return {
			isTable = false,
			global = str,
		}
	end
end

function Bonocles.GlobalHasKey(key)
	return _G[key] ~= nil
end

function Bonocles:console()
	self:print("[a]. Watch a Global.", false, true)
	local choice = io.read("*l")
	if choice == "a" then
		self:print("Global's name : ")
		local global = io.read("*l")
		local deconstructedGlobal = self:deconstructGlobal(global)
		local displayName = global
		local varName = deconstructedGlobal.global
		local Svarname = varName
		if self.GlobalHasKey(varName) then
			local varName = _G[varName]
			if not deconstructedGlobal.isTable then
				Watcher:watch(displayName, function()
					return tostring(_G[Svarname])
				end)
			else
				local property = deconstructedGlobal.property
				Watcher:watch(displayName, function()
					return tostring(varName[tostring(property)])
				end)
			end
		else
			self:print("Global Does not exist.")
		end
	end
end

return Bonocles
