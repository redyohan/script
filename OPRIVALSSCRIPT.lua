local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

-- Wait for admin check
repeat task.wait() until player:GetAttribute("IsAdmin") ~= nil

if not player:GetAttribute("IsAdmin") then
    return
end

print("Admin powers loaded!")

local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local enabled = false
local flying = false
local BV, BG = nil, nil

--------------------------------------------------------------------
-- FLY FUNCTION
--------------------------------------------------------------------
local function toggleFly()
    if flying then
        flying = false
        if BV then BV:Destroy() end
        if BG then BG:Destroy() end
        character.Humanoid.PlatformStand = false
        return
    end

    flying = true
    character.Humanoid.PlatformStand = true

    BV = Instance.new("BodyVelocity")
    BV.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    BV.Parent = hrp

    BG = Instance.new("BodyGyro")
    BG.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    BG.Parent = hrp

    rs.RenderStepped:Connect(function()
        if flying and BV and BG then
            BG.CFrame = workspace.CurrentCamera.CFrame
            BV.Velocity = workspace.CurrentCamera.CFrame.LookVector * 80
        end
    end)
end

--------------------------------------------------------------------
-- ESP / HIGHLIGHTS
--------------------------------------------------------------------
local espEnabled = false
local highlights = {}

local function toggleESP()
    espEnabled = not espEnabled

    if espEnabled then
        for _,plr in pairs(game.Players:GetPlayers()) do
            if plr ~= player then
                local char = plr.Character
                if char and not highlights[plr] then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.new(1, 0, 0)
                    h.OutlineColor = Color3.new(1,1,1)
                    h.Parent = char
                    highlights[plr] = h
                end
            end
        end
    else
        for p,h in pairs(highlights) do
            h:Destroy()
        end
        highlights = {}
    end
end

--------------------------------------------------------------------
-- TRACERS
--------------------------------------------------------------------
local tracersEnabled = false
local tracerFolder = Instance.new("Folder", workspace)

local function toggleTracers()
    tracersEnabled = not tracersEnabled
    tracerFolder:ClearAllChildren()
end

rs.RenderStepped:Connect(function()
    if tracersEnabled then
        tracerFolder:ClearAllChildren()
        for _,plr in pairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local beam = Instance.new("Beam")
                local a = Instance.new("Attachment", workspace.CurrentCamera)
                local b = Instance.new("Attachment", plr.Character.HumanoidRootPart)
                beam.Attachment0 = a
                beam.Attachment1 = b
                beam.Parent = tracerFolder
            }
        end
    end
end)

--------------------------------------------------------------------
-- AUTO TARGET ASSIST (for your weapons)
--------------------------------------------------------------------
local assistEnabled = false

local function getClosestPlayer()
    local closest, dist = nil, math.huge
    for _,plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos = plr.Character.HumanoidRootPart.Position
            local camPos = workspace.CurrentCamera.CFrame.Position
            local d = (pos - camPos).Magnitude
            if d < dist then
                dist = d
                closest = plr
            end
        end
    end
    return closest
end

rs.RenderStepped:Connect(function()
    if assistEnabled then
        local target = getClosestPlayer()
        if target and target.Character then
            workspace.CurrentCamera.CFrame = CFrame.lookAt(
                workspace.CurrentCamera.CFrame.Position,
                target.Character.HumanoidRootPart.Position
            )
        end
    end
end)

--------------------------------------------------------------------
-- MAIN TOGGLE KEY: M
--------------------------------------------------------------------
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.M then
        enabled = not enabled

        if enabled then
            toggleFly()
            toggleESP()
            toggleTracers()
            assistEnabled = true
        else
            toggleFly()
            toggleESP()
            toggleTracers()
            assistEnabled = false
        end
    end
end)

print("Press M to toggle ALL admin powers.")
