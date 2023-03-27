--loader script ripped from infinite yield and fixed by knux
--the lag is caused by xml decoding

local replacementscripts = {
  ["Exploring"] = game:HttpGet("https://raw.githubusercontent.com/KnuxTheFixer/dex/main/exploring.lua",true), -- required for dex to work, notable changes are: replacing a http call to an api that no longer exists with a function that does the same thing, fixing nilinstances and runningscripts folders
}

local speedload = false --skip the xml decoding for one premade (may be outdated)

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

local function moveiy(dex) --check if iy in running and move it out of the way
  if Holder then --iy var
    local menu = dex:WaitForChild("SideMenu",math.huge)
    local oldpos = menu.AbsolutePosition.X + menu.AbsoluteSize.X --save the position otherwise it wont retract iy along with it
    local function moveaway()
      local iypos,dexpos = Holder.AbsolutePosition.X + Holder.AbsoluteSize.X, menu.AbsolutePosition.X + menu.AbsoluteSize.X
      if iypos >= oldpos then
        local wsize,iysize = workspace.CurrentCamera.ViewportSize.X,Holder.AbsoluteSize.X
        Holder.Position = UDim2.new(UDim.new(1,math.clamp(dexpos-iysize,1,wsize-iysize)-wsize),Holder.Position.Y)
      end
      oldpos = dexpos
    end
    local function noerror()
      pcall(moveaway)
    end
    menu:GetPropertyChangedSignal("Position"):Connect(noerror)
    Holder:GetPropertyChangedSignal("Position"):Connect(noerror)
    noerror()
  end
end

local function playerlist(dex)
  local enabled = game:GetService("StarterGui"):GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList) --check if we even need to run this
  if enabled then
    local buttons = {dex:WaitForChild("Toggle",math.huge),dex:WaitForChild("SideMenu",math.huge):WaitForChild("Toggle",math.huge)}
    local playerlist = game:GetService("CoreGui"):WaitForChild("PlayerList")
    playerlist.Enabled = false -- set it to false initially since dex opens when ran
    for _,b in pairs(buttons) do
      b.MouseButton1Click:Connect(function()
        playerlist.Enabled = b==buttons[2]
      end)
    end
  end
end

local Dex = getobjects("rbxassetid://10055842438")[1]
Dex.DisplayOrder = 10 --so that other coregui elements don't get drawn over top
Dex.Parent = PARENT
task.spawn(moveiy,Dex) --make iy cmdbar move out of the way
task.spawn(playerlist,Dex) --close the playerlist while open to make it look better

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
    if Script.Name=="Creator" then
      Script.Text = "Created by: <b>Moon</b>\nEdited by: wally, ic3, w a e\nFixed by: Knux"
    end
    if Script.Name=="Version" then
      Script.Text = "Fixed Version"
    end --gotta make sure we know who fixed it
    if Script:IsA("LocalScript") then
      local source = replacementscripts[Script.Name]
      if source then
        pcall(function()
          Script.Source = source
        end)
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
