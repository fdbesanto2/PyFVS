      BLOCK DATA BLKDAT
      use prgprm_mod
      implicit none
C----------
C  **BLKDAT--UT  DATE OF LAST REVISION:  08/15/12
C----------
C
C     SEE **MAIN** FOR DICTIONARY OF VARIABLE NAMES.
C----------
COMMONS
      INCLUDE 'COEFFS.F77'
C
      INCLUDE 'ESPARM.F77'
C
      INCLUDE 'ESCOMN.F77'
C
      INCLUDE 'PDEN.F77'
C
      INCLUDE 'ECON.F77'
C
      INCLUDE 'HTCAL.F77'
C
      INCLUDE 'CONTRL.F77'
C
      INCLUDE 'PLOT.F77'
C
      INCLUDE 'RANCOM.F77'
C
      INCLUDE 'SCREEN.F77'
C
      INCLUDE 'GGCOM.F77'
C
      INCLUDE 'FVSSTDCM.F77'
C
C----------
      INTEGER I,J,K
C----------
C SPECIES LIST FOR UTAH VARIANT:
C
C  1=WB,  2=LM,  3=DF,  4=WF,  5=BS,  6=AS,  7=LP,  8=ES,  9=AF, 10=PP,
C 11=PI, 12=WJ, 13=GO, 14=PM, 15=RM, 16=UJ, 17=GB, 18=NC, 19=FC, 20=MC,
C 21=BI, 22=BE, 23=OS, 24=OH
C
C VARIANT EXPANSION:
C GO AND OH USE OA (OAK SP.) EQUATIONS FROM UT
C PM USES PI (COMMON PINYON) EQUATIONS FROM UT
C RM AND UJ USE WJ (WESTERN JUNIPER) EQUATIONS FROM UT
C GB USES BC (BRISTLECONE PINE) EQUATIONS FROM CR
C NC, FC, AND BE USE NC (NARROWLEAF COTTONWOOD) EQUATIONS FROM CR
C MC USES MC (CURL-LEAF MTN-MAHOGANY) EQUATIONS FROM SO
C BI USES BM (BIGLEAF MAPLE) EQUATIONS FROM SO
C OS USES OT (OTHER SP.) EQUATIONS FROM UT
C
C     1 = WHITEBARK PINE               WB  PINUS ALBICAULIS
C     2 = LIMBER PINE                  LM  PINUS FLEXILIS
C     3 = DOUGLAS-FIR                  DF  PSEUDOTSUGA MENZIESII
C     4 = WHITE FIR                    WF  ABIES CONCOLOR
C     5 = BLUE SPRUCE                  BS  PICEA PUNGENS
C     6 = QUAKING ASPEN                AS  POPULUS TREMULOIDES
C     7 = LODGEPOLE PINE               LP  PINUS CONTORTA
C     8 = ENGELMANN SPRUCE             ES  PICEA ENGELMANNII
C     9 = SUBALPINE FIR                AF  ABIES LASIOCARPA
C    10 = PONDEROSA PINE               PP  PINUS PONDEROSA
C    11 = COMMON PINYON                PI  PINUS EDULIS
C    12 = WESTERN JUNIPER              WJ  JUNIPERUS OCCIDENTALIS
C    13 = GAMBEL OAK                   GO  QUERCUS GAMBELII
C    14 = SINGLELEAF PINYON            PM  PINUS MONOPHYLLA
C    15 = ROCKY MOUNTAIN JUNIPER       RM  JUNIPERUS SCOPULORUM
C    16 = UTAH JUNIPER                 UJ  JUNIPERUS OSTEOSPERMA
C    17 = GREAT BASIN BRISTLECONE PINE GB  PINUS LONGAEVA
C    18 = NARROWLEAF COTTONWOOD        NC  POPULUS ANGUSTIFOLIA
C    19 = FREMONT COTTONWOOD           FC  POPULUS FREMONTII
C    20 = CURL-LEAF MOUNTAIN-MAHOGANY  MC  CERCOCARPUS LEDIFOLIUS
C    21 = BIGTOOTH MAPLE               BI  ACER GRANDIDENTATUM
C    22 = BOXELDER                     BE  ACER NEGUNDO
C    23 = OTHER SOFTWOODS              OS
C    24 = OTHER HARDWOODS              OH
C
C----------
C TYPE DECLARATIONS AND COMMON STATEMENT FOR CONTROL VARIABLES.
C----------
C
      DATA COR2 /MAXSP*1./, HCOR2 /MAXSP*1./,RCOR2/MAXSP*1.0/,
     &     BKRAT/MAXSP*0./
C
      DATA TREFMT /
     >'(I4,T1,I7,F6.0,I1,A3,F4.1,F3.1,2F3.0,F4.1,I1,3(I2,I2),2I1,I2,2I3,
     >2I1,F3.0)' /
C
      DATA YR / 10.0 /, IRECNT/ 0 /,ICCODE/0/
C
      DATA IREAD,ISTDAT,JOLIST,JOSTND,JOSUM,JOTREE/ 15,2,3,16,4,8 /
C----------
C COMMON STATEMENT FOR ESCOMN VARIABLE
C----------
      DATA XMIN/1.0, 1.0, 1.0, 0.5, 0.5, 6.0, 1.0, 0.5, 0.5, 1.0,
     &          0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 3.0, 3.0, 0.5,
     &          0.5, 3.0, 0.5, 0.5/
      DATA DBHMID/1.0,3.0,5.0,7.0,9.0,12.0,16.0,20.0,24.0,28.0/,
     &  ISPSPE/6,13,18,19,21,22/,
     &  BNORML/3*1.0,1.046,1.093,1.139,1.186,1.232,1.278,1.325,1.371,
     &   1.418,1.464,1.510,1.557,1.603,1.649,1.696,1.742,1.789/,
     &  HHTMAX/9.0, 9.0, 10.0, 7.0, 7.0, 16.0, 10.0, 7.0, 7.0, 10.0,
     &         6.0, 6.0, 10.0, 6.0, 6.0,  6.0,  9.0,16.0,16.0,  6.0,
     &         6.0,16.0,  9.0,10.0/,
     &  IFORCD/401,407,408,410,418,419,  0,  0,  0,  0,
     &           0,  0,  0,  0,  0,  0,  0,  0,  0,  0/,
     &  IFORST/  20*1 /
C
C     OCURHT ZEROES OUT PROBABILITIES WHICH CANNOT OCCUR BY DEFINITION.
C     (DIMENSIONED (16,MAXSP) WITH THE 16 BEING THE HABITAT TYPE GROUP
C      AS SHOWN IN TABLE 3, PG 6, GTR INT-279) WHICH DOES NOT PERTAIN
C      TO THE UT VARIANT)
C
      DATA ((OCURHT(I,J),I=1,16),J=1,24)/384*0.0 /
C
C     OCURNF ZEROES OUT PROBABILITIES ON NATIONAL FORESTS BY SPECIES.
C     (DIMENSIONED 20,MAXSP WITH THE 20 BEING 20 FOREST CODES SHOWN
C      IN ARRAY IFORCD ABOVE AND MAPPED AS SHOWN IN ARRAY IFORST)
C
      DATA ((OCURNF(I,J),I=1,20),J=1,24)/480*0.0 /
C----------
C COMMON STATEMENT FOR PLOT VARIABLES.
C----------
      DATA JSP /
     & 'WB ',   'LM ',   'DF ',   'WF ',   'BS ',   'AS ',   'LP ',
     & 'ES ',   'AF ',   'PP ',   'PI ',   'WJ ',   'GO ',   'PM ',
     & 'RM ',   'UJ ',   'GB ',   'NC ',   'FC ',   'MC ',   'BI ',
     & 'BE ',   'OS ',   'OH '/
C
      DATA FIAJSP /
     & '101',   '113',   '202',   '015',   '096',   '746',   '108',
     & '093',   '019',   '122',   '106',   '064',   '814',   '133',
     & '066',   '065',   '142',   '749',   '748',   '475',   '322',
     & '313',   '298',   '998'/
C
      DATA PLNJSP /
     & 'PIAL  ','PIFL2 ','PSME  ','ABCO  ','PIPU  ','POTR5 ','PICO  ',
     & 'PIEN  ','ABLA  ','PIPO  ','PIED  ','JUOC  ','QUGA  ','PIMO  ',
     & 'JUSC2 ','JUOS  ','PILO  ','POAN3 ','POFR2 ','CELE3 ','ACGR3 ',
     & 'ACNE2 ','2TE   ','2TD   '/
C
      DATA NSP /'WB1','LM1','DF1','WF1','BS1','AS1','LP1','ES1','AF1',
     >          'PP1','PI1','WJ1','GO1','PM1','RM1','UJ1','GB1','NC1',
     >          'FC1','MC1','BI1','BE1','OS1','OH1',
     >          'WB2','LM2','DF2','WF2','BS2','AS2','LP2','ES2','AF2',
     >          'PP2','PI2','WJ2','GO2','PM2','RM2','UJ2','GB2','NC2',
     >          'FC2','MC2','BI2','BE2','OS2','OH2',
     >          'WB3','LM3','DF3','WF3','BS3','AS3','LP3','ES3','AF3',
     >          'PP3','PI3','WJ3','GO3','PM3','RM3','UJ3','GB3','NC3',
     >          'FC3','MC3','BI3','BE3','OS3','OH3'/
      DATA JTYPE /122*0/
C----------
C COMMON STATEMENT FOR COEFFS VARIABLES
C----------
      DATA HT1/
     &   4.1920,  4.1920,  4.5879,  4.3008,   4.5293,
     &   4.4421,  4.3767,  4.5293,  4.4717,   4.6024,
     &   3.2000,  3.2000,  3.2000,  3.2000,   3.2000,
     &   3.2000,  4.1920,  4.4421,  4.4421,   5.1520,
     &   4.7000,  4.4421,  4.2597,  3.2000/
      DATA HT2/
     &  -5.1651, -5.1651, -8.9277, -6.8139,  -7.7725,
     &  -6.5405, -6.1281, -7.7725, -6.7387, -11.4693,
     &  -5.0000, -5.0000, -5.0000, -5.0000,  -5.0000,
     &  -5.0000, -5.1651, -6.5405, -6.5405, -13.5760,
     &  -6.3260, -6.5405, -9.3949, -5.0000/
C
C  RESIDUAL ERROR ESTIMATES WERE MULTIPLIED BY 0.75 TO APPROXIMATE
C  CORRECTION FOR MEASUREMENT ERROR; 6/11/91--WRW.
C
      DATA SIGMAR/
     &  0.46710, 0.46710, 0.34418, 0.24060, 0.35168,
     &  0.37500, 0.28860, 0.35168, 0.28005, 0.27338,
     &      0.2,     0.2,     0.2,     0.2,     0.2,
     &      0.2,     0.2,     0.2,     0.2,  0.5357,
     &   0.5107,     0.2, 0.46710,     0.2/
C
      DATA BREAK/
     &   3.,   3.,   3.,   3.,   3.,   3.,   3.,   3.,   3.,   3.,
     &  99.,  99.,  99.,  99.,  99.,  99.,  99.,   1.,   1.,  99.,
     &  99.,   1.,   3.,  99./
C
      DATA REGNBK/2.999/
C
      DATA S0/55329D0/,SS/55329./
C
      DATA LSCRN,JOSCRN/.FALSE.,6/
C
      DATA JOSUME/13/
C
      DATA KOLIST,FSTOPEN /27,.FALSE./
C
      END
