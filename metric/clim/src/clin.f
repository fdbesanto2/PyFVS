      SUBROUTINE CLIN (DEBUG,LKECHO)
      use contrl_mod
      use metric_mod
      use plot_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
      INCLUDE 'CLIMATE.F77'
C
      INTEGER    KWCNT
      PARAMETER (KWCNT = 7)

      CHARACTER*8  TABLE(KWCNT), KEYWRD
      CHARACTER*10 KARD(7)
      CHARACTER*2048 CHTMP,FMT
      CHARACTER*40 CSTDID
      CHARACTER*30 CCLIM,CYR
      LOGICAL      LNOTBK(7),LKECHO,DEBUG
      REAL         ARRAY(7),TMPATTRS(MXCLATTRS)
      INTEGER      KODE,IPRMPT,NUMBER,I,I1,I2,IYRTMP,IUTMP,IRTNCD

      DATA TABLE /
     >     'END','CLIMDATA','MORTMULT','AUTOESTB','GROWMULT',
     >     'MXDENMLT','CLIMREPT'/

C
C     **********          EXECUTION BEGINS          **********
C

C     SIGNAL THAT THE CLIMATE MODEL IS NOW ACTIVE.

   10 CONTINUE
C
      CALL KEYRDR (IREAD,JOSTND,DEBUG,KEYWRD,LNOTBK,
     >             ARRAY,IRECNT,KODE,KARD,LFLAG,LKECHO)
C
C  RETURN KODES 0=NO ERROR,1=COLUMN 1 BLANK OR ANOTHER ERROR,2=EOF
C               LESS THAN ZERO...USE OF PARMS STATEMENT IS PRESENT.
C

      IF (KODE.LT.0) THEN
         IPRMPT=-KODE
      ELSE
         IPRMPT=0
      ENDIF
      IF (KODE .LE. 0) GO TO 30
      IF (KODE .EQ. 2) CALL ERRGRO(.FALSE.,2)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN

      CALL ERRGRO (.TRUE.,6)
      GOTO 10
   30 CONTINUE
      CALL FNDKEY (NUMBER,KEYWRD,TABLE,KWCNT,KODE,.FALSE.,JOSTND)
C
C     RETURN KODES 0=NO ERROR,1=KEYWORD NOT FOUND,2=MISSPELLING.
C
      IF (KODE .EQ. 0) GOTO 90
      IF (KODE .EQ. 1) THEN
         CALL ERRGRO (.TRUE.,1)
         GOTO 10
      ENDIF
      GOTO 90
C
C     SPECIAL END-OF-FILE TARGET
C
   80 CONTINUE
      CALL ERRGRO(.FALSE.,2)
      CALL fvsGetRtnCode(IRTNCD)
      IF (IRTNCD.NE.0) RETURN

   90 CONTINUE
C
C     PROCESS OPTIONS
C
      GO TO( 100, 200, 300, 400, 500, 600, 700), NUMBER

  100 CONTINUE
C                        OPTION NUMBER 1 -- END

      LCLIMATE= NATTRS .GT. 0 .AND. NYEARS.GT. 0

      IF(LKECHO .AND. LCLIMATE) WRITE(JOSTND,105) KEYWRD
  105 FORMAT (/1X,A8,'   CLIMATE EXTENSION ACTIVE, END OF OPTIONS.')
      IF(LKECHO .AND. .NOT. LCLIMATE) WRITE(JOSTND,106) KEYWRD
  106 FORMAT (/1X,A8,'   CLIMATE EXTENSION MISSING REQUIRED DATA '
     >        'AND IS NOT ACTIVE. END OF OPTIONS.')
      RETURN

  200 CONTINUE
C                        OPTION NUMBER 2 -- CLIMDATA
      NATTRS=0
      NYEARS=0
      INDXSPECIES=0
      READ (IREAD,'(A)',END=80) CLIMATE_NAME
      IRECNT = IRECNT+1
      CLIMATE_NAME=ADJUSTL(CLIMATE_NAME)
      READ (IREAD,'(A)',END=80) CHTMP  !GET THE FILE NAME
      IRECNT = IRECNT+1
      CHTMP=ADJUSTL(CHTMP)
      IF(LKECHO)WRITE (JOSTND,210) KEYWRD,TRIM(CLIMATE_NAME),
     >       TRIM(NPLT),TRIM(CHTMP)
  210 FORMAT (/1X,A8,T13,'READING ATTRS SCORES FOR CLIMATE=',A,
     >        ' AT STAND=',A,' FROM FILE=',A)
      OPEN (NEWUNIT=IUTMP,FILE=TRIM(CHTMP),STATUS='OLD',ERR=298)
      I2=0
      READ (IUTMP,'(A)',END=296) CHTMP
      I2=I2+1
      READ (CHTMP,*,END=211) CSTDID,CCLIM,CYR,ATTR_LABELS  ! toss the first three
  211 CONTINUE
      IF (CSTDID .NE. "StandID") WRITE (JOSTND,212) TRIM(CSTDID)
  212 FORMAT (T13,'ATTRS FILE CREATION TAG=',A)
      DO I=1,MXCLATTRS
        IF (ICHAR(ATTR_LABELS(I)(1:1)).EQ. 0 .OR.
     >      ATTR_LABELS(I)(1:1).EQ.' ') EXIT
        NATTRS=NATTRS+1
      ENDDO
  215 CONTINUE
      READ (IUTMP,'(A)',END=290) CHTMP
      I2=I2+1
      READ (CHTMP,*) CSTDID,CCLIM
      IF (TRIM(CSTDID).NE.TRIM(NPLT)) GOTO 215
      IF (TRIM(CCLIM) .NE.TRIM(CLIMATE_NAME)) GOTO 215
      READ (CHTMP,*) CSTDID,CCLIM,IYRTMP,(TMPATTRS(I),I=1,NATTRS)
      IF (NYEARS.EQ.0) THEN
        NYEARS=1
        YEARS(1)=IYRTMP
        I1=1
      ELSE
        I1=0
        DO I=1,NYEARS
          IF (YEARS(I).NE.IYRTMP) CYCLE
          I1=I
          EXIT
        ENDDO
        IF (I1.EQ.0) THEN
          IF (NYEARS.EQ.MXCLYEARS) THEN
            WRITE (JOSTND,'(T13,"TOO MANY YEARS IN CLIMATE DATA.")')
            NATTRS=0
            NYEARS=0
            INDXSPECIES=0
            CLOSE (UNIT=IUTMP)
            CALL RCDSET (2,.TRUE.)
            GOTO 10
          ENDIF
          NYEARS=NYEARS+1
          I1=NYEARS
          YEARS(NYEARS)=IYRTMP
        ENDIF
      ENDIF
      ATTRS(I1,1:NATTRS)=TMPATTRS(1:NATTRS)
      GOTO 215
  290 CONTINUE
      IF(LKECHO)WRITE (JOSTND,291) I2,NATTRS,NYEARS
  291 FORMAT (T13,'RECORDS READ=',I4,'; NUMBER OF ATTRIBUTES=',
     >  I4,'; NUMBER OF YEARS=',I4)
      IF (NYEARS*NATTRS.EQ.0) THEN
        WRITE (JOSTND,'(T13,"NO CLIMATE DATA FOR THIS STAND.")')
        NATTRS=0
        NYEARS=0
        INDXSPECIES=0
        CLOSE (UNIT=IUTMP)
        CALL RCDSET (2,.TRUE.)
        GOTO 10
      ENDIF
      CLOSE (UNIT=IUTMP)
      DO I1=1,NATTRS
        IF ('dd5'  .EQ.TRIM(ATTR_LABELS(I1))) IXDD5  =I1
        IF ('mat'  .EQ.TRIM(ATTR_LABELS(I1))) IXMAT  =I1
        IF ('map'  .EQ.TRIM(ATTR_LABELS(I1))) IXMAP  =I1
        IF ('mtcm' .EQ.TRIM(ATTR_LABELS(I1))) IXMTCM =I1
        IF ('mtwm' .EQ.TRIM(ATTR_LABELS(I1))) IXMTWM =I1
        IF ('gsp'  .EQ.TRIM(ATTR_LABELS(I1))) IXGSP  =I1
        IF ('d100' .EQ.TRIM(ATTR_LABELS(I1))) IXD100 =I1
        IF ('mmin' .EQ.TRIM(ATTR_LABELS(I1))) IXMMIN =I1
        IF ('dd0'  .EQ.TRIM(ATTR_LABELS(I1))) IXDD0  =I1
        IF ('gsdd5'.EQ.TRIM(ATTR_LABELS(I1))) IXGSDD5=I1
        IF ('pSite'.EQ.TRIM(ATTR_LABELS(I1))) IXPSITE=I1
        IF ('DEmtwm'  .EQ.TRIM(ATTR_LABELS(I1))) IDEmtwm  =I1
        IF ('DEmtcm'  .EQ.TRIM(ATTR_LABELS(I1))) IDEmtcm  =I1
        IF ('DEdd5'   .EQ.TRIM(ATTR_LABELS(I1))) IDEdd5   =I1
        IF ('DEsdi'   .EQ.TRIM(ATTR_LABELS(I1))) IDEsdi   =I1
        IF ('DEdd0'   .EQ.TRIM(ATTR_LABELS(I1))) IDEdd0   =I1
        IF ('DEpdd5'  .EQ.TRIM(ATTR_LABELS(I1))) IDEmapdd5=I1
        IF (      IXMTCM.GT.0 .AND. IXMAT  .GT.0
     >      .AND. IXGSP .GT.0 .AND. IXD100 .GT.0
     >      .AND. IXMMIN.GT.0 .AND. IXDD0  .GT.0
     >      .AND. IXDD5 .GT.0 .AND. IXPSITE.GT.0
     >      .AND. IXGSDD5.GT.0
     >      .AND. IDEmtwm   .GT. 0
     >      .AND. IDEmtcm   .GT. 0
     >      .AND. IDEdd5    .GT. 0
     >      .AND. IDEsdi    .GT. 0
     >      .AND. IDEdd0    .GT. 0
     >      .AND. IDEmapdd5 .GT. 0) EXIT
      ENDDO

      DO I=1,MAXSP
        DO I1=1,NATTRS
          IF (TRIM(PLNJSP(I)).EQ.TRIM(ATTR_LABELS(I1))) THEN
            INDXSPECIES(I)=I1
            EXIT
          ENDIF
        ENDDO
      ENDDO

      IF(LKECHO) THEN
        I2=1
        DO I=1,NATTRS
          CHTMP(I2:)=''
          IF (IXMTCM.EQ.I .OR. IXDD5.EQ.I  .OR. IXMAT  .EQ.I .OR.
     >       IXPSITE.EQ.I .OR. IXGSP.EQ.I  .OR. IXD100 .EQ.I .OR.
     >       IXGSDD5.EQ.I .OR. IXMMIN.EQ.I  .OR. IXDD0  .EQ.I .OR.
     >       IXMTWM .EQ.I .OR. IXMAP .EQ.I  .OR.
     >       IDEmtwm.EQ.I .OR. IDEmtcm.EQ.I .OR. IDEdd5.EQ.I  .OR.
     >       IDEdd0 .EQ.I .OR. IDEmapdd5.EQ.I.OR.IDEsdi.EQ.I )
     >        CHTMP(I2:) = ' *USED*'
          DO I1=1,MAXSP
            IF (TRIM(PLNJSP(I1)).EQ.TRIM(ATTR_LABELS(I))) THEN
              WRITE (CHTMP(I2:),'(I3,"=",A)') I1,JSP(I1)
              EXIT
            ENDIF
          ENDDO
          I2=I2+8
        ENDDO
        I2=0
        DO I=1,NATTRS,14  ! write them 14 at a time
          I2=I2+14
          IF (I2.GT.NATTRS) I2=NATTRS
          WRITE (JOSTND,292) TRIM(CHTMP(((I-1)*8)+1:(I2*8)))
  292     FORMAT (/T13,'CODES: ',A)
          WRITE (JOSTND,293) ADJUSTR(ATTR_LABELS(I:I2))
  293     FORMAT ( T13,'YEAR ',14A8)
          FMT = ' T13,I4,1X'
          DO I1=I,I2
            FMT(1:1)=ATTR_LABELS(I1)(1:1)
            CALL UPCASE(FMT(1:1))
             IF (ATTR_LABELS(I1)(1:1).EQ.FMT(1:1)) THEN
               IF (ATTR_LABELS(I1)(1:2).EQ.'DE') THEN
                 FMT=TRIM(FMT)//',F8.2'
               ELSE
                 FMT=TRIM(FMT)//',F8.3'
               ENDIF
             ELSE
               FMT=TRIM(FMT)//',F8.1'
             ENDIF
          ENDDO
          FMT(1:1)='('
          FMT = TRIM(FMT)//')'
          DO I1=1,NYEARS
            WRITE (JOSTND,FMT) YEARS(I1),ATTRS(I1,I:I2)
          ENDDO
        ENDDO
        I2=0
        DO I=1,MAXSP
          IF (INDXSPECIES(I).EQ.0) I2=I2+1
        ENDDO
        IF (I2.GT.0) THEN
          WRITE (JOSTND,'(/T13,''SPECIES WITHOUT ATTRIBUTES:'')')
          DO I=1,MAXSP
            IF (INDXSPECIES(I).EQ.0) WRITE (JOSTND,294)
     >             I,JSP(I),PLNJSP(I)
  294       FORMAT (T13,'FVS INDEX=',I3,', ALPHA CODE=',A3,
     >              ', FIA CODE=',A)
          ENDDO
        ENDIF
      ENDIF
      IF (IXGSP  .EQ.0) WRITE (JOSTND,295) 'gsp'
  295 FORMAT (/,' ********',T13,'WARNING: ',A,' NOT FOUND.')
      IF (IXMAT  .EQ.0) WRITE (JOSTND,295) 'mat'
      IF (IXD100 .EQ.0) WRITE (JOSTND,295) 'd100'
      IF (IXGSP  .EQ.0) WRITE (JOSTND,295) 'gsp'
      IF (IXD100 .EQ.0) WRITE (JOSTND,295) 'd100'
      IF (IXMMIN .EQ.0) WRITE (JOSTND,295) 'mmin'
      IF (IXDD0  .EQ.0) WRITE (JOSTND,295) 'dd0'
      IF (IXPSITE.EQ.0) WRITE (JOSTND,295) 'pSite'
      GOTO 10
  296 CONTINUE
      WRITE (JOSTND,297)
  297 FORMAT (/,' ********',T13,
     >          'ERROR: FILE READ ERROR, DATA NOT STORED.')
      NATTRS=0
      NYEARS=0
      INDXSPECIES=0
      CLOSE (UNIT=IUTMP)
      CALL RCDSET (2,.TRUE.)
      GOTO 10
  298 CONTINUE
      WRITE (JOSTND,299)
  299 FORMAT (T13,'FILE OPEN ERROR, FILE NOT READ.')
      CALL RCDSET (2,.TRUE.)
      GOTO 10
  300 CONTINUE
C                        OPTION NUMBER 3 -- MORTMULT
      CALL SPDECD (1,I,NSP(1,1),JOSTND,IRECNT,KEYWRD,
     >             ARRAY,KARD)
      IF (I.GT.0 .AND. I.LE.MAXSP) THEN
        IF (LNOTBK(2)) CLMRTMLT1(I)=ARRAY(2)
        IF (LNOTBK(3)) CLMRTMLT2(I)=ARRAY(3)
        IF(LKECHO)WRITE(JOSTND,310) KEYWRD,I,JSP(I),CLMRTMLT1(I),
     >        CLMRTMLT2(I)
  310   FORMAT (/1X,A8,'   CLIMATE-CAUSED MORTALITY MULTIPLIERS',
     >       ' FOR SPECIES ',I3,'=',A,' ARE ',2F12.4)
      ELSE IF (I.EQ.0) THEN
        IF (LNOTBK(2)) CLMRTMLT1 = ARRAY(2)
        IF (LNOTBK(3)) CLMRTMLT2 = ARRAY(3)
        IF(LKECHO)WRITE(JOSTND,315) KEYWRD,CLMRTMLT1(1),
     >        CLMRTMLT2(I)
  315   FORMAT (/1X,A8,'   CLIMATE-CAUSED MORTALITY MULTIPLIERS',
     >       ' FOR ALL SPECIES ARE',2F12.4)
      ENDIF
      GOTO 10
  400 CONTINUE
C                        OPTION NUMBER 4 -- AUTOESTB
      IF (LNOTBK(1)) AESTOCK=ARRAY(1)
      IF (LNOTBK(2)) AESNTREES=ARRAY(2)/ACRtoHA
      IF (LNOTBK(3)) NESPECIES=IFIX(ARRAY(3))
      IF (NESPECIES.GT.MAXSP) NESPECIES=MAXSP
      LAESTB=.TRUE.
      IF(LKECHO)WRITE(JOSTND,410) KEYWRD,AESTOCK,AESNTREES*ACRtoHA,
     >  NESPECIES
  410 FORMAT (/1X,A8,'   TURN ON AUTOMATIC',
     >  ' ESTABLISHMENT IN THE CLIMATE MODEL. STOCKING THRESHOLD= ',
     >  F6.2,' PERCENT; BASE NUMBER OF TREES/ACRE TO ADD ',F6.2/T13,
     >  'MAXIMUM NUMBER OF SPECIES TO ADD =',I3)
      CALL ESNOAU (KEYWRD,LKECHO)
      GOTO 10
  500 CONTINUE
C                        OPTION NUMBER 5 -- GROWMULT
      CALL SPDECD (1,I,NSP(1,1),JOSTND,IRECNT,KEYWRD,
     >             ARRAY,KARD)
      IF (I.GT.0 .AND. I.LE.MAXSP) THEN
        IF (LNOTBK(2)) CLGROWMULT(I)=ARRAY(2)
        IF(LKECHO)WRITE(JOSTND,510) KEYWRD,I,JSP(I),CLGROWMULT(I)
  510   FORMAT (/1X,A8,'   CLIMATE-CAUSED GROWTH MULTIPLIER',
     >       ' FOR SPECIES ',I3,'=',A,' IS ',F12.4)
      ELSE IF (I.EQ.0) THEN
        IF (LNOTBK(2)) CLGROWMULT = ARRAY(2)
        IF(LKECHO)WRITE(JOSTND,515) KEYWRD,CLGROWMULT(1)
  515   FORMAT (/1X,A8,'   CLIMATE-CAUSED GROWTH MULTIPLIER',
     >       ' FOR ALL SPECIES IS',F12.4)
      ENDIF
      GOTO 10
  600 CONTINUE
C                        OPTION NUMBER 6 -- MXDENMLT
      CLMXDENMULT = ARRAY(1)
      IF (LKECHO) WRITE(JOSTND,610) KEYWRD,CLMXDENMULT
  610   FORMAT (/1X,A8,'   CLIMATE-CAUSED MAXIMUM DENSITY ADJUSTMENT',
     >          ' MULTIPLIER IS ',F10.4)
      GOTO 10
  700 CONTINUE
C                        OPTION NUMBER 7 -- CLIMREPT
      JCLREF = 0
      IF (LKECHO) WRITE(JOSTND,710) KEYWRD
  710   FORMAT (/1X,A8,'   GENERATE FVS-CLIMATE REPORT.')
      GOTO 10
      RETURN
      END
