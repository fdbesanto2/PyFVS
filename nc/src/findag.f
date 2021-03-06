      SUBROUTINE FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX1,HTMAX1,
     &                  HTMAX2,DEBUG)
      use contrl_mod
      use plot_mod
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **FINDAG--NC  DATE OF LAST REVISION:  01/17/11
C----------
C  THIS ROUTINE FINDS EFFECTIVE TREE AGE BASED ON INPUT VARIABLE(S)
C  CALLED FROM **COMCUP
C  CALLED FROM **CRATET
C  CALLED FROM **HTGF
C----------
C  COMMONS
C
C----------
C  DECLARATIONS
C----------
      LOGICAL DEBUG
      INTEGER I,ISPC
      REAL AGMAX(MAXSP),AG,DIFF,HGUESS,SINDX,TOLER
      REAL D1,D2,H,SITAGE,SITHT,AGMAX1,HTMAX1,HTMAX2
C----------
C  DATA STATEMENTS
C----------
      DATA AGMAX/MAXSP*200.0/
C----------
C  INITIALIZATIONS
C----------
      AG = 2.0
      TOLER = 2.0
      AGMAX1 = AGMAX(ISPC)
      HTMAX1 = 300.
      SINDX = SITEAR(ISPC)
C----------
C  CRATET CALLS FINDAG AT THE BEGINING OF THE SIMULATION TO
C  CALCULATE THE AGE OF INCOMMING TREES.  AT THIS POINT ABIRTH(I)=0.
C  THE AGE OF INCOMMING TREES HAVING H>=HMAX IS CALCULATED BY
C  ASSUMEING A GROWTH RATE OF 0.10FT/YEAR FOR THE INTERVAL H-HMAX.
C  TREES REACHING HMAX DURING THE SIMULATION ARE IDENTIFIED IN HTGF.
C----------
      IF(H .GE. HTMAX1) THEN
        SITAGE = AGMAX1 + (H - HTMAX1)/0.10
        SITHT = H
        GO TO 30
      ENDIF
C
   75 CONTINUE
C----------
C  CALL HTCALC TO CALCULATE POTENTIAL HT GROWTH
C----------
      CALL HTCALC(SINDX,ISPC,AG,HGUESS,JOSTND,DEBUG)
C
      IF(DEBUG)WRITE(JOSTND,91200)I,AG,HGUESS,H
91200 FORMAT(' IN GUESS AN AGE--I,AG,HGUESS,H ',I5,3F10.2)
C
      DIFF=ABS(HGUESS-H)
      IF(DIFF .LE. TOLER .OR. H .LT. HGUESS)THEN
        SITAGE = AG
        SITHT = HGUESS
        GO TO 30
      END IF
      AG = AG + 2.
C
      IF(AG .GT. AGMAX1) THEN
C----------
C  H IS TOO GREAT AND MAX AGE IS EXCEEDED
C----------
        SITAGE = AGMAX1
        SITHT = H
        GO TO 30
      ELSE
        GO TO 75
      ENDIF
C
   30 CONTINUE
      IF(DEBUG)WRITE(JOSTND,50)I,SITAGE,SITHT,AGMAX1,HTMAX1
   50 FORMAT(' LEAVING SUBROUTINE FINDAG I,SITAGE,SITHT,AGMAX1,HTMAX1=',
     &I5,4F10.3)
C
      RETURN
      END
C**END OF CODE SEGMENT
