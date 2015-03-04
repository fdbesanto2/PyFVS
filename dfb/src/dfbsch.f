      SUBROUTINE DFBSCH
      use prgprm_mod
      implicit none
C----------
C  **DFBSCH DATE OF LAST REVISION:  05/30/13
C----------
C
C  THIS SUBROUTINE IS CALLED TO SCHEDULE REGIONAL OUTBREAKS RANDOMLY.
C
C  THIS SUBROUTINE WAS COPIED FROM THE SUBROUTINE TMSCHD OF THE DFTM
C  MODEL AND MODIFIED FOR USE WITH THE DFB MODEL.  THE TMSCHD MODEL WAS
C  WRITTEN BY :   N.L. CROOKSTON   MAY 1978 & JUNE 1981   INT -- MOSCOW
C  THE CONCEPT FOR THE 'RANSCHED' OPTION IS FROM A. R. STAGE.
C  INT -- MOSCOW.
C
C  CALLED BY :
C     MAIN   [PROGNOSIS]
C
C  CALLS :
C     DFBRAN  (SUBROUTINE)  [DFB]
C     OPNEW   (SUBROUTINE)  [PROGNOSIS]
C
C  LOCAL VARIABLES :
C     I      - COUNTER TO LOOP THROUGH CYCLES.
C     I1     - POSITION IN IY ARRAY TO START THE SEARCH TO FIND THE
C              NEXT OUTBREAK YEAR.
C     IFINYR - FINAL YEAR OF SIMULATION.
C     INVYR  - THE INVENTORY YEAR.
C     IPREV  - THE DATE OF THE LAST RECORDED DFB REGIONAL OUTBREAK.
C     IYI    - CYCLE TO SCHEDULE REGIONAL OUTBREAK (SUBSCRIPT OF ARRAY
C              IY).
C     KODE   - ERROR CODE FROM OPTION PROCESSOR ROUTINE OPNEW.
C     NEXT   - THE YEAR OF THE NEXT OUTBREAK.
C     NYR    - COUNTER THAT KEEPS TRACK OF THE NUMBER OF CALLS TO THE
C              RANDOM NUMBER GENERATOR BEFORE A NUMBER IS DRAWN THAT
C              FITS THE PROBABILITY OF A DFB EVENT.
C     PRMS   - HOLDS PARAMETERS FOR CALL TO OPTION PROCESSOR ROUTINE
C              OPNEW.
C     RAND   - A UNIFORM RANDOM NUMBER (0-1).
C
C  COMMON BLOCK VARIABLES USED :
C     DBEVNT - (DFBCOM)   INPUT
C     DEBUIN - (DFBCOM)   INPUT
C     IDBSCH - (DFBCOM)   INPUT
C     IPAST  - (DFBCOM)   INPUT
C     IWAIT  - (DFBCOM)   INPUT
C     IY     - (CONTRL)   INPUT
C     JODFB  - (DFBCOM)   INPUT
C     JOSTND - (CONTRL)   INPUT
C     LDFBON - (DFBCOM)   INPUT
C     NCYC   - (CONTRL)   INPUT
C     ORSEED - (DFBCOM)   INPUT
C
C REVISION HISTORY:
C   02-AUG-01 Lance R. David (FHTET)
C     (previous revision date was 01/17/96)
C     Added double precision variable TSEED to replace the addition statement
C     as the arugument in the call to DFBCSD because it caused a LF95 error.
C------------------------------------------------------------------------------
COMMONS
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'DFBCOM.F77'
C

      INTEGER IFINYR, I, I1, INVYR, IPREV, IYI, KODE, NEXT, NYR

      REAL    RAND, PRMS(1)
      DOUBLE PRECISION TSEED

      IF (DEBUIN) WRITE (JODFB,*) '** ENTERING SUBROUTINE DFBSCH'

C
C     IF THE DFB MODEL IS BEING USED AND REGIONAL OUTBREAKS ARE TO BE
C     SCHEDULED RANDOMLY THEN SCHEDULE THE REGIONAL OUTBREAKS.
C
      IF (LDFBON .AND. IDBSCH .EQ. 2) THEN
C
C        INITIALIZE VARIABLES.
C
         INVYR = IY(1)
         I1 = 1
         IPREV = IPAST
         IFINYR = IY(NCYC) + 10

C
C        START OF LOOP THAT RANDOMLY CALCULATES EACH REGIONAL OUTBREAK
C        AND SCHEDULES IT.
C
  100    CONTINUE
         NYR = 0

C
C        START OF LOOP THAT TESTS THE PROBABILITY OF REGIONAL OUTBREAK
C        TO A RANDOM NUMBER.  EACH CYCLE OF THIS LOOP REPRESENTS A YEAR.
C
  200    CONTINUE
         CALL DFBRAN(RAND)
         IF (RAND .LE. DBEVNT) GOTO 400
         NYR = NYR + 1
C
C        IF THE NEXT POSSIBLE REGIONAL OUTBREAK DATE IS BEYOND THE
C        ENDING DATE FOR THE SIMULATION THEN EXIT THIS ROUTINE
C        (GOTO 1000).
C
         IF ((IPREV + IWAIT + NYR) .GE. IFINYR) GOTO 1000
C
C        END OF LOOP TO TEST THE PROBABILITY OF REGIONAL OUTBREAK TO A
C        RANDOM NUMBER.
C
         IF (NYR .LT. 100) GOTO 200

C
C        THE ABOVE LOOP WAS EXECUTED TO MANY TIMES.  THE EVENT
C        PROBABILITY (DBEVNT) MAY BE TOO DAMN SMALL OR EQUAL TO ZERO.
C
         WRITE (JOSTND,300) DBEVNT
  300    FORMAT (//,'***** WARNING:  DOUGLAS-FIR BEETLE EVENT ',
     &      'PROBABILITY EQUALS:',E13.7,'.  NO OUTBREAKS SCHEDULED.')
         GOTO 1000

  400    CONTINUE
C
C        CALCULATE THE NEXT REGIONAL OUTBREAK BASED ON THE NUMBER OF
C        ITERATIONS OF THE ABOVE LOOP.
C
         NEXT = IPREV + IWAIT + NYR

         IF (NEXT .LT. INVYR) NEXT = INVYR
         IPREV = NEXT

C
C        INITIALIZE IYI AND I.
C
         IYI = 0
         I = I1
C
C        LOOP THROUGH EACH CYCLE YEAR UNTIL YOU REACH THE FIRST CYCLE
C        YEAR AFTER THE CALCULATED OUTBREAK YEAR.
C
  500    IF (IY(I) .GT. NEXT) GOTO 600
         I = I + 1
         GOTO 500
C
C        SET THE CYCLE YEAR TO THE CYCLE YEAR FOUND ABOVE MINUS 1 CYCLE
C        YEAR.
C
  600    CONTINUE
         IYI = I - 1

C
C        CALL THE EVENT MONITOR TO ADD THE REGIONAL OUTBREAK.
C
         CALL OPNEW (KODE, IY(IYI), 2208, 0, PRMS)
         IF (KODE .NE. 0) GOTO 1000
         I1 = IYI

         IF (IYI .GE. NCYC) GOTO 1000

C
C        GO TO THE TOP OF THE LOOP THAT SCHEDULES THE OUTBREAKS.
C
         GOTO 100
      ENDIF

 1000 CONTINUE

C
C     RESET SEED TO THE ORIGINAL SEED + 1128.  THIS IS DONE SO THAT
C     CHANGING THE LENGTH OF THE RUN WON'T CHANGE VALUES IN THE
C     RANDOM CALCULATIONS DURING AN OUTBREAK ON SIMULATIONS OF THE SAME
C     STAND.  (1128 WAS CHOSEN AT RANDOM).
C
      TSEED = ORSEED + 1128D0
      CALL DFBCSD(TSEED)

      IF (DEBUIN) WRITE (JODFB,*) '** LEAVING SUBROUTINE DFBSCH'

      RETURN
      END
