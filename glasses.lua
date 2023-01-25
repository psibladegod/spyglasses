term = require("term")
internet = require("internet")
com = require("component")
gpu = com.gpu
bridge = com.openperipheral_bridge
os.execute("rm -r /home/lib")
os.execute("mkdir /home/lib")
os.execute("wget -f https://pastebin.com/raw/Vwdrd7hi /home/lib/json.lua")

json = require("json")

url = ""

Global = 2
Other = 3

local function GetChunk(startInd, endInd)
   local rangeText = "bytes=" .. tostring(startInd) .. "-" .. tostring(endInd)
   local headers = {
      ['Range'] = rangeText
   }
   local req = internet.request(url, nil, headers, "GET")
   local result = ""
   for line in req do
      result = result .. line
   end
   return result
end

local function GetLengthOnServer()
   local req = internet.request(url)
   os.sleep(0.1)
   local _,_, responseHeaders = req.response()
   local str = responseHeaders["Content-Length"][1]
   return tonumber(str)
end
local function getDate()
   local req = internet.request("https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Moscow")
   local result = ""
   for line in req do
      result = result .. line
   end
   j = json.decode(result)
   local yearStr = j.year
   local monthStr = j.month
   local dayStr = j.day
   if (tonumber(dayStr) <10) then
      dayStr = '0' .. dayStr
   end
   if (tonumber(monthStr)< 10) then
      monthStr = "0" .. monthStr
   end
   return dayStr .. "-" .. monthStr .. "-" .. yearStr
end

local function UpdateUrl()
   url = "https://logs1.shadowcraft.ru/Hitech_public_logs/" .. getDate() .. ".txt"
end

buff = {}

local function addBuff(body)
   for i = 1, 10, 1 do
      if (buff[i] == nil) then
         buff[i] = body;
         return
      end
   end

   for i = 1, 9, 1 do
      buff[i] = buff[i + 1];
   end

   buff[10] = body
end

function mysplit(inputstr, sep)
   if sep == nil then
      sep = "%s"
   end
   local t = {}
   for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
      table.insert(t, str)
   end
   return t
end

function SplitResponse(inputstr)
   local t = {}
   local message = ''
   for i, symbol in pairs(stringToArray(inputstr)) do

      if (symbol =="\n") then
         table.insert(t, message)
         message = ""
      else
         message = message .. symbol
      end
   end
   return t
end

local function DrawOnGlasses(body)
   addBuff(body)
   bridge.clear()
   for i= 1, 10, 1 do
      if (buff[i] == nil) then
         break
      end

      bridge.addText(5, 2 + 10 * i, buff[i], OxFFFFFF)
   end
   bridge.sync()
end

-- Строку в массив делает прикинь
function stringToArray(text)
   t= {}
   text:gsub(".", function(c)
   table.insert(t, c)
   end)
   return t
end

-- Проверяет окрас тхт
function isColored(text)
   for pos, i in pairs(stringToArray(text)) do
      if (i ~= "&")then
         if (i ~= " ")then
            return false
         end
      else
         return true
      end
    end
return true
end

-- Проверяет в глобале ли?
function GetMessageDetails(text)
   local time = text:sub(0, 11)
   local LorG = text:sub(12, 14)
   local messageType = Other
   local playerName = ""
   local messageIndex = 0
   if (LorG == “[L]") then
      messageType = Local
   end
   if (LorG == “[G]") then
      messageType = Global
   end
   
   local whitespaceCount = 0
   local playerNameCalculation = false
   for pos, symbol in pairs(stringToArray(text)) do
      if (symbol == "") then
         playerNameCalculation = false
         whitespaceCount = whitespaceCount + 1
         
         if (messageType == Other) then
            if (whitespaceCount == 1) then
               playerNameCalculation = true
            end
            if (whitespaceCount == 2) then
               return messageType, pos, playerName, time
            end
            
         end
         if (messageType ~= Other) then
            if (whitespaceCount == 2) then
               playerNameCalculation = true
            end
            if (whitespaceCount == 3) then
               return messageType, pos, playerName:sub(1, -2), time
            end
         end
      else
         if(playerNameCalculation) then
            playerName = playerName .. symbol
         end
      end
   end
end

   --pastelimit
   
   -- делит строку на части
function split(str,pat)
      local t = {}
      local fpat = "(.-)" .. pat
      local last_end = 1
      local s, e, cap = str:find(fpat, 1)
      while do
         if s ~=1 or cap ~="" then
            table.insert(t,cap)
         end
         last_end = e + 1
         s, e, cap = str:find(fpat,last_end)
      end
      if (last_end == cap) then
         cap = str:sub(last_end)
         table.insert(t, cup)
      end
      return t
end


-- Устанавливает цвет шрифта от зависимости паттернов

function SetColor(num)
   if (num == "0") then
      gpu.setForeground(0x333333)
   end
   if (num == "1") then
      gpu.setForeground(0x000099)
   end
   if (num == "2") then
      gpu.setForeground(0x006600)
   end
   if (num == "3") then
      gpu.setForeground(0x006666)
   end
   if (num == "4") then
      gpu.setForeground(0x660000)
   end
   if (num == "5") then
      gpu.setForeground(0x660066)
   end
   if (num == "6") then
      gpu.setForeground(0xFF8000)
   end
   if (num == "7") then
      gpu.setForeground(0xA0A0A0)
   end
   if (num == "8") then
      gpu.setForeground(0x404040)
   end
   if (num == "9") then
      gpu.setForeground(0x3399FF)
   end
   if (num == "a") then
      gpu.setForeground(0x99FF33)
   end
   if (num == "b") then
      gpu.setForeground(0x00FFFF)
   end
   if (num == "c") then
      gpu.setForeground(0xFF3333)
   end
   if (num == "d") then
      gpu.setForeground(0xFF00FF)
   end
   if (num == "e") then
      gpu.setForeground(0xFFFF00)
   end
   if (num == "f") then
      gpu.setForeground(0xFFFFFF)
   end
end

 -- Выводит сообщение
 function WriteMessage(text)
    -- local t = split(text,"&")
    local t = mysplit(text,"&")
    for pos, i in pairs(t) do
       if (pos == 1 and not isColored(text)) then
          io.write(i)
       else
          SetColor(string.sub(i, 1, 1))
          io.write(string.sub(i, 2))
       end
    end
 end

-- Выводит остальную часть сообщения

function PrintMessageOnMonitor(playerName, msg, messageType, pos, time)
   local type = ""
   msg = string.sub(msg, pos + 1)
   gpu. setForeground(OxOOFFFF)
   io.write(time)
   gpu.setForeground(OxFFFFFF)
   if (messageType == Other) then
      gpu.setForeground(OxFF0000)
   else
      if (messageType == Local) then
         gpu.setForeground(OxFFFFFF)
         io.write(“[L] “)
      else
         msg = msg:sub(2)
         gpu.setForeground(OxFF9933)
         io.write(“[G] “)
      end
   end
   gpu.setForeground(Ox00FFO0)
   io.write(playerName)
   gpu.setForeground(OxFFFFFF)
   io.write:(": ")
   WriteMessage(msg)
   io.write("\n")
end


function PrintOnMonitor(fullMessage)
   local messageType, pos, playerName, time = GetMessageDetails(fullMessage)
   PrintMessageOnMonitor(playerName, fullMessage, messageType, pos, time)
end

UpdateUrl()
PreuLength = GetLengthOnServer()
Counter = 101
local function MainLoop()
   if (Counter > 100) then
      UpdateUrl()
      Counter = 0
   end
Counter = Counter + 1
local currentLength = GetLengthOnServer()
   if (currentLength ~= PrevLength) then
      local begTenp = PrevLength
      PrevLength = currentLength
      local data = GetChunk(begTenp, currentLength)
      
      local messages = SplitResponse(data)
      
      for i, message in pairs(messages) do
         DrawOnGlasses(message)
         PrintOnMonitor(message)
      end
   end
end

term.clear()
while (1) do
   os.sleep(0.1)
   pcall(MainLoop)
   --MainLoop()
end






















