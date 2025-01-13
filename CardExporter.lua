--- STEAMODDED HEADER
--- MOD_NAME: Card Exporter
--- MOD_ID: CardExporter
--- MOD_AUTHOR: [elbe]
--- MOD_DESCRIPTION: Exports cards for external use
--- PRIORITY: 0

----------------------------------------------
------------MOD CODE -------------------------

SMODS.load_file("Mods/CardExporter/ca.lua")() --third party json library
local json = require "json"

local output_root = "output/"
local copy_command = 'xcopy "Mods\\CardExporter\\Template" "' .. output_root .. '" /Y /S /I'
local output_images = true
local output_on_hover = false

local sets = {}
sets["Joker"] = {}
sets["Consumables"] = {}
sets["Back"] = {}
sets["Seal"] = {}
sets["Voucher"] = {}
sets["Stake"] = {}
sets["Sleeve"] = {}
sets["Skill"] = {}
sets["Tag"] = {}
sets["Edition"] = {}
sets["Enhanced"] = {}
sets["Booster"] = {}
sets["Curse"] = {}
sets["Contract"] = {}
sets["Blind"] = {}
sets["D6 Side"] = {}
sets["Sticker"] = {}
sets["Mods"] = {}
sets["PlayingCards"] = {}
sets["Suit"] = {}

local function copy_template()
    os.execute(copy_command)
end

local function convert_to_hex(colour_table)
    if not colour_table then return end
    local colour = "#" ..
        string.format("%02x", colour_table[1] * 255) ..
        string.format("%02x", colour_table[2] * 255) ..
        string.format("%02x", colour_table[3] * 255)
    return colour
end

local function output_image(card)
    if not card.atlas and card.set then
        card.atlas = card.set
    end
    if output_images and G.ASSET_ATLAS and G.ASSET_ATLAS[card.atlas] and not G.ASSET_ATLAS[card.atlas].image_data then
        for _,v in ipairs(G.asset_atli) do
            if v.name == card.set then
                local sprite_path = v.path
                G.ASSET_ATLAS[card.atlas].image_data = love.image.newImageData(sprite_path)
            end
        end
    end
    if output_images and G.ASSET_ATLAS and G.ASSET_ATLAS[card.atlas] and G.ASSET_ATLAS[card.atlas].image_data then
        local file_path = output_root .. "images/" .. card.key:gsub("?", "_") .. ".png"
        local w = (G.ASSET_ATLAS[card.atlas].px * G.SETTINGS.GRAPHICS.texture_scaling)
        local h = (G.ASSET_ATLAS[card.atlas].py * G.SETTINGS.GRAPHICS.texture_scaling)
        local newImageData = love.image.newImageData(w, h)
        local newImageDataSoul = nil
        local newImageDataExtra = nil

        local canvas = love.graphics.newCanvas(w, h, {type = '2d', readable = true})
        newImageData:paste(G.ASSET_ATLAS[card.atlas].image_data, 0, 0, card.pos.x * w, card.pos.y * h, w, h)
        if card.soul_pos then
            if card.soul_pos.extra then
                newImageDataExtra = love.image.newImageData(w, h)
                newImageDataExtra:paste(G.ASSET_ATLAS[card.atlas].image_data, 0, 0, card.soul_pos.extra.x * w, card.soul_pos.extra.y * h, w, h)
            end
            newImageDataSoul = love.image.newImageData(w, h)
            newImageDataSoul:paste(G.ASSET_ATLAS[card.atlas].image_data, 0, 0, card.soul_pos.x * w, card.soul_pos.y * h, w, h)
        end

        love.graphics.push()
        local prevcanvas = love.graphics.getCanvas()
        love.graphics.setColor( 255, 255, 255, 255 )
        canvas = love.graphics.newCanvas(w, h)
        love.graphics.setCanvas( canvas)
        love.graphics.draw(love.graphics.newImage(newImageData),0,0)
        if newImageDataSoul then
            if newImageDataExtra then
                love.graphics.draw(love.graphics.newImage(newImageDataExtra), 0,0)
            end
            love.graphics.draw(love.graphics.newImage(newImageDataSoul), 0,0)
        end
        love.graphics.setCanvas( prevcanvas )
        newImageData = canvas:newImageData( )
        love.graphics.pop()

        if love.filesystem.exists(file_path) then
            love.filesystem.remove(file_path)
        end
        newImageData:encode("png", file_path)
    end
end

local function output_rendered_image(card)
    local file_path = output_root .. "images/" .. card.config.center.key:gsub("?", "_") .. ".png"
    local w = 71 * G.SETTINGS.GRAPHICS.texture_scaling
    local h = 95 * G.SETTINGS.GRAPHICS.texture_scaling

    local canvas = love.graphics.newCanvas(w, h, {type = '2d', readable = true})
    love.graphics.push()
    local oldCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas( canvas )

    love.graphics.clear(0,0,0,0)
    love.graphics.setColor(1, 1, 1, 1)

    if card.edition and card.edition.type and G.SHADERS[card.edition.type]  then
        love.graphics.setShader(G.SHADERS[card.edition.type])
    else
        if card.edition then
            local edition_key = card.edition.key
            if edition_key and SMODS.Centers[edition_key] and G.SHADERS[SMODS.Centers[edition_key].shader] then
                love.graphics.setShader(G.SHADERS[SMODS.Centers[edition_key].shader])
            end
        end
    end
    love.graphics.draw(
        card.children.center.atlas.image,
        card.children.center.sprite,
        0,0,0,2,2
    )

    love.graphics.setShader()
    love.graphics.setCanvas(oldCanvas)
    love.graphics.pop()

    if love.filesystem.exists(file_path) then
        love.filesystem.remove(file_path)
    end
    canvas:newImageData():encode('png', file_path)
end

local function output_image_2(card)
    if not card.atlas and card.set then
        card.atlas = card.set
    end
    if G.ASSET_ATLAS and G.ASSET_ATLAS[card.atlas] and not G.ASSET_ATLAS[card.atlas].image_data then
        for _,j in ipairs(G.asset_atli) do
            if j.name == card.set then
                local sprite_path = j.path
                G.ASSET_ATLAS[card.atlas].image_data = love.image.newImageData(sprite_path)
            end
        end
    end
    print(tostring(G.ASSET_ATLAS[card.atlas]))
    print(tostring(G.ASSET_ATLAS[card.atlas].image_data))
    if G.ASSET_ATLAS and G.ASSET_ATLAS[card.atlas] and G.ASSET_ATLAS[card.atlas].image_data then
        local file_path = output_root .. "images/" .. card.config.center.key:gsub("?", "_") .. ".png"
        local w = (G.ASSET_ATLAS[card.atlas].px * G.SETTINGS.GRAPHICS.texture_scaling)
        local h = (G.ASSET_ATLAS[card.atlas].py * G.SETTINGS.GRAPHICS.texture_scaling)
        local newImageData = love.image.newImageData(w, h)
        local newImageDataSoul = nil
        local newImageDataExtra = nil

        local canvas = love.graphics.newCanvas(w, h, {type = '2d', readable = true})
        newImageData:paste(G.ASSET_ATLAS[card.atlas].image_data, 0, 0, card.pos.x * w, card.pos.y * h, w, h)
        if card.soul_pos then
            newImageDataSoul = love.image.newImageData(w, h)
            newImageDataSoul:paste(G.ASSET_ATLAS[card.atlas].image_data, 0, 0, card.soul_pos.x * w, card.soul_pos.y * h, w, h)
            if card.soul_pos.extra then
                newImageDataExtra = love.image.newImageData(w, h)
                newImageDataExtra:paste(G.ASSET_ATLAS[card.atlas].image_data, 0, 0, card.soul_pos.extra.x * w, card.soul_pos.extra.y * h, w, h)
            end
        end

        love.graphics.push()
        local prevcanvas = love.graphics.getCanvas()
        love.graphics.setColor( 255, 255, 255, 255 )
        canvas = love.graphics.newCanvas(w, h)
        love.graphics.setCanvas( canvas)
           love.graphics.draw(love.graphics.newImage(newImageData),0,0)
        if newImageDataSoul then
            love.graphics.draw(love.graphics.newImage(newImageDataSoul), 0,0)
            if newImageDataExtra then
                love.graphics.draw(love.graphics.newImage(newImageDataExtra), 0,0)
            end
        end
        love.graphics.setCanvas( prevcanvas )
        newImageData = canvas:newImageData( )
        love.graphics.pop()

        if love.filesystem.exists(file_path) then
            love.filesystem.remove(file_path)
        end
        newImageData:encode("png", file_path)
    end
end

local function CheckForOverride(image_path)
    local image_path_gif = image_path:gsub(".png", "_override.gif")
    local image_path_png = image_path:gsub(".png", "_override.png")
    if love.filesystem.exists(output_root .. image_path_gif) then
        return image_path_gif
    elseif love.filesystem.exists(output_root .. image_path_png) then
        return image_path_png
    else
        return image_path
    end
end

local function get_name_from_table(table)
    local name = ""
    for i,_ in ipairs(table)do
        if table[i].config.object then
            for _,t2 in ipairs(table[i].config.object.strings) do
                name = name .. tostring(t2.string)
            end
        else
            name = name .. tostring(table[i].config.text)
        end
    end
    return name
end

local function get_desc_from_table(desc_table)
    local desc = {}
    local phrase = {}
    for i,_ in ipairs(desc_table)do
        local line = {}
        for i2,_ in ipairs(desc_table[i]) do
            phrase = {}
            if desc_table[i][i2].nodes then
                phrase["text"] = tostring(desc_table[i][i2].nodes[1].config.text)
                phrase["colour"] = convert_to_hex(desc_table[i][i2].nodes[1].config.colour)
                phrase["background_colour"] = convert_to_hex(desc_table[i][i2].config.colour)
            else
                phrase["text"] = tostring(desc_table[i][i2].config.text)
                phrase["colour"] = convert_to_hex(desc_table[i][i2].config.colour)
            end
            table.insert(line, phrase)
        end
        table.insert(desc, line)
    end
    return desc
end

local function check_for_tags(card)
    local tags = {}
    ---- chcek for chips
    if ((type(card.ability.chips) == "number") and (card.ability.chips > 0)) or
       ((type(card.ability.t_chips) == "number") and (card.ability.t_chips > 0)) then
            table.insert(tags,"chips")
    end
    if not (card.ability.extra == nil) and (type(card.ability.extra) == "table") and
        ((type(card.ability.extra.current_chips) == "number")  and (card.ability.extra.current_chips > 0) or
        ((type(card.ability.extra.chips) == "number")  and (card.ability.extra.chips > 0))) then
            table.insert(tags,"chips")
    end
    ---- check for mult
    if ((type(card.ability.mult) == "number") and (card.ability.mult > 0)) or
       ((type(card.ability.t_mult) == "number") and (card.ability.t_mult > 0)) then
            table.insert(tags,"mult")
    end
    if not (card.ability.extra == nil) and (type(card.ability.extra) == "table") and
        ((type(card.ability.extra.s_mult) == "number")  and (card.ability.extra.s_mult > 0) or
        ((type(card.ability.extra.mult) == "number")  and (card.ability.extra.mult > 0))) then
            table.insert(tags,"mult")
    end
    ---- check for xmult
    if  ((type(card.ability.Xmult) == "number") and (card.ability.Xmult > 1)) or
        ((type(card.ability.xmult) == "number") and (card.ability.xmult > 1)) or
        ((type(card.ability.x_mult) == "number") and (card.ability.x_mult > 1)) then
            table.insert(tags,"xmult")
    end
    if not (card.ability.extra == nil) and (type(card.ability.extra) == "table") and
        (((type(card.ability.extra.Xmult) == "number")  and (card.ability.extra.Xmult > 0)) or
        ((type(card.ability.extra.xmult) == "number")  and (card.ability.extra.xmult > 0)) or
        ((type(card.ability.extra.x_mult) == "number")  and (card.ability.extra.x_mult > 0))) then
            table.insert(tags,"xmult")
    end
    ---- check for xchips
    if not (card.ability.extra == nil) and (type(card.ability.extra) == "table") and
        (((type(card.ability.extra.xchips) == "number")  and (card.ability.extra.xchips > 0)) or
        ((type(card.ability.extra.X_chips) == "number")  and (card.ability.extra.X_chips > 0)) or
        ((type(card.ability.extra.x_chips) == "number")  and (card.ability.extra.x_chips > 0))) then
            table.insert(tags,"xchips")
    end

    return tags
end

local function process_joker(card, center)
    local item = {}
    local badges = {}
    local custom_rarity = ""
    if card.ability_UIBox_table then
        item.name = get_name_from_table(card.ability_UIBox_table.name)
        item.description = get_desc_from_table(card.ability_UIBox_table.main)
        if center.set_card_type_badge then
            center:set_card_type_badge(card, badges)
        end
    end
    if  badges[1] and 
        badges[1].nodes[1] and 
        badges[1].nodes[1].nodes[2] and 
        badges[1].nodes[1].nodes[2].config.object.config.string and 
        badges[1].nodes[1].nodes[2].config.object.config.string[1] then
        custom_rarity = badges[1].nodes[1].nodes[2].config.object.config.string[1]
    end
    item.rarity = ({localize('k_common'), localize('k_uncommon'), localize('k_rare'), localize('k_legendary'), localize('k_fusion'),
        ['cry_epic'] = 'Epic', ['cry_exotic'] = 'Exotic', ['cere_divine'] = 'Divine', ['evo'] = 'Evolved', ['poke_safari'] = 'Safari'})[center.rarity]
    if custom_rarity ~= "" then
        item.rarity = custom_rarity
    end
    item.key = center.key
    item.set = center.set
    if center.mod and center.mod.id ~= "Aura" and center.mod.id ~= "aure_spectral" then
        item.mod = center.mod.id
    end
    item.tags = check_for_tags(card)
    item.image_url = CheckForOverride("images/" .. center.key:gsub("?", "_") .. ".png")
    if item.name then
        sets["Joker"][item.key] = item
    end
end

local function process_consumable(card, center)
    local set_name = G.localization.misc.dictionary[center.set] or center.set
    set_name = set_name:gsub(" ","_")
    if not sets["Consumables"][set_name] then
        sets["Consumables"][set_name] = {}
    end
    if not sets["Consumables"][set_name][center.key] then
        local item = {}
        if card.ability_UIBox_table then
            item.name = get_name_from_table(card.ability_UIBox_table.name)
            item.description = get_desc_from_table(card.ability_UIBox_table.main)
        end
        item.key = center.key
        item.set = center.set:gsub(" ","_")
        if center.mod and center.mod.id ~= "Aura" and center.mod.id ~= "aure_spectral" then
            item.mod = center.mod.id
        end
        item.tags = {}
        item.image_url = CheckForOverride("images/" .. center.key:gsub("?", "_") .. ".png")
        if item.name then
            sets["Consumables"][set_name][item.key] = item
        end
    end
end

local function process_other(card, center)
    local item = {}
    if card.ability_UIBox_table then
        item.name = get_name_from_table(card.ability_UIBox_table.name)
        item.description = get_desc_from_table(card.ability_UIBox_table.main)
    end
    item.key = center.key
    item.set = center.set
    if center.mod and center.mod.id ~= "Aura" and center.mod.id ~= "aure_spectral" then
        item.mod = center.mod.id
    end
    item.tags = {}
    item.image_url = CheckForOverride("images/" .. center.key:gsub("?", "_") .. ".png")
    if item.name then
        sets[item.set][item.key] = item
    end
end

local function process_playing_card(card, center, key)
    local item = {}
    center.key = key
    center.atlas = center.lc_atlas
    output_image(center)
    if not sets["PlayingCards"][center.suit] then
        sets["PlayingCards"][center.suit] = {}
    end
    if card.ability_UIBox_table then
        item.name = get_name_from_table(card.ability_UIBox_table.name)
        item.description = get_desc_from_table(card.ability_UIBox_table.main)
    end
    item.key = key
    item.set = center.suit
    if center.mod and center.mod.id ~= "Aura" and center.mod.id ~= "aure_spectral" then
        item.mod = center.mod.id
    end
    item.tags = {}
    item.image_url = CheckForOverride("images/" .. key:gsub("?", "_") .. ".png")
    if item.name then
        sets["PlayingCards"][item.set][item.key] = item
    end
end

local function process_card(card)
    local center = card.config.center
    output_image(center)
    if center.object_type == "Consumable" or center.consumable == true or center.consumeable == true or (center.type and center.type.atlas == "ConsumableType") then
        process_consumable(card, center)
    else
        if not sets[center.set] then
            sets[center.set] = {}
        end
        if not sets[center.set][center.key] then
            if center.set == "Joker" then
                process_joker(card, center)
            elseif center.set == "Skill" then
                process_other(card, center)
            else
                process_other(card, center)
            end
        end
    end
end

local function process_blind(blind)
    local item = {}
    output_image(blind)
    if not sets["Blind"] then
        sets["Blind"] = {}
    end
    if not sets["Blind"][blind.key] then
        item.key = blind.key
        item.name = localize{type ='name_text', key = blind.key, set = 'Blind'}

        local loc_vars = nil
        if item.name == 'The Ox' then
            loc_vars = {localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands')}
        end
        if blind.loc_vars and type(blind.loc_vars) == 'function' then
            local res = blind:loc_vars() or {}
            loc_vars = res.vars or {}
        end
        item.description = localize{type = 'raw_descriptions', key = blind.key, set = 'Blind', vars = loc_vars or blind.vars}

        if blind.mod and blind.mod.id ~= "Aura" and blind.mod.id ~= "aure_spectral" then
            item.mod = blind.mod.id
        end
        item.tags = {}
        item.image_url = CheckForOverride("images/" .. blind.key:gsub("?", "_") .. ".png")
        if item.name then
            sets["Blind"][item.key] = item
        end
    end
end

local function process_curse(curse)
    local item = {}
    output_image(curse)
    if not sets["Curse"] then
        sets["Curse"] = {}
    end
    if not sets["Curse"][curse.key] then
        item.key = curse.key
        item.name = get_name_from_table(localize{type = 'name', set = curse.set, key = curse.key, nodes = {}})
        local loc_vars = nil
        if item.name == 'The Ox' then
            loc_vars = {localize(G.GAME.current_round.most_played_poker_hand, 'poker_hands')}
        end
        if curse.loc_vars and type(curse.loc_vars) == 'function' then
            local res = curse:loc_vars() or {}
            loc_vars = res.vars or {}
        end
        item.description = localize{type = 'descriptions', key = curse.key, set = curse.set, vars = loc_vars or {}, nodes = {}}
        if curse.mod and curse.mod.id ~= "Aura" and curse.mod.id ~= "aure_spectral" then
            item.mod = curse.mod.id
        else
            item.mod = "JeffDeluxeConsumablesPack"
        end
        item.tags = {}
        item.image_url = CheckForOverride("images/" .. curse.key:gsub("?", "_") .. ".png")
        if item.name then
            sets["Curse"][item.key] = item
        end
    end
end

local function process_d6_side(d6_side)
    local item = {}
    output_image(d6_side)
    if not sets["D6 Side"] then
        sets["D6 Side"] = {}
    end
    if not sets["D6 Side"][d6_side.key] then
        item.key = d6_side.key
        local loc_vars = nil
        local dummy_d6_side = {
            key = d6_side.key,
            extra = copy_table(d6_side.config),
            edition = nil,
        }
        if d6_side.loc_vars and type(d6_side.loc_vars) == "function" then loc_vars = d6_side:loc_vars({}, nil, dummy_d6_side) end
        item.name = localize{type = 'name_text', key = d6_side.key, set = 'Other'}
        item.description = localize{type = 'raw_descriptions', key = d6_side.key, set = 'Other', vars = loc_vars and loc_vars.vars or nil}
        if d6_side.mod and d6_side.mod.id ~= "Aura" and d6_side.mod.id ~= "aure_spectral" then
            item.mod = d6_side.mod.id
        end
        item.tags = {}
        item.image_url = CheckForOverride("images/" .. d6_side.key:gsub("?", "_") .. ".png")
        if item.name then
            sets["D6 Side"][item.key] = item
        end
    end
end

local function process_edition(card)
    local item = {}
    local center = card.config.center
    output_rendered_image(card)
    if card.ability_UIBox_table then
       item.name = get_name_from_table(card.ability_UIBox_table.name)
       item.description = get_desc_from_table(card.ability_UIBox_table.main)
    end
    item.key = center.key
    item.set = center.set
    if center.mod and center.mod.id ~= "Aura" and center.mod.id ~= "aure_spectral" then
        item.mod = center.mod.id
    end
    item.tags = {}
    item.image_url = CheckForOverride("images/" .. center.key:gsub("?", "_") .. ".png")
    if item.name then
        sets[item.set][item.key] = item
    end
end

local function process_enhancement(card)
    local item = {}
    local center = card.config.center    
    output_image(center)
    if card.ability_UIBox_table then
        item.name = localize{type = 'name_text', key = center.key, set = center.set}
        item.description = get_desc_from_table(card.ability_UIBox_table.main)
    end
    item.key = center.key
    item.set = center.set
    if center.mod and center.mod.id ~= "Aura" and center.mod.id ~= "aure_spectral" then
        item.mod = center.mod.id
    end
    item.tags = {}
    item.image_url = CheckForOverride("images/" .. center.key:gsub("?", "_") .. ".png")
    if item.name then
        sets[item.set][item.key] = item
    end
end

local function process_seal(card, seal)
    local item = {}
    output_image(seal)
    if card.ability_UIBox_table then
        item.name = get_name_from_table(card.ability_UIBox_table.name)
        item.description = get_desc_from_table(card.ability_UIBox_table.main)
    end
    item.key = seal.key
    item.set = seal.set
    if seal.mod and seal.mod.id ~= "Aura" and seal.mod.id ~= "aure_spectral" then
        item.mod = seal.mod.id
    end
    item.tags = {}
    item.image_url = CheckForOverride("images/" .. seal.key:gsub("?", "_") .. ".png")
    if item.name then
        sets[item.set][item.key] = item
    end
end

local function process_stake(stake)
    local item = {}
    output_image(stake)
    item.key = stake.key
    item.name = localize{type = 'name_text', set = 'Stake', key = stake.key}
    local loc_vars = nil
    if stake.loc_vars and type(stake.loc_vars) == 'function' then
        local res = stake:loc_vars() or {}
        loc_vars = res.vars or {}
    end
    if stake.mod and stake.mod.id ~= "Aura" and stake.mod.id ~= "aure_spectral" then
        item.mod = stake.mod.id
    end
    item.description = localize{type = 'raw_descriptions', key = stake.key, set = "Stake", nodes = {}, vars = loc_vars}
    item.image_url = CheckForOverride("images/" .. stake.key:gsub("?","_") .. ".png")
    if item.name then
        sets["Stake"][item.key] = item
    end
end

local function process_sticker(center)
    local item = {}
    output_image(center)
    item.name = localize{type = 'name_text', set = 'Other', key = center.key}
    local loc_vars = nil
    if item.key == 'banana' then
        loc_vars = {  G.GAME.probabilities.normal or 1, 10  }
    elseif item.key == "perishable" then
        loc_vars = { G.GAME.perishable_rounds or 1, G.GAME.perishable_rounds}
    elseif item.key == "pinned" then
        loc_vars = { key = "cry_pinned_consumeable" }
    elseif item.key == "eternal" then
        loc_vars = { key = "cry_eternal_voucher" }
    elseif item.key == "rental" then
        loc_vars = { G.GAME.rental_rate or 1 }
    elseif center.loc_vars and type(center.loc_vars) == 'function' then
        --local res = center:loc_vars() or {}
        --loc_vars = res.vars or {}
    end
    item.description = localize{type = 'raw_descriptions', key = center.key, set = "Other", nodes = {}, vars = loc_vars}
    item.key = center.key
    item.set = "Sticker"
    if center.mod then
        item.mod = center.mod.id
    end
    item.tags = {}
    item.image_url = CheckForOverride("images/" .. center.key:gsub("?", "_") .. ".png")
    if item.name then
        sets["Sticker"][item.key] = item
        print(tprint(item))
    end
end

local function process_tag(tag)
    local item = {}
    tag.set = "Tag"
    output_image(tag)
    if tag.tag_sprite.ability_UIBox_table then
       item.name = get_name_from_table(tag.tag_sprite.ability_UIBox_table.name)
       item.description = get_desc_from_table(tag.tag_sprite.ability_UIBox_table.main)
    end
    item.key = tag.key
    item.set = tag.set
    if tag.mod and tag.mod.id ~= "Aura" and tag.mod.id ~= "aure_spectral" then
        item.mod = tag.mod.id
    end
    item.tags = {}
    item.image_url = CheckForOverride("images/" .. tag.key:gsub("?", "_") .. ".png")
    if item.name then
        sets["Tag"][item.key] = item
    end
end

local function process_suit(suit)
    local item = {}
    item.name = G.localization.misc.suits_plural[suit.key]
    item.key = suit.key
    if suit.mod and suit.mod.id ~= "Aura" and suit.mod.id ~= "aure_spectral" then
        item.mod = suit.mod.id
    end
    if item.name then
        sets["Suit"][item.key] = item
    end
end

local function process_mod(mod)
    local item = {}
    item.name = mod.display_name
    item.id = mod.id
    item.description = mod.description
    item.badge_colour = convert_to_hex(mod.badge_colour)
    if item.name then
        sets["Mods"][item.id] = item
    end
end

local card_hover_ref = Card.hover
Card.hover = function(self)
    card_hover_ref(self)
    if output_on_hover == true then
        process_card(self)
    end
end

local createOptionsRef = create_UIBox_options
function create_UIBox_options()
    G.EXPORT_FILTER = "" 
    local contents = createOptionsRef()
    if G.STAGE == G.STAGES.RUN then
        local m = UIBox_button({
            minw = 5,
            button = "CardExporter_Menu",
            label = { "Card Exporter"},
            colour = G.C.SO_1.SPADES,
        })
        table.insert(contents.nodes[1].nodes[1].nodes[1].nodes, #contents.nodes[1].nodes[1].nodes[1].nodes + 1, m)
    end
    return contents
end

G.FUNCS.CardExporter_Menu = function(e)
    local tabs = create_tabs({
        snap_to_nav = true,
        tabs = {
            {
                chosen = true,
                tab_definition_function = function()
                    return config_export_tab()
                end
            },
        }
    })
    G.FUNCS.overlay_menu{
        definition = create_UIBox_generic_options({
            back_func = "options",
            contents = {tabs}
        }),
        config = {offset = {x=0,y=10}}
    }
end

function config_export_tab()
    return {
        n = G.UIT.ROOT,
        config = {
            emboss = 0.05,
            minh = 6,
            r = 0.1,
            minw = 10,
            align = "cm",
            padding = 0.2,
            colour = G.C.BLACK
        },
        nodes = {
            UIBox_button({label = {"Export Cards"}, button = "create_output", colour = G.C.ORANGE, minw = 5, minh = 0.7, scale = 0.6}),
            --UIBox_button({label = {"Test Shader"}, button = "test_shader", colour = G.C.ORANGE, minw = 5, minh = 0.7, scale = 0.6}),
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    create_text_input({
                        colour = G.C.RED,
                        hooked_colour = darken(copy_table(G.C.RED), 0.3),
                        w = 4.5,
                        h = 1,
                        max_length = 100,
                        extended_corpus = true,
                        prompt_text = "Mod IDs, 'Balatro' for non-mod objects",
                        ref_table = G,
                        ref_value = "EXPORT_FILTER",
                        keyboard_offset = 1,
                    }),
                },
            }, --textbox
        },
    }
end

G.FUNCS.test_shader = function(e)
    local w = 71 * G.SETTINGS.GRAPHICS.texture_scaling
    local h = 95 * G.SETTINGS.GRAPHICS.texture_scaling
    local card = G.jokers.cards[1]

    local canvas = love.graphics.newCanvas(w, h, {type = '2d', readable = true})
    love.graphics.push()
    local oldCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas( canvas )

    love.graphics.clear(0,0,0,0)
    love.graphics.setColor(1, 1, 1, 1)

    if card.edition and card.edition.type and G.SHADERS[card.edition.type]  then
        love.graphics.setShader(G.SHADERS[card.edition.type])
    else
        if card.edition then
            local edition_key = card.edition.key
            if edition_key and SMODS.Centers[edition_key] and G.SHADERS[SMODS.Centers[edition_key].shader] then
                love.graphics.setShader(G.SHADERS[SMODS.Centers[edition_key].shader])
            end
        end
    end
    love.graphics.draw(
        card.children.center.atlas.image,
        card.children.center.sprite,
        0,0,0,2,2
    )

    --love.graphics.setShader()
   -- love.graphics.setCanvas(oldCanvas)
   -- love.graphics.pop()
end

function table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

local function filterListFromString(str)
    str = string.gsub(str, " ", "")
    local result = {}
    for match in (str .. ","):gmatch("(.-),") do
        table.insert(result, match)
    end
    return result
end

G.FUNCS.create_output = function(e)
    local mod_filter = filterListFromString(G.EXPORT_FILTER or "")
    local clean_filter = {}
    print(tprint(mod_filter))
    if #mod_filter == 1 and mod_filter[1] == "" then
        table.insert(clean_filter, "Balatro")
        for k,_ in pairs(SMODS.Mods) do
            table.insert(clean_filter, k)
        end
    else
        for _,v in ipairs(mod_filter) do
            if v == "Balatro" then
                table.insert(clean_filter, "Balatro")
            end
            if SMODS.Mods[v] then
                table.insert(clean_filter, v)
            end
        end
    end

    local card = nil
    if not love.filesystem.exists(output_root) then
        love.filesystem.createDirectory(output_root)
    end
    if not love.filesystem.exists(output_root .. "images") then
        love.filesystem.createDirectory(output_root .. "images")
    end

    for k,v in pairs(G.P_CENTERS) do
        if not v.mod then
            v.mod = {}
            v.mod.id = "Balatro"
        end
        if table.contains(clean_filter, v.mod.id) then
            print("Processing " .. k .. " | " .. tostring(v.set))
            v.unlocked = true
            v.discovered = true
            if v.set == "Edition" then
                card = Card(G.jokers.T.x + G.jokers.T.w/2, G.jokers.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, v)
                card:set_edition(v.key, true, true)
                card:hover()
                process_edition(card)
            elseif v.set == "Enhanced" then
                card = Card(G.jokers.T.x + G.jokers.T.w / 2, G.jokers.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, v)
                card:set_ability(v, true, true)
                card:hover()
                process_enhancement(card)
            elseif v.set == "Sticker" then
                card = create_card("Default", G.jokers, nil, nil, nil, nil, "c_base", nil)
                card:set_sticker(v, true, true)
                card:hover()
            elseif not v.set or v.set == "Other" or v.set == "Default" then
            else
                card = create_card(v.set, G.jokers, v.legendary, v.rarity, nil, nil, v.key, nil)
                card:hover()
                process_card(card)
            end
            if card then
                card:stop_hover()
                G.jokers:remove_card(card)
                card:remove()
            end
            card = nil
        end
    end

    for k,v in pairs(G.P_BLINDS) do
        if not v.mod then
            v.mod = {}
            v.mod.id = "Balatro"
        end
        if table.contains(clean_filter, v.mod.id) then
            print("Processing " .. k .. " | " .. tostring(v.set))
            v.discovered = true
            process_blind(v)
        end
    end

    if G.P_CURSES then
        for k,v in pairs(G.P_CURSES) do
            if not v.mod then
                v.mod = {}
                v.mod.id = "Balatro"
            end
            if table.contains(clean_filter, v.mod.id) then
                print("Processing " .. k .. " | " .. tostring(v.set))
                v.discovered = true
                process_curse(v)
            end
        end
    end

    if G.P_D6_SIDES then
        for k,v in pairs(G.P_D6_SIDES) do
            if not v.mod then
                v.mod = {}
                v.mod.id = "Balatro"
            end
            if table.contains(clean_filter, v.mod.id) then
                print("Processing " .. k .. " | " .. tostring(v.set))
                process_d6_side(v)
            end
        end
    end

    for k,v in pairs(G.P_SEALS) do
        if not v.mod then
            v.mod = {}
            v.mod.id = "Balatro"
        end
        if table.contains(clean_filter, v.mod.id) then
            print("Processing " .. k .. " | " .. tostring(v.set))
            v.discovered = true
            card = create_card("Default", G.jokers, nil, nil, nil, nil, "c_base", nil)
            card:set_seal(v.key, true)
            card:hover()
            process_seal(card, v)
            if card then
                card:stop_hover()
                G.jokers:remove_card(card)
                card:remove()
            end
            card = nil
        end
    end

    if G.P_SKILLS then
        for k,v in pairs(G.P_SKILLS) do
            if not v.mod then
                v.mod = {}
                v.mod.id = "Balatro"
            end
            if table.contains(clean_filter, v.mod.id) then
                print("Processing " .. k .. " | " .. tostring(v.set))
                v.discovered = true
                card = Card(G.jokers.T.x + G.jokers.T.w/2, G.jokers.T.y, G.CARD_W, G.CARD_H, nil, v, { bypass_discovery_center = true})
                card:hover()
                process_card(card)
                if card then
                    card:stop_hover()
                    G.jokers:remove_card(card)
                    card:remove()
                end
                card = nil
            end
        end
    end

    for k,v in pairs(G.P_STAKES) do
        if not v.mod then
            v.mod = {}
            v.mod.id = "Balatro"
        end
        if table.contains(clean_filter, v.mod.id) then
            print("Processing " .. k .. " | " .. tostring(v.set))
            v.discovered = true
            process_stake(v)
        end
    end

    for k,v in pairs(SMODS.Stickers) do
        --if table.contains(clean_filter, v.mod.id) then
            --print("Processing " .. k .. " | " .. tostring(v.set))
            --v.discovered = true
            --process_sticker(v)
        --end
    end

    for k,v in pairs(G.P_TAGS) do
        if not v.mod then
            v.mod = {}
            v.mod.id = "Balatro"
        end
        if table.contains(clean_filter, v.mod.id) then
            print("Processing " .. k .. " | " .. tostring(v.set))
            v.discovered = true
            local temp_tag = Tag(v.key, true)
            local _, temp_tag_sprite = temp_tag:generate_UI()
            temp_tag_sprite:hover()
            process_tag(temp_tag)
            temp_tag_sprite:stop_hover()
            temp_tag_sprite:remove()
            temp_tag = nil
        end
    end

    for k,v in pairs(G.P_CARDS) do
        if not v.mod then
            v.mod = {}
            v.mod.id = "Balatro"
        end
        if table.contains(clean_filter, v.mod.id) then
            print("Processing " .. k .. " | " .. tostring(v.suit))
            card = create_playing_card({front = G.P_CARDS[k]},  G.hand, true, true, {G.C.SECONDARY_SET.Spectral})
            card:hover()
            process_playing_card(card, v, k)
            if card then
                card:stop_hover()
                G.jokers:remove_card(card)
                card:remove()
            end
        end
    end

    for k,v in pairs(SMODS.Suits) do
        if not v.mod then
            v.mod = {}
            v.mod.id = "Balatro"
        end
        if table.contains(clean_filter, v.mod.id) then
            print("Processing " .. k .. " | " .. tostring(v.key))
            process_suit(v)
        end
    end

    local base_mod = {
        display_name = "Balatro",
        id = "Balatro",
        badge_colour = G.C.RED
    }
    process_mod(base_mod)

    for k,v in pairs(SMODS.Mods) do
        if table.contains(clean_filter, k) then
            print("Processing " .. k .. " | " .. tostring(v.name))
            process_mod(v)
        end
    end

    local output = json.encode(sets)
    if love.filesystem.exists(output_root .. "cards.json") then
        love.filesystem.remove(output_root .. "cards.json")
    end
    love.filesystem.write(output_root .. "cards.js", "cards = " .. output:gsub("'","\\'"))   --outputting to js file/object to get around browser security annoyances
    copy_template()
    print("complete")
end

-------------------------------------------------
------------MOD CODE END-------------------------