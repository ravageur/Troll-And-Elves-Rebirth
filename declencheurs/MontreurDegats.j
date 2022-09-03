function reduireArmureMD takes unit unite, integer typeUnite returns nothing
    local HashMapUniteTimeur hmut = HashMapUniteTimeur.getHMUTParUnite(unite)
    if hmut == 0 then
        set hmut = HashMapUniteTimeur.creerHMUT(unite)
    endif
    if typeUnite == 'h00N' then
        call hmut.abaisserArmure(80.0, 5.0)
    elseif typeUnite == 'h00O' then
        call hmut.abaisserArmure(160.0, 5.0)
    elseif typeUnite == 'h00E' then
        call hmut.abaisserArmure(320.0, 5.0)
    elseif typeUnite == 'h00J' then
        call hmut.abaisserArmure(640.0, 5.0)
    elseif typeUnite == 'h00F' then
        call BlzSetUnitArmor(unite, BlzGetUnitArmor(unite) - 5120)
    endif
    set hmut = 0
endfunction

function montreurDegatsActions takes nothing returns nothing
    local texttag texteTag
    local unit unite = GetTriggerUnit()
    local unit uniteDegats = GetEventDamageSource()
    local player joueur = GetOwningPlayer(uniteDegats)
    local real uniteDegatsArmure = BlzGetUnitArmor(uniteDegats)
    local real resultat = 0
    if GetEventDamage() > 0 then
        set texteTag = CreateTextTagUnitBJ("|c" + Couleur.getCouleurHexJoueur(joueur) + I2S(R2I(GetEventDamage())), unite, 0, 10, 100, 100, 100, 0)
        call SetTextTagPermanent(texteTag, false)
        call SetTextTagLifespan(texteTag, 3)
        call SetTextTagFadepoint(texteTag, 2)
        call SetTextTagVelocity(texteTag, 0, 0.03)
        if joueur == Jeu.joueurTroll or GetUnitTypeId(uniteDegats) == 'H00D' then
            if GetUnitTypeId(unite) != 'H000' and GetUnitTypeId(unite) != 'H00D' then
                set resultat = GetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD) + R2I(GetEventDamage() * Jeu.getSpeed())
                if resultat > 9999999 then
                    set resultat = 64000 - ((GetEventDamage() * Jeu.getSpeed() / 64000) - (I2R(R2I(GetEventDamage() * Jeu.getSpeed() / 64000))))
                    call SetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD) - (R2I(resultat)  + (R2I(GetEventDamage() * Jeu.getSpeed() / 64000) * 64000)))
                    if resultat == 0 then
                        call SetPlayerState(joueur, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(joueur, PLAYER_STATE_RESOURCE_LUMBER) + R2I(GetEventDamage() * Jeu.getSpeed() / 64000))
                    else
                        call SetPlayerState(joueur, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(joueur, PLAYER_STATE_RESOURCE_LUMBER) + R2I(GetEventDamage() * Jeu.getSpeed() / 64000) + 1)
                    endif
                else
                    call SetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD) + R2I(GetEventDamage() * Jeu.getSpeed()))
                endif
                call Jeu.setOrHidding(R2I(GetEventDamage() * (1 - (uniteDegatsArmure * Jeu.armureReduction) / (1 + uniteDegatsArmure * Jeu.armureReduction))))
            endif
            call reduireArmureMD(unite, GetUnitTypeId(uniteDegats))
        endif
    endif
    call Dialogue.parler(unite, uniteDegats)
    set uniteDegats = null
    set joueur = null
    set unite = null
    set texteTag = null
endfunction

//===========================================================================
function InitTrig_MontreurDegats takes nothing returns nothing
    local event eventLeak
    local triggercondition tc
    local conditionfunc cf
    local player joueur
    local integer i = 0
    set gg_trg_MontreurDegats = CreateTrigger()
    loop
    exitwhen i == 12
        set joueur = Player(i)
        if Jeu.estUnJoueur(joueur) then
            set eventLeak = TriggerRegisterPlayerUnitEvent(gg_trg_MontreurDegats, joueur, EVENT_PLAYER_UNIT_DAMAGED, null)
        endif
        set i = i + 1
    endloop
    set cf = Condition(function montreurDegatsActions)
    set tc = TriggerAddCondition(gg_trg_MontreurDegats, cf)
    set tc = null
    set cf = null
    set eventLeak = null
    set joueur = null
endfunction