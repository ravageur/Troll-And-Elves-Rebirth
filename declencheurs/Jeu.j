function jeuConditions takes nothing returns boolean
    call Jeu.gainOr()
    call Jeu.ajouterXpTL()
    return false
endfunction

//===========================================================================
function InitTrig_Jeu takes nothing returns nothing
    local event eventLeak
    local triggercondition tc
    local conditionfunc cf = Condition(function jeuConditions)
    set gg_trg_Jeu = CreateTrigger()
    set eventLeak = TriggerRegisterTimerEvent(gg_trg_Jeu, 1.00, true)
    set tc = TriggerAddCondition(gg_trg_Jeu, cf)
    set tc = null
    set cf = null
    set eventLeak = null
endfunction