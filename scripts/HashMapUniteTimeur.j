function reinitialisationArmure takes nothing returns nothing
    local timer timeur = GetExpiredTimer()
    local HashMapUniteTimeur hmut = HashMapUniteTimeur.getHMUT(timeur)
    call hmut.reinitialiserArmure()
    call hmut.detruireUnHMUT(timeur)
    set hmut = 0
    set timeur = null
endfunction

struct HashMapUniteTimeur

    private static thistype array hmuts[36]
    private static integer indexHMUT = 0
    private static integer nbNullHMUT = 0

    private unit unite
    private real armureARedonner = 0.0
    private integer typeUniteHMUT
    private player joueurHMUT
    private SuperTimeur superTimeurHMUT

    public static method creerHMUT takes unit unite returns thistype
        local integer i = 0
        if nbNullHMUT == 0 then
            set hmuts[indexHMUT] = thistype.create(unite)
            set indexHMUT = indexHMUT + 1
            return hmuts[indexHMUT - 1]
        else
            loop
            exitwhen i == indexHMUT
                if hmuts[i] == 0 then
                    set hmuts[i] = thistype.create(unite)
                    set nbNullHMUT = nbNullHMUT - 1
                    return hmuts[i]
                endif
                set i = i + 1
            endloop
        endif
        return 0
    endmethod

    public static method create takes unit unite returns thistype
        local thistype hmut = thistype.allocate()
        call hmut.initHMUT(unite)
        return hmut
    endmethod

    public method initHMUT takes unit unite returns nothing
        set this.unite = unite
        set typeUniteHMUT = GetUnitTypeId(unite)
        set joueurHMUT = GetOwningPlayer(unite)
        set superTimeurHMUT = SuperTimeur.create(false, "", false)
    endmethod

    public method getTypeUniteHMUT takes nothing returns integer
        return typeUniteHMUT
    endmethod

    public method getUniteHMUT takes nothing returns unit
        return unite
    endmethod

    public method getJoueurHMUT takes nothing returns player
        return joueurHMUT
    endmethod

    public method lancerTimerHMUT takes real temps, code fonction returns nothing
        call superTimeurHMUT.lancerTimer(temps, fonction)
    endmethod

    public method egaleHMUT takes timer timeur returns boolean
        if superTimeurHMUT.egaleST(timeur) then
            return true
        endif
        return false
    endmethod

    public method egaleUniteHMUT takes unit unite returns boolean
        if this.unite == unite then
            return true
        endif
        return false
    endmethod

    public method abaisserArmure takes real armureEnleve, real temps returns nothing
        call BlzSetUnitArmor(unite, BlzGetUnitArmor(unite) - armureEnleve)
        set armureARedonner = armureARedonner + armureEnleve
        if superTimeurHMUT.getTempsRestantST() <= 0.0 then
            call lancerTimerHMUT(temps, function reinitialisationArmure)
        else
            call superTimeurHMUT.detruireST()
            set superTimeurHMUT = SuperTimeur.create(false, "", false)
            call lancerTimerHMUT(temps, function reinitialisationArmure)
        endif
    endmethod

    public method reinitialiserArmure takes nothing returns nothing
        call BlzSetUnitArmor(unite, BlzGetUnitArmor(unite) + armureARedonner)
    endmethod

    public method revivreHMUT takes real posX, real posY returns nothing
        local player joueur
        if IsHeroUnitId(typeUniteHMUT) then
            call ReviveHero(unite, posX, posY, true)
        else
            set joueur = GetOwningPlayer(unite)
            call CreateUnit(joueurHMUT, typeUniteHMUT, posX, posY, 270)
        endif
    endmethod

    public method detruireHMUT takes nothing returns nothing
        call superTimeurHMUT.detruireST()
        set unite = null
        set joueurHMUT = null
        set superTimeurHMUT = 0
        call this.destroy()
    endmethod

    public static method getHMUT takes timer timeur returns thistype
        local integer i = 0
        loop
        exitwhen i == indexHMUT
            if hmuts[i] != 0 and hmuts[i].egaleHMUT(timeur) then
                return hmuts[i]
            endif
            set i = i + 1
        endloop
        return 0
    endmethod

    public static method getHMUTParUnite takes unit unite returns thistype
        local integer i = 0
        loop
        exitwhen i == indexHMUT
            if hmuts[i] != 0 and hmuts[i].egaleUniteHMUT(unite) then
                return hmuts[i]
            endif
            set i = i + 1
        endloop
        return 0
    endmethod

    public static method detruireUnHMUT takes timer timeur returns nothing
        local integer i = 0
        loop
        exitwhen i == indexHMUT
            if hmuts[i] != 0 and hmuts[i].egaleHMUT(timeur) then
                call hmuts[i].detruireHMUT()
                set hmuts[i] = 0
                set nbNullHMUT = nbNullHMUT + 1
                return
            endif
            set i = i + 1
        endloop
    endmethod
endstruct