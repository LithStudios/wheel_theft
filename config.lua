Config = {}

Config.debug = false

-- Enabling this will let players lift the car up by using a `/...` command
Config.command = {
    enabled = false,
    name = 'lift'
}

Config.esxSettings = {
    enabled = true,
    useNewESXExport = true,
    account = 'bank'
}

Config.qbSettings = {
    enabled = false,
    useNewQBExport = true,
    account = 'bank',
    payInItems = {
        enabled = false, -- If enabled, player will receive payment in items instead in their account
        itemName = 'cash',
        count = math.random(100, 500)
    }
}

--Prints target vehicle's license plate number to client's console
Config.printLicensePlateToConsole = true

-- System on who can raise and lower vehicles ANY vehicle
-- Players can only raise/lower TARGET VEHICLES by default
Config.jackSystem = {
   ['raise'] = {
       everyone = false, --everyone can raise any car

       -- Only these jobs can raise any car
       jobs = {
           'police',
           'ems', -- Add your jobs here/Continue the list
       }
   },
   --If your server has 'Advanced Wheel Spacers' Script, this feature will automatically be turned off (Needs additional compatibility)
   ['lower'] = {
       everyone = false, --everyone can lower any car

       -- Only these jobs can lower any car
       jobs = {
           'police',
           'ems', -- Add your jobs here/Continue the list
       }
   },
}

Config.job = {
    jobOnly = false,

    --Modify or add your job names here
    jobNames = {
        'thug',
    }
}

--- PLACEHOLDER - TARGET IS NOT IMPLEMENTED INTO THE SCRIPT
--- Comments are placed in the script files, so you can see where to add target if you wish to :)
Config.target = {
    enabled = false,
    system = 'ox-target'
}

-------------------------------------------------
--- DISPATCH
-------------------------------------------------
Config.dispatch = {
    enabled = false, -- Whether to enable the dispatch
    notifyThief = true, --If thief should be notified that police has been alerted

    alertChance = 10, --- The chance of theft being notified to police members NOTE: The event gets called 4 times (once per each wheel) so set the chance to a relatively low number

    -- using 'in-built' dispatch will look like this: [LINK TO HOW IT LOOKS]
    system = 'in-built',  -- Setting for the dispatch system to use 'cd-dispatch', 'core-dispatch-old', 'core-dispatch-new' or 'ps-dispatch'
    policeCode = '10-31',  -- Police code for the wheel theft
    eventName = 'Theft',  -- Name of the theft event
    description = 'Suspect is stealing vehicle wheels',  -- Description of the theft event

    blip = {
        sprite = 380,  -- Sprite for the Theft blip
        color = 59,  -- Color for the Theft blip
        scale = 1.0,  -- Scale for the Theft blip

        timeout = 60,  -- Time in seconds for the blip to disappear after the Theft event is over

        showRadar = true,  -- Setting to show the Theft blip on the radar
    },
}

--Used for notifying police members of theft crime if Config.dispatch is enabled
Config.policeJobNames = {
    'police'
}

-- Whether to spawn a pick up truck for wheel theft (Check `client/truckSpawn.lua` if you want to edit this system)
-- Script checks if the current spawn is occupied, it will move to the next spawn coordinates - if all spots are taken - displays message to player
Config.spawnPickupTruck = {
    enabled = true,

    -- Add more models by separating each with a comma ","
    models = {
        'bison'
    },

    truckSpawnCoords = {
        {
            x = 407.6,
            y = -1917.2,
            z = 25.1,
            h = 50.6 -- heading
        },
        {
            x = 405.58,
            y = -1919.7,
            z = 24.9,
            h = 51.0
        },
        {
            x = 403.3,
            y = -1922.0,
            z = 24.7,
            h = 46.7
        }
    }
}

Config.jackStandName = 'ls_jackstand_alt'

-- If route should be drawn on the minimap/map for the player
Config.enableBlipRoute = true

Config.missionBlip = {
    showBlip = true, -- whether or not to show the mission ped blip
    blipColor = 29,
    blipIcon = 514,
    blipLabel = 'Tire Theft Mission',
}

Config.blips = {
    policeBlip = {
        sprite = 161,
        color = 47,
        scale = 2.0,
        alpha = 150,
        shortRange = false,
    },
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
    }
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
-- To translate the messages edit the message on the right side! DO NOT edit the message between the square brackets
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
    ['Put the ~r~ stolen wheels ~w~ in the crate to finish the sale'] = 'Put the ~r~ stolen wheels ~w~ in the crate to finish the sale',
    ['. ~w~ Proceed with caution!'] = '. ~w~ Proceed with caution!',
    ['Theft commited at ~y~'] = 'Theft commited at ~y~',
    ['~r~ No seats available at the moment'] = '~r~ No seats available at the moment'
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
