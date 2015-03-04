      SUBROUTINE MPBDRV
      use prgprm_mod
      implicit none
C----------
C  **MPBDRV        DATE OF LAST REVISION:  08/22/14
C----------
C
C     INTERFACING PROGRAM TO CALL MPBMOD
C
C Revision History
C   05/31/00 GEB
C     Adding variable IDXLP, the index of Lodgepole pine in arrays
C     Defined in mpblkd.f, which is variant dependent
C   12/01/98 RNH
C     Adapated to 24 species (CR variant)
C   07/02/10 Lance R. David (FMSC)
C   03/29/13 Lance R. David (FMSC)
C     Some variables defined locally were already defined in a common.
C   08/22/14 Lance R. David (FMSC)
C     Function name was used as variable name.
C     changed variable INT to INCRS
C----------
COMMONS
      INCLUDE 'ARRAYS.F77'
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'PLOT.F77'
C
      INCLUDE 'MPBCOM.F77'
C

      CHARACTER*4 IF60

      INTEGER ITWO, MAXCLS, KODE, II, I1, I2, I, J

      REAL A3(1),A4(1),A5(1),A6(1),A7(1),A8(1),
     &     DGI,DDS5,BAI5,X,DEAD,SUMDED

      DATA MAXCLS/ 30 /,ITWO/ 2 /, IF60/'F6.0'/
C
C     BETTER= REALITIVE IMPORTANCE VALUES OF ATTRIBUTES OF INTEREST
C     CLASS = ATTRIBUTES IN THEIR RESPECTIVE CLASSES
C     IMPROB= POINTS TO THE POSITION WITHIN CLASS OF PROB
C     NACLAS= ACTUAL  NUMBER OF CLASSES     1 <= NACLAS <= 30
C     NCLASS= NUMBER OF CLASSES REQUESTED   2 <= NCLASS <= 30
C     NATR  = NUMBER OF ATTRIBUTES TO BE CLASSIFIED
C     DEBUIN= TRUE WHEN 'DEBUG' WAS SPECIFIED IN TREMOD SYSIN
C     WORKIN= TRUE IF MPBMOD WAS IN THE MID OF AN INFESTATION
C             WHEN IT LAST RETURNED TO MPBDRV.  CAN ALSO BE
C             SET TRUE WHEN 'MANUAL' IS SPECIFIED IN TREMOD SYSIN.
C     LBET  = TRUE IF BETTER HAS BEEN INITIALIZED
C     RGMORT= FALSE WHEN MPBMOD CAUSES 'PRCENT' OR MORE PERCENT
C             MORTALITY FOR SPECIES 'ISPC'.  TRUE IF MORTS
C             IS TO CALCULATE ADDITIONAL MORTALITY
C     PRCENT= PERCENT MORTALITY CRITERIA FOR SWITCHING 'RGMORT'
C     DEAD  = TOTAL PROB WHICH IS DEAD UPON RETURN FROM MPBMOD
C     SURVIV= PERCENT SURVIVAL IN EACH CLASS
C
C Revision History
C    Last noted revision date.
C   07/02/10 Lance R. David (FMSC)
C----------
C********************        EXECUTION   STARTS        ***************
C
C     IF WE ARE NOT IN THE MIDST OF AN OUTBREAK;
C     COMPUTE PERIODIC GROWTH RATIO.
C
      IF (MPBYR.EQ.0) CALL MPGR
C
C     Changed pointer array ISCT subscript from 7 to IDXLP to correspond
C     with new species mapping and new location for LP (RNH Dec98, GEB May2000)
C
      I1 = ISCT(IDXLP,1)
      I2 = ISCT(IDXLP,2)
C
C      I1 = ISCT(7,1)
C      I2 = ISCT(7,2)
      ILP=I2-I1+1
      DO 10 J=I1,I2
      I = IND1(J)
C
C     LOAD ARRAY 'IPT'
C
      IPT(J) = I
C
C     CALCULATE PHLOEM THICKNESS OF EACH TREE RECORD.
C     STORE VALUES IN XPT FOR COMPRESSION.
C
C     CALCULATE DELTA DIAMETER SQUARED FOR A 5 YEAR PERIOD.
C
      DGI = DG(I)
      DDS5 = ( 2. * DBH(I) * DGI + DGI * DGI ) / 2.0
      BAI5 = DDS5 * 0.7853982
C
C     PHLOEM MODEL: (FROM D. M. COLE (1973))
C     TREES UNDER 4.5 FEET TALL HAVE NO DIAMETER GROWTH...THEREFORE
C     ONLY ESTIMATE PHLOEM ON TREES WHICH HAVE DIA. GROWTH.
C
      XPT(I)=0.
      IF (BAI5.GT..0001) XPT(I) = EXP(-3.17152 + .12591*ALOG(BAI5) +
     >               .50932*ALOG(DBH(I)) - .0077*HT(I))
C
C     THE FOLLOWING PHLOEM MODEL WAS CALIBRATED FROM DATA COLLECTED
C     IN THE BLUE MOUNTAINS, EASTERN OR.  AND HAS A STRONGERR
C     CORRELATION WITH DIA GROWTH THAN COLE'S.
C
C*    IF (BAI5.GT..0001) XPT(I) = EXP(-2.90907+0.45506*ALOG(BAI5) -
C*   >                            0.37328*ALOG(DBH(I))+0.0029*HT(I))
C
   10 CONTINUE
C
C     LOAD ARRAYS 'CLASS' AND 'MPISC'
C
      IF ( DEBUIN ) WRITE (JOMPB,20)
   20 FORMAT ('CALLING GARBEL (LP)')
C
      CALL GARBEL ( IPT(I1),ILP,KEYMPB,BETTER,6,
     >            NACLAS,.5,CLASS,MPISC,WK3,DBH,XPT,A3,A4,A5,
     >            A6,A7,A8,PROB,KODE,MAXCLS,ITWO)
      IF (KODE .EQ. 0) GO TO 40
      WRITE  (JOMPB,30)
   30 FORMAT (/'********    ERROR - LPMPB: SUBROUTINE GARBEL FAILED')
   40 CONTINUE
C
C     ADD THE PROPER OFFSET TO SECTOR POINTERS
C
      DO 50 I = 1, NACLAS
      MPISC(I,1) = MPISC(I,1) + I1 - 1
      MPISC(I,2) = MPISC(I,2) + I1 - 1
   50 CONTINUE
C
C     STORE TOTAL PROB FOR EACH CLASS.  THIS ALLOWS CALCULATION OF
C     PROPORTIONATE SURVIVAL IN CLASS(I,IMPROB)
C
      DO 60 I=1,NACLAS
      SURVIV(I) = CLASS(I,IMPROB)
   60 CONTINUE
C
C*    IF ( .NOT. DEBUIN ) GO TO 90
C
C     THIS DEBUG OUTPUT IS DEPENTENT UPON A FIXED CLASSIFICATION
C     SYSTEM. (THE VALUES OF 'KEYMPB' ARE ASSUMED)
C
C*    WRITE (JOMPB,62)
C* 62 FORMAT ('CLASS    MPISC  II    I     DBH',
C*   >        '     PHLOEM      PROB     P-VECTOR',/)
C*    DO 80 J=1,NACLAS
C*    I1= MPISC(J,1)
C*    I2= MPISC(J,2)
C*    DO 70 II=I1,I2
C*    I=IPT(II)
C*    WRITE (JOMPB,65) II,I,DBH(I),XPT(I),PROB(I),WK3(I)
C* 65 FORMAT (13X,2I5,F10.2,F10.4,F10.2,F12.5)
C* 70 CONTINUE
C*    WRITE (JOMPB,75) J,I1,I2,CLASS(J,2),CLASS(J,3),CLASS(J,1)
C* 75 FORMAT (/,I3,I6,I5,9X,F10.2,F10.4,F10.2/)
C* 80 CONTINUE
C
C* 90 CONTINUE
C
      IF ( MPBYR .EQ. 0 ) CALL MPBHED
C
C                         *********   CALL MPBMOD   **********
C
      CALL SURFCE
      CALL MPBMOD
C
C     CALCULATE PROPORTIONATE REDUCTION IN CLASS(I,IMPROB)
C
      DO 100 I=1,NACLAS
      SURVIV (I) = CLASS(I,IMPROB) / SURVIV(I)
  100 CONTINUE
C
      IF ( .NOT. DEBUIN ) GO TO 130
      WRITE (JOMPB,110) (SURVIV(I),I=1,NACLAS)
  110 FORMAT (/,'SURVIV . . .',//,3(10E13.3,/))
C
  130 CONTINUE
C
C     PUT DEAD TREES IN WK2--CONVERTED TO VOLUMNS IN UPDATE.
C
      SUMDED=0.0
      DO 140 J=1,NACLAS
      I1= MPISC(J,1)
      I2= MPISC(J,2)
      DEAD = 1.-SURVIV(J)
      SUMDED=SUMDED+TPROB
      DO 135 II=I1,I2
      I=IPT(II)
      X = PROB(I)*DEAD
      IF (X .GT. WK2(I)) WK2(I)=X
      IF (PROB(I)-WK2(I) .LT. 1E-6) WK2(I)=PROB(I)-1E-6
  135 CONTINUE
  140 CONTINUE

C
C     IF WE JUST RETURNED FORM MPBMOD FOR THE LAST TIME, FOR THIS
C     STAND AND FOR THIS EPIDEMIC, WE PRINT THE OUTBREAK GRAPH
C
      IF ( DEBUIN ) WRITE (JOMPB,170) MPBYR,MPBGRF
  170 FORMAT (//,'MPBYR = ',I3,' MPBGRF = ',L2)
      IF ( MPBYR .GT. 0 .OR. .NOT. MPBGRF ) RETURN
C
C     ENTRY TO WRITE FINAL PLOT OUTPUT (GRAPH)
C
      ENTRY MPLOTW
C
      CALL MPBHED
      WRITE (JOMPB,180)
  180 FORMAT (/,T7,'** ATTACK, EMERGENCE & PIONEER DENSITIES',
     >        ' (A,E,D),  SURFACE KILLED (*),  BEETLES PRODUCED',
     >        ' (B), AND P **',/,T7,
     >        '    NOTE:  $ SHOWS ACTUAL SURFACE KILLED DATA',/)
C
      CALL PTOPT ( IPLTNO, JOMPB, IF60  , INCRS + 1, 1 )
C
      RETURN
      END
