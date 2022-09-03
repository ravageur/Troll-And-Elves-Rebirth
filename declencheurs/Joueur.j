function joueurConditions takes nothing returns boolean
    local eventid eventIdentifiant = GetTriggerEventId()
    local player joueur = GetTriggerPlayer()
    local unit unite
    local string message = GetEventPlayerChatString()
    local string messageDecoupe
    if eventIdentifiant == EVENT_PLAYER_UNIT_SELECTED then
        set unite = GetTriggerUnit()
        call Jeu.setUniteSelectionne(joueur, unite)
        set unite = null
    elseif message != "" then
        set messageDecoupe = SubString(message, 0, 3)
        if messageDecoupe == "-gg" then
            call Jeu.donnerOB(joueur, message, PLAYER_STATE_RESOURCE_GOLD)
        elseif message == "-gl" then
            call Jeu.donnerOB(joueur, message, PLAYER_STATE_RESOURCE_LUMBER)
        else
            set messageDecoupe = SubString(message, 0, 9)
            if messageDecoupe == "-distance" then
                call Jeu.definirDistanceJoueur(joueur, message)
            elseif messageDecoupe == "-rotation" then
                call Jeu.definirRotationJoueur(joueur, message)
            endif
        endif
    elseif eventIdentifiant == EVENT_PLAYER_LEAVE then
        call Jeu.joueurQuitte(joueur)
    endif
    set joueur = null
    set eventIdentifiant = null
    return false
endfunction

function InitTrig_Joueur takes nothing returns nothing
    local event eventLeak
    local triggercondition tc
    local conditionfunc cf = Condition(function joueurConditions)
    local player joueur
    local integer i = 0
    set gg_trg_Joueur = CreateTrigger()
    loop
    exitwhen i == 12
        set joueur = Player(i)
        if Jeu.estUnJoueur(joueur) then
            set eventLeak = TriggerRegisterPlayerEvent(gg_trg_Joueur, joueur, EVENT_PLAYER_LEAVE)
            set eventLeak = TriggerRegisterPlayerChatEvent(gg_trg_Joueur, joueur, "-gg", false)
            set eventLeak = TriggerRegisterPlayerChatEvent(gg_trg_Joueur, joueur, "-gl", false)
            set eventLeak = TriggerRegisterPlayerChatEvent(gg_trg_Joueur, joueur, "-distance", false)
            set eventLeak = TriggerRegisterPlayerChatEvent(gg_trg_Joueur, joueur, "-rotation", false)
            set eventLeak = TriggerRegisterPlayerUnitEvent(gg_trg_Joueur, joueur, EVENT_PLAYER_UNIT_SELECTED, null)
        endif
        set i = i + 1
    endloop
    set tc = TriggerAddCondition(gg_trg_Joueur, cf)
    set tc = null
    set cf = null
    set eventLeak = null
    set joueur = null
endfunction
