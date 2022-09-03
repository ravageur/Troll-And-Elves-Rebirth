function attendreUnPeu takes nothing returns nothing
    call Dialogue.sonFini()
endfunction

function dialogueFini takes nothing returns nothing
    local SuperTimeur superTimeur = SuperTimeur.creerTimeur(false, "", false)
    call EndCinematicScene()
    call superTimeur.lancerTimer(3.0, function attendreUnPeu)
    set superTimeur = 0
endfunction

struct Dialogue

    private static SuperTimeur timeurDialogue
    private static sound son = CreateSound("SonImporte/BloodElfEngineerPissed6.wav", false, false, false, 0, 0, "HeroAcksEAX")
    private static integer nbIDSon = 0
    private static integer array derniersSonsJouees[3]
    private static boolean entrainDeJouer = false
    private static constant real pvCritique = 0.3 // En pourcentage ^^

    public static method parler takes unit uniteAttaquee, unit uniteAttaque returns nothing
        local real aleatoire
        local player joueur
        local integer idJoueur
        if entrainDeJouer == false then
            set idJoueur = elfAProximiter()
            if idJoueur != -1 then
                set joueur = Player(idJoueur)
                set aleatoire = GetRandomReal(0, 1)
                if estUnMur(GetUnitTypeId(uniteAttaquee)) and aleatoire < 0.50 then
                    set aleatoire = GetRandomReal(0, 1)
                    if aleatoire > 59 and verifierIDSon(0) and toursAlentours(GetUnitX(uniteAttaquee), GetUnitY(uniteAttaquee), 600) == false then
                        call lancerSonEN("Critters/BloodElfPeasant/BloodElfEngineerPissed6", 'u000', "Hmm... tower defence. No, that's a silly idea, it would never work.", 0, joueur)
                    else
                        if GetUnitLifePercent(uniteAttaquee) < pvCritique then
                            set aleatoire = GetRandomReal(0, 100)
                            if aleatoire < 0.30 and verifierIDSon(1) then
                                call lancerSonEN("Human/Peasant/PeasantYesAttack4", 'u000', "That's it, I'm dead.", 1, joueur)
                            elseif aleatoire < 0.50 and verifierIDSon(2) then
                                call lancerSonEN("Undead/Acolyte/AcolytePissed2", 'u000', "Anyways, who cares? In 100 years we'll be all dead.", 2, joueur)
                            elseif aleatoire < 0.80 and verifierIDSon(3) then
                                call lancerSonEN("Human/Peasant/PeasantWarcry1", 'u000', "Euhwaaaeuh...", 3, joueur)
                            elseif verifierIDSon(4) then
                                call lancerSonEN("Human/Kael/KaelPissed1", 'u000', "It is to be good for nothing to be good only for oneself.", 4, joueur) // Traduction pas sur a 100 %
                            endif
                        else
                            set aleatoire = GetRandomReal(0, 1)
                            if aleatoire < 5 and verifierIDSon(5) then
                                call lancerSonEN("Human/Priest/PriestPissed6", 'u000', "In the four corners of Paris, you will find scattered the small pieces of the puzzle !", 5, joueur)
                            elseif aleatoire < 0.10 and verifierIDSon(6) then
                                call lancerSonEN("Human/TheCaptain/CaptainPissed1", 'u000', "I should have been a farmer like my father wanted.", 6, joueur)
                            elseif aleatoire < 0.15 and verifierIDSon(7) then
                                call lancerSonEN("Human/Priest/PriestPissed4", 'u000', "Help! There is a pec that threatens me! It has an acorn in it's hand !", 7, joueur)
                            elseif aleatoire < 0.20 and verifierIDSon(8) then
                                call lancerSonEN("Human/Uther/UtherPissed2", 'u000', "As if the Orcs weren't enough.", 8, joueur)
                            elseif aleatoire < 0.50 and verifierIDSon(9) then
                                call lancerSonEN("Critters/BloodElfPeasant/BloodElfEngineerYesAttack1", 'u000', "Probability of success? Zero.", 9, joueur)
                            elseif verifierIDSon(10) then
                                call lancerSonEN("Human/Kael/KaelYesAttack3", 'u000', "This is too easy.", 10, joueur)
                            endif
                        endif
                    endif
                elseif GetUnitTypeId(uniteAttaquee) == 'H000' or GetUnitTypeId(uniteAttaque) == 'H000' then
                    set aleatoire = GetRandomReal(0, 1)
                    if GetUnitLifePercent(Jeu.troll) > pvCritique then
                        if aleatoire < 0.075 and verifierIDSon(11) then
                            call lancerSonEN("Human/HeroMountainKing/HeroMountainKingPissed7", 'H000', "Rum! Women and beer dammit !", 11, Jeu.joueurTroll)
                        elseif aleatoire < 0.15 and verifierIDSon(12) then
                            call lancerSonEN("Creeps/IceTroll/IceTrollPissed4", 'H000', "Why not clafoutis? Everyone loves the clafoutis ...", 12, Jeu.joueurTroll)
                        elseif aleatoire < 0.225 and verifierIDSon(13) then
                            call lancerSonEN("Creeps/ForestTroll/ForestTrollReady1", 'H000', "No quarters !", 13, Jeu.joueurTroll)
                        elseif aleatoire < 0.30 and verifierIDSon(14) then
                            call lancerSonEN("IceTrollYesAttack2", 'H000', "I, will kill !", 14, Jeu.joueurTroll)
                        elseif aleatoire < 0.375 and verifierIDSon(15) then
                            call lancerSonEN("Orc/HeadHunter/HeadHunterWarcry1", 'H000', "Tazdingo !", 15, Jeu.joueurTroll)
                        elseif aleatoire < 0.45 and verifierIDSon(16) then
                            call lancerSonEN("Orc/HeadHunter/HeadHunterYesAttack2", 'H000', "Will soon suffer !", 16, Jeu.joueurTroll)
                        endif
                    elseif verifierIDSon(17) then
                        call lancerSonEN("Creeps/IceTroll/IceTrollPissed1", 'H000', "I'm too old for this crap.", 17, Jeu.joueurTroll)
                    endif
                endif
                set joueur = null
                set entrainDeJouer = true
                set timeurDialogue = SuperTimeur.creerTimeur(false, "", true)
                call timeurDialogue.lancerTimer(I2R(GetSoundDuration(son)) / 1000, function dialogueFini)
                set timeurDialogue = 0
            endif
        endif
    endmethod

    private static method elfAProximiter takes nothing returns integer
        local unit array elfs
        local unit unite
        local player joueur
        local integer taille = 0
        local integer i = 0
        loop
        exitwhen i == 12
            set unite = Jeu.getElfJoueur(i)
            if unite != null and SuperMath.uniteEstAuxAlentours(unite, Jeu.troll, 900) then
                set elfs[taille] = unite
                set taille = taille + 1
            endif
            set i = i + 1
        endloop
        set unite = null
        if taille != 0 then
            set i = GetRandomInt(0, taille - 1)
            set joueur = GetOwningPlayer(elfs[i])
            set i = 0
            loop
            exitwhen i == taille
                set elfs[i] = null
                set i = i + 1
            endloop
            set i = Jeu.getIdJoueur(joueur)
            set joueur = null
            return i
        else
            return -1
        endif
    endmethod

    // private static method lancerSon takes string nomFichier, integer typeUnite, string sousTitres, integer idSon, player joueur returns nothing
    //     set son = CreateSound("SonImporte/" + nomFichier + ".wav", false, false, false, 0, 0, "HeroAcksEAX")
    //     call StartSound(son)
    //     call SetCinematicScene(typeUnite, GetPlayerColor(joueur), "", "", GetSoundDuration(son), GetSoundDuration(son))
    //     call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "|c" + Couleur.getCouleurHexJoueur(joueur) + Jeu.getNomJoueur(joueur) + ":|r " + sousTitres)
    //     call KillSoundWhenDone(son)
    //     call ajouterIDSon(idSon)
    // endmethod

    private static method lancerSonEN takes string nomFichier, integer typeUnite, string sousTitres, integer idSon, player joueur returns nothing
        set son = CreateSound("Units/" + nomFichier + ".flac", false, false, false, 0, 0, "HeroAcksEAX")
        call StartSound(son)
        call SetCinematicScene(typeUnite, GetPlayerColor(joueur), "", "", GetSoundDuration(son), GetSoundDuration(son))
        call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "|c" + Couleur.getCouleurHexJoueur(joueur) + Jeu.getNomJoueur(joueur) + ":|r " + sousTitres)
        call KillSoundWhenDone(son)
        call ajouterIDSon(idSon)
    endmethod

    private static method verifierIDSon takes integer idSon returns boolean
        local integer i = 0
        loop
        exitwhen i == 3
            if derniersSonsJouees[i] == idSon then
                return false
            endif
            set i = i + 1
        endloop
        return true
    endmethod

    private static method ajouterIDSon takes integer idSon returns nothing
        set derniersSonsJouees[nbIDSon] = idSon
        if nbIDSon == 2 then
            set nbIDSon = 0
        else
            set nbIDSon = nbIDSon + 1
        endif
    endmethod

    private static method toursAlentours takes real posX, real posY, real portee returns boolean
        local group unites = CreateGroup()
        local rect rectangle = Rect(SuperMath.minReals(posX - portee, posX + portee), SuperMath.minReals(posY - portee, posY + portee), SuperMath.maxReals(posX - portee, posX + portee), SuperMath.maxReals(posY - portee, posY + portee))
        local unit unite
        local integer i = 0
        local integer tailleGroupe
        local integer id
        local boolean resultat = false
        call GroupEnumUnitsInRect(unites, rectangle, null)
        set tailleGroupe = BlzGroupGetSize(unites)
        loop
            exitwhen i == tailleGroupe
            set unite = BlzGroupUnitAt(unites, i)
            set id = GetUnitTypeId(unite)
            if estUneTour(id) then
                set resultat = true
                exitwhen true
            endif
            set i = i + 1
        endloop
        call RemoveRect(rectangle)
        call DestroyGroup(unites)
        set unite  = null
        set rectangle = null
        set unites = null
        return resultat
    endmethod

    public static method sonFini takes nothing returns nothing
        set entrainDeJouer = false
    endmethod

    private static method estUnMur takes integer id returns boolean
        if id == 'u002' or id == 'u003' or id == 'u004' or id == 'u005' or id == 'u006' or id == 'u00G' or id == 'u00K' or id == 'u00L' or id == 'u00M' or id == 'u00N' or id == 'u00Y' or id == 'u00Z' or id == 'u010' or id == 'u011' or id == 'u012' or id == 'u013' or id == 'u00E' or id == 'u00F' then
            return true
        endif
        return false
    endmethod

    private static method estUneTour takes integer id returns boolean
        if id == 'h001' or id == 'h002' or id == 'h003' or id == 'h004' or id == 'h005' or id == 'h006' or id == 'h007' or id == 'h008' or id == 'h009' or id == 'h00A' or id == 'h00B' or id == 'h00C' or id == 'h00D' or id == 'h00E' or id == 'h00F' then
            return true
        endif
        return false
    endmethod
endstruct