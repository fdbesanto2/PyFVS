      SUBROUTINE ESOUT (LFG)
      use contrl_mod
      use eshap_mod
      use prgprm_mod
      implicit none
C----------
C  **ESOUT  DATE OF LAST REVISION:   07/17/13
C----------
C
C     PART OF THE ESTABLISHMENT MODEL SUBSYSTEM.  COPIES THE
C     PRINT DATA FROM FILE JOREGT TO JOSTND. CALLED FROM MAIN.
C
      INCLUDE 'ESHAP2.F77'
C
      INTEGER ISTLNB
      CHARACTER*132 RECORD
      LOGICAL LFG,LL
C
C     IF NO OUTPUT IS ASKED FOR (IPRINT = 0), DO NOT OPEN THE FILE.
C
      IF (IPRINT.EQ.0 .OR. JOREGT.EQ.JOSTND) RETURN
C
C     IS FILE OPENED?
C
      INQUIRE(UNIT=JOREGT,OPENED=LL)
      IF (.NOT.LL) RETURN
C
C     REWIND THE ESTAB OUTPUT FILE.
C
      ENDFILE JOREGT
      REWIND JOREGT
C
C     COPY THE FILE TO THE PRINTER.
C
   10 CONTINUE
      READ (JOREGT,20,END=40) RECORD
   20 FORMAT (A)
      IF (.NOT.LFG) THEN
         LFG=.TRUE.
         WRITE (JOSTND,30)
   30    FORMAT (132('-'))
      ENDIF

      IF (RECORD.NE.' ') THEN
         WRITE (JOSTND,20) RECORD(1:MAX0(1,ISTLNB(RECORD)))
      ELSE
         WRITE (JOSTND,20)
      ENDIF
      GOTO 10
   40 CONTINUE
C
C     PREPARE THE FILE FOR THE NEXT STAND.
C
      REWIND JOREGT
      RETURN
      END
