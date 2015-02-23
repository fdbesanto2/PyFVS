      SUBROUTINE FMCFMD (IYR, FMD)
      use arrays_mod
      use fmcom_mod
      use fmparm_mod
      use contrl_mod
      use fmfcom_mod
      use prgprm_mod
      implicit none
C----------
C  **FMCFMD FIRE-AK-DATE OF LAST REVISION:  03/04/08
C----------
C  SINGLE-STAND VERSION
C  CALLED FROM: FMBURN
C  PURPOSE:
C     THIS SUBROUTINE RETURNS TWO TYPES OF INFORMATION: THE FUEL MODEL
C     THAT WOULD BE USED IF THE STATIC FUEL MODEL OPTION IS SELECTED
C     (STORED AS IFMD(1), WITH A WEIGTH OF FWT(1)=1.0 AND THE CLOSEST
C     FUEL MODELS (UP TO 4) AND THEIR WEIGHTINGS FOR USE BY THE DYNAMIC
C     FUEL MODEL OPTION
C----------
C  CALL LIST DEFINITIONS:
C     FMD:     FUEL MODEL NUMBER
C
C  COMMON BLOCK VARIABLES AND PARAMETERS:
C     SMALL:   SMALL FUELS FROM DYNAMIC FUEL MODEL
C     LARGE:   LARGE FUELS FROM DYNAMIC FUEL MODEL
C----------
COMMONS
      INCLUDE 'PLOT.F77'
C
C----------
C     LOCAL VARIABLE DECLARATIONS
C----------
      INTEGER ICLSS
      PARAMETER(ICLSS = 13)
C

      INTEGER  IYR,FMD
      INTEGER  IPTR(ICLSS), ITYP(ICLSS)
      INTEGER  J,I,K,L
      REAL     XPTS(ICLSS,2),EQWT(ICLSS), AFWT
      LOGICAL  DEBUG
C----------
C  THESE ARE THE INTEGER TAGS ASSOCIATED WITH EACH FIRE MODEL
C  CLASS. THEY ARE RETURNED WITH THE WEIGHT
C----------
      DATA IPTR / 1,2,3,4,5,6,7,8,9,10,11,12,13 /
C----------
C  THESE ARE 0 FOR REGULAR LINES, -1 FOR HORIZONTAL AND 1 FOR
C  VERTICAL LINES. IF ANY OF THE LINES DEFINED BY XPTS() ARE OF
C  AN UNUSUAL VARIETY, THIS MUST BE ENTERED HERE SO THAT
C  SPECIAL LOGIC CAN BE INVOKED.  IN THIS CASE, ALL THE LINE
C  SEGMENTS HAVE A |SLOPE| THAT IS > 0 AND LESS THAN INIF.
C----------
      DATA ITYP / ICLSS * 0 /
C----------
C  XPTS: FIRST COLUMN ARE THE SMALL FUEL VALUES FOR EACH FIRE MODEL
C  WHEN LARGE FUEL= 0 (I.E. THE X-INTERCEPT OF THE LINE). SECOND
C  COLUMN CONTAINS THE LARGE FUEL VALUE FOR EACH FIRE MODEL WHEN
C  SMALL FUEL=0 (I.E. THE Y-INTERCEPT OF THE LINE).
C----------
      DATA ((XPTS(I,J), J=1,2), I=1,ICLSS) /
     &   5., 15.,   ! FMD   1
     &   5., 15.,   ! FMD   2
     &   5., 15.,   ! FMD   3
     &   5., 15.,   ! FMD   4
     &   5., 15.,   ! FMD   5
     &   5., 15.,   ! FMD   6
     &   5., 15.,   ! FMD   7
     &   5., 15.,   ! FMD   8
     &   5., 15.,   ! FMD   9
     &  15., 30.,   ! FMD  10
     &  15., 30.,   ! FMD  11
     &  30., 60.,   ! FMD  12
     &  45.,100./   ! FMD  13

C----------
C  INITIALLY SET ALL MODELS OFF; NO TWO CANDIDATE MODELS ARE
C  COLINEAR, AND COLINEARITY WEIGHTS ARE ZERO. IF TWO CANDIDATE
C  MODELS ARE COLINEAR, THE WEIGHTS MUST BE SET, AND
C  MUST SUM TO 1, WRT EACH OTHER
C----------
      DO I = 1,ICLSS
        EQWT(I)  = 0.0
      ENDDO
C----------
C  BEGIN ROUTINE
C----------
      CALL DBCHK (DEBUG,'FMCFMD',6,ICYC)
C
      IF (DEBUG) WRITE(JOSTND,1) ICYC,IYR,LUSRFM
    1 FORMAT(' FMCFMD CYCLE= ',I2,' IYR=',I5,' LUSRFM=',L5)
C----------
C  IF USER-SPECIFIED FM DEFINITIONS, THEN WE ARE DONE.
C----------
      IF (LUSRFM) RETURN
C
      IF (DEBUG) WRITE(JOSTND,6) ICYC,IYR,HARVYR,LDYNFM,PERCOV,FMKOD,
     >           SMALL,LARGE
    6 FORMAT(' FMCFMD CYCLE= ',I2,' IYR=',I5,' HARVYR=',I5,
     >       ' LDYNFM=',L2,' PERCOV=',F7.2,' FMKOD=',I4,
     >       ' SMALL=',F7.2,' LARGE=',F7.2)
C----------
C  LOW FUEL MODEL SELECTION
C  THIS IS CURRENTLY PART OF A STRIPPED-DOWN VERSION OF AK-FFE.
C  NO FUEL MODEL LOGIC CALIBRATION WAS DONE, SO WE JUST SET THE FUEL
C  MODEL TO FM 8, UNLESS HIGH FUEL LOADS LEAD TO A 10, 11, 12, OR 13
C----------
      EQWT(8) = 1.0
C----------
C  END OF DETAILED LOW FUEL MODEL SELECTION
C----------
C----------
C      DURING THE 5 YEARS AFTER AN ENTRY, AND ASSUMING THAT SMALL+LARGE
C      ACTIVITY FUELS HAVE JUMPED BY 10%, THEN MODEL 11 IS A
C      CANDIDATE MODEL, SHARING WITH 10. THE WEIGHT OF THE SHARED
C      RELATIONSHIP DECLINES FROM PURE 11 INITIALLY, TO PURE 10 AFTER
C      THE PERIOD EXPIRES.
C----------
      AFWT = MAX(0.0, 1.0 - (IYR - HARVYR) / 5.0)
      IF (SLCHNG .GE. SLCRIT .OR. LATFUEL) THEN
        LATFUEL = .TRUE.
        EQWT(11)  = AFWT
        IF (AFWT .LE. 0.0) LATFUEL = .FALSE.
      ENDIF
      IF (.NOT. LATFUEL) AFWT = 0.0
C----------
C        MODELS 10,12, AND 13 ARE CANDIDATE MODELS FOR NATURAL FUELS
C----------
      EQWT(10) = 1.0 - AFWT
      EQWT(12) = 1.0
      EQWT(13) = 1.0
C----------
C  CALL FMDYN TO RESOLVE WEIGHTS, SORT THE WEIGHTED FUEL MODELS
C  FROM THE HIGHEST TO LOWEST, SET FMD (USING THE HIGHEST WEIGHT)
C----------
      CALL FMDYN(SMALL,LARGE,ITYP,XPTS,EQWT,IPTR,ICLSS,LDYNFM,FMD)
C
      IF (DEBUG) WRITE (JOSTND,10) FMD,LDYNFM
   10 FORMAT (' FMCFMD, FMD=',I4,' LDYNFM=',L2)
C
      RETURN
      END
