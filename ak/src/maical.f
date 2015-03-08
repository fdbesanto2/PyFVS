      SUBROUTINE MAICAL
      use htcal_mod
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use outcom_mod
      use prgprm_mod
      implicit none
C----------
C  **MAICAL--AK    DATE OF LAST REVISION:  05/08/12
C----------
C  THIS SUBROUTINE CALCULATES THE MAI FOR THE STAND.
C  CALLED FROM CRATET.
C----------
C
C----------
      INTEGER ISPNUM(MAXSP),ISICD,IERR
      REAL SSSI,ADJMAI
C----------
C  INITIALIZE INTERNAL VARIABLES:
C----------
      DATA ISPNUM/098,242,011,264,263,042,108,098,019,351,747,300,098/
C----------
C     THE SPECIES ORDER IS AS FOLLOWS:
C     1 = WHITE SPRUCE (WS)
C     2 = WESTERN RED CEDAR (RC)
C     3 = PACIFIC SILVER FIR (SF)
C     4 = MOUNTAIN HEMLOCK (MH)
C     5 = WESTERN HEMLOCK (WH)
C     6 = ALASKA CEDAR (YC)
C     7 = LODGEPOLE PINE (LP)
C     8 = SITKA SPRUCE (SS)
C     9 = SUBALPINE FIR (AF)
C    10 = RED ALDER (RA)
C    11 = COTTONWOOD (CW)
C    12 = OTHER HARDWOODS (OH)
C    13 = OTHER SOFTWOODS (OS)
C
C   RMAI IS FUNCTION TO CALCULATE ADJUSTED MAI.
C-------
      IF (ISISP .EQ. 0) ISISP=5
      SSSI=SITEAR(ISISP)
      IF (SSSI .EQ. 0.) SSSI=80.0
      ISICD=ISPNUM(ISISP)
      RMAI=ADJMAI(ISICD,SSSI,10.0,IERR)
      IF(RMAI .GT. 128.0)RMAI=128.0
      RETURN
      END
