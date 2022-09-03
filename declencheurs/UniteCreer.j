function getTA takes integer type1, integer type2, integer type3, integer type4 returns integer
    local integer vitesse = Jeu.getSpeed()
    if vitesse == 1 then
        return type1
    elseif vitesse == 2 then
        return type2
    elseif vitesse == 3 then
        return type3
    else
        return type4
    endif
endfunction

function definirVitesseBois takes nothing returns nothing
    local unit unite = GetTrainedUnit()
    local integer idUnite = GetUnitTypeId(unite)
    local integer typeAbilite = 0
    if idUnite == 'e000' then
        set typeAbilite = getTA('A040', 'A041', 'A042', 'A043')
    elseif idUnite == 'e002' then
        set typeAbilite = getTA('A044', 'A045', 'A046', 'A047')
    elseif idUnite == 'e003' then
        set typeAbilite = getTA('A048', 'A049', 'A050', 'A051')
    elseif idUnite == 'e004' then
        set typeAbilite = getTA('A052', 'A053', 'A054', 'A055')
    elseif idUnite == 'e00A' then
        set typeAbilite = getTA('A056', 'A057', 'A058', 'A059')
    elseif idUnite == 'e00B' then
        set typeAbilite = getTA('A060', 'A061', 'A062', 'A063')
    elseif idUnite == 'e00C' then
        set typeAbilite = getTA('A064', 'A065', 'A066', 'A067')
    elseif idUnite == 'e00N' then
        set typeAbilite = getTA('A068', 'A069', 'A070', 'A071')
    endif
    if typeAbilite != 0 then
        call UnitAddAbility(unite, typeAbilite)
    endif
    set unite = null
endfunction


function estMineDor takes integer type1, integer type2, integer type3, integer type4, integer type5, integer type6, integer type7, integer type8 returns nothing
    local unit unite = GetConstructedStructure()
    local integer idUnite = GetUnitTypeId(unite)
    local player joueur = GetOwningPlayer(unite)
    local unit u
    if idUnite == type1 or idUnite == type2 or idUnite == type3 or idUnite == type4 or idUnite == type5 or idUnite == type6 or idUnite == type7 or idUnite == type8 then
        call SetResourceAmount(unite, 1000000000)
        set u = CreateUnit(joueur, 'e006', GetUnitX(unite), GetUnitY(unite), bj_UNIT_FACING)
        call IssueTargetOrder(u, "smart", unite)
    endif
    set u = null
    set joueur = null
    set unite = null
endfunction

function uniteCreerConditions takes nothing returns boolean
    local unit unite = GetTriggerUnit()
    local integer vitesse = Jeu.getSpeed()
    local eventid eventId = GetTriggerEventId()
    if eventId == EVENT_PLAYER_UNIT_CONSTRUCT_FINISH then
        if Jeu.ajouterUniteGenerateur(unite) then
        elseif vitesse == 1 then
            call estMineDor('e00J', 'e00S', 'e00V', 'e008', 'e00Z', 'e012', 'e015', 'e019')
        elseif vitesse == 2 then
            call estMineDor('e00D', 'e005', 'e00T', 'e00W', 'e009', 'e013', 'e016', 'e018')
        elseif vitesse == 3 then
            call estMineDor('e00O', 'e00R', 'e00U', 'e00X', 'e010', 'e014', 'e017', 'e01A')
        elseif vitesse == 4 then
            call estMineDor('e00P', 'e00Q', 'e001', 'e00Y', 'e011', 'e00K', 'e00L', 'e00M')
        endif
    else
        call definirVitesseBois()
    endif
    set unite = null
    set eventId = null
    return false
endfunction

//===========================================================================
function InitTrig_UniteCreer takes nothing returns nothing
    local player joueur
    local conditionfunc cf = Condition(function uniteCreerConditions)
    local event eventLeak
    local triggercondition tc
    local integer i = 0
    set gg_trg_UniteCreer = CreateTrigger()
    loop
    exitwhen i == 12
        set joueur = Player(i)
        if Jeu.estUnJoueur(joueur) then
            set eventLeak = TriggerRegisterPlayerUnitEvent(gg_trg_UniteCreer, joueur, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH, null)
            set eventLeak = TriggerRegisterPlayerUnitEvent(gg_trg_UniteCreer, joueur, EVENT_PLAYER_UNIT_TRAIN_FINISH, null)
        endif
        set i = i + 1
    endloop
    set tc = TriggerAddCondition(gg_trg_UniteCreer, cf)
    set tc = null
    set cf = null
    set eventLeak = null
    set joueur = null
endfunction