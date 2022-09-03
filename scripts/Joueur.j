struct Joueur

    private player joueur
    private string nom
    private integer niveauArmure = 0
    private integer armureBonus = 0
    private real rotationCam = 304.0
    private real distanceCam = 70.0
    private camerasetup cameraJoueur = CreateCameraSetup()     

    public static method create takes integer idJoueur returns thistype
        local thistype joueur = thistype.allocate()
        call joueur.initialiserJoueur(idJoueur)
        return joueur
    endmethod

    private static method definirVraiNom takes player joueur returns string
        local string nomDuJoueur = GetPlayerName(joueur)
        local integer i = StringLength(nomDuJoueur)
        local string caractere
        loop
            exitwhen i == -1
            set caractere = SubString(nomDuJoueur, i - 1, i)
            if caractere == "#" then
                return SubString(nomDuJoueur, 0, i - 1)
                exitwhen true
            endif
            set i = i - 1
        endloop
        return nomDuJoueur
    endmethod

    public method initialiserJoueur takes integer idJoueur returns nothing
        local player joueurLocal = GetLocalPlayer()
        set this.joueur = Player(idJoueur)
        set this.nom = definirVraiNom(joueur)
        if joueurLocal == joueur then 
            call CameraSetupSetField(cameraJoueur, CAMERA_FIELD_ZOFFSET, 0.0, 0)
            call CameraSetupSetField(cameraJoueur, CAMERA_FIELD_ROTATION, 90.0, 0)
            call CameraSetupSetField(cameraJoueur, CAMERA_FIELD_ANGLE_OF_ATTACK, 304.0, 0)
            call CameraSetupSetField(cameraJoueur, CAMERA_FIELD_TARGET_DISTANCE, 1650.0, 0)
            call CameraSetupSetField(cameraJoueur, CAMERA_FIELD_ROLL, 0.0, 0)
            call CameraSetupSetField(cameraJoueur, CAMERA_FIELD_FIELD_OF_VIEW, 70.0, 0)
            call CameraSetupSetField(cameraJoueur, CAMERA_FIELD_FARZ, 5000.0, 0)
            call CameraSetupSetField(cameraJoueur, CAMERA_FIELD_NEARZ, 16.0, 0)
            call CameraSetupSetDestPosition(cameraJoueur, GetCameraTargetPositionX(), GetCameraTargetPositionY(), 0)
        endif
    endmethod

    public method getNom takes boolean sansId returns string
        if sansId then
            return nom
        else
            return GetPlayerName(joueur)
        endif
    endmethod

    public method setDistanceCamera takes real distance returns nothing
        local player joueurLocal = GetLocalPlayer()
        if distance > 100.0 and distance < 4500.0 then
            set distanceCam = distance
            if joueurLocal == joueur then
                call CameraSetupSetField(cameraJoueur, CAMERA_FIELD_FIELD_OF_VIEW, distance, 0)
                call CameraSetupSetDestPosition(cameraJoueur, GetCameraTargetPositionX(), GetCameraTargetPositionY(), 0)
                call CameraSetupApplyForceDuration(cameraJoueur, true, 0.00)
            endif
        endif
        set joueurLocal = null
    endmethod

    public method setRotationCamera takes real rotation returns nothing
        local player joueurLocal = GetLocalPlayer()
        call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "Rotation a définir: " + R2S(rotation))
        if rotation >= 0.0 and rotation < 360.0 then
            call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "Rotation de la caméra avant la commande: " + R2S(GetCameraField(CAMERA_FIELD_ROTATION)))
            set rotationCam = rotation
            if joueurLocal == joueur then
                call CameraSetupSetField(cameraJoueur, CAMERA_FIELD_ROTATION, rotation, 0)
                call CameraSetupSetDestPosition(cameraJoueur, GetCameraTargetPositionX(), GetCameraTargetPositionY(), 0)
                call DisplayTextToForce(bj_FORCE_ALL_PLAYERS, "Rotation de la caméra après la commande: " + R2S(GetCameraField(CAMERA_FIELD_ROTATION)))
                call CameraSetupApplyForceDuration(cameraJoueur, true, 0.00)
            endif
        endif
        set joueurLocal = null
    endmethod

    public method augmenterNiveauArmure takes nothing returns nothing
        set niveauArmure = niveauArmure + 1
        set armureBonus = armureBonus + 60 + (niveauArmure * 16)
    endmethod

    public method getArmureBonus takes nothing returns integer
        return armureBonus
    endmethod

    public method sauvegarderInfos takes nothing returns nothing
        call PreloadGenClear()
        call PreloadGenStart()
        call Preload("Camera:\n\n\tDistance: " + R2S(distanceCam) + "\n\n\tRotation: " + R2S(rotationCam))
        call PreloadGenEnd("Troll And Elves Rebirth\\" + getNom(false) +".txt")
    endmethod

    public method getInfosCamera takes nothing returns nothing
        call Preloader("Troll And Elves Rebirth\\" + getNom(false) +".txt")
        call FlushChildHashtable(udg_MEGAHASHTABLE, Jeu.getIdJoueur(joueur))
    endmethod

endstruct