      SUBROUTINE FMCRBOUT (IYR)
      use arrays_mod
      use fmcom_mod
      use fmparm_mod
      use contrl_mod
      use fmfcom_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
*     SINGLE-STAND VERSION
*     CALLED FROM: FMMAIN
*     CALLS:  FMCBIO
*  PURPOSE:
*     PRINT THE STAND CARBON REPORT
***********************************************************************
*
*  CALL LIST DEFINITIONS:
*     IYR:     CURRENT YEAR
*
***********************************************************************

C     PARAMETER INCLUDE FILES.


C     COMMON INCLUDE FILES

      INCLUDE 'PLOT.F77'
C      INCLUDE 'FMCLCOM.F77'
      INCLUDE 'METRIC.F77'

C     VARIABLE DECLARATIONS

      INTEGER   IYR

      LOGICAL   DEBUG,LDCAY,LMERCH
      INTEGER   I,JROUT,DBSKODE
      INTEGER   JS
      REAL      VT, X, H, D
      REAL      V(11)
      REAL      ABIO, MBIO, RBIO, XDCAY

C     CHECK FOR DEBUG.

      CALL DBCHK (DEBUG,'FMCRBOUT',8,ICYC)
      IF (DEBUG) WRITE(JOSTND,1) ICYC
    1 FORMAT(' ENTERING FMCRBOUT CYCLE = ',I2)
C
C     MAIN (STAND) CARBON REPORT.
C     RETRIEVE THE UNIT NUMBER TO BE USED FOR THE REPORT.
C
      CALL GETLUN (JROUT)
C
      IF (DEBUG) WRITE(JOSTND,40) ICRPTB,ICRPTE,IDCRPT,JROUT
   40 FORMAT(' FMDOUT: ICRPTB=',I5,' ICRPTE=',I5,
     >  ' IDCRPT=',I5,' JROUT=',I3)

      IF (CRDCAY .GT. 0.0) THEN
        LDCAY = .TRUE.
      ELSE
        LDCAY = .FALSE.
      ENDIF

C
C     THERE ARE 11 INDICATORS:
C
C      1 = ABOVEGROUND TOTAL LIVE
C      2 = ABOVEGOURND TOTAL MERCH
C      3 = BELOWGROUND LIVE
C      4 = BELOWGROUND DEAD (WHICH DECAYS)
C      5 = STANDING DEAD
C      6 = FOREST DOWN DEAD WOOD
C      7 = FOREST FLOOR (LITTER AND DUFF)
C      8 = FOREST SHRUB+HERB
C      9 = TOTAL STAND CARBON
C     10 = TOTAL CARBON REMOVED THIS REPORTING PERIOD
C     11 = TOTAL CARBON RELEASED FROM FIRE
C
C     1: CALCULATE THE INDICATORS, USING EITHER FFE OR JENKINS LOGIC
C        THERE MAY BE SOME EAST VS WEST VARIANT DIFFERENCES (THIS VERSION
C        IS IN /FIRE/NI/SRC, SO WILL DO FOR WEST; OTHER WOULD BE /FIRE/LS/SRC
C        WITH SAME FILENAME

C     2: LOAD ANY CONVERSION FACTORS (IMPERIAL -> METRIC) INTO THE
c        CNV() ARRAY BEFORE THE CALL TO THE DATABASE WRITE.

C      NOTES: ABG, BG, SNAGS, DDW, SHRUBS, HARVEST: C = BIOMASS*0.5
C      FOREST FLOOR: C = BIOMASS * 0.37 (Smith & Heath, research paper NE-722)
C     - JENKINS EQUATIONS GIVE KG. WE NEED TO CHANGE TO TONS

      DO I = 1,11
        V(I) = 0.0
      ENDDO

      DO I = 1,ITRN
        D = DBH(I)

C     1. ABOVEGROUND BIOMASS (ABIO)
C     2. MERCH BIOMASS       (MBIO) ("Stem wood" in Jenkin's paper; proportion)
C     3. BELOWGROUND LIVE    (RBIO) ("Coarse roots" in Jenkin's paper; proportion)
C     CALCULATE JENKINS EQUATIONS OF BIOMASS

        CALL FMCBIO(D, ISP(I), ABIO, MBIO, RBIO)

        ABIO = ABIO * FMPROB(I)
        MBIO = MBIO * FMPROB(I)
        RBIO = RBIO * FMPROB(I)

        V(3) = V(3) + RBIO

C       EASTERN FVS VARIANTS USE "TOTAL" VOLUME AS COMMERCIALLY
C       USEFUL, SO LMERCH IS .FALSE.; WESTERN VARIANTS USE
C       "MERCH" VOLUME AS COMMERCIALLY USEFUL, SO LMERCH IS .TRUE.

        IF (ICMETH .EQ. 1) THEN  ! JENKINS
          V(1) = V(1) + ABIO
          V(2) = V(2) + MBIO
        ELSE                     ! FFE
          JS = ISP(I)
          H = HT(I)
          X = -1.0
          LMERCH = .FALSE.
          IF (LVWEST) LMERCH = .TRUE.
          CALL FMSVL2(JS,D,H,X,VT,LMERCH,DEBUG,JOSTND)
          V(2) = V(2) + FMPROB(I) * VT * V2T(JS)
        ENDIF
      ENDDO

C     USE FFE EQUATIONS FOR BIOMASS OF ABIO, AND REPLACE THE VALUE IN THE ARRAY

      IF (ICMETH .EQ. 1) THEN    ! JENKINS
        V(10) = BIOREM(1)
      ELSE                       ! FFE
        V(1)  = BIOLIVE
        V(10) = BIOREM(2)
      ENDIF

C     SNAGS, DOWN DEAD WOOD, FOREST FLOOR, SHRUBS, ALL USE FFE EQUATIONS
C     ROOTS (WHEN DECAY >0) USE JENKINS EQUATIONS.

      V(4)  = BIOROOT
      V(5)  = BIOSNAG
      V(6)  = BIODDW
      V(7)  = BIOFLR
      V(8)  = BIOSHRB
      V(11) = BIOCON(1) * 0.37 + BIOCON(2) * 0.50

C     CONVERT BIOMASS TO C, BUT NOT 9TH OR 11TH

      DO I = 1,10
        SELECT CASE (I)
          CASE (1:6,8,10)
            V(I) = V(I) * 0.50
          CASE (7)
            V(I) = V(I) * 0.37
        END SELECT
      ENDDO

C     CONVERT UNITS IF NECESSARY

      IF (ICMETRC.EQ.1) THEN
        DO I = 1,11
          V(I) = V(I) * TItoTM / ACRtoHA
        ENDDO
      ELSEIF (ICMETRC.EQ.2) THEN
        DO I = 1,11
          V(I) = V(I) * TItoTM
        ENDDO
      ENDIF

C     SUM UP POOLS, POSSIBLY INCLUDING 4

      V(9) = V(1)+V(3)+V(5)+V(6)+V(7)+V(8)
      IF (LDCAY) THEN
        V(9) = V(9) + V(4)
      ELSE
        V(4) = -1.0
      ENDIF

C     SET ARRAY FOR CARBSTAT EVENT MONITOR FUNCTION

      DO I = 1,11
          CARBVAL(I) = V(I)
      ENDDO

C     ZERO OUT THE ACCUMULATING VARIABLES
C     DECAY THE DEAD ROOTS IF DECAY>0 AFTER 900 STATEMENT

      BIOSNAG   = 0.0
      BIODDW    = 0.0
      BIOFLR    = 0.0
      BIOSHRB   = 0.0
      BIOREM(1) = 0.0
      BIOREM(2) = 0.0
      BIOLIVE   = 0.0
      BIOCON(1) = 0.0
      BIOCON(2) = 0.0

C     JUMP TO THE END IF THIS YEAR IS NOT WITHIN THE REPORTING PERIOD, OR
C     ON THE REPORTING INTERVAL

      IF (IYR .LT. ICRPTB .OR. IYR .GT. ICRPTE) GOTO 900

C     CALL THE DBS MODULE TO OUTPUT FUEL DATA TO A DATABASE

      DBSKODE = 1
      CALL DBSFMCRPT(IYR,NPLT,V,11,DBSKODE)
      IF(DBSKODE.EQ.0) GOTO 900

C     IF HEADER REQUESTED AND THIS IS THE FIRST OPPORTUNITY TO PRINT
C     IT, THEN DO SO.
C
      ICRPAS = ICRPAS + 1
      IF (ICRPAS .EQ. 1) THEN
        WRITE(JROUT,699) IDCRPT
        WRITE(JROUT,699) IDCRPT
        WRITE(JROUT,700) IDCRPT
        WRITE(JROUT,701) IDCRPT
        WRITE(JROUT,702) IDCRPT
        IF (ICMETRC.EQ.1) THEN
          WRITE(JROUT,707) IDCRPT
        ELSEIF (ICMETRC.EQ.2) THEN
          WRITE(JROUT,709) IDCRPT
        ELSE
          WRITE(JROUT,708) IDCRPT
        ENDIF
        WRITE(JROUT,699) IDCRPT
        WRITE(JROUT, 44) IDCRPT,NPLT,MGMID
        WRITE(JROUT,700) IDCRPT
        WRITE(JROUT,704) IDCRPT
        WRITE(JROUT,705) IDCRPT
        WRITE(JROUT,706) IDCRPT
        WRITE(JROUT,700) IDCRPT

  699   FORMAT(1(/1X,I5))
  700   FORMAT(1X,I5,1X,110('-'))
  701   FORMAT(1X,I5,1X,30X,'******  CARBON REPORT VERSION 1.0 ******')
  702   FORMAT(1X,I5,1X,41X,'STAND CARBON REPORT '
     >                      '(BASED ON STOCKABLE AREA)')
   44   FORMAT(1X,I5,' STAND ID: ',A26,4X,'MGMT ID: ',A4)
  704   FORMAT(1X,I5,1X,6(' '),'Aboveground Live    Belowground',
     >    24(' '),'Forest',13(' '),'Total    Total     Carbon')
  705   FORMAT(1X,I5,1X,5(' '),17('-'),' ',17('-'),'    Stand  ',
     >    25('-'),'    Stand  Removed   Released')
  706   FORMAT(1X,I5,1X,'YEAR    Total    Merch     Live     ',
     >    'Dead     Dead      DDW    Floor  Shb/Hrb   ',
     >    'Carbon   Carbon  from Fire')
  707   FORMAT(1X,I5,1X,25(' '),
     > ('ALL VARIABLES ARE REPORTED IN METRIC TONS/HECTARE'))
  708   FORMAT(1X,I5,1X,30(' '),
     > ('ALL VARIABLES ARE REPORTED IN TONS/ACRE'))
  709   FORMAT(1X,I5,1X,27(' '),
     > ('ALL VARIABLES ARE REPORTED IN METRIC TONS/ACRE'))
      ENDIF

      WRITE(JROUT,800) IDCRPT,IYR,(V(I),I=1,11)
  800 FORMAT(1X,I5,1X,I4,10(2X,F7.1),4X,F7.1)
C
C     REGARDLESS OF PRINTING STATUS, DECAY ROOTS
C     CALLING ROUTINE IS ANNUAL (IFMYR1, IFMYR2), SO
C     JUST A COMPLEMENT-MULTIPLIER.
C     CLCWD PROVIDES POSSIBLE CLIMATE-SENSITIVE CHANGE
C     TO DECAY RATE. SEE SUB FMCWD FOR OTHER CWD EXAMPLES.
C
  900 IF (LDCAY) THEN
        X = 1.0
C        CALL CLCWD(Q10CWD(12),REFMATCWD(12),X)
        BIOROOT = BIOROOT * (1.0 - CRDCAY*X)**NYRS
      ELSE
        BIOROOT = 0.0
      ENDIF

      RETURN
      END
