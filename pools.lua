-- Used for all dice weighing modes except Situational, which needs special code
Pools = {
    -- The way dice were handled in the jam version
    Legacy = {
        Operators = {"add","add","add","add", "mul","mul","mul", "sub", "div"},
        Die = {1,2,3,4,5,6}
    },
    -- All outcomes are equally likely
    Even = {
        Operators = {"add","mul","sub","div"},
        Die = {1,2,3,4,5,6}
    },
    -- Negative outcomes are more common
    Unfair = {
        Operators = {"sub","sub","sub","sub", "div","div","div", "add", "mul"},
        Die = {1,1,1,1,1,2,2,2,2,3,3,3,3,4,5,6}
    },
    -- No negative outcomes
    Blessed = {
        Operators = {"add", "mul"},
        Die = {4,5,6}
    }
}

PoolIDs = {
    [0] = Pools.Legacy,
    [1] = Pools.Even,
    [3] = Pools.Unfair,
    [4] = Pools.Blessed
}

function GetPoolByID(id)
    if id == 2 then
        local Stats = player:get("stats")
        local die = {}
        -- Calculate Total Statistic Score
        local statscore = math.max(0,math.min(1,(Stats["Attack"]/150)*0.4 + (Stats["Defense"]/150)*0.4 + (Stats["Luck"]/90)*0.2))
        local istatscore = 1-statscore
        for n = 1, istatscore*8 do
            table.insert(die, 6)
        end
        for n = 1, istatscore*6 do
            table.insert(die, 5)
        end
        for n = 1, istatscore*4 do
            table.insert(die, 4)
        end
        for n = 1, statscore*8 do
            table.insert(die, 1)
        end
        for n = 1, statscore*6 do
            table.insert(die, 2)
        end
        for n = 1, statscore*4 do
            table.insert(die, 3)
        end

        local ops = {"add","mul","sub","div"}
        for n = 1, istatscore*16 do
            table.insert(ops, "add")
        end
        for n = 1, istatscore*10 do
            table.insert(ops, "mul")
        end
        for n = 1, statscore*10 do
            table.insert(ops, "sub")
        end
        for n = 1, statscore*7 do
            table.insert(ops, "div")
        end

        return {Die = die, Operators = ops}
    end
    return PoolIDs[id]
end