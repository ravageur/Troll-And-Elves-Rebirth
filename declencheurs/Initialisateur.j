function initialisateurConditions takes nothing returns boolean
    call Guide.creerQuetes()
    call Jeu.initialiserJeu()
    call Map.initialiser()
    call DisableTrigger(gg_trg_Initialisateur)
    call DestroyTrigger(gg_trg_Initialisateur)
    return false
endfunction
    
//===========================================================================
function InitTrig_Initialisateur takes nothing returns nothing
    local event eventLeak
    local triggercondition tc
    local conditionfunc cf = Condition(function initialisateurConditions)
    set gg_trg_Initialisateur = CreateTrigger()
    set eventLeak = TriggerRegisterTimerEvent(gg_trg_Initialisateur, 0.14, false)
    set tc = TriggerAddCondition(gg_trg_Initialisateur, cf)
    set tc = null
    set cf = null
    set eventLeak = null
endfunction