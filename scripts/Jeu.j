library librairieJeu

    function fonctionAmeliorationBatimentTroll takes nothing returns boolean
        local unit unite = GetTriggerUnit()
        local integer typeUnite = GetUnitTypeId(unite)
        if typeUnite == 'u00B' or typeUnite == 'u01A' or typeUnite == 'u019' then
            call BlzSetUnitSkin(unite, 'nth0')
            call SetUnitScale(unite, 0.750, 0.750, 0.0)
            call BlzSetUnitRealField(unite, UNIT_RF_SELECTION_SCALE, 2.0)
        endif
        set unite = null
        return false
    endfunction

    function fonctionFaireRevivreJeu takes nothing returns nothing
        call Jeu.faireRevivreJeu()
    endfunction

    function commencerPartie5 takes nothing returns nothing
        local sound son = CreateSound("Units\\Creeps\\ForestTroll\\ForestTrollPissed1.flac", false, false, false, 0, 0, "HeroAcksEAX")
        local rect zoneDepart = Jeu.getZoneDepart()
        local unit unite = Map.getBatimentTroll()
        local real xResultat = SuperMath.getTailleRegionX(zoneDepart) / 2 + SuperMath.minRectangleX(zoneDepart)
        local real yResultat = SuperMath.getTailleRegionY(zoneDepart) / 2 + SuperMath.minRectangleY(zoneDepart)
        local integer i = 0
        set Jeu.timeurJeu = 0
        set Jeu.troll = CreateUnit(Jeu.joueurTroll, 'H000', xResultat, yResultat, 270)
        call Jeu.construireDeclencheurUP()
        call Jeu.ajouterUniteGenerateur(unite)
        set unite = null
        call StartSound(son)
        call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "Let's have a look here shall we...")
        call KillSoundWhenDone(son)
        loop 
        exitwhen i == 12 
            if Jeu.elfs[i] != null then
                call SetUnitMoveSpeed(Jeu.elfs[i], GetUnitDefaultMoveSpeed(Jeu.elfs[i]))
            endif
            set i = i + 1
        endloop
        set zoneDepart = null
        set son = null
    endfunction

    function commencerPartie4 takes nothing returns nothing
        local sound son = CreateSound("Units\\Human\\HeroArchMage\\HeroArchMagePissed1.flac", false, false, false, 0, 0, "HeroAcksEAX")
        local player joueur
        local integer i = 0
        local rect zoneDepart = Jeu.getZoneDepart()
        local real xResultat = SuperMath.minRectangleX(zoneDepart)
        local real yResultat = SuperMath.minRectangleY(zoneDepart)
        set Jeu.joueurTroll = Player(Choix.choisirTroll(Jeu.choixJeu))
        call Map.definirProprietaireBatimentTroll(Jeu.joueurTroll, false)
        call Jeu.choixJeu.afficher(false, true, null)
        call Choix.supprimerChoix(Jeu.choixJeu)
        set Jeu.choixJeu = 0
        call Jeu.definirAllieeEtEnnemis()
        call Jeu.creerMultitable()
        call Jeu.roundABienCommencer()
        call DisplayTextToForce( bj_FORCE_ALL_PLAYERS, "The Troll is: |c" + Couleur.getCouleurHexJoueur(Jeu.joueurTroll) + GetPlayerName(Jeu.joueurTroll) + "|r")
        call EnableTrigger(gg_trg_UniteDetruite)
        loop 
        exitwhen i == 12
            set joueur = Player(i)
            if joueur != Jeu.joueurTroll and Jeu.estUnJoueur(joueur) then
                call SetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD) + 40 - Jeu.getSpeed() * 10)
                set Jeu.elfs[i] = CreateUnit(joueur, 'u000', xResultat + GetRandomReal(0, SuperMath.getTailleRegionX(zoneDepart)), yResultat + GetRandomReal(0, SuperMath.getTailleRegionY(zoneDepart)), 270.00)
                call SetUnitMoveSpeed(Jeu.elfs[i], 1000)
            else
                set Jeu.elfs[i] = null
            endif
            set i = i + 1
        endloop
        call StartSound(son)
        call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "The only chance we have of winning the war is to face them, despite the possible cons...")
        call KillSoundWhenDone(son)
        call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "You are walking in the woods, while the Troll is coming ..." )
        set son = null
        call Map.setBrouillard(FOG_OF_WAR_FOGGED, true)
        set zoneDepart = null
        set Jeu.timeurJeu = SuperTimeur.create(true, "The troll comes in:", true)
        call Jeu.timeurJeu.lancerTimer(30.0, function commencerPartie5)
    endfunction

    function commencerPartie3 takes nothing returns nothing
        call Choix.choisirVitesse(Jeu.choixJeu)
        call Jeu.choixJeu.afficher(false, true, null)
        call Choix.supprimerChoix(Jeu.choixJeu)
        call Jeu.reinitialiserOrHidding()
        set Jeu.choixJeu = Choix.creerChoix("Do you want to be the Troll ?", 2, true, true, "Beginning in:", true)
        call Choix.initialiserBouttons(Jeu.choixJeu, 2)
        call Jeu.choixJeu.afficher(true, true, null)
    endfunction

    function commencerPartie2 takes nothing returns nothing
        set Jeu.choixJeu = Choix.creerChoix("Wich speed do you want ?", 1, true, true, "Time remaining to choose:", true)
        call Choix.initialiserBouttons(Jeu.choixJeu, 1)
        call Jeu.choixJeu.afficher(true, true, null)
    endfunction

    struct Jeu
        public static constant real armureReduction = 0.060
        public static constant integer niveauAutoLevelUpStop = 10
        public static player joueurTroll = null
        public static unit troll = null
        public static unit array elfs[12]
        public static SuperTimeur timeurJeu
        public static Choix choixJeu

        private static rect zoneDepart
        private static multiboard multitable
        private static trigger batimentAmeliorer = null
        private static Generateur generateursOr
        private static HashMapUniteTimeur array loupsEtAnges[12] // 0 = jamais tué
        private static Joueur array joueurs[12]
        private static unit array unitesSelectionnes[12]
        private static integer nbJoueursPresents = 0
        private static integer nbEquipeTroll = 1
        private static integer nbElfsRestants = 0
        private static integer nbAnges = 0
        private static integer speed = 1
        private static integer orHidding = 0
        private static integer xpParSeconde = 0
        private static boolean roundACommencer = false

        public static method getIdJoueur takes player joueur returns integer
            return GetConvertedPlayerId(joueur) - 1
        endmethod

        /**
        * Cette fonction permet d'initialiser.
        *
        * @param nothing
        *
        * @return nothing
        */
        public static method initialiserJeu takes nothing returns nothing
            local player joueur
            local integer i = 0
            loop 
            exitwhen i == 12
                set joueur = Player(i)
                if estUnJoueur(joueur) then
                    set nbJoueursPresents = nbJoueursPresents + 1
                    set joueurs[i] = Joueur.create(i)
                endif
                set i = i + 1
            endloop
            set joueur = null
        endmethod

        /**
        * Cette fonction permet de commencer une partie sur une map spécifique choisi.
        * 
        * @param integer map
        *
        * @return nothing
        */
        public static method commencer takes nothing returns nothing
            local integer i = 0
            local player joueur
            call setZoneDepartMap(Map.getIDMap())
            set nbElfsRestants = 0
            loop
            exitwhen i == 12
                set joueur = Player(i)
                if estUnJoueur(joueur) then
                    call SetPlayerTechMaxAllowedSwap('u001', 1, joueur)
                    set nbElfsRestants = nbElfsRestants + 1
                endif
                set i = i + 1
            endloop
            set nbElfsRestants = nbElfsRestants - 1
            set joueur = null
            call initialiserGenerateurs()
            set timeurJeu = SuperTimeur.creerTimeur(false, "", true)
            call timeurJeu.lancerTimer(2.0, function commencerPartie2)
        endmethod

        public static method construireDeclencheurUP takes nothing returns nothing
            local event eventLeak
            local triggercondition tc
            local conditionfunc cf = Condition(function fonctionAmeliorationBatimentTroll)
            local integer mapID = Map.getIDMap()
            local unit unite = Map.getBatimentTroll()
            if mapID == 1 or mapID == 3 or mapID == 5 or mapID == 7 then
                set batimentAmeliorer = CreateTrigger()
                set eventLeak = TriggerRegisterPlayerUnitEvent(batimentAmeliorer, joueurTroll, EVENT_PLAYER_UNIT_UPGRADE_START, null)
                set tc = TriggerAddCondition(batimentAmeliorer, cf)
            endif
            set tc = null
            set cf = null
            set eventLeak = null
            set unite = null
        endmethod

        public static method roundABienCommencer takes nothing returns nothing
            set roundACommencer = true
        endmethod

        public static method getRoundACommencer takes nothing returns boolean
            return roundACommencer
        endmethod

        /**
        * Cette fonction permet d'initialiser les tableaux générateurs.
        *
        * @param nothing
        *
        * @return nothing
        */
        private static method initialiserGenerateurs takes nothing returns nothing
            set generateursOr = Generateur.create()
            call generateursOr.ajouterTypeUniteAutorise('u00B', 1)
            call generateursOr.ajouterTypeUniteAutorise('u001', 1)
            call generateursOr.ajouterTypeUniteAutorise('u007', 1)
            call generateursOr.ajouterTypeUniteAutorise('u008', 1)
            call generateursOr.ajouterTypeUniteAutorise('u009', 1)
            call generateursOr.ajouterTypeUniteAutorise('u00Q', 1)
            call generateursOr.ajouterTypeUniteAutorise('u00S', 1)
            call generateursOr.ajouterTypeUniteAutorise('u00T', 1)
            call generateursOr.ajouterTypeUniteAutorise('u00W', 1)
            call generateursOr.ajouterTypeUniteAutorise('u017', 1)
            call generateursOr.ajouterTypeUniteAutorise('u018', 1)
        endmethod

        /**
        * Cette fonction permet d'initialiser les mines d'or.
        *
        * @param nothing
        *
        * @return nothing
        */
        public static method initialiserMinesDors takes nothing returns nothing
            local player joueur
            local integer i = 0
            loop
            exitwhen i == 12
                set joueur = Player(i)
                if estUnJoueur(joueur) then
                    call definirVitesseMineDor('e00J', 'e00D', 'e00O', 'e00P', joueur)
                    call definirVitesseMineDor('e00S', 'e005', 'e00R', 'e00Q', joueur)
                    call definirVitesseMineDor('e00V', 'e00T', 'e00U', 'e001', joueur)
                    call definirVitesseMineDor('e008', 'e00W', 'e00X', 'e00Y', joueur)
                    call definirVitesseMineDor('e00Z', 'e009', 'e010', 'e011', joueur)
                    call definirVitesseMineDor('e012', 'e013', 'e014', 'e00K', joueur)
                    call definirVitesseMineDor('e015', 'e016', 'e017', 'e00L', joueur)
                    call definirVitesseMineDor('e019', 'e018', 'e01A', 'e00M', joueur)
                endif
                set i = i + 1
            endloop
            set joueur = null
        endmethod

        /**
        * Cette fonction permet de définir la vitesse pour une mine d'or entre ce 4 types.
        *
        * @param integer type1
        * @param integer type2
        * @param integer type3
        * @param integer type4
        * @param player joueur
        *
        * @return nothing
        */
        private static method definirVitesseMineDor takes integer type1, integer type2, integer type3, integer type4, player joueur returns nothing
            if speed == 1 then
                call SetPlayerTechMaxAllowedSwap(type1, 2147483648, joueur)
                call SetPlayerTechMaxAllowedSwap(type2, 0, joueur)
                call SetPlayerTechMaxAllowedSwap(type3, 0, joueur)
                call SetPlayerTechMaxAllowedSwap(type4, 0, joueur)
            elseif speed == 2 then
                call SetPlayerTechMaxAllowedSwap(type1, 0, joueur)
                call SetPlayerTechMaxAllowedSwap(type2, 2147483648, joueur)
                call SetPlayerTechMaxAllowedSwap(type3, 0, joueur)
                call SetPlayerTechMaxAllowedSwap(type4, 0, joueur)
            elseif speed == 3 then
                call SetPlayerTechMaxAllowedSwap(type1, 0, joueur)
                call SetPlayerTechMaxAllowedSwap(type2, 0, joueur)
                call SetPlayerTechMaxAllowedSwap(type3, 2147483648, joueur)
                call SetPlayerTechMaxAllowedSwap(type4, 0, joueur)
            elseif speed == 4 then
                call SetPlayerTechMaxAllowedSwap(type1, 0, joueur)
                call SetPlayerTechMaxAllowedSwap(type2, 0, joueur)
                call SetPlayerTechMaxAllowedSwap(type3, 0, joueur)
                call SetPlayerTechMaxAllowedSwap(type4, 2147483648, joueur)
            endif
        endmethod

        /**
        * Cette fonction permet de créer le multitable qui donne toutes les infos de ce qui se passe en jeu.
        * 
        * @param nothing
        *
        * @return nothing
        */
        public static method creerMultitable takes nothing returns nothing
            local multiboarditem emplacement
            local player joueur
            local integer array typesJoueurs // -1 = Troll, 0 = elfs, 1 = loups et 2 = ange
            local integer nbLoups = nbEquipeTroll - 1
            local integer i = 0
            local integer j = 0
            loop
            exitwhen i == 12
                set joueur = Player(i)
                if joueur != joueurTroll then
                    if loupsEtAnges[i] != 0 then
                        if loupsEtAnges[i].getTypeUniteHMUT() == 'H00D' then
                            set typesJoueurs[i] = 1
                        else
                            set typesJoueurs[i] = 2
                        endif
                    else
                        set typesJoueurs[i] = 0
                    endif
                else
                    set typesJoueurs[i] = -1
                endif
                set i = i + 1
            endloop
            set i = 0
            set multitable = CreateMultiboard()
            call MultiboardSetTitleText(multitable, "Troll And Elves Rebirth")
            call MultiboardSetColumnCount(multitable, 1)
            call MultiboardSetRowCount(multitable, nbEquipeTroll + nbElfsRestants + nbAnges + 8)
            call MultiboardSetItemsStyle(multitable, true, false)
            call MultiboardSetItemsWidth(multitable, 0.2)
            set emplacement = MultiboardGetItem(multitable, 0, 0)
            call MultiboardSetItemValue(emplacement, "Troll   -   " + I2S(nbEquipeTroll))
            set emplacement = MultiboardGetItem(multitable, 1, 0)
            call MultiboardSetItemValue(emplacement, "|c" + Couleur.getCouleurHexJoueur(joueurTroll) + getNomJoueur(joueurTroll) + "|r")
            call MultiboardSetItemIcon(emplacement, "ReplaceableTextures\\CommandButtons\\BTNDarkTroll.blp")
            call MultiboardSetItemStyle(emplacement, true, true)
            loop
            exitwhen i == 12
                if typesJoueurs[i] == 1 then
                    set joueur = Player(i)
                    set emplacement = MultiboardGetItem(multitable, i - j + 2 , 0)
                    call MultiboardSetItemValue(emplacement, "|c" + Couleur.getCouleurHexJoueur(joueur) + getNomJoueur(joueur) + "|r")
                    call MultiboardSetItemIcon(emplacement, "ReplaceableTextures\\CommandButtons\\BTNSpiritWolf.blp")
                    call MultiboardSetItemStyle(emplacement, true, true)
                else
                    set j = j + 1
                endif
                set i = i + 1
            endloop
            set i = 0
            set j = 0
            set emplacement = MultiboardGetItem(multitable, nbLoups + 2, 0)
            call MultiboardSetItemValue(emplacement, "|c00FFD700Gold in the hidding: " + I2S(orHidding) + "|r")
            set emplacement = MultiboardGetItem(multitable, nbLoups + 4, 0)
            call MultiboardSetItemValue(emplacement, "Elves   -   " + I2S(nbElfsRestants))
            loop
                exitwhen i == 12
                set joueur = Player(i)
                if estUnJoueur(joueur) and joueur != joueurTroll then
                    if typesJoueurs[i] == 0 then
                        set emplacement = MultiboardGetItem(multitable, nbLoups + j + 5, 0)
                        call MultiboardSetItemValue(emplacement, "|c" + Couleur.getCouleurHexJoueur(joueur) + getNomJoueur(joueur) + "|r")
                        call MultiboardSetItemIcon(emplacement, "ReplaceableTextures\\CommandButtons\\BTNElfVillager.blp")
                        call MultiboardSetItemStyle(emplacement, true, true)
                        set j = j + 1
                    elseif typesJoueurs[i] == 2 then
                        set emplacement = MultiboardGetItem(multitable, nbLoups + j + 5, 0)
                        call MultiboardSetItemValue(emplacement, "|c" + Couleur.getCouleurHexJoueur(joueur) + getNomJoueur(joueur) + "|r")
                        call MultiboardSetItemIcon(emplacement, "ReplaceableTextures\\CommandButtons\\BTNJaina.blp")
                        call MultiboardSetItemStyle(emplacement, true, true)
                        set j = j + 1
                    endif
                endif
                set i = i + 1
            endloop
            set emplacement = MultiboardGetItem(multitable, nbLoups + nbAnges + nbElfsRestants + 7, 0)
            call MultiboardSetItemValue(emplacement, "|c00FFD700Buy wood for: " + I2S(Market.getPrix()) + "|r")
            call MultiboardSetItemIcon(emplacement, "UI\\Feedback\\Resources\\ResourceLumber.blp")
            call MultiboardSetItemStyle(emplacement, true, true)
            set emplacement = MultiboardGetItem(multitable, nbLoups + nbAnges + nbElfsRestants + 8, 0)
            call MultiboardSetItemValue(emplacement, "|cff00ff00Sell wood for: " + I2S(Market.getPrix() - 10) + "|r")
            call MultiboardSetItemIcon(emplacement, "UI\\Feedback\\Resources\\ResourceGold.blp")
            call MultiboardSetItemStyle(emplacement, true, true)
            call MultiboardDisplay(multitable, true)
            set joueur = null
            set emplacement = null
        endmethod

        public static method actualiserMultitable takes nothing returns nothing
            call MultiboardDisplay(multitable, false)
            call MultiboardClear(multitable)
            call DestroyMultiboard(multitable)
            call creerMultitable()
        endmethod

        /**
        * Cette fonction permet d'actualiser le prix dans l'affichage du multitable
        * 
        * @param nothing
        *
        * @return nothing
        */
        public static method actualiserAffichagePrix takes nothing returns nothing
            local multiboarditem emplacement
            if multitable != null then
                set emplacement = MultiboardGetItem(multitable, nbEquipeTroll - 1 + nbAnges + nbElfsRestants + 7, 0)
                call MultiboardSetItemValue(emplacement, "|cff00ff00Buy wood for: " + I2S(Market.getPrix()) + "|r")
                set emplacement = MultiboardGetItem(multitable, nbEquipeTroll - 1 + nbAnges + nbElfsRestants + 8, 0)
                call MultiboardSetItemValue(emplacement, "|cff00ff00Sell wood for: " + I2S(Market.getPrix() - 10) + "|r")
            endif
        endmethod

        /**
        * Cette fonction permet d'actualiser le prix dans l'affichage du multitable
        * 
        * @param nothing
        *
        * @return nothing
        */
        public static method actualiserOrHidding takes nothing returns nothing
            local multiboarditem emplacement
            if multitable != null then
                set emplacement = MultiboardGetItem(multitable, nbEquipeTroll - 1 + 2, 0)
                call MultiboardSetItemValue(emplacement, "|c00FFD700Gold in the hidding: " + I2S(orHidding) + "|r")
            endif
        endmethod

        /**
        * Cette fonction permet de savoir si c'est un joueur humain.
        * 
        * @param player joueur
        *
        * @return boolean
        */
        public static method estUnJoueur takes player joueur returns boolean
            local mapcontrol mapControl =  GetPlayerController(joueur)
            local playerslotstate playerSlotState = GetPlayerSlotState(joueur)
            if mapControl == MAP_CONTROL_USER and playerSlotState == PLAYER_SLOT_STATE_PLAYING then
                set mapControl = null
                set playerSlotState = null
                return true
            endif
            set mapControl = null
            set playerSlotState = null
            return false
        endmethod

        /**
        * Cette fonction permet de définir les alliances entre joueurs
        *
        * @param nothing
        *
        * @return nothing
        */
        public static method definirAllieeEtEnnemis takes nothing returns nothing
            local player joueur1 = null
            local player joueur2 = null
            local integer i = 0
            local integer j = 0
            loop 
            exitwhen i == 12
                set joueur1 = Player(i)
                loop
                exitwhen j == 12
                    set joueur2 = Player(j)
                    if joueur1 != joueur2 then
                        if joueur1 == joueurTroll or joueur2 == joueurTroll then
                            call SetPlayerAllianceStateBJ(joueur1, joueur2, bj_ALLIANCE_UNALLIED)
                        else
                            call SetPlayerAllianceStateBJ(joueur1, joueur2, bj_ALLIANCE_ALLIED_VISION)
                        endif
                    endif
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
            set joueur1 = null
            set joueur2 = null
        endmethod 

        public static method allierJoueurAuTroll takes player joueur returns nothing
            local player joueurTemp
            local integer i = 0
            loop
            exitwhen i == 12
                set joueurTemp = Player(i)
                if joueurTemp == joueurTroll then
                    call SetPlayerAllianceStateBJ(joueur, joueurTemp, bj_ALLIANCE_ALLIED_VISION)
                    call SetPlayerAllianceStateBJ(joueurTemp, joueur, bj_ALLIANCE_ALLIED_VISION)
                else
                    call SetPlayerAllianceStateBJ(joueur, joueurTemp, bj_ALLIANCE_UNALLIED)
                    call SetPlayerAllianceStateBJ(joueurTemp, joueur, bj_ALLIANCE_UNALLIED)
                endif
                set i = i + 1
            endloop
            set joueurTemp = null
        endmethod

        /**
        * Cette fonction permet de d'obtenir la région de départ en fonction de l'identifiant de la map.
        *
        * @param integer map
        *
        * @return nothing
        */
        private static method setZoneDepartMap takes integer map returns nothing
            if map == 1 then
                set zoneDepart = Rect(5696.00, 6848.00, -24416.00, -23232.00)
            elseif map == 2 then
                set zoneDepart = Rect(19008.00, 19904.00, -20800.00, -20032.00)
            elseif map == 3 then
                set zoneDepart = Rect(15776.00, 16992.00, -28768.00, -27552.00)
            elseif map == 4 then
                set zoneDepart = Rect(27200.00, 28096.00, -28608.00, -27712.00)
            elseif map == 5 then
                set zoneDepart = Rect(27168.00, 28128.00, -21216.00, -20288.00)
            elseif map == 6 then
                set zoneDepart = Rect(21856.00, 22976.00, -9280.00, -8128.00)
            elseif map == 7 then
                set zoneDepart = Rect(8704.00, 9728.00, -11776.00, -10752.00)
            elseif map == 8 then
                set zoneDepart = Rect(8640.00, 9792.00, -2880.00, -1728.00)
            else 
                set zoneDepart = Rect(2432.00, 3456.00, -11776.00, -10624.00)
            endif
        endmethod

        public static method getZoneAngeMilieu takes location localisation returns location
            local integer idMap = Map.getIDMap()
            if idMap == 1 then
                set localisation = Location(5888, -16800)
            elseif idMap == 2 then
                set localisation = Location(23392, -20096)
            elseif idMap == 3 then
                set localisation = Location(15392, -28160)
            elseif idMap == 4 then
                set localisation = Location(27904, -26720)
            elseif idMap == 5 then
                set localisation = Location(27648, -17056)
            elseif idMap == 6 then
                set localisation = Location(23808, -14688)
            elseif idMap == 7 then
                set localisation = Location(8704, -7328)
            elseif idMap == 8 then
                set localisation = Location(9216, -4960)
            else
                set localisation = Location(2688, -1376)
            endif
            return localisation
        endmethod

        /**
        * Cette fonction permet d'obtenir la zone de départ la ou il y a le camp du Troll.
        *
        * @param nothing
        *
        * @return rect
        */
        public static method getZoneDepart takes nothing returns rect
            return zoneDepart
        endmethod

        /**
        * Cette fonction permet d'ajouter une unité a l'une des listes de générateurs
        *
        * @param unit unite
        *
        * @return nothing
        */
        public static method ajouterUniteGenerateur takes unit unite returns boolean
            local player joueur
            if generateursOr.ajouterUniteGeneratrice(unite) then
                if GetUnitTypeId(unite) == 'u001' then
                    set joueur = GetOwningPlayer(unite)
                    call SetPlayerTechMaxAllowedSwap('u001', 0, joueur)
                    set joueur = null
                endif
                return true
            endif
            return false
        endmethod

        /**
        * Cette fonction permet d'enlever une unité de l'une des listes de générateurs
        *
        * @param unit unite
        *
        * @return nothing
        */
        public static method enleverUniteGenerateur takes unit unite returns boolean
            local player joueur
            if generateursOr.enleverUniteGeneratrice(unite) then
                set joueur = GetOwningPlayer(unite)
                call SetPlayerTechMaxAllowedSwap('u001', 1, joueur)
                set joueur = null
                return true
            endif
            return false
        endmethod

        public static method setUniteSelectionne takes player joueur, unit uniteSelectionne returns nothing
            set unitesSelectionnes[getIdJoueur(joueur)] = uniteSelectionne
        endmethod

        public static method donnerOB takes player joueur, string message, playerstate ob returns nothing
            local player joueurTemp = GetOwningPlayer(unitesSelectionnes[getIdJoueur(joueur)])
            local integer nb = S2I(SubString(message, 4, StringLength(message)))
            local integer nbOr = GetPlayerState(joueur, ob)
            local string typeRessource
            local string couleur
            if ob == PLAYER_STATE_RESOURCE_GOLD then
                set typeRessource = "gold|r"
                set couleur = "|c00FFD700"
            else
                set typeRessource = "lumber|r"
                set couleur = "|c0000FF00"
            endif
            if nb > 0 and GetPlayerAlliance(joueur, joueurTemp, ALLIANCE_SHARED_VISION) then
                if nb > nbOr then
                    call SetPlayerState(joueur, ob, 0)
                    call SetPlayerState(joueurTemp, ob, GetPlayerState(joueurTemp, ob) + nbOr)
                    call DisplayTextToPlayer(joueur, 0, 0, "You gave " + couleur + I2S(nbOr) + " " + typeRessource + " to |c" + Couleur.getCouleurHexJoueur(joueurTemp) + getNomJoueur(joueurTemp) + "|r")
                    call DisplayTextToPlayer(joueurTemp, 0, 0, "You received " + couleur + I2S(nbOr) + " " + typeRessource + " from |c" + Couleur.getCouleurHexJoueur(joueur) + getNomJoueur(joueur) + "|r")
                else
                    call SetPlayerState(joueur, ob, nbOr - nb)
                    call SetPlayerState(joueurTemp, ob, GetPlayerState(joueurTemp, ob) + nb)
                    call DisplayTextToPlayer(joueur, 0, 0, "You have gave " + couleur + I2S(nb) + " " + typeRessource + " to |c" + Couleur.getCouleurHexJoueur(joueurTemp) + getNomJoueur(joueurTemp) + "|r")
                    call DisplayTextToPlayer(joueurTemp, 0, 0, "You received " + couleur + I2S(nb) + " " + typeRessource + " from |c" + Couleur.getCouleurHexJoueur(joueur) + getNomJoueur(joueur) + "|r")
                endif
            endif
        endmethod


        /**
        * Cette fonction permet de détruire la base d'un elf instantannément ou non.
        *
        * @param player joueur
        * @param boolean detruireBaseInstantannement
        *
        * @return nothing
        */
        public static method unElfEstMort takes player joueur, boolean detruireBaseInstantannement returns nothing
            local Choix choix
            set nbElfsRestants = nbElfsRestants - 1
            if nbElfsRestants == 0 then
                call partieTerminer()
            else
                call detruireUnites(joueur, detruireBaseInstantannement)
                set choix = Choix.creerChoix("Who do you want to help ?", 3, true, false, "", true)
                call Choix.initialiserBouttons(choix, 3)
                call choix.afficher(true, false, joueur)
                set choix = 0
            endif
        endmethod

        public static method elfMortTransformer takes integer typeChoix, integer idJoueur returns nothing
            local unit unite
            local player joueur = Player(idJoueur)
            local location localisation = null
            if typeChoix == 0 then
                call SetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD, 0)
                call SetPlayerState(joueur, PLAYER_STATE_RESOURCE_LUMBER, 0)
                set localisation = getZoneAngeMilieu(localisation)
                set unite = CreateUnit(joueur, 'u00R', GetLocationX(localisation), GetLocationY(localisation), 270)
                call RemoveLocation(localisation)
                set localisation = null
                set loupsEtAnges[idJoueur] = HashMapUniteTimeur.create(unite)
                set nbAnges = nbAnges + 1
                call actualiserMultitable()
            elseif typeChoix == 1 then
                call SetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD) / 2 + GetPlayerState(joueur, PLAYER_STATE_RESOURCE_LUMBER) / 1000 / 2)
                call SetPlayerState(joueur, PLAYER_STATE_RESOURCE_LUMBER, 0)
                call allierJoueurAuTroll(joueur)
                set unite = CreateUnit(joueur, 'H00D', SuperMath.getTailleRegionX(zoneDepart) / 2 + SuperMath.minRectangleX(zoneDepart), SuperMath.getTailleRegionY(zoneDepart) / 2 + SuperMath.minRectangleY(zoneDepart), 270)
                set loupsEtAnges[idJoueur] = HashMapUniteTimeur.create(unite)
                set nbEquipeTroll = nbEquipeTroll + 1
                call actualiserMultitable()
            endif
            set joueur = null
        endmethod

        public static method faireRevivreJeu takes nothing returns nothing
            local timer timeur = GetExpiredTimer()
            local location localisation = null
            local integer i = 0
            loop
            exitwhen i == 12
                if loupsEtAnges[i] != 0 and loupsEtAnges[i].egaleHMUT(timeur) then
                    if loupsEtAnges[i].getTypeUniteHMUT() == 'u00R' then
                        set localisation = getZoneAngeMilieu(localisation)
                        call loupsEtAnges[i].revivreHMUT(GetLocationX(localisation), GetLocationY(localisation))
                        set localisation = null
                    else
                        call loupsEtAnges[i].revivreHMUT(SuperMath.getTailleRegionX(zoneDepart) / 2 + SuperMath.minRectangleX(zoneDepart), SuperMath.getTailleRegionY(zoneDepart) / 2 + SuperMath.minRectangleY(zoneDepart))
                    endif
                    exitwhen true
                endif
                set i = i + 1
            endloop
            set timeur = null
        endmethod

        public static method loupOuAngeMeurt takes integer idJoueur returns nothing
            call loupsEtAnges[idJoueur].lancerTimerHMUT(10.0, function fonctionFaireRevivreJeu)
        endmethod

        public static method getLoupOuAnge takes timer timeur, player joueur returns HashMapUniteTimeur
            local integer i = 0
            if timeur != null then
                loop
                exitwhen i == 12
                    if loupsEtAnges[i].egaleHMUT(timeur) then
                        return loupsEtAnges[i]
                    endif
                    set i = i + 1
                endloop
            else
                return loupsEtAnges[getIdJoueur(joueur)]
            endif
            return 0 // #CompilateurDebilos
        endmethod

        /**
        * Cette fonction permet d'obtenir la vitesse actuel.
        *
        * @param nothing
        *
        * @return integer
        */
        public static method getSpeed takes nothing returns integer
            return speed
        endmethod

        /**
        * Cette fonction permet de définir la vitesse.
        *
        * @param integer speedVar
        *
        * @return nothing
        */
        public static method setSpeed takes integer speedVar returns nothing
            set speed = speedVar
            set xpParSeconde = 2 * speed
            call initialiserMinesDors()
        endmethod

        public static method getNbJoueurs takes nothing returns integer
            return nbJoueursPresents
        endmethod

        public static method ajouterXpTL takes nothing returns nothing
            local integer i = 0
            local unit unite
            if troll != null then
                call SetHeroXP(troll, GetHeroXP(troll) + xpParSeconde, true)
            endif
            loop
            exitwhen i == 12
                if loupsEtAnges[i] != 0 and loupsEtAnges[i].getTypeUniteHMUT() == 'H00D' then
                    set unite = loupsEtAnges[i].getUniteHMUT()
                    call SetHeroXP(unite, GetHeroXP(unite) + xpParSeconde, true)
                endif
                set i = i + 1
            endloop
            set unite = null
        endmethod

        /**
        * Cette fonction permet de gagner de l'or tel que les maisons ou les mines d'or.
        *
        * @param nothing
        *
        * @return nothing
        */
        public static method gainOr takes nothing returns nothing
            local texttag textTag
            local HashMapGenerateur hmg
            local unit unite
            local player joueurProprietaire = null
            local real pointValeur
            local integer i = 0
            local integer taille = generateursOr.getTailleTableau()
            loop
            exitwhen i == taille
                set hmg = generateursOr.getGenerateur(i)
                if hmg != 0 then
                    set unite = hmg.getUnite()
                    set pointValeur = GetUnitPointValue(unite)
                    set joueurProprietaire = GetOwningPlayer(unite)
                    set textTag = CreateTextTag()
                    call disparaitreTextTag(textTag, joueurProprietaire)
                    if pointValeur >= 0 then
                        call SetTextTagText(textTag, "+" + I2S(R2I(pointValeur * speed)), 0.025)
                    else
                        call SetTextTagText(textTag, "-" + I2S(R2I(pointValeur * speed)), 0.025)
                    endif
                    call SetTextTagColor(textTag, 255, 220, 0, 255)
                    call SetTextTagPos(textTag, GetUnitX(unite), GetUnitY(unite), 0.00)
                    call SetTextTagPermanent(textTag, false)
                    call SetTextTagLifespan(textTag, 3)
                    call SetTextTagFadepoint(textTag, 2)
                    call SetTextTagVelocity(textTag, 0, 0.03)
                    call AdjustPlayerStateBJ(R2I(pointValeur * speed), joueurProprietaire, PLAYER_STATE_RESOURCE_GOLD)
                endif
                set i = i + 1
            endloop
            set textTag = null
            set joueurProprietaire = null
        endmethod

        /**
        * Cette fonction permet de montrer le texttag d'une unité a seulement celui qui possède cette unité
        * pour éviter de faire lager les autres joueurs.
        *
        * @param texttag textag
        * @param player joueur
        *
        * @return nothing
        */
        private static method disparaitreTextTag takes texttag textag, player joueur returns nothing
            local player joueurTemp = GetLocalPlayer()
            if joueurTemp != joueur then
                call SetTextTagVisibility(textag, false)
            endif
            set joueurTemp = null
        endmethod

        public static method setOrHidding takes integer degats returns nothing
            local integer resultat = degats * 2 * speed
            if troll != null and resultat > orHidding  then
                set orHidding = resultat
                call Jeu.actualiserOrHidding()
            endif
        endmethod

        public static method getOrHidding takes nothing returns integer
            return orHidding
        endmethod

        public static method reinitialiserOrHidding takes nothing returns nothing
            set orHidding = 5 * 2 * speed
        endmethod

        /**
        * Cette fonction permet de détruire toutes les unités d'un joueur.
        * PS: pour l'instant c'est instantannée
        *
        * @param player joueur
        * @param boolean detruireInstantannement
        *
        * @return nothing
        */
        private static method detruireUnites takes player joueur, boolean detruireInstannement returns nothing
            local group groupeUnites = CreateGroup()
            local unit unite
            local integer i = -1
            local integer tailleGroupe
            call GroupEnumUnitsOfPlayer(groupeUnites, joueur, null)
            set tailleGroupe = BlzGroupGetSize(groupeUnites)
            loop
                set i = i + 1
                set unite = BlzGroupUnitAt(groupeUnites, i)
                call KillUnit(unite)
                call RemoveUnit(unite)
            exitwhen i == tailleGroupe
            endloop
            // J'ai la flemme de faire le truc instantannément.
            call DestroyGroup(groupeUnites)
            set unite = null
            set groupeUnites = null
        endmethod

        public static method getNomJoueur takes player joueur returns string
            return joueurs[getIdJoueur(joueur)].getNom(true)
        endmethod

        public static method definirDistanceJoueur takes player joueur, string message returns nothing
            call joueurs[getIdJoueur(joueur)].setDistanceCamera(I2R(S2I(SubString(message, 9, StringLength(message)))))
        endmethod

        public static method definirRotationJoueur takes player joueur, string message returns nothing
            call joueurs[getIdJoueur(joueur)].setRotationCamera(I2R(S2I(SubString(message, 9, StringLength(message)))))
        endmethod

        public static method getElfJoueur takes integer idJoueur returns unit
            return elfs[idJoueur]
        endmethod

        public static method joueurQuitte takes player leJoueur returns nothing
            local player joueur
            local integer idJoueur = Jeu.getIdJoueur(leJoueur)
            set nbJoueursPresents = nbJoueursPresents - 1
            if roundACommencer then
                if leJoueur == joueurTroll then
                    call partieTerminer()
                elseif nbElfsRestants == 1 then
                    call partieTerminer()
                elseif loupsEtAnges[idJoueur] != 0 then
                    call loupsEtAnges[idJoueur].detruireHMUT()
                    set loupsEtAnges[idJoueur] = 0
                else
                    call detruireUnites(leJoueur, false)
                    call actualiserMultitable()
                    set nbElfsRestants = nbElfsRestants - 1
                endif
            endif
            set joueur = Map.getChoisisseur() 
            if leJoueur == joueur then
                call Map.definirChoisiseurDeMap()
            endif
        endmethod

        /**
        * Cette fonction permet de terminer la partie actuel et de tout réinitialiser à zéro.
        *
        * @param nothing
        *
        * @return nothing
        */
        public static method partieTerminer takes nothing returns nothing
            local integer i = 0
            local player joueur = Player(PLAYER_NEUTRAL_PASSIVE)
            set roundACommencer = false
            if batimentAmeliorer != null then
                call DisableTrigger(batimentAmeliorer)
                call DestroyTrigger(batimentAmeliorer)
                set batimentAmeliorer = null
            endif
            call DisableTrigger(gg_trg_UniteDetruite)
            call MultiboardClear(multitable)
            call DestroyMultiboard(multitable)
            set multitable = null
            call generateursOr.detruireGenerateur()
            call Map.definirProprietaireBatimentTroll(joueur, true)
            if GetUnitState(troll, UNIT_STATE_LIFE) <= 0 then
                call KillUnit(troll)
            endif
            call RemoveUnit(troll)
            set joueurTroll = null
            set troll = null
            call RemoveRect(zoneDepart)
            set zoneDepart = null
            set i = 0
            loop
            exitwhen i == 12
                set joueur = Player(i)
                call SetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD, 0)
                call SetPlayerState(joueur, PLAYER_STATE_RESOURCE_LUMBER, 0)
                set elfs[i] = null
                call loupsEtAnges[i].detruireHMUT()
                call detruireUnites(joueur, true)
                set i = i + 1
            endloop
            set joueur = null
            call Map.reactiverMap()
            call EnableTrigger(gg_trg_Camera)
            call DisableTrigger(gg_trg_Jeu)
        endmethod
        
    endstruct
endlibrary