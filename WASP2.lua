@name WASP 2 - Multipourpose Bot (Gunnanmon)

@inputs Target:entity
@inputs NumZero NumPeriod NumPlus NumEnter NumSlash
@inputs Range

@outputs Vec:vector GPS:vector Mult MultNeg Thr
@outputs TarNex Arm CamSel CamZoom
@outputs TarHud GunHud ForceHud GrabHud
@outputs GunFire ForceFire GrabFire Ammo
@outputs CamPitch CamYaw

@persist ID:entity Height Dist Weapon AmmoChk Cam


interval(20)

if(first()) {timer(£Wait£,1)}
if(clk(£Wait£)) {ID = entity():owner()}

Mult = 10000
MultNeg = -10000
GPS = entity():pos()

if (~NumEnter & NumEnter)
   {
    Cam = (Cam + 1)%4
    CamSel = (Cam > 0)
    if (Cam) {CamZoom = 90}
    if (Cam == 2) {CamZoom = 8}
    if (Cam == 3) {CamZoom = 0}
   }

if (Cam > 0)
   {
    CamPitch = entity():angles():pitch()
    CamYaw = entity():angles():yaw()
   }

if (~NumPlus & NumPlus)
   {
    Weapon = (Weapon + 1)%4
    GunHud = (Weapon == 1)
    GrabHud = (Weapon == 2)
    ForceHud = (Weapon == 3)
    GrabFire = 0
   }

if ((~NumPeriod & NumPeriod) & !NumSlash) {Arm = (Arm + 1)%2}

if (Ammo > 0) {Ammo -= 0.2}
if (Ammo > 50) {AmmoChk = 0, Ammo = 50} else {AmmoChk = 1}
if (NumZero & !NumSlash) {TarNex = 1} else {TarNex = 0}
if ((NumSlash & NumZero) & GunHud) {Ammo += 1}
if (Arm & (Range > 0) & GunHud) {Ammo += 1}

if (Arm)
   {
    TarHud = Target:id() 
    
    if (TarHud)
       {
        Dist = Target:pos():distance(GPS)
        if (Target:isPlayer() | Target:isNPC())
           {
            if (Target:health() >= 0) {Thr = ((Dist > 100) * (Range < 75)) * Dist^2}
            else {Thr = 0, TarNex = 1}
           } 
        else {Thr = ((Dist > 100) * (Range < 75)) * Dist^2}
        
        Vec = GPS - Target:pos() - vec(0,0,Target:height()/2)
        GunFire = (GunHud * (Range > 0)) * ((Dist < 107) * AmmoChk)
        GrabFire = (GrabHud * (Range > 0)) * (Dist < 107)
        ForceFire = (ForceHud * (Range > 0)) * (Dist < 107) * 10000
       }

    else
       {
        Dist = ID:pos():distance(GPS)
        Thr = (Dist^2) * (Dist > 200)
        Vec = GPS - ID:pos() - vec(0,0,200)
        GunFire = 0, GrabFire = 0, ForceFire = 0, TarNex = 0
       }
   }

if (!NumSlash & !Arm)
   {
    TarHud = Target:id()
    Dist = ID:pos():distance(entity():pos())
    Thr = (Dist^2) * (Dist > 150)
    Vec = GPS - ID:pos() - vec(0,0,120)
    GunFire = 0, ForceFire = 0
   }

if (NumSlash)
   {
    Arm = 0
    Vec = GPS - (ID:eye() * (9999999 + ID:shootPos():length()) + ID:shootPos())
    Thr = NumPeriod * 10000
    GunFire = NumZero * GunHud * AmmoChk
    GrabFire = NumZero * GrabHud
    ForceFire = NumZero * ForceHud * 10000
   }
