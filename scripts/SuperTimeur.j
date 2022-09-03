library timeurUtils

    function autoDestruction takes nothing returns boolean
        local timer timeur = GetExpiredTimer()
        call SuperTimeur.supprimerTimer(timeur)
        set timeur = null
        return true
    endfunction

    struct SuperTimeur

        private static integer indexTimeurs = 0
        private static integer nbIndexNullTimeurs = 0
        private static thistype array timeurs[24]
        private timer timeurST
        private timerdialog timeurDialogST
        private trigger autoDestructionST

        public static method creerTimeur takes boolean afficher, string titre, boolean sautoDetruire returns thistype
            local integer i = 0
            if nbIndexNullTimeurs == 0 then
                set timeurs[indexTimeurs] = thistype.create(afficher, titre, sautoDetruire)
                set indexTimeurs = indexTimeurs + 1
                return timeurs[indexTimeurs - 1]
            else
                loop
                exitwhen i == 32
                    if timeurs[i] == 0 then
                        set timeurs[i] = thistype.create(afficher, titre, sautoDetruire)
                        set nbIndexNullTimeurs = nbIndexNullTimeurs - 1
                        return timeurs[i]
                    endif
                    set i = i + 1
                endloop
            endif
            return 0
        endmethod

        public static method create takes boolean afficher, string titre, boolean sautoDetruire returns thistype
            local thistype superTimeur = thistype.allocate()
            call superTimeur.creerST(afficher, titre, sautoDetruire)
            return superTimeur
        endmethod

        public method creerST takes boolean afficher, string titre, boolean sautoDetruire returns nothing
            set timeurST = CreateTimer()
            if afficher then
                set timeurDialogST = CreateTimerDialog(timeurST)
                call TimerDialogSetTitle(timeurDialogST, titre)
                call TimerDialogDisplay(timeurDialogST, true)
            endif
            if sautoDetruire then
                set autoDestructionST = CreateTrigger()
                call TriggerRegisterTimerExpireEvent(autoDestructionST, timeurST)
                call TriggerAddCondition(autoDestructionST, Condition(function autoDestruction))
            endif
        endmethod

        public method lancerTimer takes real temps, code fonction returns nothing
            call TimerStart(timeurST, temps, false, fonction)
        endmethod

        public method egaleST takes timer timeur returns boolean
            if timeurST == timeur then
                return true
            endif
            return false
        endmethod

        public method getTempsRestantST takes nothing returns real
            return TimerGetRemaining(timeurST)
        endmethod

        public method detruireST takes nothing returns nothing
            call PauseTimer(timeurST)
            call DisableTrigger(autoDestructionST)
            call DestroyTimerDialog(timeurDialogST)
            call DestroyTimer(timeurST)
            call DestroyTrigger(autoDestructionST)
            set timeurST = null
            set timeurDialogST = null
            set autoDestructionST = null
            call this.destroy()
        endmethod

        public static method supprimerTimer takes timer timeur returns nothing
            local integer i = 0
            if timeur != null then
                loop
                exitwhen i == 32
                    if timeurs[i] != 0 and timeurs[i].egaleST(timeur) then
                        call timeurs[i].detruireST()
                        if i != 0 then
                            set nbIndexNullTimeurs = nbIndexNullTimeurs + 1
                        endif
                        exitwhen true
                    endif
                    set i = i + 1
                endloop
            endif
        endmethod
    endstruct
endlibrary