      SUBROUTINE TREDEL (IVACT,INDEX)
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C     DELETES TREE RECORDS BY MOVING TREES FROM THE BOTTOM OF THE LIST
C     TO FILL IN EMPTY TREE RECORD LOCATIONS AT THE TOP OF THE LIST.
C     VACANT RECORDS ARE LABELED BY THE CALLING ROUTINE BY SETTING
C     THE SIGN OF CORRESPONDING MEMBERS OF INDEX NEGATIVE.  THE VALUE
C     OF IVACT IS PASSED IN AS THE NUMBER OF NEGATIVE MEMBERS OF INDEX.
C
C     **** MODIFICATION:  IF ITRN-IVAC IS EQUAL TO 1 WHEN THIS ROUTINE
C     IS CALLED, THE TREE RECORD IS DUPLICATED AND THE PROB IS SPLIT
C     BETWEEN EACH DUP.  NL CROOKSTON, APRIL 1985.
C
C     **** MODIFICATION: RECORDS BEING DELETED ARE MOVED TO THE BOTTOM
C     OF THE ARRAYS RATHER THAN BEING DISCARDED. THIS MAKES THE VALUES
C     AVAILABLE FOR FURTHER CALCULATIONS (SUCH AS SPMCDBH ON CUT TREES).
C     GARY DIXON, MAY 1998.
C
C     NL CROOKSTON-FORESTRY SCIENCES LAB, MOSCOW, ID.-JUNE 1982.
C
      INCLUDE 'ARRAYS.F77'
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'ESTREE.F77'
C
      INTEGER INDEX(MAXTRE),IVACT,IV,IR,IVAC,IREC
C
C     IF THERE ARE NO TREE RECORDS, BRANCH TO SET IREC1 AND RETURN.
C
      IF (ITRN.LE.0) GOTO 50
C
C     (A) SORT THE INDEX LIST SUCH THE VACANCY POINTERS ARE AT THE
C     TOP OF THE LIST.  THE ABSOLUTE VALUES OF THESE POINTERS POINT
C     TO THE VACANCIES IN DESCENDING ORDER.
C
      CALL IQRSRT(INDEX,ITRN)
C
C     (B) UPDATE THE VISULIZATION DATA STRUTURE FOR THE DELETED
C         TREES AND THEN INITIALIZE THE DATA STRUCTURE TO
C         RE-REFERENCE DATA
C
      CALL SVTDEL(INDEX,IVACT)
      CALL SVCMP1
C
C     (C) INITILIZE THE POINTERS TO THE INDICES OF
C     VACANCIES AND TREES. IVACT POINTS TO THE END OF THE
C     VACANCY POINTERS.
C
      IV = IVACT+1
      IR = ITRN+1
   10 CONTINUE
C
C     (D) DECREMENT THE INDEX TO THE VACANCY POINTERS.
C     IF THERE ARE NO MORE VACANCIES: EXIT
C
      IV = IV-1
      IF (IV .LT. 1) GO TO 20
C
C     (E) DECREMENT THE INDEX TO THE TREE POINTERS.
C     IF THERE ARE NO MORE TREES: EXIT
C
      IR = IR-1
      IF (IR .LE. IVACT) GO TO 20
C
C     (F) LOAD THE POINTERS TO THE VACANCY AND THE TREE RECORD.
C     IF THE VACANCY POINTER IS GREATER THAN THE TREE POINTER:  EXIT
C
      IVAC = -INDEX(IV)
      IREC = INDEX(IR)
      IF (IVAC .GT. IREC) GO TO 20
C
C     (F) MOVE THE TREE FROM POSITION IREC TO POSITION IVAC.
C
      CALL TREMOV (IVAC,IREC)
C
C     CALL WESTERN ROOT DISEASE MODEL VER. 3.0 SUBROUTINE TO DELETE
C     AND PACK WESTERN ROOT DISEASE TREELIST
C
      CALL RDTDEL (IVAC,IREC,0)
C
C     CALL BLISTER RUST ROUTINE TO REMOVE BLISTER RUST RECORDS.
C
      CALL BRTDEL (IVAC,IREC)
C
C     CALL THE FIRE MODEL TO MOVE ITS TREES
C
      CALL FMTDEL (IVAC,IREC)
C
C     REGISTER THE MOVE WITH THE VISULIZATION DATA
C
      CALL SVCMP2 (IVAC,IREC)
C
C     (G) GO ON TO THE NEXT TREE/VACANCY.
C
      GO TO 10
   20 CONTINUE
C
C     REBUILD THE VISULIZATION DATA POINTERS
C
      CALL SVCMP3
C
C     RESET ITRN.
C
      ITRN=ITRN-IVACT
   50 CONTINUE
      IREC1=ITRN
      RETURN
      END
