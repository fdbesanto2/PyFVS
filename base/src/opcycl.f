      SUBROUTINE OPCYCL (NCYC,IY)
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C     OPTION PROCESSING ROUTINE - NL CROOKSTON - JAN 1981 - MOSCOW
C
C     OPCYCL ESTABLISHES THE VALUES IN ARRAY IMGPTS SUCH THAT
C     IMGPTS(ICYC,1) POINTS TO THE POSITION IN IOPSRT WHICH
C     INTURN POINTS TO THE FIRST ACTIVITY TO BE
C     ACCOMPLISHED DURING CYCLE ICYC (IF NO ACTIVITIES, THE
C     VALUE WILL BE ZERO), AND IMGPTS(ICYC,2) POINTS TO THE LAST
C     VALUE IN IOPSRT WHICH POINTS TO ACTIVITY APPLICABLE TO
C     CYCLE ICYC.
C
      INCLUDE 'OPCOM.F77'
C
      INTEGER IY(MAXCY1),NCYC,MXACT,I,J,ILDT,IY2
C
C     SET MXACT EQUAL TO THE BOTTOM OF IACT.
C
      MXACT=IMGL-1
C
C     IF THERE ARE NO ACTIVITIES;
C     THEN: SIMPLY INITIALIZE IMGPTS TO ZEROS AND RETURN.
C
      IF (MXACT .GT. 0) GOTO 5
      DO 1 I=1,NCYC
      IMGPTS(I,1)=0
    1 CONTINUE
      RETURN
    5 CONTINUE
C
C     ELSE:
C     LOAD THE SMALLEST DATE INTO ILDT AND INITIALIZE A COUNTER,
C     J, WHICH WILL BE USED TO STEP THRU IOPSRT.
C
      J=1
      ILDT=IOPSRT(1)
      ILDT=IDATE(ILDT)
C
C     DO FOR ALL CYCLES
C
      DO 40 I=1,NCYC
C
C     LET IY2 BE THE VALUE OF THE FIRST YEAR OF THE NEXT CYCLE.
C
      IY2=IY(I+1)
C
C     IF THE SMALLEST DATE IS GE TO THE FIRST YEAR OF THE NEXT
C     CYCLE, OR IF THE ACTIVITIES LIST IS COMPLETELY ASSIGNED,
C     THEN: THE CURRENT CYCLE CONTAINS NO MANAGEMENT.
C
      IF (ILDT.GE.IY2 .OR. J.GT.MXACT) GOTO 30
C
C     ELSE: SAVE THE VALUE OF J AS THE POINTER TO THE FIRST
C     POISTION IN IOPSRT WHICH POINTS TO THE FIRST ACTIVITY OF THE
C     CYCLE AND START LOOKING FOR THE LAST ACTIVITY OF THE CYCLE.
C
      IMGPTS(I,1)=J
   10 CONTINUE
      J=J+1
C
C     IF J IS GT THE NUMBER OF ACTIVITIES;
C     THEN: THE LAST ACTIVITY IS ALSO THE LAST ONE FOR THIS CYCLE.
C
      IF (J .GT. MXACT) GOTO 20
C
C     ELSE: CONTINUE SERCHING FOR THE LAST ACTIVITY FOR THIS CYCLE.
C
      ILDT=IOPSRT(J)
      ILDT=IDATE(ILDT)
C
C     IF THE CURRENT VALUE OF ILDT IS LESS THAN THE LAST YEAR OF THE
C     CURRENT CYCLE; THEN: WE HAVE NOT FOUND THE LAST ACTIVITY
C     APPLICABLE TO THE CYCLE.
C
      IF(ILDT .LT. IY2) GOTO 10
C
C     ELSE: THE LAST ACTIVITY HAS BEEN FOUND. SAVE THE POINTER AND
C     GO ON TO THE NEXT CYCLE.
C
   20 CONTINUE
      IMGPTS(I,2)=J-1
      GOTO 40
   30 CONTINUE
      IMGPTS(I,1)=0
      IMGPTS(I,2)=0
   40 CONTINUE
      RETURN
      END
