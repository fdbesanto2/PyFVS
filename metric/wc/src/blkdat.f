      BLOCK DATA BLKDAT
      use prgprm_mod
      implicit none
C----------
C  **BLKDAT--WC/M   DATE OF LAST REVISION:  02/15/12
C----------
C
C     SEE **MAIN** FOR DICTIONARY OF VARIABLE NAMES.
C
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
      INCLUDE 'VARCOM.F77'
C
C     TYPE DECLARATIONS AND COMMON STATEMENT FOR CONTROL VARIABLES.
C
      INTEGER I,J
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
C
C   COMMON STATEMENT FOR ESCOMN VARIABLE
C
      DATA XMIN/ 1.0, 2*1.5, 7*1.0, 1.4, 3*1.0, 1.3, 1.5,
     &           13*1.0, 1.5, 9*1.0/
      DATA ISPSPE/ 17,21,22,23,24,25,26,27,28,33,34,35,36,37/
      DATA HHTMAX/ 21*20.0,50.0,17*20.0 /
      DATA DBHMID/1.0,3.0,5.0,7.0,9.0,12.0,16.0,20.0,24.0,28.0/,
     &  BNORML/3*1.0,1.046,1.093,1.139,1.186,1.232,1.278,1.325,1.371,
     &  1.418,1.464,1.510,1.557,1.603,1.649,1.696,1.742,1.789/,
     &  IFORCD/  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     &           0,  0,  0,  0,  0,  0,  0,  0,  0,  0/,
     &  IFORST/  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
     &           0,  0,  0,  0,  0,  0,  0,  0,  0,  0/
C
C     OCURHT ZEROES OUT PROBABILITIES WHICH CANNOT OCCUR BY DEFINITION.
C
      DATA ((OCURHT(I,J),I=1,16),J=1,MAXSP)/624*0.0/
C
C     OCURNF ZEROES OUT PROBABILITIES ON NATIONAL FORESTS BY SPECIES.
C
      DATA ((OCURNF(I,J),I=1,20),J=1,MAXSP)/780*0.0/
C
C     COMMON STATEMENT FOR PLOT VARIABLES.
C
C     SPECIES LIST FOR WEST CASCADES VARIANT
C
C     1 = PACIFIC SILVER FIR (SF)      ABIES AMABILIS			[BA]
C     2 = WHITE FIR (WF)               ABIES CONCOLOR			[BC]
C     3 = GRAND FIR (GF)               ABIES GRANDIS			[BG]
C     4 = SUBALPINE FIR (AF)           ABIES LASIOCARPA			[BL]
C     5 = CALIFORNIA RED FIR (RF)/     ABIES MAGNIFICA			[BM]
C         SHASTA RED FIR
C     6 =
C     7 = NOBLE FIR (NF)               ABIES PROCERA			[BP]
C     8 = ALASKA CEDAR (YC)/           CHAMAECYPARIS NOOTKATENSIS	[YC]
C         WESTERN LARCH                LARIX OCCIDENTALIS		[LW]
C     9 = INCENSE CEDAR (IC)           LIBOCEDRUS DECURRENS		[OA]
C    10 = ENGELMANN SPRUCE (ES)/       PICEA ENGELMANNII		[SE]
C         SITKA SPRUCE                 PICEA SITCHENSIS			[SS]
C    11 = LODGEPOLE PINE (LP)          PINUS CONTORTA			[PL]
C    12 = JEFFREY PINE (JP)            PINUS JEFFREYI			[JP] - unchanged
C    13 = SUGAR PINE (SP)              PINUS LAMBERTIANA		[PS]
C    14 = WESTERN WHITE PINE (WP)      PINUS MONTICOLA			[PW]
C    15 = PONDEROSA PINE (PP)          PINUS PONDEROSA			[PY]
C    16 = DOUGLAS-FIR (DF)             PSEUDOTSUGA MENZIESII	[FD]
C    17 = COAST REDWOOD (RW)           SEQUOIA SEMPERVIRENS		[OC]
C    18 = WESTERN REDCEDAR (RC)        THUJA PLICATA			[CW]
C    19 = WESTERN HEMLOCK (WH)         TSUGA HETEROPHYLLA		[HW]
C    20 = MOUNTAIN HEMLOCK (MH)        TSUGA MERTENSIANA		[HM]
C    21 = BIGLEAF MAPLE (BM)           ACER MACROPHYLLUM		[MB]
C    22 = RED ALDER (RA)               ALNUS RUBRA				[DR]
C    23 = WHITE ALDER (WA) /           ALNUS RHOMBIFOLIA
C         PACIFIC MADRONE              ARBUTUS MENZIESII		[RA]
C    24 = PAPER BIRCH (PB)             BETULA PAPYRIFERA		[EP]
C    25 = GIANT CHINKAPIN (GC) /       CASTANOPSIS CHRYSOPHYLLA	[GC] - unchanged
C         TANOAK                       LITHOCARPUS DENSIFLORUS
C    26 = QUAKING ASPEN (AS)           POPULUS TREMULOIDES		[AT]
C    27 = BLACK COTTONWOOD (CW)        POPULUS TRICHOCARPA		[AC] - (should be ACT)
C    28 = OREGON WHITE OAK (WO) /      QUERCUS GARRYANA			[QG]
C         CALIFORNIA BLACK OAK         QUERCUS KELLOGGII
C    29 = WESTERN JUNIPER (WJ)         JUNIPERUS OCCIDENTALIS	[J ] - unchanged
C    30 = SUBALPINE LARCH (LL)         LARIX LYALLII			[LA]
C    31 = WHITEBARK PINE (WB)          PINUS ALBICAULIS			[PA]
C    32 = KNOBCONE PINE (KP)           PINUS ATTENUATA			[KP] - unchanged
C    33 = PACIFIC YEW (PY)             TAXUS BREVIFOLIA			[TW]
C    34 = PACIFIC DOGWOOD (DG)         CORNUS NUTTALLII			[GP]
C    35 = HAWTHORN (HT)                CRATAEGUS sp.			[HT] - unchanged
C    36 = BITTER CHERRY (CH)           PRUNUS EMARGINATA		[VB]
C    37 = WILLOW (WI)                  SALIX sp.				[W ]
C    38 =
C    39 = OTHER (OT)
C
      DATA JSP /
     & 'BA ',   'BC ',   'BG ',   'BL ',   'BM ',   '   ',   'BP ',
     & 'YC ',   'OA ',   'SE ',   'PL ',   'JP ',   'PS ',   'PW ',
     & 'PY ',   'FD ',   'OC ',   'CW ',   'HW ',   'HM ',   'MB ',
     & 'DR ',   'RA ',   'EP ',   'GC ',   'AT ',   'AC ',   'QG ',
     & 'WJ ',   'LA ',   'PA ',   'KP ',   'TW ',   'GP ',   'HT ',
     & 'VB ',   'WI ',   '   ',   'OT '/
C
      DATA FIAJSP /
     & '011',   '015',   '017',   '019',   '020',   '   ',   '022',
     & '042',   '081',   '093',   '108',   '116',   '117',   '119',
     & '122',   '202',   '211',   '242',   '263',   '264',   '312',
     & '351',   '352',   '375',   '431',   '746',   '747',   '815',
     & '064',   '072',   '101',   '103',   '231',   '492',   '500',
     & '768',   '920',   '   ',   '999'/
C
      DATA PLNJSP /
     & 'ABAM  ','ABCO  ','ABGR  ','ABLA  ','ABMA  ','      ','ABPR  ',
     & 'CHNO  ','CADE27','PIEN  ','PICO  ','PIJE  ','PILA  ','PIMO3 ',
     & 'PIPO  ','PSME  ','SESE3 ','THPL  ','TSHE  ','TSME  ','ACMA3 ',
     & 'ALRU2 ','ALRH2 ','BEPA  ','CHCHC4','POTR5 ','POBAT ','QUGA4 ',
     & 'JUOC  ','LALY  ','PIAL  ','PIAT  ','TABR2 ','CONU4 ','CRATA ',
     & 'PREM  ','SALIX ','      ','2TREE '/
C
      DATA JTYPE /130,170,250,260,280,290,310,320,330,420,
     &            470,510,520,530,540,550,570,610,620,640,
     &            660,670,680,690,710,720,730,830,850,999,92*0 /
C
      DATA NSP /  'BA1','BC1','BG1','BL1','BM1','__1','BP1','YC1',
     &'OA1','SE1','PL1','JP1','PS1','PW1','PY1','FD1','OC1','CW1',
     &'HW1','HM1','MB1','DR1','RA1','EP1','GC1','AT1','AC1','QG1','WJ1',
     &'LA1','PA1','KP1','TW1','GP1','HT1','VB1','WI1','__1','OT1',
     &            'BA2','BC2','BG2','BL2','BM2','__2','BP2','YC2',
     &'OA2','SE2','PL2','JP2','PS2','PW2','PY2','FD2','OC2','CW2',
     &'HW2','HM2','MB2','DR2','RA2','EP2','GC2','AT2','AC2','QG2','WJ2',
     &'LA2','PA2','KP2','TW2','GP2','HT2','VB2','WI2','__2','OT2',
     &            'BA3','BC3','BG3','BL3','BM3','__3','BP3','YC3',
     &'OA3','SE3','PL3','JP3','PS3','PW3','PY3','FD3','OC3','CW3',
     &'HW3','HM3','MB3','DR3','RA3','EP3','GC3','AT3','AC3','QG3','WJ3',
     &'LA3','PA3','KP3','TW3','GP3','HT3','VB3','WI3','__3','OT3'/
C
C   COMMON STATEMENT FOR COEFFS VARIABLES
C   HT1 AND HT2 ARE HEIGHT DUBBING COEFFICIENTS FOR TREES 5.0" DBH
C   AND LARGER.

C
      DATA HT1/
     & 5.288, 2*5.308, 3*5.313, 5.327, 5.143, 2*5.188, 4.865, 5.333,
     & 2*5.382, 5.333, 5.288, 5.188, 5.271, 5.298, 5.081, 4.700,
     & 4.886, 7*5.152, 4*5.188, 6*5.152/
C
      DATA HT2/
     & -14.147, 2*-13.624, 3*-15.321, -15.450, -13.497, 2*-13.801,
     & -9.305, -17.762, 2*-15.866, -17.762, -14.147, -13.801, -14.996,
     & -13.240, -13.430, -6.326, -8.792, 7*-13.576, 4*-13.801,
     & 6*-13.576/
C
C  SIGMAR VALUES FOR
C  **REFIT OF WO(28) by GOULD&HARRINGTON ESM 041910
C
      DATA SIGMAR/
     & 0.5450, 2*0.4390, 0.3960, 2*0.3102, 0.4275, 0.3931,
     & 2*0.4842, 0.3690, 0.3222, 2*0.5494, 0.3222, 0.4456,
     & 0.4842, 0.4442, 0.4104, 0.3751, 0.5107, 0.7487,
     & 5*0.5357, 0.236, 0.5357, 4*0.4842, 6*0.5357/
C
C   DATA STATEMENTS FOR VARIABLES IN VARCOM COMMON BLOCK.
C   HTT1 IS USED TO STORE THE HEIGHT DUBBING COEFFICIENTS FOR TREES
C   LESS THAN 5.0" DBH.
C
      DATA HTT1/
C
C   HTT1(ISPC,1) IS USED TO STORE THE CONSTANT COEFFICIENT.
C
     & 1.3134, 2*1.4769, 1.4261, 2*1.3526, 1.7100,
     & 3*1.5907, 0.9717, 1.0756, 2*0.9717, 1.0756, 7.1391, 1.5907,
     & 2.3115, 1.3608, 1.2278, 9*0.0994, 4*1.5907, 6*0.0994,
C
C   HTT1(ISPC,2) IS USED TO STORE THE DBH COEFFICIENT.
C
     & 0.3432, 2*0.3579, 0.3334, 2*0.3335, 0.2943, 3*0.3040,
     & 0.3934, 0.4369, 2*0.3934, 0.4369, 4.2891, 0.3040, 0.2370,
     & 0.6151, 0.4000, 9*4.9767, 4*0.3040, 6*4.9767,
C
C   HTT1(ISPC,3) IS USED TO STORE THE CR COEFFICIENT.
C
     & 0.0366, 3*0.0, 2*0.0367, 0.0, 3*0.0, 0.0339, 0.0,
     & 2*0.0339, 0.0, -0.7150, 0.0, -0.0556, 21*0.0,
C
C   HTT1(ISPC,4) IS USED TO STORE THE DBH SQUARED COEFFICIENT.
C
     & 15*0.0, 0.2750, 2*0.0, -0.0442, 20*0.0,
C
C   HTT1(ISPC,5) IS USED TO STORE THE DUMMY VARIABLE FOR
C   MANAGED/UNMANAGED STANDS.
C
     & 6*0.0, 0.1054, 3*0.0, 0.3044, 0.0, 2*0.3044, 0.0,
     & 2.0393, 0.0, 0.3218, 0.0829, 20*0.0,
C
C   HTT1(ISPC,6) THRU HTT1(ISPC,9) ARE NOT USED. SET TO 0.0
C
     & 156*0.0/
C
      DATA BB0/
     &0.0071839,2*-0.30935,2.75780,2*0.0,-564.38,0.6192,128.8952205,
     &2.75780,-0.0968,128.8952205,2*-4.62536,128.8952205,3*0.6192,
     &-1.7307,22.8741,0.6192,59.5864,5*0.6192,0.0,0.6192,0.0,
     &9*0.6192/
C
      DATA BB1/
     &0.0000571,2*1.2383,0.83312,2*1.51744,22.25,-5.3394,-0.016959,
     &0.83312,0.02679,-0.016959,2*1.346399,-0.016959,3*-5.3394,
     &0.1394,0.950234,-5.3394,0.7953,5*-5.3394,0.0,-5.3394,
     &1.46897,9*-5.3394/
C
      DATA BB2/
     &1.39005,2*0.001762,0.015701,2*1.4151E-6, 0.04995,
     &240.29,1.23114,0.015701,-0.00009309,1.23114,2*-135.354483,
     &1.23114,3*240.29,-0.0616,-0.00206465,240.29,0.00194,5*240.29,
     &0.0, 240.29,0.0092466,9*240.29/
C
       DATA BB3/
     &0.0,2*-5.4E-6,22.71944,2*-0.0440853,6.80,3368.9,-0.7864,
     &22.71944,0.0,-0.7864,2*0.0,-0.7864,3*3368.9,0.0137,0.5,3368.9,
     &-0.00074,5*3368.9,0.0, 3368.9,-2.3957E-4,9*3368.9/
C
       DATA BB4/
     &0.0,2*2.046E-7,-0.63557,2*-3.0495E6,2843.21,0.0,2.49717,
     &-0.63557,0.0,2.49717,2*0.0,2.49717,3*0.0,0.00192,1.365566,
     &0.0,0.9198,7*0.0,1.1122E-6,9*0.0/
C
      DATA BB5/
     & 0.0,2*-4.04E-13,0.0,2*5.72474E-4,34735.54,0.0,-0.0045042,2*0.0,
     & -0.0045042,2*0.0,-0.0045042,3*0.0,0.00007,2.045963,9*0.0,
     & -0.12528,9*0.0/
C
      DATA BB6/
     & 0.0,2*-6.2056,5*0.0,0.33022,2*0.0,0.33022,2*0.0,0.33022,
     & 3*0.0,1.8219,10*0.0,0.039636,9*0.0/
C
      DATA BB7/
     & 0.0,2*2.097,5*0.0,100.43,2*0.0,100.43,2*0.0,100.43,3*0.0,
     & 0.199298,10*0.0,-4.278E-4,9*0.0/
C
      DATA BB8/
     & 0.0,2*-0.09411,15*0.0,0.00438,10*0.0,1.7039E-6,9*0.0/
C
       DATA BB9/
     & 0.0,2*-4.382E-5,26*0.0,73.57,9*0.0/
C
      DATA BB10/
     & 0.0,2*2.007E-11,26*0.0,-0.12528,9*0.0/
C
      DATA BB11/
     & 0.0,2*-2.054E-17,26*0.0,0.039636,9*0.0/
C
      DATA BB12/
     & 0.0,2*-84.93,26*0.0,-4.278E-4,9*0.0/
C
      DATA BB13/
     & 29*0.0,1.7039E-6,9*0.0/
C
      DATA REGNBK/2.999/
C
      DATA S0/55329D0/,SS/55329./
C
      DATA LSCRN,JOSCRN/.FALSE.,6/
C
      DATA JOSUME/13/
C
      END
