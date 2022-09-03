struct Guide

    public static method creerQuetes takes nothing returns nothing
        local quest queteInfo = CreateQuest()
        call QuestSetTitle(queteInfo, "About")
        call QuestSetDescription(queteInfo, "Troll & Elves is a map created by IaMfReNcH.\n\nThis map has been created before as \"Le Traqueur\" by VisionElf. Most of texts has been translated by Mokra~akaNeoniK\n\nAll scripts has been remade by me, so all codes are make by me now and i will make another map or there are more maps (Because i want to keep the original map so former players can remember these olds times before Reforged) this map will be updated by me to add features ^___^.\n\n\nFor those who want to see the script, sorry but i will not open this map for one reason and this reason is the cheat... Because there are people who will add trigger to give gold for themselves and then players will not know wich is the map who has no cheat :/")
        call QuestSetIconPath(queteInfo, "ReplaceableTextures\\CommandButtons\\BTNScrollOfRegenerationGreen.blp")
        call QuestSetRequired(queteInfo, true)
        set queteInfo = CreateQuest()
        call QuestSetTitle(queteInfo, "Changelog")
        call QuestSetDescription(queteInfo, "1. Scripts are remake to be much optimizd (And organized also -_-\")\n\n2. Bug with units you can't destroy when the troll is not near has been fixed !!!!!\n\n3. Now everyone can vote a speed x1, x2 or x4 for each round !!!\n\n4. Only textfloat of your units will appear for you.")
        call QuestSetIconPath(queteInfo, "ReplaceableTextures\\CommandButtons\\BTNEngineeringUpgrade.blp")
        call QuestSetRequired(queteInfo, true)
        set queteInfo = CreateQuest()
        call QuestSetTitle(queteInfo, "Give |c00FFD700gold|r or |c0000FF00lumber|r")
        call QuestSetDescription(queteInfo, "You can give |c00FFD700gold|r or |c0000FF00lumber|r to another player.\n\nFirstly, select a unit belonging to the player you want to give it to. Then use the commands below:\n\nTo give |c00FFD700gold|r you need to use this command: |c00FFD700-gg|r <amount>\nTo give |c0000FF00lumber|r you need to use this command: |c0000FF00-gl|r <amount>\n\n\n ")
        call QuestSetIconPath(queteInfo, "ReplaceableTextures\\CommandButtons\\BTNEngineeringUpgrade.blp")
        call QuestSetRequired(queteInfo, true)
        set queteInfo = null
    endmethod

endstruct