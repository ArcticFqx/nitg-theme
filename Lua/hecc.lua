local hecc = {
    "StepMania",
    "Mashing with your hands",
    "In The Groove 2",
    "Konmai will sue",
    "Dance Mat Game",
    "Chegg: *Kweh*",
    "┃  ┃╻ ┃┃ ┃▁",
    "Getting whipped by mods",
    "UKSRTale release imminent",
    "Show me your metrics.ini",
    "MAX300 Simulator",
    "O-oooooooooo AAAAE-A-A-I-A-U- JO-oooooooooooo AAE-O-A-A-U-U-A- E-eee-ee-eee AAAAE-A-E-I-E-A- JO-ooo-oo-oo-oo EEEEO-A-AAA-AAAA",
    "osu!",
    "hecc",
    "Powered by Ligma",
    "I love Video Games! Like a Video Game! Like a whole Video Game! You have no Video Game!!",
    "Just bracket it, you'll be fine!",
    "It's like osu, but you use your feet",
    "Ignotis me senpai"
}

math.randomseed(tonumber(os.date("%S")))
math.random( 1, table.getn(hecc) )

return string.format("NotITG %s  -  %s",
    string.gsub(
        string.gfind( GetSerialNumber(), "%d+%-%x+")(),
        "%x+$",
        function(s) 
            return string.format("%03d",tonumber(s,16)) 
        end
    ),
    hecc[math.random(1,table.getn(hecc))]
)