-- Quality of Lanters, a simple QOL mod for lanterns. It's pretty awesome
-- By Skylarr


-- Fuel PostInits
AddPrefabPostInit("lightbulb", function(inst)
    inst:AddTag("lanternfuel")
end)

AddPrefabPostInit("slurtleslime", function(inst)
    inst:AddTag("lanternfuel")
end)

AddPrefabPostInit("fireflies", function(inst)
    inst:AddTag("lanternfuel")
end)

-- Lantern postinit
AddPrefabPostInit("lantern", function(inst)
    local function OnTick(inst)
        if inst.components.container and inst.components.container:GetItemInSlot(1) then
            local owner = inst.components.inventoryitem.owner

            local fueltogive = inst.components.container:GetItemInSlot(1).components.fuel.fuelvalue
            local currentfuel = inst.components.fueled.currentfuel
            local maxfuel = inst.components.fueled.maxfuel

            if (maxfuel - currentfuel) > fueltogive then
                local fuelitem = inst.components.container:GetItemInSlot(1).components.stackable:Get(1)
                inst.components.fueled:TakeFuelItem(fuelitem, owner)
            end
        end
    end

    local function OnEquip(inst, data)
        local owner = data.owner
        if inst.components.container ~= nil then
            inst.components.container:Open(owner)
        end
    end

    local function OnUnequip(inst, data)
        local owner = data.owner
        if inst.components.container ~= nil then
            inst.components.container:Close(owner)
        end
    end
    
    -- Start Container stuff ---------
    local containers = GLOBAL.require("containers")

    -- local oldwidgetsetup = containers.widgetsetup

    params = containers.params

    -- GLOBAL.containers.widgetsetup = function(container, prefab)
    --     if not prefab and container.inst.prefab == "inv_pons" then
    --         prefab = "backpack"
    --     end
    --     oldwidgetsetup(container, prefab)
    -- end

    params.lantern_inv =
    {
        widget =
        {
            slotpos =
            {
                GLOBAL.Vector3(0,   32 + 4,  0),
            },
            animbank = "ui_cookpot_1x2",
            animbuild = "ui_cookpot_1x2",
            pos = GLOBAL.Vector3(0, 15, 0),
        },
        usespecificslotsforitems = true,
        type = "hand_inv",
    }
    
    function params.lantern_inv.itemtestfn(container, item, slot)
        return item:HasTag("lanternfuel") -- Tag added by this mod, not in vanilla.
    end
    -- End Container -------
    

    if not GLOBAL.TheWorld.ismastersim then
        inst.OnEntityReplicated = function(inst) 
            inst.replica.container:WidgetSetup("lantern_inv") 
        end

        return
    end

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("lantern_inv")
	inst.components.container.canbeopened = false

    inst.tick = inst:DoPeriodicTask(1, OnTick)

    inst:ListenForEvent("equipped", OnEquip)
    inst:ListenForEvent("unequipped", OnUnequip)
    inst:ListenForEvent("itemget", OnTick)
end)