      SUBROUTINE FMCANC (IYR,FMOIS,CFTMP,CANBURN,ROS,INTSTY,FCLS)
      use contrl_mod
      use fmcom_mod
      use fmfcom_mod
      use fmparm_mod
      use prgprm_mod
      implicit none
C
C  $Id$
C
C----------
C  **FMCANC FIRE-BC
C----------
*     SINGLE-STAND VERSION
*     CALLED FROM: FMPOFL
*                  FMBURN
*----------------------------------------------------------------------
*  PURPOSE:  CALCULATES THE CROWN FIRES USING THE CANADIAN METHOD
*----------------------------------------------------------------------
*
*  CALL LIST DEFINITIONS:
*     FMOIS    FIRE TYPE BEING CALCULATED
*     CFTMP    LABEL FOR TYPE OF FIRE
*     OINIT1   TORCHING INDEX
*     OACT1    CROWNING INDEX
*     CANBURN  FLAG FOR WHETHER CROWNING IS EVEN POSSIBLE
*
*  LOCAL VARIABLE DEFINITIONS:
*     CAC       CRITERION FOR ACTIVE CROWNING
*     CCR       CRITICAL MINIMUM RATE OF SPREAD FOR ACTIVE CROWNING
*     CFB       CROWN FRACTION BURNED
*     CROSA     PREDICTED CROWN FIRE SPERAD RATE
*     INTSTY    INTENSITY - MAY BE EQUIVALENT TO FUEL CONSUMPTION
*     USEMOIS   FUEL MOISTURE: EFFM, WHICH EQUATES TO 1HR DEAD FUEL MOISTURE
*     ROSP      PASSIVE CROWN FIRE SPREAD
*
*  COMMON BLOCK VARIABLES AND PARAMETERS:
*     ACTCBH   ACTUAL CROWN BASE HEIGHT (FT) (-1 means that there isn't one)
*     CBD      CROWN BULK DENSITY (METRIC UNITS)
*
***********************************************************************

C     PARAMETER STATEMENTS.

C     PARAMETER INCLUDE FILES.

C     COMMON INCLUDE FILES.
      INCLUDE 'PLOT.F77'
      INCLUDE 'METRIC.F77'

C     VARIABLE DECLARATIONS.

      INTEGER IYR,FMOIS, CANBURN
      REAL    OINIT1(3), OACT1(3)
      CHARACTER*8 CFTMP
      LOGICAL DEBUG
      INTEGER I,J, FCLS
      REAL CCR, CFB
      REAL CROSA
      REAL CAC
      REAL ROSP, ROS
      REAL MWIND, USEMOIS
      REAL INTSTY, TOTLOAD
      REAL TA2KGM2

      CALL DBCHK (DEBUG,'FMCANC',6,ICYC)
      IF (DEBUG) WRITE(JOSTND,7) ICYC,FMOIS,CBD
    7 FORMAT(' ENTERING FMCANC CYCLE=',I3,' FMOIS=',I2,' CBD=',F7.3)
      TA2KGM2 = (0.90718 / 0.4046945) * (1000. / 10000.)

      OINIT1(FMOIS) = -1.0
      OACT1(FMOIS) = -1.0
      FCLS = 0
      INTSTY = 0.0
C
C     IF THE CROWN IS VERY SPARSE, THEN CAN HAVE NO CROWN FIRE, SO IGNORE
C     THIS IS DIRECTLY FROM FMCFIR
C
      IF (CBD .LE. 0.0 .OR. CANBURN .EQ. 0) THEN
        CFTMP = 'SURFACE'
        CRBURN = 0.0
        OINIT1(FMOIS) = -1.0
        OACT1(FMOIS) = -1.0
        RFINAL = ROS
        RETURN
      ENDIF

C     FROM EMAIL FROM MIGUEL CRUZ

C     MWIND IS METRIC WIND - M/S INSTEAD OF MILES/HOUR
      MWIND = FWIND * MItoKM * 1000. / (60. * 60.)
C     EMAIL SAYS "FUEL MOISTURE": WE WILL USE 1 HR FUELS
      USEMOIS = MOIS(1,1)

C     CHANGE LOADING TO METRIC
      TOTLOAD = (TCLOAD + SMALL + LARGE) * FT3pACRtoM3pHA

      CCR = 3. / CBD
      CROSA = 11.021*(MWIND*3.6)**0.8966 * CBD**0.1901 *
     &        Exp(-0.1714* USEMOIS)
      CAC = CROSA / CCR
      ROSP = CROSA*Exp(-CAC)

      IF (CAC .GT. 1.0) THEN
        CFTMP = "ACTIVE"
C           (NOTE FROM STEVE: THE ROSA IN THE EMAIL SHOULD BE CROSA)
        RFINAL = CROSA * MtoFT
        FIRTYPE = 1
        CRBURN = 1.0
c        INTSTY =  18600*CROSA* TOTLOAD
c       calculate intensity from surface fuel and crown consumption instead of load
        INTSTY =  300*CROSA*  (CFIM_INPUT(25) + TCLOAD*TA2KGM2*CRBURN)
      ELSE
        CFTMP = "PASSIVE"
        RFINAL = ROSP  * MtoFT
        FIRTYPE = 2
        CFB = 1 - EXP(-.23*(CROSA - (ROS*FTtoM)))
        CRBURN = CFB
C        INTSTY =  18600*ROSP* TOTLOAD
        INTSTY =  300*ROSP* (CFIM_INPUT(25) + TCLOAD*TA2KGM2*CRBURN)
      ENDIF
C     Change from KJ/min/m to Kw/m
C      INTSTY = INTSTY / 60       !now done by changing 18600 to 300


C     CALCULATE INTENSITY CLASS
      IF (INTSTY .LT. 10.0) THEN
        FCLS = 1
      ELSE IF (INTSTY .LT. 500.0) THEN
        FCLS = 2
      ELSE IF (INTSTY .LT. 2000.0) THEN
        FCLS = 3
      ELSE IF (INTSTY .LT. 4000.0) THEN
        FCLS = 4
      ELSE IF (INTSTY .LT. 10000.0) THEN
        FCLS = 5
      ELSE
        FCLS = 6
      ENDIF


      IF (DEBUG) WRITE(JOSTND,*) 'CAC = ',CAC
      IF (DEBUG) WRITE(JOSTND,*) 'CROSA = ',CROSA
      IF (DEBUG) WRITE(JOSTND,*) 'CRBURN = ',CRBURN

      IF (DEBUG) WRITE(JOSTND,8) FMOIS,CFTMP,RFINAL
    8 FORMAT(' FMCFIR FMOIS=',I2,' CFTMP=',A,
     >       ' RFINAL=',F13.3)

      RETURN
      END
