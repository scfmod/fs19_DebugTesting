---@type InspectTable
local InspectTable = DebugUtil.InspectTable

if InspectTable == nil then
    error('inspectorTest > DebugUtil.InspectTable not set, SCFToolkit missing?')
end

local inspectorTest = {}
---@type table<number,Test>
local testList = {}

--------

---@class Test
---@field func
---@field name
---@field sym

--------

inspectorTest.runTestByKey = function(sym)
    for k, test in pairs(testList) do
        if test.sym == sym then
            if type(test.func) ~= 'function' then
                error('Test \'' .. test.name .. '\' does not have a function to run')
            end
            print('-- Running test \'' .. test.name .. '\' | sym: ' .. sym)
            test.func()
        end
    end
end

---@param test Test
inspectorTest.addTest = function(test)
    table.insert(testList, test)
end

--------

local function inspect(name, sym, variable, max_depth)
    inspectorTest.addTest({
        name = name,
        sym = sym,
        func = function()
            local inspection = InspectTable(name, variable)

            local result
            result = inspection:traverse(nil, max_depth)

            if result == false then
                print('----')
                return false
            end
            print('\n-------- INSPECT')
            inspection:print()

            print('----\n')
            return true
        end
    })
end

local function setup()
    inspect('AnimalHusbandry', Input.KEY_1, AnimalHusbandry)
    inspect('Vehicle', Input.KEY_1, AnimalHusbandry)
    inspect('g_farmManager.', Input.KEY_1, g_farmManager)
end

--------

function inspectorTest:update(d) end
function inspectorTest:draw() end
function inspectorTest:deleteMap() end
function inspectorTest:mouseEvent(x, y, isDown, isUp, button) end
function inspectorTest:keyEvent(unicode, sym, modifier, isDown)
    if isDown then
        inspectorTest.runTestByKey(sym)
    end
end
function inspectorTest:loadMap()
    setup()
end

--------

function getOneHusbandryIndex()
    for k,v in pairs(g_currentMission.husbandries) do
        return k
    end
end

inspectorTest.addTest({ name = 'inspect g_currentMission.husbandries[]', sym = Input.KEY_3, func = function()
    local inspector = InspectTable('husbandry', g_currentMission.husbandries[getOneHusbandryIndex()])
    inspector:traverse(nil, 2)
    inspector:print()
    return true
end
})
inspectorTest.addTest({ name = 'g_currentMission.husbandries[]:getMaxNumAnimals', sym = Input.KEY_4, func = function()
    g_currentMission.husbandries[getOneHusbandryIndex()]:getMaxNumAnimals()
    print('getMaxNumAnimals: ' .. tostring(result) .. '\n')
    return true
end
})
inspectorTest.addTest({ name = 'g_currentMission.husbandries[index].modulesById[1].maxNumAnimals', sym = Input.KEY_5, func = function()
    local index = getOneHusbandryIndex()
    g_currentMission.husbandries[index].modulesById[1].maxNumAnimals = 1024
    print('getMaxNumAnimals: ' .. tostring(g_currentMission.husbandries[index]:getMaxNumAnimals()))
    return true
end
})

--------

addModEventListener(inspectorTest)