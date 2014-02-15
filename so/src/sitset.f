      SUBROUTINE SITSET
      IMPLICIT NONE
C----------
C  **SITSET--SO   DATE OF LAST REVISION:  05/11/11
C----------
C THIS SUBROUTINE LOADS THE SITEAR ARRAY WITH A SITE INDEX FOR EACH
C SPECIES WHICH WAS NOT ASSIGNED A SITE INDEX BY KEYWORD, AND
C LOADS THE SDIDEF ARRAY WITH AN SDI MAX FOR EACH SPECIES WHICH WAS
C NOT ASSIGNED AN SDI VALUE BY KEYWORD.
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
COMMONS
C----------
C  SPECIES ORDER:
C  1=WP,  2=SP,  3=DF,  4=WF,  5=MH,  6=IC,  7=LP,  8=ES,  9=SH,  10=PP,
C 11=JU, 12=GF, 13=AF, 14=SF, 15=NF, 16=WB, 17=WL, 18=RC, 19=WH,  20=PY,
C 21=WA, 22=RA, 23=BM, 24=AS, 25=CW, 26=CH, 27=WO, 28=WI, 29=GC,  30=MC,
C 31=MB, 32=OS, 33=OH
C----------
      LOGICAL DEBUG
      CHARACTER FORST*2,FORDUM*2,DIST*2,PROD*2,VAR*2,VOLEQ*10
      CHARACTER*4 ASPEC
      INTEGER IFIASP, ERRFLAG
      INTEGER NTOHI,NSISET,NSDSET,I,JSISP,INDEX,KNTECO,ISEQ,NUM,ISFLAG
      INTEGER ITOHI,ISPC,K,J,JJ,INTFOR,IREGN,IRDUM
      REAL SIAGE(MAXSP),SI(MAXSP),SILO(MAXSP),SIHI(MAXSP)
      REAL C6(MAXSP),C5(MAXSP)
      REAL FORMAX,RSI,RSDI,TEM,SINDX,AG
C
      DATA C5 /
     & 624., 647., 547., 759., 624., 706., 406., 671., 800., 571.,
     & 353., 759., 800., 353., 353., 460., 353., 353., 580., 570.,
     & 353., 550., 550., 550., 550., 353., 400., 550., 353., 353.,
     & 353., 547., 550./
C
      DATA C6/
     & 447., 447., 767., 659., 758., 447., 541., 659., 750., 429.,
     & 500., 659., 659., 659., 659., 250., 250., 650., 650., 650.,
     & 200., 300., 300., 250., 250., 200., 200., 150., 250., 100.,
     & 100., 447., 250./
C
      DATA FORMAX/850./
C----------
C  IF SILO AND/OR SIHI, ALSO CHANGE THEM IN **REGENT**
C----------
      DATA SILO/
     &  13.,  27.,  21.,   5.,   5.,   5.,   5.,  12.,  10.,   7.,
     &   5.,   9.,   6.,   4.,   7.,  20.,  60.,  29.,   6.,   5.,
     &   5.,  56., 108.,  30.,  10.,  10.,  21.,  20.,   5.,   5.,
     &   5.,   5.,   5./
C
      DATA SIHI/
     & 137., 178., 148., 195., 133., 169., 140., 227., 134., 176.,
     &  40., 173., 127., 221., 210.,  65., 147., 152., 203.,  75.,
     & 100., 192., 142.,  66., 191., 104.,  85.,  93., 100.,  75.,
     &  75., 175., 125./
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'SITSET',6,ICYC)
C----------
C  DETERMINE HOW MANY SITE VALUES AND SDI VALUES WERE SET VIA KEYWORD.
C----------
      NTOHI=0
      NSISET=0
      NSDSET=0
      DO 5 I=1,MAXSP
      IF(SITEAR(I) .GT. 0.) NSISET=NSISET+1
      IF(SDIDEF(I) .GT. 0.) NSDSET=NSDSET+1
    5 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)'ENTERING SITSET, SITE VALUES SET = ',
     &NSISET,'  SDI VALUES SET = ',NSDSET
C----------
C  SET SITE SPECIES AND SITE INDEX IF NOT SET BY KEYWORD.
C  FOR REGION 6 FORESTS SET SDI DEFAULTS HERE ALSO.
C----------
      IF(IFOR .LE. 3) THEN
C----------
C       REGION 6 FOREST --- CALL **ECOCLS** WITH THE ECOCLASS CODE,
C       AND GET BACK THE DEFAULT SITE SPECIES, ALL SITE INDICIES,
C       AND DEFAULT SDI MAXIMUMS ASSOCIATED WITH THE ECOCLASS
C----------
        JSISP=0
        INDEX=0
        KNTECO=0
   10   CALL ECOCLS (PCOM,ASPEC,RSDI,RSI,ISFLAG,NUM,INDEX,ISEQ)
        KNTECO=KNTECO+1
        IF(DEBUG)WRITE(JOSTND,*)'AFTER ECOCLS,PCOM,ASPEC,RSDI,RSI,',
     &  'ISFLAG,NUM,INDEX,ISEQ = ',PCOM,ASPEC,RSDI,RSI,ISFLAG,
     &  NUM,INDEX,ISEQ
C----------
C IF DEFAULT SDI IS OUT OF BOUNDS, RESET IT.
C----------
        ITOHI=0
        IF(RSDI .GT. FORMAX)THEN
          RSDI=FORMAX
          ITOHI=1
        ENDIF
C----------
C       LOOP THROUGH JSP ARRAY AND DETERMINE FVS SEQUENCE NUMBER FOR
C       THIS SPECIES
C----------
        IF(ISEQ .EQ. 0) GO TO 25
        IF(JSISP.EQ.0 .AND. ISFLAG.EQ.1) JSISP=ISEQ
        IF(ISISP.LE.0 .AND. ISFLAG.EQ.1) ISISP=ISEQ
        IF(SITEAR(ISEQ).LE.0. .AND. NSISET.EQ.0) SITEAR(ISEQ)=RSI
        IF(SDIDEF(ISEQ) .LE. 0.) THEN
          SDIDEF(ISEQ)=RSDI
          IF(ITOHI .GT. 0) NTOHI=NTOHI+1
        ENDIF
        IF(ISISP.GT.0 .AND. ISFLAG.EQ.1) THEN
          IF(SDIDEF(ISISP) .LE. 0.) THEN
            SDIDEF(ISISP)=RSDI
            IF(ITOHI .GT. 0) NTOHI=NTOHI+1
          ENDIF
        ENDIF
   25   CONTINUE
        IF(NUM.GT.1 .AND. KNTECO.LT.NUM) THEN
          INDEX=INDEX+1
          GO TO 10
        ENDIF
      ELSE
        IF(ISISP .LE. 0) ISISP = 4
        IF(SITEAR(ISISP) .LE. 0.0) SITEAR(ISISP) = 50.
        JSISP= ISISP
      ENDIF
C---------
C  ON THE CHANCE THAT A SITE SPECIES WAS NOT ENCOUNTERED IN **ECOCLS**
C  PROVIDE A REGION 6 GLOBAL DEFAULT.
C----------
      IF(IFOR .LE. 3) THEN
        IF(ISISP .LE. 0) ISISP = 10
        IF(SITEAR(ISISP) .LE. 0.0) SITEAR(ISISP) = 70.
      ENDIF
C----------
C  TRANSLATE THE SITES AND KEEP
C
C  SITE SPECIES 11(UT), 16(TT) AND 24(UT) USE THE FOLLOWING SITE
C  METHOD
C----------
C
C  SET SITE FOR UT VARIANT SPECIES 11 16, AND 24
C
      IF(ISISP.EQ.11 .OR. ISISP.EQ.16 .OR. ISISP.EQ.24)THEN
        TEM = 30.
        IF(ISISP .GT. 0 .AND. SITEAR(ISISP) .GT. 0.0)TEM=SITEAR(ISISP)
        IF(TEM.LT.SILO(ISISP))TEM=SILO(ISISP)
        DO 20 I=1,MAXSP
        SI(I)=SILO(I)+(TEM-SILO(ISISP))/(SIHI(ISISP)-SILO(ISISP))
     &  *(SIHI(I)-SILO(I))
        IF(I .EQ. 5 )THEN
          SI(I)=SI(I)/3.281
          IF(SI(I).GT.28.)SI(I)=28.
        ENDIF
   20   CONTINUE
        GO TO 32
      ELSE
        CALL SICHG(ISISP,SITEAR(ISISP),SIAGE)
      ENDIF
C
C SI IS A VECTOR X MAXSP GIVING EQUIVALENT SITES FOR EACH SPECIES
C
      IF (DEBUG) WRITE(JOSTND,9003)ISISP,SITEAR(ISISP),SIAGE
 9003 FORMAT('MAIN REF SPECIES ',I5,' SITE INDEX ',F10.1/
     &((4X,11F6.1)/))
C
      IF(DEBUG)WRITE(JOSTND,*)'IN SITSET STARTING DO 30 LOOP'
      DO 30 ISPC=1,MAXSP
      AG=SIAGE(ISPC)
      SINDX=SITEAR(ISISP)
      CALL HTCALC(IFOR,SINDX,ISISP,AG,SI(ISPC),JOSTND,DEBUG)
C----------
C  CHANGE THE SITE INDEX OF HEMLOCK TO METRIC.
C----------
      IF(ISPC .EQ. 5 )THEN
        SI(ISPC)=SI(ISPC)/3.281
        IF(SI(ISPC).GT.28.)SI(ISPC)=28.
      ENDIF
      IF(ISPC.EQ.11 .OR. ISPC.EQ.16 .OR. ISPC.EQ.24)THEN
        TEM=SITEAR(ISISP)
        IF(TEM.LT.SILO(ISISP))TEM=SILO(ISISP)
        IF(SITEAR(ISPC).LE.0.0)
     &  SI(ISPC)=SILO(ISPC)+(TEM-SILO(ISISP))/(SIHI(ISISP)-SILO(ISISP))
     &  *(SIHI(ISPC)-SILO(ISPC))
      ENDIF
C
C DELETED A REFERENCE TO SPECIES 6 AS WELL AS 5 SO HTCALC IS CONSISTENT
C WITH THE NEED TO DEMETRIC THE HEMLOCK SITE.  RALPH 1/24/89
C
   30 CONTINUE
      IF (DEBUG) WRITE(JOSTND,9025) SINDX,ISISP,SI
 9025 FORMAT('IN SIADJ  SINDX ', F10.2,' SPECIES ',I5,
     &       ' TRANSLATED SITES'/,((11F6.1)/))
C
C IF SITELG() HAS NOT BEEN SET WITH SITECOD KEYWORD, LOAD
C IT WITH SITE VALUES TRANSLATED FROM SITE INDEX OF SITE SPECIES.
C
   32 CONTINUE
      DO 35 I=1,MAXSP
      IF(SITEAR(I) .EQ. 0.0) SITEAR(I)=SI(I)
   35 CONTINUE
C----------
C LOAD THE SDIDEF ARRAY
C----------
      K=ISISP
      IF(SDIDEF(K) .LE. 0.) K=JSISP
      DO 40 I=1,MAXSP
        IF(SDIDEF(I) .GT. 0.0) GO TO 40
        IF(BAMAX .GT. 0.) THEN
          SDIDEF(I)=BAMAX/(0.5454154*(PMSDIU/100.))
        ELSEIF(IFOR .LE. 3) THEN
          SDIDEF(I) = SDIDEF(K) * (C6(I)/C6(K))
          IF(SDIDEF(I) .GT. FORMAX)THEN
            SDIDEF(I)=FORMAX
            NTOHI=NTOHI+1
          ENDIF
        ELSE
          SDIDEF(I) = C5(I)
        ENDIF
   40 CONTINUE
C
C----------
C  WRITE SIDMAX, BY SPECIES, TO OUTPUT
C----------
      DO 92 I=1,15
      J=(I-1)*10 + 1
      JJ=J+9
      IF(JJ.GT.MAXSP)JJ=MAXSP
      WRITE(JOSTND,90)(NSP(K,1)(1:2),K=J,JJ)
   90 FORMAT(/'SPECIES ',5X,10(A2,6X))
      WRITE(JOSTND,91)(SDIDEF(K),K=J,JJ )
   91 FORMAT('SDI MAX ',   10F8.0)
      IF(JJ .EQ. MAXSP)GO TO 93
   92 CONTINUE
   93 CONTINUE
C
      IF(NTOHI .GT. 0)WRITE(JOSTND,102)FORMAX
  102 FORMAT(/'*NOTE -- AT LEAST ONE DEFAULT MAXIMUM SDI EXCEEDED THE FO
     &REST DEFAULT MAXIMUM. FOREST DEFAULT MAXIMUM OF ',F5.0,' USED.',/
     &,'          YOU MAY NEED TO SPECIFICALLY RESET VALUES FOR THESE SP
     &ECIES USING THE SDIMAX KEYWORD.')
C----------
C  LOAD VOLUME DEFAULT MERCH. SPECS.
C----------
      SELECT CASE(IFOR)
      CASE(1:3)
        DO I=1,MAXSP
        IF(TOPD(I) .LE. 0.) TOPD(I) = 4.5
        IF(BFTOPD(I) .LE. 0.) BFTOPD(I) = 4.5
        END DO
      CASE DEFAULT
        DO I=1,MAXSP
        IF(TOPD(I) .LE. 0.) TOPD(I) = 6.
        IF(BFTOPD(I) .LE. 0.) BFTOPD(I) = 6.
        END DO
      END SELECT
C----------
C  SET METHB & METHC DEFAULTS.  DEFAULTS ARE INITIALIZED TO 999 IN
C  **GRINIT**.  IF THEY HAVE A DIFFERENT VALUE NOW, THEY WERE CHANGED
C  BY KEYWORD IN INITRE. ONLY CHANGE THOSE NOT SET BY KEYWORD.
C
C  DESCHUTES, FREMONT, AND WINEMA (IFOR=1,2,3) ARE R6 FORESTS.
C  KLAMATH, LASSEN, MODOC, AND PLUMAS (IFOR=4,5,6,7) ARE R5 FORESTS.
C  INDUSTRY (IFOR=7) USE R5 DEFAULTS.
C----------
      DO 50 ISPC=1,MAXSP
      IF(IFOR.LT.4)THEN
        IF(METHB(ISPC).EQ.999)METHB(ISPC)=6
        IF(METHC(ISPC).EQ.999)METHC(ISPC)=6
      ELSE
        IF(METHB(ISPC).EQ.999)METHB(ISPC)=6
        IF(METHC(ISPC).EQ.999)METHC(ISPC)=6
      ENDIF
   50 CONTINUE
C----------
C  LOAD VOLUME EQUATION ARRAYS FOR ALL SPECIES
C----------
      INTFOR = KODFOR - (KODFOR/100)*100
      WRITE(FORST,'(I2)')INTFOR
      IF(INTFOR.LT.10)FORST(1:1)='0'
      IREGN = KODFOR/100
      DIST='  '
      PROD='  '
      VAR='SO'
C
C  USE R5 EQUS FOR INDUSTRY LANDS
C  (FC=701 USES 505), ALSO IN INITRE VOLEQNUM PROCESS
C
      IF(IREGN.EQ.7)THEN
        IRDUM=5
        FORDUM='05'
      ELSE
        IRDUM=IREGN
        FORDUM=FORST
      ENDIF
C
      DO ISPC=1,MAXSP
      READ(FIAJSP(ISPC),'(I4)')IFIASP
      IF(((METHC(ISPC).EQ.6).OR.(METHC(ISPC).EQ.9)).AND.
     &     (VEQNNC(ISPC).EQ.'          '))THEN
        CALL VOLEQDEF(VAR,IRDUM,FORDUM,DIST,IFIASP,PROD,VOLEQ,ERRFLAG)
        VEQNNC(ISPC)=VOLEQ
      ENDIF
      IF(((METHB(ISPC).EQ.6).OR.(METHB(ISPC).EQ.9)).AND.
     &     (VEQNNB(ISPC).EQ.'          '))THEN
        CALL VOLEQDEF(VAR,IRDUM,FORDUM,DIST,IFIASP,PROD,VOLEQ,ERRFLAG)
        VEQNNB(ISPC)=VOLEQ
      ENDIF
      ENDDO
C----------
C  IF FIA CODES WERE IN INPUT DATA, WRITE TRANSLATION TABLE
C---------
      IF(LFIA) THEN
        CALL FIAHEAD(JOSTND)
        WRITE(JOSTND,211) (NSP(I,1)(1:2),FIAJSP(I),I=1,MAXSP)
 211    FORMAT ((T12,8(A3,'=',A6,:,'; '),A,'=',A6))
      ENDIF
C----------
C  WRITE VOLUME EQUATION NUMBER TABLE
C----------
      CALL VOLEQHEAD(JOSTND)
      WRITE(JOSTND,230)(NSP(J,1)(1:2),VEQNNC(J),VEQNNB(J),J=1,MAXSP)
 230  FORMAT(4(2X,A2,4X,A10,1X,A10,1X))
C
      RETURN
      END
