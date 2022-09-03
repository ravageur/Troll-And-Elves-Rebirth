function choixMapAutomatique takes nothing returns nothing
    call Map.mapChoisiAuto()
endfunction

function detecteurClavierConditions takes nothing returns boolean
    local eventid cle = GetTriggerEventId()
    local player joueur = GetTriggerPlayer()
    if cle == EVENT_PLAYER_ARROW_LEFT_DOWN then
        call Map.choisir(0, joueur)
    elseif cle == EVENT_PLAYER_ARROW_RIGHT_DOWN then
        call Map.choisir(1, joueur)
    elseif cle == EVENT_PLAYER_ARROW_UP_DOWN then
        call Map.choisir(2, joueur)
    elseif cle == EVENT_PLAYER_ARROW_DOWN_DOWN then
        call Map.choisir(3, joueur)
    endif
    set cle = null
    set joueur = null
    return false
endfunction

struct Map

    private static boolean reinitialiserLaCamera = false
    private static camerasetup cameraPresentation = CreateCameraSetup()
    private static integer map
    private static player choisisseur
    private static Choix choixMap = 0
    private static SuperTimeur timeurMap = 0
    private static unit array campTroll[7]
    private static fogmodifier array visions[12]
    private static boolean choisisseurEstAfk = true
    private static trigger detecteurClavier = null

    /**
    * Cette fonction permet d'initialiser la classe Map
    * 
    * @param nothing
    *
    * @return nothing
    */
    public static method initialiser takes nothing returns nothing
        local rect carte = GetPlayableMapRect()
        local player joueur
        local integer i = 0
        set map = GetRandomInt(1, 9)
        call setCameraMap()
        loop
        exitwhen i == 12
            set joueur = Player(i)
            set visions[i] = CreateFogModifierRect(joueur, FOG_OF_WAR_VISIBLE, carte, true, false)
            call FogModifierStart(visions[i])
            set i = i + 1
        endloop
        set carte = null
        call definirChoisiseurDeMap()
        call DisplayTextToForce(GetPlayersAll(), "|c" + Couleur.getCouleurHexJoueur(choisisseur) + Jeu.getNomJoueur(choisisseur) + "|r will choose the map !")
        set joueur = Player(PLAYER_NEUTRAL_PASSIVE)
        set campTroll[0] = CreateUnit(joueur, 'u00C', 8768.0, -1856.0, 270.000) // Niveau 3 Regen
        set campTroll[1] = CreateUnit(joueur, 'u00J', 9664.0, -1856.0, 270.000) // Niveau 1 Regen
        set campTroll[2] = CreateUnit(joueur, 'u00B', 9536.0, -1856.0, 270.000) // Batiment Troll
        set campTroll[3] = CreateUnit(joueur, 'u015', 9664.0, -1984.0, 270.000) // Niveau 2 Regen
        set campTroll[4] = CreateUnit(joueur, 'u00I', 9216.0, -2304.0, 270.000) // Niveau 1 Arme
        set campTroll[5] = CreateUnit(joueur, 'u00U', 8896.0, -1856.0, 270.000) // Niveau 2 Arme
        set campTroll[6] = CreateUnit(joueur, 'u00D', 8768.0, -1984.0, 270.000) // Niveau 3 Arme
        set joueur = null
        call lancerTimerMap()
    endmethod

    public static method creerDetecteurClavier takes nothing returns nothing
        local event eventLeak
        local triggercondition tc
        local conditionfunc cf = Condition(function detecteurClavierConditions)
        if detecteurClavier != null then
            call DisableTrigger(detecteurClavier)
            call DestroyTrigger(detecteurClavier)
            set detecteurClavier = null
        endif
        set detecteurClavier = CreateTrigger()
        set eventLeak = TriggerRegisterPlayerEvent(detecteurClavier, choisisseur, EVENT_PLAYER_ARROW_LEFT_DOWN)
        set eventLeak = TriggerRegisterPlayerEvent(detecteurClavier, choisisseur, EVENT_PLAYER_ARROW_RIGHT_DOWN)
        set eventLeak = TriggerRegisterPlayerEvent(detecteurClavier, choisisseur, EVENT_PLAYER_ARROW_UP_DOWN)
        set eventLeak = TriggerRegisterPlayerEvent(detecteurClavier, choisisseur, EVENT_PLAYER_ARROW_DOWN_DOWN)
        set tc = TriggerAddCondition(detecteurClavier, cf)
        set tc = null
        set eventLeak = null
        set cf = null
    endmethod

    public static method lancerTimerMap takes nothing returns nothing
        if timeurMap != 0 then
            call timeurMap.detruireST()
            set timeurMap = SuperTimeur.create(false, "", true)
            call timeurMap.lancerTimer(10.0, function choixMapAutomatique)
        else
            set timeurMap = SuperTimeur.create(false, "", true)
            call timeurMap.lancerTimer(10.0, function choixMapAutomatique)
        endif
    endmethod

    public static method resetChoisisseurEstAfk takes nothing returns nothing
        set choisisseurEstAfk = true
    endmethod

    public static method setBrouillard takes fogstate typeDeBrouillard, boolean shareVision returns nothing
        local rect carte = GetPlayableMapRect()
        local player joueur
        local integer i = 0
        loop
        exitwhen i == 12
            set joueur = Player(i)
            call FogModifierStop(visions[i])
            call DestroyFogModifier(visions[i])
            set visions[i] = CreateFogModifierRect(joueur, typeDeBrouillard, carte, shareVision, false)
            call FogModifierStart(visions[i])
            set i = i + 1
        endloop
        set joueur = null
        set carte = null
    endmethod

    public static method getChoisisseur takes nothing returns player
        return choisisseur
    endmethod

    public static method getIDMap takes nothing returns integer
        return map
    endmethod

    public static method definirChoisiseurDeMap takes nothing returns nothing
        local player joueur
        local mapcontrol mapControl
        local playerslotstate playerSlotState
        loop 
            set joueur = ForcePickRandomPlayer(GetPlayersAll())
            if Jeu.estUnJoueur(joueur) then
                set choisisseur = joueur
                call creerDetecteurClavier()
                exitwhen true
            endif
        endloop
        set joueur = null
        set mapControl = null
        set playerSlotState = null
    endmethod

    /**
    * Cette fonction permet de gérer le choix en fonction des touches utilisé par le joueur humain choisi.
    * 
    * @param nothing
    *
    * @return nothing
    */
    public static method choisir takes integer typeTouche, player joueur returns nothing
        if joueur == choisisseur then
            if typeTouche == 0 then
                set map = map - 1
                set choisisseurEstAfk = false
            elseif typeTouche == 1 then
                set map = map + 1
                set choisisseurEstAfk = false
            elseif typeTouche == 2 then
                set choisisseurEstAfk = false
                call up()
            elseif typeTouche == 3 then
                set map = GetRandomInt(1, 9)
                set choisisseurEstAfk = false
            endif
            call lancerTimerMap()
            if map < 1 then
                set map = 9
            elseif map > 9 then
                set map = 1
            endif 
            call setCameraMap()
        endif
    endmethod

    public static method mapChoisiAuto takes nothing returns nothing
        local integer nbJoueurs = Jeu.getNbJoueurs()
        local integer aleatoire = GetRandomInt(1, 2)
        if choixMap != 0 then
            call Choix.supprimerChoix(choixMap)
            set choixMap = 0
        endif
        // if choisisseurEstAfk then
        //     if nbJoueurs >= 6 then
        //         if aleatoire == 1 then
        //             set map = 1
        //         else
        //             set map = 6
        //         endif
        //     elseif nbJoueurs >= 4 then
        //         set aleatoire = GetRandomInt(1, 4)
        //         if aleatoire == 1 then
        //             set map = 2
        //         elseif aleatoire == 2 then
        //             set map = 3
        //         elseif aleatoire == 3 then
        //             set map = 7
        //         else
        //             set map = 8
        //         endif
        //     else
        //         if aleatoire == 1 then
        //             set map = 4
        //         else
        //             set map = 5
        //         endif
        //     endif
        // endif
        call setReinitialiserCamera(true)
        call DisableTrigger(gg_trg_Camera)
        call setCameraMap()
        call DisableTrigger(detecteurClavier)
        call EnableTrigger(gg_trg_Jeu)
        call Jeu.commencer()
    endmethod

    public static method getReinitialiserCamera takes nothing returns boolean
        return reinitialiserLaCamera
    endmethod

    public static method setReinitialiserCamera takes boolean doitReinitialiser returns nothing
        set reinitialiserLaCamera = doitReinitialiser
    endmethod

    /**
    * Cette fonction permet de définir la camera en fonction de la map que devraient voirs les joueurs humains.
    * 
    * @param nothing
    *
    * @return nothing
    */
    public static method setCameraMap takes nothing returns nothing
        if reinitialiserLaCamera then
            call reinitialiserCamera()
        else
            if map == 1 then
                call grandeForetEnneige()
            elseif map == 2 then
                call foretEte1()
            elseif map == 3 then
                call miniForetEnneige1()
            elseif map == 4 then
                call miniForetEte()
            elseif map == 5 then
                call miniForetEnneige2()
            elseif map == 6 then
                call grandeForetEte()
            elseif map == 7 then
                call foretEnneige()
            elseif map == 8 then
                call foretEte2()
            else
                call foretEte3()
            endif
        endif
    endmethod

    /**
    * Cette fonction permet de choisir la map que regarde les joueurs lors du choix.
    * 
    * @param nothing
    *
    * @return nothing
    */
    private static method up takes nothing returns nothing
        if choixMap == 0 then
            set choixMap = Choix.creerChoix("Do you want choose this map ?", 0, true, false, "", false)
            call Choix.initialiserBouttons(choixMap, 0)
            call choixMap.afficher(true, false, choisisseur)
        endif
    endmethod

    public static method reactiverMap takes nothing returns nothing
        call Map.setBrouillard(FOG_OF_WAR_VISIBLE, true)
        call Map.setReinitialiserCamera(false)
        call Map.resetChoisisseurEstAfk()
        call EnableTrigger(detecteurClavier)
    endmethod

    public static method mapChoisi takes nothing returns nothing
        if choixMap.getChoixJoueur(Jeu.getIdJoueur(choisisseur)) == 0 then
            call timeurMap.detruireST()
            set timeurMap = 0
            call Choix.supprimerChoix(choixMap)
            set choixMap = 0
            call setReinitialiserCamera(true)
            call DisableTrigger(gg_trg_Camera)
            call setCameraMap()
            call DisableTrigger(detecteurClavier)
            call EnableTrigger(gg_trg_Jeu)
            call Jeu.commencer()
        else
            call choixMap.afficher(false, false, choisisseur)
            call Choix.supprimerChoix(choixMap)
            set choixMap = 0
        endif
    endmethod

    /**
    * Cette fonction permet de définir la camera servant de copie pour que les cameras des joueurs suivent.
    * 
    * @param nothing
    *
    * @return nothing
    */
    private static method setCamera takes real targetX, real targetY, real offsetZ, real rotation, real angleOfAttack, real targetDistance, real roll, real fieldOfView, real farClipping, real nearz returns nothing
        call CameraSetupSetField(cameraPresentation, CAMERA_FIELD_ZOFFSET , offsetZ , 0)
        call CameraSetupSetField(cameraPresentation, CAMERA_FIELD_ROTATION , rotation , 0)
        call CameraSetupSetField(cameraPresentation, CAMERA_FIELD_ANGLE_OF_ATTACK , angleOfAttack , 0)
        call CameraSetupSetField(cameraPresentation, CAMERA_FIELD_TARGET_DISTANCE , targetDistance , 0)
        call CameraSetupSetField(cameraPresentation, CAMERA_FIELD_ROLL , roll , 0)
        call CameraSetupSetField(cameraPresentation, CAMERA_FIELD_FIELD_OF_VIEW , fieldOfView , 0)
        call CameraSetupSetField(cameraPresentation, CAMERA_FIELD_FARZ , farClipping , 0)
        call CameraSetupSetField(cameraPresentation, CAMERA_FIELD_NEARZ, nearz, 0)
        call CameraSetupSetField(cameraPresentation, CAMERA_FIELD_LOCAL_PITCH, 0.0, 0)
        call CameraSetupSetField(cameraPresentation, CAMERA_FIELD_LOCAL_YAW, 0.0, 0)
        call CameraSetupSetField(cameraPresentation, CAMERA_FIELD_LOCAL_ROLL, 0.0, 0)
        call CameraSetupSetDestPosition(cameraPresentation , targetX , targetY , 0)
        call CameraSetupApplyForceDuration(cameraPresentation, true, 0.00)
    endmethod

    private static method miniForetEte takes nothing returns nothing
        call BlzSetUnitSkin(campTroll[0], 'nfh1')
        call BlzSetUnitSkin(campTroll[1], 'nfh1')
        call BlzSetUnitSkin(campTroll[2], 'nfh0')
        call BlzSetUnitSkin(campTroll[3], 'nfh1')
        call BlzSetUnitSkin(campTroll[4], 'nfh1')
        call BlzSetUnitSkin(campTroll[5], 'nfh1')
        call BlzSetUnitSkin(campTroll[6], 'nfh1')
        call SetUnitPosition(campTroll[0], 27712.0, -28480.0)
        call SetUnitPosition(campTroll[1], 27968.0, -27840.0)
        call SetUnitPosition(campTroll[2], 27648.0, -28096.0)
        call SetUnitPosition(campTroll[3], 27968.0, -27968.0)
        call SetUnitPosition(campTroll[4], 27328.0, -27840.0)
        call SetUnitPosition(campTroll[5], 27328.0, -27968.0)
        call SetUnitPosition(campTroll[6], 27584.0, -28480.0)
        call definirCampTroll()
        call setCamera(27429.49, -28447.29, 0.0, 55.91, 318.35, 1586.31, 0.0, 70.0, 5500.0, 100.0)
    endmethod

    private static method foretEte1 takes nothing returns nothing
        call BlzSetUnitSkin(campTroll[0], 'nfh1')
        call BlzSetUnitSkin(campTroll[1], 'nfh1')
        call BlzSetUnitSkin(campTroll[2], 'nfh0')
        call BlzSetUnitSkin(campTroll[3], 'nfh1')
        call BlzSetUnitSkin(campTroll[4], 'nfh1')
        call BlzSetUnitSkin(campTroll[5], 'nfh1')
        call BlzSetUnitSkin(campTroll[6], 'nfh1')
        call SetUnitPosition(campTroll[0], 19776.0, -20672.0)
        call SetUnitPosition(campTroll[1], 19648.0, -20160.0)
        call SetUnitPosition(campTroll[2], 19456.0, -20480.0)
        call SetUnitPosition(campTroll[3], 19776.0, -20224.0)
        call SetUnitPosition(campTroll[4], 19264.0, -20160.0)
        call SetUnitPosition(campTroll[5], 19136.0, -20224.0)
        call SetUnitPosition(campTroll[6], 19136.0, -20672.0)
        call definirCampTroll()
        call setCamera(19640.00, -20426.64, 0.0, 134.53, 325.12, 2049.04, 0.0, 70.0, 5500.0, 100.0)
    endmethod

    private static method foretEte2 takes nothing returns nothing
        call BlzSetUnitSkin(campTroll[0], 'nfh1')
        call BlzSetUnitSkin(campTroll[1], 'nfh1')
        call BlzSetUnitSkin(campTroll[2], 'nfh0')
        call BlzSetUnitSkin(campTroll[3], 'nfh1')
        call BlzSetUnitSkin(campTroll[4], 'nfh1')
        call BlzSetUnitSkin(campTroll[5], 'nfh1')
        call BlzSetUnitSkin(campTroll[6], 'nfh1')
        call SetUnitPosition(campTroll[0], 9664.0, -1984.0)
        call SetUnitPosition(campTroll[1], 9536.0, -1856.0)
        call SetUnitPosition(campTroll[2], 9216.0, -2304.0)
        call SetUnitPosition(campTroll[3], 9664.0, -1856.0)
        call SetUnitPosition(campTroll[4], 8896.0, -1856.0)
        call SetUnitPosition(campTroll[5], 8768.0, -1856.0)
        call SetUnitPosition(campTroll[6], 8768.0, -1984.0)
        call definirCampTroll()
        call setCamera(9436.23, -2371.99, 0.0, 123.86, 313.12, 2196.15, 0.0, 70.0, 8052.55, 100.0)
    endmethod

    private static method foretEte3 takes nothing returns nothing
        call BlzSetUnitSkin(campTroll[0], 'nfh1')
        call BlzSetUnitSkin(campTroll[1], 'nfh1')
        call BlzSetUnitSkin(campTroll[2], 'nfh0')
        call BlzSetUnitSkin(campTroll[3], 'nfh1')
        call BlzSetUnitSkin(campTroll[4], 'nfh1')
        call BlzSetUnitSkin(campTroll[5], 'nfh1')
        call BlzSetUnitSkin(campTroll[6], 'nfh1')
        call SetUnitPosition(campTroll[0], 3264.0, -11392.0)
        call SetUnitPosition(campTroll[1], 2624.0, -11008.0)
        call SetUnitPosition(campTroll[2], 3136.0, -10880.0)
        call SetUnitPosition(campTroll[3], 2752.0, -11584.0)
        call SetUnitPosition(campTroll[4], 2624.0, -11136.0)
        call SetUnitPosition(campTroll[5], 2880.0, -11584.0)
        call SetUnitPosition(campTroll[6], 3264.0, -11264.0)
        call definirCampTroll()
        call setCamera(2957.53, -11260.61, 0.0, 125.00, 325.12, 2415.77, 0.0, 70.0, 5500.0, 100.0)
    endmethod

    private static method grandeForetEte takes nothing returns nothing
        call BlzSetUnitSkin(campTroll[0], 'nfh1')
        call BlzSetUnitSkin(campTroll[1], 'nfh1')
        call BlzSetUnitSkin(campTroll[2], 'nfh0')
        call BlzSetUnitSkin(campTroll[3], 'nfh1')
        call BlzSetUnitSkin(campTroll[4], 'nfh1')
        call BlzSetUnitSkin(campTroll[5], 'nfh1')
        call BlzSetUnitSkin(campTroll[6], 'nfh1')
        call SetUnitPosition(campTroll[0], 22720.0, -9088.0)
        call SetUnitPosition(campTroll[1], 22592.0, -8256.0)
        call SetUnitPosition(campTroll[2], 22400.0, -8704.0)
        call SetUnitPosition(campTroll[3], 22848.0, -8512.0)
        call SetUnitPosition(campTroll[4], 22208.0, -8256.0)
        call SetUnitPosition(campTroll[5], 21952.0, -8512.0)
        call SetUnitPosition(campTroll[6], 22080.0, -9088.0)
        call definirCampTroll()
        call setCamera(22902.29, -9011.16, 0.0, 115.26, 329.66, 2415.77, 0.0, 70.0, 10000.0, 100.0)
    endmethod

    private static method miniForetEnneige1 takes nothing returns nothing
        call BlzSetUnitSkin(campTroll[0], 'nth1')
        call BlzSetUnitSkin(campTroll[1], 'nth1')
        call BlzSetUnitSkin(campTroll[2], 'nth0')
        call BlzSetUnitSkin(campTroll[3], 'nth1')
        call BlzSetUnitSkin(campTroll[4], 'nth1')
        call BlzSetUnitSkin(campTroll[5], 'nth1')
        call BlzSetUnitSkin(campTroll[6], 'nth1')
        call SetUnitPosition(campTroll[0], 16704.0, -28544.0)
        call SetUnitPosition(campTroll[1], 16576.0, -27712.0)
        call SetUnitPosition(campTroll[2], 16384.0, -28160.0)
        call SetUnitPosition(campTroll[3], 16832.0, -27968.0)
        call SetUnitPosition(campTroll[4], 16192.0, -27712.0)
        call SetUnitPosition(campTroll[5], 15936.0, -27968.0)
        call SetUnitPosition(campTroll[6], 16064.0, -28544.0)
        call definirCampTroll()
        call setCamera(16187.12, -28372.67, 0.0, 54.72, 310.79, 2111.38, 0.0, 70.0, 10000.0, 100.0)
    endmethod

    private static method miniForetEnneige2 takes nothing returns nothing
        call BlzSetUnitSkin(campTroll[0], 'nth1')
        call BlzSetUnitSkin(campTroll[1], 'nth1')
        call BlzSetUnitSkin(campTroll[2], 'nth0')
        call BlzSetUnitSkin(campTroll[3], 'nth1')
        call BlzSetUnitSkin(campTroll[4], 'nth1')
        call BlzSetUnitSkin(campTroll[5], 'nth1')
        call BlzSetUnitSkin(campTroll[6], 'nth1')
        call SetUnitPosition(campTroll[0], 27968.0, -21056.0)
        call SetUnitPosition(campTroll[1], 27968.0, -20416.0)
        call SetUnitPosition(campTroll[2], 27648.0, -20736.0)
        call SetUnitPosition(campTroll[3], 27968.0, -20736.0)
        call SetUnitPosition(campTroll[4], 27328.0, -20416.0)
        call SetUnitPosition(campTroll[5], 27328.0, -20736.0)
        call SetUnitPosition(campTroll[6], 27328.0, -21056.0)
        call definirCampTroll()
        call setCamera(27544.13, -20917.86, 0.0, 66.04, 329.19, 1442.10, 0.0, 70.0, 10000.0, 100.0)
    endmethod

    private static method foretEnneige takes nothing returns nothing
        call BlzSetUnitSkin(campTroll[0], 'nth1')
        call BlzSetUnitSkin(campTroll[1], 'nth1')
        call BlzSetUnitSkin(campTroll[2], 'nth0')
        call BlzSetUnitSkin(campTroll[3], 'nth1')
        call BlzSetUnitSkin(campTroll[4], 'nth1')
        call BlzSetUnitSkin(campTroll[5], 'nth1')
        call BlzSetUnitSkin(campTroll[6], 'nth1')
        call SetUnitPosition(campTroll[0], 9536.0, -11584.0)
        call SetUnitPosition(campTroll[1], 9408.0, -10816.0)
        call SetUnitPosition(campTroll[2], 9216.0, -11328.0)
        call SetUnitPosition(campTroll[3], 9664.0, -11072.0)
        call SetUnitPosition(campTroll[4], 9024.0, -10816.0)
        call SetUnitPosition(campTroll[5], 8768.0, -11072.0)
        call SetUnitPosition(campTroll[6], 8896.0, -11584.0)
        call definirCampTroll()
        call setCamera(9193.58, -11336.36, 0.0, 68.87, 308.30, 1650.0, 0.0, 70.0, 10000.0, 100.0)
    endmethod

    private static method grandeForetEnneige takes nothing returns nothing
        call BlzSetUnitSkin(campTroll[0], 'nth1')
        call BlzSetUnitSkin(campTroll[1], 'nth1')
        call BlzSetUnitSkin(campTroll[2], 'nth0')
        call BlzSetUnitSkin(campTroll[3], 'nth1')
        call BlzSetUnitSkin(campTroll[4], 'nth1')
        call BlzSetUnitSkin(campTroll[5], 'nth1')
        call BlzSetUnitSkin(campTroll[6], 'nth1')
        call SetUnitPosition(campTroll[0], 6528.0, -24192.0)
        call SetUnitPosition(campTroll[1], 6528.0, -23424.0)
        call SetUnitPosition(campTroll[2], 6272.0, -23808.0)
        call SetUnitPosition(campTroll[3], 6720.0, -23808.0)
        call SetUnitPosition(campTroll[4], 6016.0, -23424.0)
        call SetUnitPosition(campTroll[5], 5824.0, -23808.0)
        call SetUnitPosition(campTroll[6], 6016.0, -24192.0)
        call definirCampTroll()
        call setCamera(6518.56, -23991.52, 0.0, 126.09, 327.46, 1862.76, 0.0, 70.0, 10000.0, 100.0)
    endmethod

    private static method definirCampTroll takes nothing returns nothing
        local integer i = 0
        loop
        exitwhen i == 7
            call SetUnitScale(campTroll[i], 0.750, 0.750, 0.0)
            call BlzSetUnitRealField(campTroll[i], UNIT_RF_SELECTION_SCALE, 2.0)
        set i = i + 1
        endloop
    endmethod

    public static method definirProprietaireBatimentTroll takes player joueur, boolean reinitialiser returns nothing
        local real x
        local real y
        local real face
        if reinitialiser then
            set x = GetUnitX(campTroll[2])
            set y = GetUnitY(campTroll[2])
            set face = GetUnitFacing(campTroll[2])
            call KillUnit(campTroll[2])
            call RemoveUnit(campTroll[2])
            set campTroll[2] = CreateUnit(joueur, 'u00B', x, y, face)
        else
            call SetUnitOwner(campTroll[2], joueur, true)
        endif
        
    endmethod

    public static method getBatimentTroll takes nothing returns unit
        return campTroll[2]
    endmethod
    
    /**
    * Permet de réinitialiser la camera de chaque joueur.
    *
    * @param nothing
    *
    * @return nothing
    */
    private static method reinitialiserCamera takes nothing returns nothing
        local real targetX = GetCameraTargetPositionX()
        local real targetY = GetCameraTargetPositionY()
        call setCamera(GetUnitX(campTroll[2]), GetUnitY(campTroll[2]), 0.0, 90.0, 304.0, 1650.0, 0.0, 70.0, 5000.0, 16.0)
    endmethod

endstruct
