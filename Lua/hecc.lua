local titles = {
    "NotITG",
    "Stepman",
    "osu!",
    "Dance Dance Revolution"
}

local hecc = {
    "StepMania - Mashing with your hands",
    "In The Groove 2 - Konmai will sue",
    "Dance Mat Game",
    "Chegg: *Kweh*",
    "I  Iı II I_",
    "Getting whipped by mods",
    "UKSRTale release imminent",
    "Show me your metrics.ini",
    "MAX300 Simulator",
    "O-oooooooooo AAAAE-A-A-I-A-U- JO-oooooooooooo AAE-O-A-A-U-U-A- E-eee-ee-eee AAAAE-A-E-I-E-A- JO-ooo-oo-oo-oo EEEEO-A-AAA-AAAA",
    "osu!",
    "Powered by Ligma",
    "I love video games. I REALLY love video games, like a lot! Like a WHOLE LOT! You have no video games."
}

math.randomseed(tonumber(os.date("%S")))
math.random( 1, table.getn(hecc) )

return hecc[math.random(1,table.getn(hecc))]