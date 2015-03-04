      SUBROUTINE FORMCL(ISPC,IFOR,D,FC)
      use prgprm_mod
      implicit none
C----------
C  **FORMCL--KM     DATE OF LAST REVISION:  01/20/15
C----------
C
C THIS PROGRAM CALCULATES FORM FACTORS FOR CALCULATING CUBIC AND
C BOARD FOOT VOLUMES.
C
      INCLUDE 'CONTRL.F77'
C
C----------
      REAL SISKFC(MAXSP,5),BLM712(MAXSP),FC,D
      INTEGER IFOR,ISPC,IFCDBH
C----------
C  FOREST ORDER: (IFOR)
C  1=KLAMATH(505)       2=SIX RIVERS(510)     3=TRINITY(514)
C  4=SISKIYOU(611)      5=HOOPA(705)          6=SIMPSON(800)
C  7=BLM COOS BAY(712)
C
C  SPECIES ORDER: (ISPC)
C  1=OC  2=SP  3=DF  4=WF  5=M   6=IC  7=BO  8=TO  9=RF 10=PP 11=OH
C----------
C  SISKIYOU  FORM CLASS VALUES
C----------
      DATA SISKFC/
     & 74., 78., 76., 80., 72., 66., 72., 74., 75., 76., 70.,
     & 74., 78., 76., 80., 72., 70., 72., 74., 75., 76., 70.,
     & 74., 78., 74., 78., 72., 70., 72., 74., 75., 76., 70.,
     & 72., 75., 74., 76., 72., 68., 72., 74., 74., 74., 70.,
     & 72., 74., 72., 75., 72., 66., 72., 74., 74., 72., 70./
      DATA BLM712/
     & 74., 76., 76., 78., 72., 66., 72., 74., 78., 80., 70./
C----------
C  FOR REGION 6 FORESTS, LOAD THE FORM CLASS USING TABLE VALUES.
C  IF A FORM CLASS HAS BEEN ENTERED VIA KEYWORD, USE IT INSTEAD.
C
C  REGION 5 VOLUME ROUTINES DON'T USE FORM CLASS.
C----------
      IF(IFOR.EQ.4 .AND. FRMCLS(ISPC).LE.0.) THEN
        IFCDBH = (D - 1.0) / 10.0 + 1.0
        IF(IFCDBH .LT. 1) IFCDBH=1
        IF(D.GT.40.9) IFCDBH=5
        FC = SISKFC(ISPC,IFCDBH)
      ELSEIF(IFOR.EQ.7 .AND. FRMCLS(ISPC).LE.0.) THEN
        FC = BLM712(ISPC)
      ELSE
        FC=FRMCLS(ISPC)
        IF(FC .LE. 0.) FC=80.
      ENDIF
C
      RETURN
      END
