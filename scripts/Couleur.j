struct Couleur

    public static method getCouleurHexJoueur takes player p returns string
        local integer indexJoueur = Jeu.getIdJoueur(p)
        if indexJoueur == 0 then
            return "00FF0402"
        elseif indexJoueur == 1 then
            return "000042FF"
        elseif indexJoueur == 2 then
            return "001CE6B9"
        elseif indexJoueur == 3 then
            return "00540081"
        elseif indexJoueur == 4 then
            return "00FFFC01"
        elseif indexJoueur == 5 then
            return "00FE8A0E"
        elseif indexJoueur == 6 then
            return "0020C000"
        elseif indexJoueur == 7 then
            return "00E55BB0"
        elseif indexJoueur == 8 then
            return "00959697"
        elseif indexJoueur == 9  then
            return "007EBFF1"
        elseif indexJoueur == 10 then
            return "00106246"
        elseif indexJoueur == 11 then
            return "004E2A04"
        elseif indexJoueur == 12 then
            return "009C0000"
        elseif indexJoueur == 13 then
            return "000000C2"
        elseif indexJoueur == 14 then
            return "0000EBEB"
        elseif indexJoueur == 15 then
            return "00BD00FF"
        elseif indexJoueur == 16 then
            return "00ECCC86"
        elseif indexJoueur == 17 then
            return "00F7A48B"
        elseif indexJoueur == 18 then
            return "00BFFF80"
        elseif indexJoueur == 19 then
            return "00DBB8EC"
        elseif indexJoueur == 20 then
            return "004F4F55"
        elseif indexJoueur == 21 then
            return "00ECF0FF"
        elseif indexJoueur == 22 then
            return "0000781E"
        elseif indexJoueur == 23 then
            return "00A46F34"
        else
            return "00FAFAFA"
        endif
        return null
    endmethod
endstruct