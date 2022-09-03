function tuerUnite takes nothing returns nothing
    local timer timeur = GetExpiredTimer()
    local HashMapUniteTimeur hmut = HashMapUniteTimeur.getHMUT(timeur)
    local unit unite = hmut.getUniteHMUT()
    call KillUnit(unite)
    set unite = null
    call HashMapUniteTimeur.detruireUnHMUT(timeur)
    set hmut = 0
    set timeur = null
endfunction

function detruireActions takes nothing returns nothing
    local unit uniteADetruire = GetSpellAbilityUnit()
    local player joueur 
    local HashMapUniteTimeur hmut
    if Jeu.troll == null or SuperMath.uniteEstAuxAlentours(uniteADetruire, Jeu.troll, 768) == false then
        set hmut = HashMapUniteTimeur.creerHMUT(uniteADetruire)
        call hmut.lancerTimerHMUT(0.15, function tuerUnite)
        set hmut = 0
    else
        set joueur = GetOwningPlayer(uniteADetruire)
        call DisplayTextToPlayer(joueur, 0, 0, "|c00FF0000The Chaos Troll is nearby, you cannot destroy this structure.|r")
        set joueur = null
    endif
    set uniteADetruire = null
endfunction

function cancelVolerOr takes nothing returns nothing
    local timer timeur = GetExpiredTimer()
    local HashMapUniteTimeur hmut = Jeu.getLoupOuAnge(timeur, null)
    local unit unite = hmut.getUniteHMUT()
    call IssueImmediateOrderById(unite, 851972)
    set unite = null
    set hmut = 0
    set timeur = null
endfunction

function volerOr takes nothing returns nothing 
    local player joueur = GetTriggerPlayer()
    local HashMapUniteTimeur hmut = Jeu.getLoupOuAnge(null, joueur)
    call hmut.lancerTimerHMUT(0.90, function cancelVolerOr)
    call SetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD) + Jeu.getOrHidding())
    set hmut = 0
    set joueur = null
endfunction

function marketActions takes integer idAbilite returns nothing
    call Market.bienvenue(idAbilite)
    call Jeu.actualiserAffichagePrix()
endfunction

function abilitiesConditions takes nothing returns boolean
    local eventid eventId = GetTriggerEventId()
    local integer idAbilite = GetSpellAbilityId()
    if idAbilite == 'A00R' then
        call detruireActions()
    elseif idAbilite == 'A01G' then
        call volerOr()
    else
        call marketActions(idAbilite)
    endif
    return false
endfunction

//===========================================================================
function InitTrig_Abilities takes nothing returns nothing
    local event eventLeak
    local triggercondition tc
    local conditionfunc cf = Condition(function abilitiesConditions)
    local player joueur
    local integer i = 0
    set gg_trg_Abilities = CreateTrigger()
    loop
    exitwhen i == 12
        set joueur = Player(i)
        if Jeu.estUnJoueur(joueur) then
            set eventLeak = TriggerRegisterPlayerUnitEvent(gg_trg_Abilities, joueur, EVENT_PLAYER_UNIT_SPELL_CAST, null)
        endif
        set i = i + 1
    endloop
    set tc = TriggerAddCondition(gg_trg_Abilities, cf)
    set tc = null
    set cf = null
    set eventLeak = null
    set joueur = null
endfunction