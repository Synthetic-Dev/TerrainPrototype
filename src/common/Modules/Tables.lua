local TDim = {}

function TDim:size(T)
    local len = 0
    for _ in pairs(T) do
        len = len + 1
    end
    return len
end

function TDim:values(T)
    return coroutine.wrap(function()
        for _, value in next, T do
            coroutine.yield(value)
        end
    end)
end

local TDim2 = {}

function TDim2:size(T)
    local xlen = 0
    local ylen = 0
    for _, value in pairs(T) do
        local iylen = 0
        if typeof(value) == "table" then
            for _ in pairs(value) do
                iylen += 1
            end
        end

        if iylen > ylen then
            ylen = iylen
        end
        xlen += 1
    end
    return xlen, ylen
end

function TDim2:create(a, b, xSize, ySize, fill)
    local T = {}
    for x = a, a + xSize do
        T[x] = {}
        for y = b, b + ySize do
            T[x][y] = fill
        end
    end
    return T
end

function iter2d(T, valuesOnly)
    local startX, startY = math.huge, math.huge

    local xSize, ySize = TDim2:size(T)

    for index in pairs(T) do
        if index < startX then
            startX = index
        end

        local yT = T[index]
        for yIndex in pairs(yT) do
            if yIndex < startY then
                startY = yIndex
            end
        end
    end

    local x, y = startX - 1, startY

    return coroutine.wrap(function()
        while true do
            x += 1

            if x - startX >= xSize then
                x = startX
                y += 1
            end

            if y - startY >= ySize then break end

            local value = T[x]
            if not value or typeof(value) ~= "table" then
                if valuesOnly then
                    coroutine.yield(nil)
                else
                    coroutine.yield(x, y, nil)
                end
            else
                value = value[y]

                if valuesOnly then
                    coroutine.yield(value)
                else
                    coroutine.yield(x, y, value)
                end
            end
        end
    end)
end

function TDim2:values(T)
    return iter2d(T, true)
end 

function TDim2:iter(T)
    return iter2d(T, false)
end

function TDim2:neighbours(T, x, y)
    local startX, startY = x - 1, y - 1
    local centreX, centreY = x, y
    x, y = startX - 1, startY

    return coroutine.wrap(function()
        local index = 0
        while true do
            x += 1
            index += 1

            if x >= startX + 3 then
                x = startX
                y += 1
            end

            if y >= startY + 3 then break end

            if x == centreX and y == centreY then
                index -= 1
                continue
            end

            local value = T[x]
            if not value or typeof(value) ~= "table" then continue end

            value = value[y]
            coroutine.yield(index, value)
        end
    end)
end

return {
    TDim = TDim;
    TDim2 = TDim2;
}