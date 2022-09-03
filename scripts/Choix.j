function choisirAleatoirementLoupAnge takes nothing returns nothing
    local timer timeur = GetExpiredTimer()
    local Choix choix = Choix.getChoixParTimer(timeur)
    local player joueur = choix.getJoueur()
    call Jeu.elfMortTransformer(GetRandomInt(0, 1), Jeu.getIdJoueur(joueur))
    set joueur = null
    call choix.supprimerChoix(choix)
    set choix = 0
    set timeur = null
endfunction

function choixUpMap takes nothing returns nothing
    call Map.mapChoisi()
endfunction

function choixConditions takes nothing returns nothing
    local dialog dialogue = GetClickedDialog()
    local button boutton = GetClickedButton()
    local player joueur = GetTriggerPlayer()
    call Choix.detecterBoutton(dialogue, boutton, joueur)
    set joueur = null
    set boutton = null
    set dialogue = null
endfunction

// function choixAutoDestruction takes nothing returns nothing
//     local timer timeur = GetExpiredTimer()
//     local Choix choix = Choix.getChoixParTimer(timeur)
//     call choix.executerFonctionChoix()
//     call Choix.supprimerChoix(choix)
//     set choix = 0
//     set timeur = null
// endfunction

struct Choix

    private static thistype array choixs[14]
    private static integer indexChoix = 0
    private static integer nbChoixNull = 0

    private dialog dialogue = null
    private button array bouttons[3]
    private trigger declencheurBouttons
    private SuperTimeur timeurChoix = 0
    private player joueur
    private integer fonctionAExecuter
    private integer typeDialogue = -1
    private integer indexBouttons = 0
    private integer bouttonsNull = 0
    private integer array choixJoueurs[12]
    private integer nbJoueursRestant = 0

    public static method creerChoix takes string titre, integer fonctionAExecuter, boolean creerUnTimeur, boolean afficherST, string titreST, boolean sautoDetruireST returns thistype
        local integer i = 0
        if nbChoixNull == 0 then
            set choixs[indexChoix] = thistype.create(titre, fonctionAExecuter, creerUnTimeur, afficherST, titreST, sautoDetruireST)
            set indexChoix = indexChoix + 1
            return choixs[indexChoix - 1]
        else
            loop
            exitwhen i == 14
                if choixs[i] == 0 then
                    set choixs[i] = thistype.create(titre, fonctionAExecuter, creerUnTimeur, afficherST, titreST, sautoDetruireST)
                    set nbChoixNull = nbChoixNull - 1
                    return choixs[i]
                endif
                set i = i + 1
            endloop
        endif
        return 0
    endmethod

    public static method create takes string titre, integer fonctionAExecuter, boolean creerUnTimeur, boolean afficherST, string titreST, boolean sautoDetruireST returns thistype
        local thistype choix = thistype.allocate()
        call choix.initialiserDialogue(titre, fonctionAExecuter, creerUnTimeur, afficherST, titreST, sautoDetruireST)
        return choix
    endmethod

    public method initialiserDialogue takes string titre, integer fonctionAExecuter, boolean creerUnTimeur, boolean afficherST, string titreST, boolean sautoDetruireST returns nothing
        local integer i = 0
        local conditionfunc cf = Condition(function choixConditions)
        set dialogue = DialogCreate()
        call DialogSetMessage(dialogue, titre)
        set declencheurBouttons = CreateTrigger()
        call TriggerRegisterDialogEvent(declencheurBouttons, dialogue)
        call TriggerAddCondition(declencheurBouttons, cf)
        set this.fonctionAExecuter = fonctionAExecuter
        if creerUnTimeur then
            set timeurChoix = SuperTimeur.create(afficherST, titreST, sautoDetruireST)
        endif
        set cf = null
    endmethod

    public method ajouterBoutton takes string message, integer caractere returns nothing
        local integer i = 0
        if bouttonsNull == 0 then
            set bouttons[indexBouttons] = DialogAddButton(dialogue, message, caractere)
            set indexBouttons = indexBouttons + 1
        else
            loop
            exitwhen i == indexBouttons
                if bouttons[i] == null then
                    set bouttons[i] = DialogAddButton(dialogue, message, caractere)
                    set bouttonsNull = bouttonsNull - 1
                endif
                set i = i + 1
            endloop
        endif
    endmethod

    public static method initialiserBouttons takes thistype choix, integer typeDialogue returns nothing
        call choix.setTypeDialogue(typeDialogue)
        if typeDialogue == 0 or typeDialogue == 2 then
            call choix.ajouterBoutton("|cff00ff00Y|cff30ff30es", $59)
            call choix.ajouterBoutton("|cffff0000N|cffff3030o", $4E)
        elseif typeDialogue == 1 then
            call choix.ajouterBoutton("|cffff0000x|cffff30301", $31)
            call choix.ajouterBoutton("|cff0000ffx2|r", $32)
            call choix.ajouterBoutton("|cff00ff00x|cff30ff303", $33)
            call choix.ajouterBoutton("|cff00ffffx4|r", $34)
        elseif typeDialogue == 3 then
            call choix.ajouterBoutton("|cff00ff00E|cff30ff30lf(s)", $45)
            call choix.ajouterBoutton("|cffff0000T|cffff3030roll", $54)
        endif
    endmethod

    public method setTypeDialogue takes integer typeDialogue returns nothing
        set this.typeDialogue = typeDialogue
    endmethod

    public method afficher takes boolean faireAfficher, boolean pourToutLeMonde, player joueur returns nothing
        local integer i = 0
        local player joueurTemp
        if pourToutLeMonde then
            loop
            exitwhen i == 12
                set joueurTemp = Player(i)
                set choixJoueurs[i] = -1
                if Jeu.estUnJoueur(joueurTemp) then
                    call DialogDisplay(joueurTemp, dialogue, faireAfficher)
                    set nbJoueursRestant = nbJoueursRestant + 1
                endif
                set i = i + 1
            endloop
            set joueurTemp = null
        else
            call DialogDisplay(joueur, dialogue, faireAfficher)
            set this.joueur = joueur
            set nbJoueursRestant = nbJoueursRestant + 1
        endif
        if timeurChoix != 0 then
            call timeurChoix.lancerTimer(10.0, getFonctionCH(this, fonctionAExecuter))
        endif
    endmethod

    public static method afficherMessage takes integer idBoutton, integer typeDialogue returns nothing
        local player joueur = GetTriggerPlayer()
        if typeDialogue == 1 then
            if idBoutton == 0 then
                call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "|c" + Couleur.getCouleurHexJoueur(joueur) + Jeu.getNomJoueur(joueur) + "|r has chose |cffff0000s|r|cffff3030peed x1|r")
            elseif idBoutton == 1 then
                call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "|c" + Couleur.getCouleurHexJoueur(joueur) + Jeu.getNomJoueur(joueur) + "|r has chose |cff0000ffspeed x2|r")
            elseif idBoutton == 2 then
                call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "|c" + Couleur.getCouleurHexJoueur(joueur) + Jeu.getNomJoueur(joueur) + "|r has chose |cff00ff00s|r|cff30ff30peed x3|r")
            else
                call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "|c" + Couleur.getCouleurHexJoueur(joueur) + Jeu.getNomJoueur(joueur) + "|r has chose |cff00ffffspeed x4|r")
            endif
        elseif typeDialogue == 2 then
            if idBoutton == 0 then
                call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "|c" + Couleur.getCouleurHexJoueur(joueur) + Jeu.getNomJoueur(joueur) + "|r wants to be the Troll")
            else
                call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "|c" + Couleur.getCouleurHexJoueur(joueur) + Jeu.getNomJoueur(joueur) + "|r doesn't wants to be the Troll.")
            endif
        elseif typeDialogue == 3 then
            if idBoutton == 0 then
                call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "|c" + Couleur.getCouleurHexJoueur(joueur) + Jeu.getNomJoueur(joueur) + "|r wants to help elf(s).")
            else
                call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "|c" + Couleur.getCouleurHexJoueur(joueur) + Jeu.getNomJoueur(joueur) + "|r wants to help the troll")
            endif
        endif
    endmethod

    public static method detecterBoutton takes dialog dialogue, button boutton, player joueur returns nothing
        local integer i = 0
        loop
        exitwhen i == indexChoix
            if choixs[i].egale(dialogue) then
                call choixs[i].ajouterChoixJoueur(boutton, joueur)
            endif
            set i = i + 1
        endloop
    endmethod

    /**
    * Cette fonction permet de choisir la vitesse du gain de l'or.
    * PS: NE TOUCHEZ PAS A CETTE FUCKING FONCTION DE MUISE !!!!!
    *
    * @param Choix choix
    *
    * @return nothing
    */
    public static method choisirVitesse takes thistype choix returns nothing
        local integer array vitesses
        local integer i = 0
        local integer j = 0
        local integer k = 0
        local integer l = 0
        local integer entierTemp

        loop
        exitwhen i == 12
            set entierTemp = choix.getChoixJoueur(i)
            if entierTemp != -1 then
                set vitesses[entierTemp] = vitesses[entierTemp] + 1
            endif
            set i = i + 1
        endloop
        set i = 0

        if vitesses[0] > vitesses[1] and vitesses[0] > vitesses[2] and vitesses[0] > vitesses[3] then
            call Jeu.setSpeed(1)
        elseif vitesses[1] > vitesses[0] and vitesses[1] > vitesses[2] and vitesses[1] > vitesses[3] then
            call Jeu.setSpeed(2)
        elseif vitesses[2] > vitesses[1] and vitesses[2] > vitesses[0] and vitesses[2] > vitesses[3] then
            call Jeu.setSpeed(3)
        elseif vitesses[3] > vitesses[1] and vitesses[3] > vitesses[2] and vitesses[3] > vitesses[0] then
            call Jeu.setSpeed(4)
        elseif vitesses[0] == vitesses[1] and vitesses[1] == vitesses[2] and vitesses[2] == vitesses[3] then
            set entierTemp = GetRandomInt(1, 3)
            if entierTemp == 1 then
                call Jeu.setSpeed(1)
            elseif entierTemp == 2 then
                call Jeu.setSpeed(2)
            elseif entierTemp == 3 then
                call Jeu.setSpeed(3) 
            else
                call Jeu.setSpeed(4) 
            endif
        else
            loop
            exitwhen i == 4
                if vitesses[i] == 0 then
                    set vitesses[i] = (i + 1) * -1
                endif
                set i = i + 1
            endloop
            set i = 0
            loop
            exitwhen i == 4
                loop
                    loop
                        if j != i then
                            exitwhen true
                        endif
                        set j = j + 1
                    endloop
                    exitwhen j >= 4
                    loop
                        loop
                            if k != i and k != j then
                                exitwhen true
                            endif
                            set k = k + 1
                        endloop
                        exitwhen k >= 4
                        loop
                            loop
                                if l != i and l != j and l != k then
                                    exitwhen true
                                endif
                                set l = l + 1
                            endloop
                            exitwhen l >= 4
                            if vitesses[i] == vitesses[j] and vitesses[j] == vitesses[k] and vitesses[j] != vitesses[l] then
                                set entierTemp = GetRandomInt(1, 3)
                                if entierTemp == 1 then
                                    call Jeu.setSpeed(i + 1)
                                elseif entierTemp == 2 then
                                    call Jeu.setSpeed(j + 1)
                                else
                                    call Jeu.setSpeed(k + 1) 
                                endif
                                return
                            elseif vitesses[i] == vitesses[j] and vitesses[j] != vitesses[k] and vitesses[j] != vitesses[l] then
                                set entierTemp = GetRandomInt(1, 2)
                                if entierTemp == 1 then
                                    call Jeu.setSpeed(i + 1)
                                else
                                    call Jeu.setSpeed(j + 1)
                                endif
                                return
                            endif
                            set l = l + 1
                        endloop
                        set l = 0
                        set k = k + 1
                    endloop
                    set k = 0
                    set j = j + 1
                endloop
                set j = 0
                set i = i + 1
            endloop
        endif
    endmethod

    public static method choisirTroll takes thistype choix returns integer
        local player joueur
        local integer i = 0
        local integer j = 0
        local boolean array idJoueurs
        loop
        exitwhen i == 12
            if choix.getChoixJoueur(i) == 0 then
                set j = j + 1
                set idJoueurs[i] = true
            else
                set idJoueurs[i] = false
            endif
            set i = i + 1
        endloop

        if j == 0 then
            set i = GetRandomInt(0, 11)
            loop
                set joueur = Player(i)
                if Jeu.estUnJoueur(joueur) then
                    set joueur = null
                    return i
                endif
                set i = i + 1
                if i == 12 then
                    set i = 0
                endif
            endloop
        else
            set i = 0
            set j = GetRandomInt(0, j)
            loop
                if j == 0 then
                    if idJoueurs[i] == true then
                        return i
                    endif
                else
                   set j = j - 1 
                endif
                set i = i + 1
                if i == 12 then
                    set i = 0
                endif
            endloop
        endif
        return 0 // Techniquement on y arrivera jamais a cet endroit. (Juste pour faire plaisir au compilateur)
    endmethod

    public method ajouterChoixJoueur takes button boutton, player joueur returns nothing
        local integer i = 0
        local integer idJoueur = Jeu.getIdJoueur(joueur)
        loop
        exitwhen i == indexBouttons
            if bouttons[i] != null and bouttons[i] == boutton then
                set choixJoueurs[idJoueur] = i
                call afficherMessage(i, typeDialogue)
                set nbJoueursRestant = nbJoueursRestant - 1
                if nbJoueursRestant == 0 then
                    call timeurChoix.detruireST()
                    set timeurChoix = 0
                    if typeDialogue != 3 then
                        call executerFonctionChoix()
                    else
                        call Jeu.elfMortTransformer(this.getChoixJoueur(idJoueur), idJoueur)
                    endif
                    return
                endif
            endif
            set i = i + 1
        endloop
    endmethod

    public method getJoueur takes nothing returns player
        return joueur
    endmethod

    public method getChoixJoueur takes integer idJoueur returns integer
        return choixJoueurs[idJoueur]
    endmethod

    private static method getFonctionCH takes thistype choix, integer fonctionAExecuter returns code
        local integer typeDialogue = choix.getTypeDialogue()
        if typeDialogue == 0 then
            return function choixUpMap
        elseif typeDialogue == 1 then
            return function commencerPartie3
        elseif typeDialogue == 2 then
            return function commencerPartie4
        elseif typeDialogue == 3 then
            return function choisirAleatoirementLoupAnge
        endif
        return function DoNothing
    endmethod

    public method getTypeDialogue takes nothing returns integer
        return typeDialogue
    endmethod

    public method nettoyer takes nothing returns nothing
        call DialogClear(dialogue)
    endmethod

    public method egaliteTimeur takes timer timeur returns boolean
        if timeurChoix.egaleST(timeur) then
            return true
        endif
        return false
    endmethod

    public method egale takes dialog dialogue returns boolean
        if this.dialogue == dialogue then
            return true
        endif
        return false
    endmethod

    public method executerFonctionChoix takes nothing returns nothing
        local trigger t = CreateTrigger()
        local triggeraction ta = TriggerAddAction(t, getFonctionCH(this, typeDialogue))
        call TriggerExecute(t)
        call TriggerRemoveAction(t,ta)
        call DestroyTrigger(t)
        set ta = null
        set t = null
    endmethod

    public method detruireChoix takes nothing returns nothing
        local integer i = 0
        call DialogClear(dialogue)
        call DialogDestroy(dialogue)
        if timeurChoix != 0 then
            call timeurChoix.detruireST()
        endif
        set dialogue = null
        loop
        exitwhen i == indexBouttons
            set bouttons[i] = null
            set i = i + 1
        endloop
        call this.destroy()
    endmethod

    public static method supprimerChoix takes thistype choix returns nothing
        local integer i = 0
        loop
        exitwhen i == indexChoix
            if choixs[i] == choix then
                call choixs[i].detruireChoix()
                set choixs[i] = 0
            endif
            set i = i + 1
        endloop
    endmethod

    public static method getChoixParTimer takes timer timeur returns thistype
        local integer i = 0
        loop
        exitwhen i == indexChoix
            if choixs[i].egaliteTimeur(timeur) then
                return choixs[i]
            endif
            set i = i + 1
        endloop
        return 0
    endmethod

endstruct