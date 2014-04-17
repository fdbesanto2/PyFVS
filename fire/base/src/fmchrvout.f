      SUBROUTINE FMCHRVOUT (IYR)
      IMPLICIT NONE
C----------
C  $Id$
C----------
*     SINGLE-STAND VERSION
*     CALLED FROM: FMMAIN
*  PURPOSE:
*     PRINT THE HARVESTED PRODUCTS CARBON REPORT;
***********************************************************************
*
*  CALL LIST DEFINITIONS:
*     IYR:     CURRENT YEAR
*
***********************************************************************

C     PARAMETER INCLUDE FILES.

      INCLUDE 'PRGPRM.F77'
      INCLUDE 'FMPARM.F77'

C     COMMON INCLUDE FILES

      INCLUDE 'PLOT.F77'
      INCLUDE 'CONTRL.F77'
      INCLUDE 'ARRAYS.F77'
      INCLUDE 'FMCOM.F77'
      INCLUDE 'FMFCOM.F77'
      INCLUDE 'FMPROP.F77'
      INCLUDE 'METRIC.F77'

C     VARIABLE DECLARATIONS

      INTEGER   IYR

      LOGICAL   DEBUG
      INTEGER   I,JYR,JROUT,ITODO,IACTK,NPRM,DBSKODE
      REAL      PRMS(2),V(6),XTMP
      INTEGER   JCYC, KYR, IFATE, IHW, IPL

      INTEGER   MYACT(1)

      DATA      MYACT/2545/

C     CHECK FOR DEBUG.

      CALL DBCHK (DEBUG,'FMHRVOUT',8,ICYC)
      IF (DEBUG) WRITE(JOSTND,1) ICYC
    1 FORMAT(' ENTERING FMHRVOUT CYCLE = ',I2)
C
C     CHECK TO SEE WHETHER THE ALL FUELS REPORT HAS BEEN REQUESTED.
C     RETRIEVE THE UNIT NUMBER TO BE USED FOR THE REPORT, THEN
C     FETCH THE PARAMETERS
C
      CALL GETLUN (JROUT)
      CALL OPFIND(1,MYACT,ITODO)
      IF (ITODO.GT.0) THEN
        DO I = 1,ITODO
          CALL OPGET(I,2,JYR,IACTK,NPRM,PRMS)
          IF (JYR .NE. IYR) GO TO 35
          CALL OPDONE (I,JYR)
          ICHRVB = JYR
          ICHRVE = JYR + PRMS(1)
          ICHRVI = INT(PRMS(2))
          IF (ICHRVI.EQ.0) ICHRVI=1          
   35   ENDDO
      ENDIF
C
      IF (DEBUG) WRITE(JOSTND,40) ICHRVB,ICHRVE,IDCHRV,JROUT
   40 FORMAT(' FMDOUT: ICHRVB=',I5,' ICHRVE=',I5,
     >  ' IDCHRV=',I5,' JROUT=',I3)

C
C     THERE ARE 6 INDICATORS:
C
C     1 = PRODUCTS
C     2 = LANDFILL
C     3 = ENERGY
C     4 = EMISSIONS
C     5 = MERCH CARBON STORED
C     6 = MERCH CARBON REMOVED FROM STAND
C
C     1: CALCULATE THE INDICATORS, USING EITHER FFE OR JENKINS LOGIC
C        THERE MAY BE SOME EAST VS WEST VARIANT DIFFERENCES (THIS VERSION
C        IS IN /FIRE/NI/SRC, SO WILL DO FOR WEST; OTHER WOULD BE /FIRE/LS/SRC
C        WITH SAME FILENAME

C     2: LOAD ANY CONVERSION FACTORS (FOR IMPERIAL -> METRIC)
C        INTO THE CNV() ARRAY BEFORE THE CALL TO THE DATABASE WRITE.

C     FATE(1, HWSW(ISP(I)), ICYC)
C     DETERMINE THE AMOUNT IN EACH OF THE POOLS, USING THE PROVIDED VALUES

      DO I = 1,6
        V(I) = 0.0
      ENDDO
C
C     THERE ARE 3 FATES IN FAPROP(); A 4TH IS THE SUM OF 1:3
C
      DO JCYC = 1, ICYC
        KYR = IYR - IY(JCYC) + 1
        IF (KYR .GE. 101) KYR = 101
        DO IPL = 1,2 ! PULP/SAW
          DO IHW = 1,2 !SW/HW
          XTMP = 0.
            DO IFATE = 1,3 ! 3 FATES (INUSE,LANDFILL,ENERGY); 4=sum 1:3
              XTMP = XTMP + FAPROP(ICHABT,KYR,IFATE,IPL,IHW)
              V(IFATE) = V(IFATE) +
     &          FATE(IPL,IHW,JCYC) * FAPROP(ICHABT,KYR,IFATE,IPL,IHW)
            ENDDO
            V(4) = V(4) + (FATE(IPL,IHW,JCYC) * (1.0 - XTMP))
          ENDDO
        ENDDO
      ENDDO

      V(5) = V(1) + V(2)
      V(6) = V(3) + V(4) + V(5)
C
      DO I = 1,6
        V(I) = V(I) * 0.5
      ENDDO

      IF (ICMETRC.EQ.1) THEN
        DO I = 1,6
          V(I) = V(I) * TItoTM / ACRtoHA
        ENDDO
      ELSEIF (ICMETRC.EQ.2) THEN
        DO I = 1,6
          V(I) = V(I) * TItoTM 
        ENDDO     
      ENDIF

C     SET ARRAY FOR CARBSTAT EVENT MONITOR FUNCTION

      DO I = 1,6
          CARBVAL(11 + I) = V(I)
      ENDDO
      
C     RETURN IF THIS YEAR IS NOT WITHIN THE REPORTING PERIOD, OR
C     ON THE REPORTING INTERVAL

      IF (IYR .LT. ICHRVB .OR. IYR .GT. ICHRVE) RETURN
      IF (MOD((IYR-ICHRVB),ICHRVI).NE.0) RETURN

C     CALL THE DBS MODULE TO OUTPUT FUEL DATA TO A DATABASE
      DBSKODE = 1
      CALL DBSFMHRPT(IYR,NPLT,V,6,DBSKODE)
      IF(DBSKODE.EQ.0) RETURN

C     IF HEADER REQUESTED AND THIS IS THE FIRST OPPORTUNITY TO PRINT
C     IT, THEN DO SO.
C
      ICHPAS = ICHPAS + 1
      IF (ICHPAS .EQ. 1) THEN
        WRITE(JROUT,699) IDCHRV
        WRITE(JROUT,699) IDCHRV
        WRITE(JROUT,700) IDCHRV
        WRITE(JROUT,701) IDCHRV
        WRITE(JROUT,702) IDCHRV
        IF (ICMETRC.EQ.1) THEN
          WRITE(JROUT,707) IDCHRV
        ELSEIF (ICMETRC.EQ.2) THEN
          WRITE(JROUT,709) IDCHRV                
        ELSE
          WRITE(JROUT,708) IDCHRV
        ENDIF        
        WRITE(JROUT,699) IDCHRV
        WRITE(JROUT, 44) IDCHRV,NPLT,MGMID
        WRITE(JROUT,700) IDCHRV
        WRITE(JROUT,704) IDCHRV
        WRITE(JROUT,705) IDCHRV
        WRITE(JROUT,706) IDCHRV
        WRITE(JROUT,700) IDCHRV

  699   FORMAT(1(/1X,I5))
  700   FORMAT(1X,I5,1X,122('-'))
  701   FORMAT(1X,I5,1X,30X,'******  CARBON REPORT VERSION 1.0 ******')
  702   FORMAT(1X,I5,1X,38X,'HARVESTED PRODUCTS REPORT ' 
     >                      '(BASED ON STOCKABLE AREA)')
   44   FORMAT(1X,I5,' STAND ID: ',A26,4X,'MGMT ID: ',A4)
  704   FORMAT(1X,I5,1X,44(' '),'Merch Carbon')
  705   FORMAT(1X,I5,1X,43(' '),15('-'))
  706   FORMAT(1X,I5,1X,'YEAR  Prducts  Lndfill   Energy  Emissns  ',
     >    ' Stored  Removed') 
  707   FORMAT(1X,I5,1X,25(' '),
     > ('ALL VARIABLES ARE REPORTED IN METRIC TONS/HECTARE'))
  708   FORMAT(1X,I5,1X,30(' '),
     > ('ALL VARIABLES ARE REPORTED IN TONS/ACRE'))
  709   FORMAT(1X,I5,1X,27(' '),
     > ('ALL VARIABLES ARE REPORTED IN METRIC TONS/ACRE'))
      ENDIF

      WRITE(JROUT,800) IDCHRV,IYR,(V(I),I=1,6)
  800 FORMAT(1X,I5,1X,I4,6(2X,F7.1))
C
      RETURN
      END
