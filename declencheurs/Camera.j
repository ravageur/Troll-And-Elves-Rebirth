function cameraConditions takes nothing returns boolean
    call Map.setCameraMap()
    return false
endfunction

//===========================================================================
function InitTrig_Camera takes nothing returns nothing
    local event eventLeak
    local triggercondition tc
    local conditionfunc cf = Condition(function cameraConditions)
    set gg_trg_Camera = CreateTrigger()
    set eventLeak = TriggerRegisterTimerEvent(gg_trg_Camera, 0.10, true)
    set tc = TriggerAddCondition(gg_trg_Camera, cf)
    set tc = null
    set cf = null
    set eventLeak = null
endfunction