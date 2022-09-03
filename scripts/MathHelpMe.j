library MathHelpMe
    struct SuperMath

        public static method rendrePositifReal takes real nb returns real
            if nb < 0 then
                return nb * -1
            endif
            return nb
        endmethod

        public static method minReals takes real a, real b returns real
            if a < b then
                return a
            else
                return b
            endif
        endmethod

        public static method minRectangleX takes rect rectangle returns real
            return minReals(GetRectMaxX(rectangle), GetRectMaxY(rectangle))
        endmethod

        public static method minRectangleY takes rect rectangle returns real
            return minReals(GetRectMinX(rectangle), GetRectMinY(rectangle))
        endmethod

        public static method maxReals takes real a, real b returns real
            if a > b then
                return a
            else
                return b
            endif
        endmethod

        public static method maxRectangleX takes rect rectangle returns real
            return maxReals(GetRectMaxX(rectangle), GetRectMaxY(rectangle))
        endmethod

        public static method maxRectangleY takes rect rectangle returns real
            return maxReals(GetRectMinX(rectangle), GetRectMinY(rectangle))
        endmethod

        public static method getTailleRegionX takes rect rectangle returns real
            return maxRectangleX(rectangle) - minRectangleX(rectangle)
        endmethod

        public static method getTailleRegionY takes rect rectangle returns real
            return maxRectangleY(rectangle) - minRectangleY(rectangle)
        endmethod

        public static method getDistanceUnites takes unit unite1, unit unite2 returns real
            local real xU1 = rendrePositifReal(GetUnitX(unite1))
            local real yU1 = rendrePositifReal(GetUnitY(unite1))
            local real xU2 = rendrePositifReal(GetUnitX(unite2))
            local real yU2 = rendrePositifReal(GetUnitY(unite2))
            local real xResultat = SuperMath.maxReals(xU1, xU2) - SuperMath.minReals(xU1, xU2)
            local real yResultat = SuperMath.maxReals(yU1, yU2) - SuperMath.minReals(yU1, yU2)
            return SuperMath.maxReals(xResultat, yResultat) + SuperMath.minReals(xResultat, yResultat)
        endmethod

        public static method uniteEstAuxAlentours takes unit unite1, unit unite2, real rayon returns boolean
            local real distance = getDistanceUnites(unite1, unite2)
            if distance >= rayon * -1 and distance <= rayon then
                return true
            endif
            return false
        endmethod
    endstruct
endlibrary