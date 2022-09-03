struct Market

    private static integer prix = 155

    public static method bienvenue takes integer typeDeVente returns nothing
        if acheter(typeDeVente) then
        else 
            call vendre(typeDeVente)
        endif
    endmethod

    public static method getPrix takes nothing returns integer
        return prix
    endmethod

    private static method acheter takes integer typeDeVente returns boolean
        if typeDeVente == 'A031' then // Acheter 10 bois
            if verifierOrOuBois(prix, 10, true) then
                call setPrix(prix + 5)
            endif
            return true
        elseif typeDeVente == 'A02Z' then // Acheter 200 bois
            if verifierOrOuBois(prix * 20 + 950, 200, true) then
                call setPrix(prix + 100)
            endif
            return true
        endif
        return false
    endmethod


    private static method vendre takes integer typeDeVente returns nothing
        if typeDeVente == 'A032' then // Vendre 10 bois
            if verifierOrOuBois(10, prix - 10, false) then
                call setPrix(prix - 5)
            endif
        elseif typeDeVente == 'A030' then // Vendre 200 bois
            if verifierOrOuBois(200, prix * 20 - 950 , false) then
                call setPrix(prix - 100)
            endif
        endif
    endmethod

    private static method setPrix takes integer nouveauPrix returns nothing
        set prix = nouveauPrix
        if nouveauPrix < 5 then
            set prix = 5
        endif
    endmethod

    private static method verifierOrOuBois takes integer prix, integer produit, boolean acheter returns boolean
        local player joueur = GetOwningPlayer(GetSpellAbilityUnit())
        if acheter then
            if GetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD) >= prix then
                call AdjustPlayerStateBJ(prix * -1, joueur, PLAYER_STATE_RESOURCE_GOLD)
                call AdjustPlayerStateBJ(produit, joueur, PLAYER_STATE_RESOURCE_LUMBER)
                call DisplayTextToPlayer(joueur, 0, 0, "You have buy |c0000FF00" + I2S(produit) + " lumber|r for |c00FFD700" + I2S(prix) + " gold|r.")
                set joueur = null
                return true
            else
                call DisplayTextToPlayer(joueur, 0, 0, "|c00FF0000You have not enought of|r |c00FFD700gold|r|c00FF0000, you are missing|r |c00FFD700" + I2S(prix - GetPlayerState(joueur, PLAYER_STATE_RESOURCE_GOLD))  + " gold|r |c00FF0000to get|r |c0000FF00" + I2S(produit) + " lumber|r|c00FF0000.|r")
            endif
        elseif GetPlayerState(joueur, PLAYER_STATE_RESOURCE_LUMBER) >= prix then
            call AdjustPlayerStateBJ(prix * -1, joueur, PLAYER_STATE_RESOURCE_LUMBER)
            call AdjustPlayerStateBJ(produit, joueur, PLAYER_STATE_RESOURCE_GOLD)
            call DisplayTextToPlayer(joueur, 0, 0, "You have sell |c0000FF00" + I2S(prix) + " lumber|r for |c00FFD700" + I2S(produit) + " gold|r.")
            set joueur = null
            return true
        else
            call DisplayTextToPlayer(joueur, 0, 0, "|c00FF0000You have not enought of|r |c0000FF00lumber|r|c00FF0000, you are missing|r |c0000FF00" + I2S(prix - GetPlayerState(joueur, PLAYER_STATE_RESOURCE_LUMBER))  + " lumber|r |c00FF0000to get|r |c00FFD700" + I2S(produit) + " gold|r|c00FF0000.|r")
        endif
        set joueur = null
        return false
    endmethod

endstruct