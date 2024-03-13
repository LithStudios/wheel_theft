Config = {}

Config.debug = false

Config.esxSettings = {
    enabled = true,
    useNewESXExport = true,
    account = 'bank'
}

Config.qbSettings = {
    enabled = false,
    useNewQBExport = true,
    account = 'bank'
}

Config.job = {
    jobOnly = false,

    --Modify or add your job names here
    jobNames = {
        'thug',
    }
}

Config.target = {
    enabled = false,
    system = 'ox_target'
}

Config.jackStandName = 'ls_jackstand'

-- If route should be drawn on the minimap/map for the player
Config.enableBlipRoute = true

Config.missionBlip = {
    showBlip = true, -- whether or not to show the methamphetamine selling location blip on the map
    blipColor = 29,
    blipIcon = 514,
    blipLabel = 'Tire Theft Mission',
}

-- Mission location where target vehicles will spawn (Picked randomly)
Config.missionLocations = {
    {
        x = 888.0,
        y = -1768.0,
        z = 29.0,
        h = 267.3
    },
    {
        x = 1202.9,
        y = -1383.0,
        z = 34.6,
        h = 359.0
    },
    {
        x = 1268.5,
        y = -740.3,
        z = 62.5,
        h = 320.0
    },
    {
        x = -723.4,
        y = -913.2,
        z = 18.3,
        h = 270.2
    },
    {
        x = -171.6,
        y = 214.7,
        z = 88.5,
        h = 351.1
    },
    {
        x = -504.6,
        y = 44.3,
        z = 55.8,
        h = 87.2
    },
    {
        x = 846.5,
        y = -2180.1,
        z = 29.6,
        h = 358.1
    },
    {
        x = -83.3,
        y = -1405.5,
        z = 28.7,
        h = 103.5
    },
}

--Add mission vehicles model names here
Config.vehicleModels = {
    'sultanrs',
    'cavalcade',
    'issi8',
    'radi',
    'buffalo5',
    'dominator2',
    'buffalo4',
    'z190',
    'asea',
    'asterope2',
    'rhinehart'
}

Config.missionPeds = {
    ['sale_ped'] = {
        location = {
            x = 2343.53,
            y = 3143.0,
            z = 48.2,
            h = 169.1,
        },
        wheelDropOff = {
            crateProp = 'prop_crate_09a',
            location = {
                x = 2345.7,
                y = 3141.2,
                z = 47.2,
            }
        },

        message = 'Sell the tires',
        pedModel = 'g_m_m_mexboss_01',
        duration = 2000, -- selling duration in ms

        -- By not putting the math.random into a function the price will be set randomly on each server start/script start
        -- this will result in better/worse days for selling the wheels
        price = math.random(300, 500),
        blip = {
            showBlip = true, -- whether or not to show the location blip on the map
            blipColor = 25,
            blipIcon = 431,
            blipLabel = 'Tire Sale'
        }
    },
    ['mission_ped'] = {
        location = {
            x = 401.3,
            y = -1927.1,
            z = 24.8,
            h = 355.0,
        },

        message = 'Sell the methamphetamine',
        itemLabel = 'methamphetamine',
        pedModel = 'g_m_m_mexboss_01',
        duration = 2000, -- selling duration in ms

        -- By not putting the math.random into a function the price will be set randomly on each server start/script start
        -- this will result in better/worse days for selling the wheels
        price = math.random(300, 500),
        blip = {
            showBlip = true, -- whether or not to show the location blip on the map
            blipColor = 28,
            blipIcon = 480,
            blipLabel = 'Wheel Theft Missions'
        }
    }
}

--- LOCALE
-- To translate the messages edit the message on the right side! Not the message between the square brackets
Locale = {
    ['Complete sale'] = 'Complete Sale',
    ['Your target vehicle\'s plate number: ~y~'] = 'Your target vehicle\'s plate number: ~y~',
    ['Head to ~g~ Wheel Seller ~w~ to complete mission'] = 'Head to ~g~ Wheel Seller ~w~ to complete mission',
    ['Press ~g~[~w~E~g~]~w~ to finish stealing'] = 'Press ~g~[~w~E~g~]~w~ to finish stealing',
    ['Press ~g~[~w~E~g~]~w~ to store the wheel'] = 'Press ~g~[~w~E~g~]~w~ to store the wheel',
    ['Press ~g~[~w~H~g~]~w~ to take Wheel out'] = 'Press ~g~[~w~H~g~]~w~ to take Wheel out',
    ['~r~ You can not do this'] = '~r~ You can not do this',
    ['Press ~g~[~w~E~g~]~w~ to start mission'] = 'Press ~g~[~w~E~g~]~w~ to start mission',
    ['Press ~g~[~w~E~g~]~w~ to cancel mission'] = 'Press ~g~[~w~E~g~]~w~ to cancel mission',
    ['Press ~g~[~w~E~g~]~w~ to complete the sale'] = 'Press ~g~[~w~E~g~]~w~ to complete the sale',
    ['Finish the job'] = 'Finish the job',
    ['Put the ~r~ stolen wheels ~w~ in the crate to finish the sale'] = 'Put the ~r~ stolen wheels ~w~ in the crate to finish the sale'
}

Settings = {}

Settings.wheelTakeOff = {
    wheelModel = 'prop_wheel_01',
    wheelOffset = {
        bone = 4089,
        loc = {
            x = 0.1,
            y = 0.08,
            z = 0.25,
        },
        rot = {
            x = 190.0,
            y = 0.0,
            z = 0.0,
        }
    }
}
