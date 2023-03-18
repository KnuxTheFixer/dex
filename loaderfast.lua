--loader script ripped from infinite yield cuz thats the main reason i made this fix

local replacementscripts = {
  "Exploring" = "https://raw.githubusercontent.com/KnuxTheFixer/dex/main/exploring.lua", -- required for dex to work, notable changes are: replacing a http call to an api that no longer exists with a function that does the same thing, fixing nilinstances and runningscripts folders
}
local speedload = true --skip the xml decoding for one premade (may be outdated)

InsertService = InsertService or game:GetService("InsertService")
PARENT = PARENT or game:GetService("CoreGui")
local getobjects = function(a)
  local Objects = {}
  if a then
    local b = InsertService:LoadLocalAsset(a)
    if b then
      table.insert(Objects, b)
    end
  end
  return Objects
end

local Dex = getobjects("rbxassetid://10055842438")[1]
Dex.Parent = PARENT

local function Load(Obj, Url)
  local function GiveOwnGlobals(Func, Script)
  -- Fix for this edit of dex being poorly made
  -- I (Alex) would like to commemorate whoever added this dex in somehow finding the worst dex to ever exist
  -- I (Knux) would like to commemorate whoever decided making http calls to obscure apis mandatory for making this work
    local Fenv, RealFenv, FenvMt = {}, {
      script = Script,
      speedload = speedload,
      getupvalue = function(a, b)
        return nil -- force it to use globals
      end,
      getreg = function() -- It loops registry for some idiotic reason so stop it from doing that and just use a global
        return {} -- force it to use globals
      end,
      getprops = getprops or function(inst)
        if getproperties then
          local props = getproperties(inst)
          if props[1] and gethiddenproperty then
            local results = {}
            for _,name in pairs(props) do
              local success, res = pcall(gethiddenproperty, inst, name)
              if success then
                results[name] = res
              end
            end
            return results
          end
        return props
        end
      return {}
      end
    }, {}
    FenvMt.__index = function(a,b)
      return RealFenv[b] == nil and getgenv()[b] or RealFenv[b]
    end
    FenvMt.__newindex = function(a, b, c)
      if RealFenv[b] == nil then
        getgenv()[b] = c
      else
        RealFenv[b] = c
      end
    end
    setmetatable(Fenv, FenvMt)
    pcall(setfenv, Func, Fenv)
    return Func
  end
  local function LoadScripts(_, Script)
    if Script:IsA("LocalScript") then
      if Script.Name=="Exploring" then
        Script.Source = readfile("exploring.lua")
      end
      coroutine.wrap(function()
        GiveOwnGlobals(loadstring(Script.Source,"="..Script:GetFullName()), Script)()
      end)()
    end
    table.foreach(Script:GetChildren(), LoadScripts)
  end
  LoadScripts(nil, Obj)
end
Load(Dex)
