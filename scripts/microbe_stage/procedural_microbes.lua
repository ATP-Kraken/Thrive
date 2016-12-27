--limits the size of the initial stringCodes
local MIN_INITIAL_LENGTH = 5
local MAX_INITIAL_LENGTH = 15

organelleLetters = {
    ["N"] = "nucleus",
    ["Y"] = "cytoplasm",
    ["H"] = "chloroplast",
    ["T"] = "oxytoxy",
    ["M"] = "mitochondrion",
    ["V"] = "vacuole",
    ["F"] = "flagellum",
    ["P"] = "pilus",
    ["C"] = "cilia"
}

VALID_LETTERS = {"Y", "H", "T", "M", "V", "F"}

--returns a random organelle letter
function getRandomLetter()
    return VALID_LETTERS[math.random(1, #VALID_LETTERS)]
end

--checks whether an organelle in a certain position would fit within a list of other organelles.
function isValidPlacement(organelleName, q, r, rotation, organelleList)
    --this is super hacky :/
    local data = {
        ["name"] = organelleName,
        ["q"] = q,
        ["r"] = r,
        ["rotation"] = rotation
    }

    local organelleHexes = OrganelleFactory.checkSize(data)

    for _, otherOrganelle in pairs(organelleList) do
        local otherOrganelleHexes = OrganelleFactory.checkSize(otherOrganelle)
        for __, hex in pairs(organelleHexes) do
            for ___, otherHex in pairs(otherOrganelleHexes) do
                if hex.q + q == otherHex.q + otherOrganelle.q and hex.r + r == otherHex.r + otherOrganelle.r then
                    return false
                end
            end
        end
    end
    
    return true
end

--finds a valid position to place the organelle and returns it
--maybe the values should be saved?
function getPosition(organelleName, organelleList)

    local radius = 0
    local q = 0
    local r = 0

    while true do
        --Moves into the ring of radius "radius" and center (0, 0)
        q = q + HEX_NEIGHBOUR_OFFSET[HEX_SIDE.BOTTOM_LEFT][1]
        r = r + HEX_NEIGHBOUR_OFFSET[HEX_SIDE.BOTTOM_LEFT][2]

        --Iterates in the ring
        for _, offset in pairs(HEX_NEIGHBOUR_OFFSET) do
            for i = 1, radius do
                q = q + offset[1]
                r = r + offset[2]
                --print(q, r)

                --Moves "radius" times into each direction
                for j = 0, 5 do
                    rotation = 360 * j / 6
                    if isValidPlacement(organelleName, q, r, rotation, organelleList) then
                        return q, r, rotation
                    end
                end
            end
        end
        radius = radius + 1
    end
end

--creates a list of organelles from the stringCode.
function positionOrganelles(stringCode)
    local organelleList = {{
        ["name"] = organelleLetters[string.sub(stringCode, 1, 1)],
        ["q"] = 0,
        ["r"] = 0,
        ["rotation"] = 0
    }}

    for i = 2, string.len(stringCode) do
        local organelle = organelleLetters[string.sub(stringCode, i, i)]
        q, r, rotation = getPosition(organelle, organelleList)
        local newOrganelleData = {
            ["name"] = organelle,
            ["q"] = q,
            ["r"] = r,
            ["rotation"] = rotation
        }

        table.insert(organelleList, newOrganelleData)
    end
    return organelleList
end

--creates a new random specie
function createNewSpecie()
    local stringSize = math.random(MIN_INITIAL_LENGTH, MAX_INITIAL_LENGTH)
    local stringCode = "NY" --it should always have a nucleus and a cytoplasm.
    for i = 1, stringSize do
        local newLetterIndex = math.random(#validLetters)
        stringCode = stringCode .. validLetters[newLetterIndex]
    end
    
    local specie = {
        spawnDensity = 1/9000,
        compounds = {atp = {amount = 60}},
        organelles = positionOrganelles(stringCode),
        colour = {
            r = math.random() * 0.7 + 0.3, --random float number between 0.3 and 1.0
            g = math.random() * 0.7 + 0.3,
            b = math.random() * 0.7 + 0.3,
        },
    }

    return specie
end

--creates a mutated copy of the specie
function mutate(specie)
    --placeholder
    Speedy = {
        spawnDensity = 1/15000,
        compounds = {atp = {amount = 30}},
        organelles = {
            {name="nucleus",q=0,r=0, rotation=0},
            {name="mitochondrion",q=-1,r=-2, rotation=240},
            {name="vacuole",q=1,r=-3, rotation=0},
            {name="flagellum",q=1,r=-4, rotation=0},
            {name="flagellum",q=-1,r=-3, rotation=0},
            {name="flagellum",q=0,r=-4, rotation=0},
            {name="flagellum",q=-2,r=-2, rotation=0},
            {name="flagellum",q=2,r=-4, rotation=0},
        },
        colour = {r=0.4,g=0.4,b=0.8},
    }
    return Speedy
end