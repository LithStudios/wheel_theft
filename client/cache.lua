local cache = {}

function SaveCache(key, data, lifespan)
    cache[key] = {
        data = data,
        maxAge = GetGameTimer() + (lifespan or 3000),
    }
end

function UseCache(key, cb, lifespan)
    if not cache[key] or cache[key]['maxAge'] < GetGameTimer() then
        local data = {cb()}
        SaveCache(key, data, lifespan)

        return table.unpack(data)
    end

    return table.unpack(cache[key]['data'])
end