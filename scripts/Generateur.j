struct Generateur

    private HashMapGenerateur array generateurs[512]
    private integer indexGenerateur = 0
    private integer nbNullGenerateur = 0
    private integer array typeUnitesAutorises[24]
    private integer array tempsRecoltePourChaqueTypes[24]
    private integer indexTypesAutorises = 0
    private integer nbNullTypesAutorises = 0

    public static method create takes nothing returns thistype
        return thistype.allocate()
    endmethod

    public method getGenerateur takes integer index returns HashMapGenerateur
        return generateurs[index]
    endmethod

    public method getTailleTableau takes nothing returns integer
        return indexGenerateur
    endmethod

    public method ajouterUniteGeneratrice takes unit unite returns boolean
        local integer i = 0
        local HashMapGenerateur hmg
        local integer id = uniteEstAutorise(GetUnitTypeId(unite))
        if id != -1 then
            set hmg = HashMapGenerateur.create(unite, tempsRecoltePourChaqueTypes[id])
            if nbNullGenerateur != 0 then
                loop
                exitwhen i == indexGenerateur
                    if generateurs[i] == 0 then
                        set generateurs[i] = hmg
                    endif
                    set i = i + 1
                endloop
                set nbNullGenerateur = nbNullGenerateur - 1
            else
                set generateurs[indexGenerateur] = hmg
                set indexGenerateur = indexGenerateur + 1
            endif
            return true
        endif
        return false
    endmethod

    public method enleverUniteGeneratrice takes unit unite returns boolean
        local integer i = 0
        local unit uniteHMG
        local integer id = uniteEstAutorise(GetUnitTypeId(unite))
        if id != -1 then
            loop
            exitwhen i == indexGenerateur
                set uniteHMG = generateurs[i].getUnite()
                if uniteHMG == unite then
                    call generateurs[i].detruireHMG()
                    set generateurs[i] = 0
                    set nbNullGenerateur = nbNullGenerateur + 1
                    exitwhen true
                endif
                set i = i + 1
            endloop
            set uniteHMG = null
            return true
        endif
        return false
    endmethod

    public method ajouterTypeUniteAutorise takes integer typeUnite, integer tempsRecolte returns nothing
        local integer i = 0
        if nbNullTypesAutorises != 0 then
            loop
            exitwhen i == indexTypesAutorises
                if typeUnitesAutorises[i] == 0 then
                    set typeUnitesAutorises[i] = typeUnite
                    set tempsRecoltePourChaqueTypes[i] = tempsRecolte
                    exitwhen true
                endif
                set i = i + 1
            endloop
            set nbNullTypesAutorises = nbNullTypesAutorises - 1
        else
            set typeUnitesAutorises[indexTypesAutorises] = typeUnite
            set tempsRecoltePourChaqueTypes[indexTypesAutorises] = tempsRecolte
            set indexTypesAutorises = indexTypesAutorises + 1
        endif
    endmethod

    private method uniteEstAutorise takes integer idUnite returns integer
        local integer i = 0
        loop
        exitwhen i == indexTypesAutorises
            if typeUnitesAutorises[i] == idUnite then
                return i
            endif
            set i = i + 1
        endloop
        return -1
    endmethod

    public method detruireGenerateur takes nothing returns nothing
        local integer i = 0
        loop
        exitwhen i == indexGenerateur
            call generateurs[i].detruireHMG()
            set i = i + 1
        endloop
        call this.destroy()
    endmethod

endstruct