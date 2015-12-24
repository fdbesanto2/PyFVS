      SUBROUTINE BMSETP
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **BMSETP  DATE OF LAST REVISION:  12/20/05
C----------
c     Shamelessly adapted from MDSETP.
c
C     SET UP A MULTI-STAND MOUNTAIN PINE BEETLE RUN. THIS IS DONE
C     BY SETTING UP A LIST OF PPE STAND NUMBERS IN BMSDIX AND
C     SETTING THE BEGINNING AND ENDING YEARS OF THE OUTBREAK
C     THAT OCCURS INSIDE THE CURRENT MASTER CYCLE.
C
C     AN EXTENSION OF THE PARALLEL PROCESSING EXTENSION (PROGNOSIS)
C     N.L. CROOKSTON--FORESTRY SCIENCES LAB, MOSCOW, ID--MAY 1987
C
C     CALLED FROM:  ALSTD1
C     CALLS:  CH8BSR
C             CH8SRT
C             C26BSR:THIS REPLACES CH8BSR (ABOVE)[AJM 3/21/00]
C             C26SRT: THIS REPLACES CH8SRT (ABOVE)[AJM 3/21/00]
C             GPADD
C             GPGET
C             RCDSET
C             SPLAAR
C             SPLAEX
C             SPNBEX
COMMONS
      INCLUDE 'PPEPRM.F77'
      INCLUDE 'PPCNTL.F77'

      INCLUDE 'BMPRM.F77'
      INCLUDE 'BMCOM.F77'
      INCLUDE 'BMPCOM.F77'
C
      REAL    PRMS(7)
      INTEGER MYLIST(MXSTND)
      INTEGER BMSTD0,jstk2ns,bmstkd
      REAL    AREA
C
C     IF THIS IS THE FIRST MASTER CYCLE (=2), THEN CARRY OUT THE
C     INITIAL ASSIGNMENTS: BMINI() I.E., SET THE INTITAL NUMBER OF DEAD BKP-
C     PRODUCING TREES BY STAND AND SIZE CLASS.
C     NOTE: BMCNT IS THE NUMBER OF RECORDS READ-IN VIA KEYWORD BMHIST
C     IT CAN BE GREATER THAN THE NUMBER OF STANDS IN THE RUN--e.g.  A STAND
C     MAY BE INTIALIZED WITH BKP VIA MORE THAN 1 SUPPLEMENTAL RECORD.
C
C     ALSO NOTE THAT BMSTDS() ARRAY WAS INITIALIZED IN BMPPIN WITH THE
C     BMHIST SUPPLEMENTAL RECORD STAND IDS, WHICH MAY HAVE BEEN DUPLICATED.
C     i.e.  A STAND MAY BE INITIALIZED WITH BKP INTO TREES OF A FEW SIZE CLASSES
C     NECESSITATING MORE THAN ONE RECORD IN THE BMHIST SUPPLEMETAL RECORD LIST.
C     BMSTDS ARRAY IS "CORRECTED" BELOW SO THAT IT CONTAINS (WITHOUT DUPLICATION)
C     THE PPE STAND IDS
C
      IF (MICYC.EQ.2) THEN
C
        IF (LBMDEB) WRITE(JOPPRT,'('' IN BMSETP, BMCNT= '',I4)')BMCNT
C
        IF (BMCNT.GT.0) THEN
C         CALL CH8SRT (NOSTND,STDIDS,MYLIST,.TRUE.)
          CALL C26SRT (NOSTND,STDIDS,MYLIST,.TRUE.)
          DO 10 I=1,BMCNT
            J= IFIX(BMINI(I,PBSPEC,1))
            IF ((J .GT. 0) .AND. (J .LE. NSCL)) THEN
C              CALL CH8BSR (NOSTND,STDIDS,MYLIST,BMSTDS(I),IP)
            CALL C26BSR (NOSTND,STDIDS,MYLIST,BMSTDS(I),IP)
              IF(IP .GT. 0) THEN
                IF (PBSPEC .LT. 3) PBKILL(IP,J)= BMINI(I,PBSPEC,2)
C                 DEBUG
                 IF (LBMDEB) THEN
                   WRITE (JOPPRT,5)i,bmstds(i),ip,j,bmini(i,pbspec,1),
     >             bmini(i,pbspec,2),pbkill(ip,j)
   5               FORMAT(' IN BMSETP, CYCLE1 BMHIST DATA: ',
     >                1x,I6,1X,a26,i5,I3,F4.0,2(1X,F5.2))
                 ENDIF

                IF (PBSPEC .EQ. 3) ALLKLL(IP,J)= BMINI(I,PBSPEC,2)
              ENDIF
            ENDIF
            IF (IPSON .AND. (IP .GT. 0)) THEN
              J= IFIX(BMINI(I,3,1))
              IF ((J .GT. 0) .AND. (J .LE. NSCL))
     &             ALLKLL(IP,J)= BMINI(I,3,2)
            ENDIF
C
   10     CONTINUE
        ELSE
          BMCNT=0
        ENDIF

      ENDIF
C
C     Set up year boundaries for dispersal
C
c      BMSTND=0 !I don't think we need this.  we use ibmyr1 now as the flag to bail if
c               ! "disperse" is ended
      IBMYR1=0
      CALL GPGET (301,IBMYR1,7,NPRMS,PRMS,MXSTND,BMSTD0,BMSDIX)
C
C     IF THE NUMBER OF STANDS SCHEDULED FOR THIS MASTER CYCLE IS ZERO
C     THEN: BRANCH TO END...NO OUTBREAK THIS MASTER CYCLE.
C
C     I THINK WE WHOULD KEY ON IBMYR1 INSTEAD OF BMSTD0.  AJM 12/05
C     BMSTD0 STAYS POSITIVE EVEN AFTER OUTBREAK IS HALTED
C
C      IF (BMSTD0 .LE. 0) GOTO 150
      IF (IBMYR1 .LE. 0) GOTO 150
      IF (LBMDEB) WRITE (JBMBPR,30) MICYC,BMSTD0,IBMYR1,
     >                              (BMSDIX(I),I=1,BMSTD0)
   30 FORMAT (/' IN BMSETP: MICYC=',I5,' BMSTD0=',I5,' IBMYR1=',I5,
     >        ' BMSDIX IS...'/((1X,10I5)))
C
C     LOAD STAND AND MANAGEMENT IDENTIFICATIONS.
C
C     NEW LOGIC DEC 05:  AJM
C     SKIP A BUNCH OF THIS INITIALIZATION IF ITS ALREADY DONE!
C
      IF(LBMSETP)GO TO 65
      DO 40 I= 1, BMSTD0
        BMSTDS(I) = STDIDS(BMSDIX(I))
        BMMGID(I) = MGMIDS(BMSDIX(I))
   40 CONTINUE
C
C     APPEND NONSTOCKABLE STANDS TO BM STANDS.
C     MORE THAN MXSTND IN TOTAL WILL RESUL  IN LOST DATA.
C
C  ** THIS LOGIC IS MOVED TO BELOW (SEE DO 44), AFTER WE CHECK TO SEE IF
C     THE NON-STOCKED ID HAS ALREADY BEEN ENTERED! **

C      DO 41 I = 1, NSSTND
C        J= BMSTD0 + I
C        IF (J .GT. MXSTND) GOTO 42
C        BMSDIX(J) = J
C        BMSTDS(J) = NSSTDS(I)
C        BMMGID(J) = 'NONE'
C   41 CONTINUE
C   42 CONTINUE
c
c     troubleshoot ajm 12.05
      if(lbmdeb) write (jbmbpr,47)bmstd0,nsstnd
   47 format (/' in bmsetp: bmstd0=',i5,'nsstnd=',i4)
c******************************************************
C
C     EXTRACT THE STAND NEIGHBORS AND LOCATION DATA FOR THIS RUN.
C     FIRST, SORT THE INDEX LIST ON THE STAND IDENTS LIST. NOTE
C     THAT 'BMSTND' IS REDEFINED *HERE* TO INCLUDE NONSTOCKABLE
C     STANDS. CAVEAT EMPTOR.
C
c      BMSTND = MIN(MXSTND, (BMSTD0 + NSSTND))
c      BMEND = BMSTND - NSSTND
C*************************************************************************************
C      MODIFICATIONS AJM DEC 2005
C      BMSTND IS CURRENT # OF STANDS IN THE RUN.  THIS MAY BE INCREASED LATER (BELOW)
C      DUE TO POSSIBLE INCLUSION OF NON-STOCKED POLYGONS.
C      BMSTKD IS A NEW VARIABLE KEEPING TRACK OF THE NUMBER OF STOCKED STANDS
C      WHICH FOR NOW IS SET = TO BMSTD0, BUT IT MAY BE DECREMENTED IF USER
C      DEFINES A HERETOFORE STOCKED STAND AS NONSTOCKED.
C      AT THIS POINT BMSTKD IS BEING USED FOR INFORMATIONAL PURPOSES ONLY
C
       BMSTND=BMSTD0
       BMSTKD=BMSTND
C       bmend=bmstnd-nsstnd  ! DONE BELOW.
c      (this could be done here, but it would be incorrectly calculated if the NSSTNDs
c      were truly supplemental e.g. 100 stocked stands plus 100 additional nsstnds
c      would yield ZERO BMEND stands.  wrong!)

C     CALL CH8SRT (BMSTND, BMSTDS, MYLIST, .TRUE.)
      CALL C26SRT (BMSTND, BMSTDS, MYLIST, .TRUE.)
C
C     SET ALL STANDS TO STOCKABLE, THEN MARK NONSTOCKABLE STANDS
C     ALSO INITIALIZE DB-WRITING VARIABLES (ONCE PER SIMULATION ONLY)
C
      DO 43 I = 1, BMSTND
        STOCK(I) = .TRUE.
C
C     INITIALIZE OUTPUT WRITING ACTIVITY PARAMETERS TIME ZERO ONLY
C     THESE ARE RESET IN BMSDIT IF USER REQUESTS OUTPUT.  AJM 9/1/5
C
         IF (.NOT. LDBINIT) THEN
            DO 45 IOUT=1,4
               IBEG(IOUT,I)=-1
               IEND(IOUT,I)=-1
               ISTP(IOUT,I)=-1
   45       CONTINUE
C
C     INITIIALIZE WWPBM-DB TABLE FLAGS. THESE ARE LATER SET (TO 1 OR 2)
C     VIA DB KEYWORDS (in DBSIN)IF DB TABLE IS REQUESTED
C     J=TABLE # (1=MAIN,2=TREE; 3=BKP; 4=VOL); I=STAND INDEX
C     FETCHED INTO WWPBM IN BMSDIT
            DO 46 J=1,4
               JBMDB(J,I)=-1
   46       CONTINUE
C
C     INITIALIZE WWPBM-RECOGNIZED DBS CASEIDs TO -1, FETCHED LATER
C     IN BMSDIT IF DB OUTPUT REQUESTED
C
            BMCASEID(I)=-1      ! THE STAND'S CASE ID (FOR DBS)
C
         ENDIF
C
   43 CONTINUE
C
C     NOW THAT WE'VE LOOPED THROUGH ALL STANDS AND INITIALIZED DB FLAGS
C     MARK DBINIT FLAG TO TRUE.
C
      LDBINIT = .TRUE.
C
C     THIS IS TOO COMPLICATED, SINCE NONSTOCKABLES ARE KNOWN
C     TO BE AT THE END, A PRIORI. BUT IT WORKS.
C
C     LOOK FOR NONSTOCK STAND ID IN CURRENT LIST OF STANDS.
C     IF FOUND, MARK AS NONSTOCKED, ELSE
C     INCREMENT THE NUMBER OF BMSTNDs
      jstk2ns=0
      DO 44 I = 1, NSSTND
C        CALL CH8BSR (BMSTND, BMSTDS, MYLIST, NSSTDS(I), IP)
        CALL C26BSR (BMSTND, BMSTDS, MYLIST, NSSTDS(I), IP)
        IF (IP .GT. 0) THEN
           STOCK(IP) = .FALSE.
           BMMGID(IP)= 'NSTK'
           jstk2ns=jstk2ns+1
        ELSEIF (IP .EQ.0) THEN
           BMSTND=BMSTND+1
           J= BMSTND
           IF (J .GT. MXSTND) GOTO 48 ! ISSUE WARNING?!
           BMSDIX(J) = J
           BMSTDS(J) = NSSTDS(I)
           BMMGID(J) = 'NSTK'
           STOCK(J)  = .FALSE.
        ENDIF
   44 CONTINUE
c     adjust downward the count of stocked stands
c     for stands that were previously stocked stands but that were
c     just now marked non-stocked because they were listed as such
c     (i.e. as a supplemental record under keyword NONSTOCK)
      bmstkd=bmstkd-jstk2ns
c  bmend is another counter derived differently.  it should agree
      bmend=bmstnd-nsstnd
   48 CONTINUE
C
C     RE-SORT TO UPDATE MYLIST
C
      CALL C26SRT (BMSTND, BMSTDS, MYLIST, .TRUE.)
C
C     EXTRACT THE LOCATIONS AND AREA DATA.
C
      CALL SPLAEX (BMSTDS, BMSTND, MYLIST, IRC)
C
C     IF THE RETURN CODE IS NOT ZERO, THEN THESE DATA ARE MISSING OR
C     INCOMPLETE. THE REQUESTED OUTBREAK CAN NOT HAPPEN. SET A FLAG
C     NOW...ISSUE ERROR MSG, ETC., BELOW.
C
      LBMSPR=IRC.EQ.0
      IF (LBMDEB) WRITE(JBMBPR,'(/'' IN BMSETP: LBMSPR='',L2)') LBMSPR
C      WRITE (*,*) BMSTD0, BMSTND, IRC
      IF (LBMSPR) THEN
C
C        COMPUTE TOTAL ACRES (Stockable stands)
C     !! NO! THIS IS FETCHING TOTAL ACREAGE FOR ALL STANDS STOCKED AND OTHERWISE!
C        BECAUSE BMSTND NOW INCLUDES NONSTOCKS AS WELL!

        TACRES=0.0
        STKACR=0.0
        DO 50 I=1,BMSTND
          CALL SPLAAR (I,AREA,IRC)
          LBMSPR= IRC .EQ. 0
C          IF (.NOT.LBMSPR) GOTO 60
          IF (.NOT.LBMSPR) GOTO 100
          TACRES= TACRES+AREA
          IF(STOCK(I))STKACR=STKACR+AREA
   50   CONTINUE
C   60 CONTINUE
      ELSE
        GOTO 100
      ENDIF
C
C     I'M LEAVING THE FOLLOWING IN, EVEN THOUGH IT SEEMS LIKE WE NEVER NEED NEIGHBORS DATA
C     AJM DEC 05
C
C     IF THE LOCATIONS AND AREA DATA ARE PRESENT, THEN: PREPARE THE
C     NEIGHBORS DATA. SET LNEAR FALSE IF THERE ARE MISSING DATA.
C
C      IF (LBMSPR) THEN
        CALL SPNBEX (BMSTDS,K,MYLIST,IRC)
        LNEAR= IRC .EQ. 0
        IF (LBMDEB) WRITE(JBMBPR,'(/'' IN BMSETP: LNEAR='',L2)') LNEAR
C
C     BMSTAND IDS, NONSTOCK STATUS, AND AREA INFO DONE.  WE DON'T NEED TO REPEAT
C     ANY OF THE ABOVE ANY TIME IN THE FUTURE.  SET "DONE" FLAG TO TRUE, AND
C     ENTER THIS ROUTINE AT STATEMENT LABEL 65 IN SUBSEQUENT CYCLES
C
      LBMSETP=.TRUE.
C
   65 CONTINUE
C
C     THIS IS THE STUFF THAT NEEDS TO BE CHECKED EACH CYCLE!
C
C     Set up year boundaries for dispersal.

        NPRMS= 1
        IBMYR2=IBMYR1+IFIX(PRMS(1))-1
        IBMMRT= IBMYR2-IBMYR1+1

        IF (LBMDEB) WRITE (JBMBPR,70) IBMYR1,IBMYR2
   70   FORMAT (/' IN BMSETP: IBMYR1=',I5,' IBMYR2=',I5)

c If the duration goes over the boundary of a master cycle, then reschedule
c the outbreak for the next cycle and adjust the ending year to occur in the
c n-1 year within the current master cycle.

        IF (IBMYR2.GT.MIY(MICYC)) THEN
          PRMS(1) = IBMYR2 - MIY(MICYC) + 1
          CALL GPADD (KODE,MIY(MICYC),301,NPRMS,PRMS(1),BMSTD0,BMSDIX)
          IBMYR2 = MIY(MICYC) - 1
          IBMMRT= IBMYR2-IBMYR1+1
          IF (LBMDEB) WRITE (JBMBPR,80) PRMS(1),IBMYR2
   80     FORMAT (/' IN BMSETP:  AN OUTBREAK IS SCHEDULED FOR THE ',
     >            'NEXT MASTER CYCLE. DURATION WILL BE =',F5.0,
     >            '  NEW IBMYR2=',I5)
        ENDIF
        GO TO 150
C      ELSE
  100  CONTINUE
C
C        TURN OFF THE OUTBREAK, AND WRITE AN ERROR MSG.
C
        IBMYR1= 0
        BMSTND= 0
        WRITE (JBMBPR,140) MIY(MICYC-1)
  140   FORMAT (/' ******** ERROR:  MPB/WPB/I DISPERSAL',
     >          ' MODEL RUN SCHEDULED FOR ',I4,' WAS CANCELLED '/T19,
     >          'DUE TO A LACK OF REQUIRED SPATIAL DATA.')
        CALL RCDSET (2,.TRUE.)
C
C       ENDIF
C
  150 CONTINUE
      IF (LBMDEB) WRITE (JBMBPR,160) BMSTD0,MIY(MICYC-1),LBMSPR,LBMSETP,
     >            IBMYR1,IBMYR2,bmstnd,nsstnd,bmstkd,bmend,jstk2ns,
     >            TACRES,STKACR
  160 FORMAT (/' IN BMSETP: BMSTD0=',I5,'; MIY(MICYC-1)=',I5,
     >  '; LBMSPR=',L2,'; LBMSETP=',l2,'; IBMYR1=',I5,'; IBMYR2=',I5,/
     >  '  bmstnd= ',i5,'; nsstnd=',i5,'; bmstkd=',i5,'; bmend=',i5,
     >  '; jstk2ns= ',i5,'; TACRES=',F7.2,'; STKACRE=',F7.2)
C
      RETURN
      END
