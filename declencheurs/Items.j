function estTomeRegenerationVie takes integer idItem returns integer
    if idItem == 'I022' then
        return 2560
    elseif idItem == 'I023' then
        return 5120
    elseif idItem == 'I024' then
        return 20480
    elseif idItem == 'I025' then
        return 81920
    elseif idItem == 'I029' then
        return 163840
    else
        return -1
    endif
endfunction

function estTomeArmure takes integer idItem returns integer
    if idItem == 'I020' then
        return 640
    elseif idItem == 'I01X' then
        return 1280
    elseif idItem == 'I01Y' then
        return 5120
    elseif idItem == 'I021' then
        return 20480
    elseif idItem == 'I026' then
        return 81920
    else
        return -1
    endif
endfunction


function itemsConditions takes nothing returns boolean
    local unit unite = GetTriggerUnit()
    local item litem = GetManipulatedItem()
    local integer idItem = GetItemTypeId(litem)
    local integer resultat = estTomeArmure(idItem)
    local player joueur = Player(0)

    if resultat != -1 then
        call BlzSetUnitArmor(unite, BlzGetUnitArmor(unite) + I2R(resultat))
        call RemoveItem(litem)
    else
        set resultat = estTomeRegenerationVie(idItem)
        if resultat != -1 then
            call BlzSetUnitRealField(unite, UNIT_RF_HIT_POINTS_REGENERATION_RATE, BlzGetUnitRealField(unite, UNIT_RF_HIT_POINTS_REGENERATION_RATE) + I2R(resultat))
            call RemoveItem(litem)
        endif
    endif
    set unite = null
    set litem = null
    set joueur = null
    return false
endfunction

//===========================================================================
function InitTrig_Items takes nothing returns nothing
    local event eventLeak
    local triggercondition tc
    local conditionfunc cf = Condition(function itemsConditions)
    local player joueur
    local integer i = 0
    set gg_trg_Items = CreateTrigger()
    loop
    exitwhen i == 12
        set joueur = Player(i)
        set eventLeak = TriggerRegisterPlayerUnitEvent(gg_trg_Items, joueur, EVENT_PLAYER_UNIT_PICKUP_ITEM, null)
        set i = i + 1
    endloop
    set tc = TriggerAddCondition(gg_trg_Items, cf)
    set tc = null
    set cf = null
    set eventLeak = null
    set joueur = null
endfunction