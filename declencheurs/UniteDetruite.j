function detruireTroll takes nothing returns nothing
    local timer timeur = GetExpiredTimer()
    local HashMapUniteTimeur hmut = HashMapUniteTimeur.getHMUT(timeur)
    local unit unite = hmut.getUniteHMUT()
    call RemoveUnit(unite)
    call Jeu.partieTerminer()
    set unite = null
    call HashMapUniteTimeur.detruireUnHMUT(timeur)
    set hmut = 0
    set timeur = null
endfunction

function detruireElf takes nothing returns nothing
    local timer timeur = GetExpiredTimer()
    local HashMapUniteTimeur hmut = HashMapUniteTimeur.getHMUT(timeur)
    local player joueur = hmut.getJoueurHMUT()
    local unit unite = hmut.getUniteHMUT()
    call Jeu.unElfEstMort(joueur, false)
    call RemoveUnit(unite)
    set unite = null
    set joueur = null
    call HashMapUniteTimeur.detruireUnHMUT(timeur)
    set hmut = 0
    set timeur = null
endfunction

function detruireUnite takes nothing returns nothing
    local timer timeur = GetExpiredTimer()
    local HashMapUniteTimeur hmut = HashMapUniteTimeur.getHMUT(timeur)
    local unit unite = hmut.getUniteHMUT()
    call RemoveUnit(unite)
    set unite = null
    call HashMapUniteTimeur.detruireUnHMUT(timeur)
    set hmut = 0
    set timeur = null
endfunction

function uniteDetruiteConditions takes nothing returns boolean
    local player joueur = GetTriggerPlayer()
    local unit unite = GetDyingUnit()
    local integer typeUnite = GetUnitTypeId(unite)
    local HashMapUniteTimeur hmut
    if Jeu.enleverUniteGenerateur(unite) then
        set hmut = HashMapUniteTimeur.creerHMUT(unite)
        call hmut.lancerTimerHMUT(3.0, function detruireUnite)
    elseif typeUnite == 'u000' then
        set hmut = HashMapUniteTimeur.creerHMUT(unite)
        call hmut.lancerTimerHMUT(3.0, function detruireElf)
    elseif typeUnite == 'u00R' or typeUnite == 'H00D' then
        call Jeu.loupOuAngeMeurt(Jeu.getIdJoueur(joueur))
    elseif typeUnite == 'H000' then
        set hmut = HashMapUniteTimeur.creerHMUT(unite)
        call hmut.lancerTimerHMUT(5.0, function detruireTroll)
    else
        set hmut = HashMapUniteTimeur.creerHMUT(unite)
        call hmut.lancerTimerHMUT(3.0, function detruireUnite)
    endif
    set hmut = 0
    set unite = null
    set joueur = null
    return false
endfunction

//===========================================================================
function InitTrig_UniteDetruite takes nothing returns nothing
    local event eventLeak
    local triggercondition tc
    local conditionfunc cf = Condition(function uniteDetruiteConditions)
    local player joueur
    local integer i = 0
    set gg_trg_UniteDetruite = CreateTrigger()
    loop
    exitwhen i == 12
        set joueur = Player(i)
        if Jeu.estUnJoueur(joueur) then
            set eventLeak = TriggerRegisterPlayerUnitEvent(gg_trg_UniteDetruite, joueur, EVENT_PLAYER_UNIT_DEATH, null)
        endif
        set i = i + 1
    endloop
    set tc = TriggerAddCondition(gg_trg_UniteDetruite, cf)
    set tc = null
    set cf = null
    set eventLeak = null
    call DisableTrigger(gg_trg_UniteDetruite)
endfunction