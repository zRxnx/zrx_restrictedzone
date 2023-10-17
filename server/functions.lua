Player = {
    HasCooldown = function(player)
        if not Config.Cooldown then return false end
        local identifier = PLAYER_CACHE[player].license

        if COOLDOWN[identifier] then
            if os.time() - Config.Cooldown > COOLDOWN[identifier] then
                COOLDOWN[identifier] = nil
            else
                return true
            end
        else
            COOLDOWN[identifier] = os.time()
        end

        return false
    end
}