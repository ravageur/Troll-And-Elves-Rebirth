struct HashMapGenerateur

    private unit unite = null
    private integer tempsRecolte = -1
    private integer tempsRecolteRestant = -1

    public static method create takes unit unite, integer tempsRecolte returns thistype
        local thistype generateur = thistype.allocate()
        call generateur.definirTypeGenerateur(unite, tempsRecolte)
        return generateur
    endmethod

    public method definirTypeGenerateur takes unit unite, integer tempsRecolte returns nothing
        set this.unite = unite
        set this.tempsRecolte = tempsRecolte
        set this.tempsRecolteRestant = tempsRecolte
    endmethod

    public method peutGenerer takes nothing returns boolean
        if tempsRecolteRestant == 0 then
            set tempsRecolteRestant = tempsRecolte
            return true
        endif
        set tempsRecolteRestant = tempsRecolteRestant - 1
        return false
    endmethod

    public method getUnite takes nothing returns unit
        return unite
    endmethod

    public method detruireHMG takes nothing returns nothing
        set unite = null
        call this.destroy()
    endmethod

endstruct