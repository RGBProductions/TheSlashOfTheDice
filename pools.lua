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

function GetPoolByID(id)
    if id == 0 then
        return Pools.Legacy
    end
    if id == 1 then
        return Pools.Even
    end
    if id == 2 then
        return Pools.Legacy -- Placeholder: Real pools are dynamically generated
    end
    if id == 3 then
        return Pools.Unfair -- pain
    end
    if id == 4 then
        return Pools.Blessed -- Secret Mode
    end
end