      SUBROUTINE SITSET
      use prgprm_mod
      implicit none
C----------
C  **SITSET--AK/M    DATE OF LAST REVISION:  02/25/09
C----------
C  THIS SUBROUTINE LOADS THE SITEAR ARRAY WITH A SITE INDEX FOR EACH
C  SPECIES WHICH WAS NOT ASSIGNED A SITE INDEX BY KEYWORD, AND LOADS
C  THE SDIDEF ARRAY WITH SDI MAXIMUMS FOR EACH SPECIES WHICH WAS NOT
C  ASSIGNED AN SDI MAXIMUM USING THE SDIMAX KEYWORD.
C----------
COMMONS
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'PLOT.F77'
C
      INCLUDE 'VOLSTD.F77'
C
      INCLUDE 'METRIC.F77'
C
C----------
      CHARACTER FORST*2,DIST*2,PROD*2,VAR*2,VOLEQ*10
      INTEGER IFIASP,ERRFLAG,I,INTFOR,IREGN,ISPC,J,JJ,K
      REAL SDICON(13),TEM
C
      DATA SDICON /750.,750.,750.,750.,750.,750.,
     &             750.,750.,750.,750.,750.,750.,750./
C----------
C IF SITEAR(I) HAS NOT BEEN SET WITH SITECODE KEYWORD, LOAD IT
C WITH DEFAULT SITE VALUES. CONVERT BETWEEN SS & WH; LP & AF
C GET .8 * SS; ALL OTHERS (EXCEPT RA & CW) GET WH.
C RED ALDER & COTTONWOOD GET TRANLATED FROM WH
C RED ALDER USES TOTAL AGE 20 HARRINGTON & CURTIS 1986
C COTTONWOOD USES BREAST AGE 100 CURTIS ET.AL. 1974
C----------
      TEM = 80.
      IF(ISISP .GT. 0 .AND. SITEAR(ISISP) .GT. 0.0) THEN
        TEM = SITEAR(ISISP)
        IF(ISISP .EQ. 8) TEM = 24.41 + 0.674 * SITEAR(8)
        IF(ISISP .EQ. 7 .OR. ISISP .EQ. 9) THEN
          IF(SITEAR(8).EQ.0.0) SITEAR(8)=SITEAR(ISISP)/0.8
          TEM = 24.41 + 0.674 * SITEAR(8)
        ENDIF
        IF(ISISP .EQ. 10) TEM=(SITEAR(10)+5.8812)/0.5294
        IF(ISISP .EQ. 11) TEM=(SITEAR(11)-18.3112)/1.2692
      ENDIF
      IF(SITEAR(8).EQ.0.)SITEAR(8)=-6.62+1.152*TEM
      DO 10 I=1,MAXSP
      IF(I.EQ.10 .OR. I.EQ.11) GO TO 10
      IF(I.EQ.7 .AND. SITEAR(7).EQ.0.0)SITEAR(7)=0.8*SITEAR(8)
      IF(I.EQ.9 .AND. SITEAR(9).EQ.0.0)SITEAR(9)=0.8*SITEAR(8)
      IF(SITEAR(I) .EQ. 0.0) SITEAR(I) = TEM
   10 CONTINUE
      IF(ISISP .EQ. 0) ISISP=5
      IF(SITEAR(10) .EQ. 0.) SITEAR(10)=-5.8812+0.5294*SITEAR(5)
      IF(SITEAR(11) .EQ. 0.) SITEAR(11)=18.3112+1.2692*SITEAR(5)
C----------
C LOAD THE SDIDEF ARRAY.
C----------
      DO 40 I=1,MAXSP
        IF(SDIDEF(I) .GT. 0.0) GO TO 40
        IF(BAMAX .GT. 0.) THEN
          SDIDEF(I)=BAMAX/(0.5454154*(PMSDIU/100.))
        ELSE
          SDIDEF(I) = SDICON(I)
        ENDIF
   40 CONTINUE
C
      DO 92 I=1,15
      J=(I-1)*10 + 1
      JJ=J+9
      IF(JJ.GT.MAXSP)JJ=MAXSP
      WRITE(JOSTND,90)(NSP(K,1)(1:2),K=J,JJ)
   90 FORMAT(/'SPECIES ',5X,10(A2,6X))
      WRITE(JOSTND,91)(SDIDEF(K)/ACRtoHA,K=J,JJ )
   91 FORMAT('SDI MAX ',   10F8.0)
      IF(JJ .EQ. MAXSP)GO TO 93
   92 CONTINUE
   93 CONTINUE
C----------
C  LOAD VOLUME EQUATION ARRAYS FOR ALL SPECIES
C----------
      INTFOR = KODFOR - (KODFOR/100)*100
      WRITE(FORST,'(I2)')INTFOR
      IF(INTFOR.LT.10)FORST(1:1)='0'
      IREGN = KODFOR/100
      DIST='  '
      PROD='  '
      VAR='AK'
C----------
C    R7 (CODE=701) BRITISH COLUMBIA / MAKAH INDIAN RESERVATION
C    USES THE TONGAS VOLUME EQUATIONS
C----------
      IF(IREGN.EQ.7)THEN
        IREGN=10
        FORST='03'
      ENDIF
C
      DO ISPC=1,MAXSP
      READ(FIAJSP(ISPC),'(I4)')IFIASP
      IF(((METHC(ISPC).EQ.6).OR.(METHC(ISPC).EQ.9)).AND.
     &     (VEQNNC(ISPC).EQ.'          '))THEN
        CALL VOLEQDEF(VAR,IREGN,FORST,DIST,IFIASP,PROD,VOLEQ,ERRFLAG)
        VEQNNC(ISPC)=VOLEQ
      ENDIF
      IF(((METHB(ISPC).EQ.6).OR.(METHB(ISPC).EQ.9)).AND.
     &     (VEQNNB(ISPC).EQ.'          '))THEN
        CALL VOLEQDEF(VAR,IREGN,FORST,DIST,IFIASP,PROD,VOLEQ,ERRFLAG)
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
 230  FORMAT(4(3X,A2,4X,A10,1X,A10))
C
      RETURN
      END
