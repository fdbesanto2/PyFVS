      BLOCK DATA FMCBLK
      use fmprop_mod
      use prgprm_mod
      implicit none
C----------
C   **FMCBLK--FIRE-SN  DATE OF LAST REVISION:   11/23/07
C----------
COMMONS

      INTEGER J

C     GROUPING FOR THE JENKINS BIOMASS EQUATIONS FOR C REPORTING
C     SOFTWOODS
C       1=CEDAR/LARCH
C       2=DOUGLAS-FIR
C       3=TRUE FIR/HEMLOCK
C       4=PINE
C       5=SPRUCE
C     HARDWOODS
C       6=ASPEN/ALDER/COTTONWOOD/WILLOW
C       7=SOFT MAPLE/BIRCH
C       8=MIXED HARDWOOD
C       9=HARD MAPLE/OAK/HICKORY/BEECH
C      10=WOODLAND JUNIPER/OAK/MESQUITE

      DATA BIOGRP/
     & 3, 1, 5, 4, 4,
     & 4, 4, 4, 4, 4, ! 10
     & 4, 4, 4, 4, 1,
     & 1, 3, 7, 7, 7, ! 20
     & 7, 9, 8, 7, 7,
     & 8, 9, 8, 8, 8, ! 30
     & 8, 8, 9, 8, 8,
     & 8, 8, 8, 8, 8, ! 40
     & 8, 8, 8, 8, 8,
     & 8, 8, 8, 8, 8, ! 50
     & 8, 8, 8, 8, 8,
     & 8, 8, 8, 8, 6, ! 60
     & 6, 8, 9, 9, 9,
     & 9, 9, 9, 9, 9, ! 70
     & 9, 9, 9, 9, 9,
     & 9, 9, 9, 9, 8, ! 80
     & 6, 8, 8, 8, 8,
     & 8, 8, 1, 9, 9/ ! 90

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SC;sw;pulp
C SubRegion index I = 1
C  DataType index K = 1 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      DATA (FAPROP(1,J,1,1,1), J= 1,101) /
     & 0.5703,0.5012,0.4424,0.3926,0.3502,0.3141,0.2820,0.2539,0.2278,
     & 0.2042,0.1840,0.1675,0.1543,0.1438,0.1354,0.1286,0.1231,0.1186,
     & 0.1148,0.1112,0.1083,0.1058,0.1038,0.1021,0.1005,0.0990,0.0976,
     & 0.0963,0.0950,0.0938,0.0927,0.0916,0.0905,0.0895,0.0885,0.0875,
     & 0.0865,0.0856,0.0846,0.0837,0.0828,0.0820,0.0811,0.0803,0.0795,
     & 0.0786,0.0779,0.0771,0.0763,0.0755,0.0748,0.0741,0.0734,0.0726,
     & 0.0719,0.0713,0.0706,0.0699,0.0693,0.0686,0.0680,0.0673,0.0667,
     & 0.0661,0.0655,0.0649,0.0643,0.0637,0.0631,0.0626,0.0620,0.0615,
     & 0.0609,0.0604,0.0599,0.0593,0.0588,0.0583,0.0578,0.0573,0.0568,
     & 0.0563,0.0558,0.0553,0.0549,0.0544,0.0539,0.0535,0.0530,0.0526,
     & 0.0521,0.0517,0.0513,0.0508,0.0504,0.0500,0.0496,0.0492,0.0488,
     & 0.0484,0.0480/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SC;sw;pulp
C SubRegion index I = 1
C  DataType index K = 2 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      DATA (FAPROP(1,J,2,1,1), J= 1,101) /
     & 0.0000,0.0237,0.0433,0.0594,0.0727,0.0836,0.0929,0.1007,0.1076,
     & 0.1136,0.1184,0.1219,0.1243,0.1257,0.1265,0.1268,0.1267,0.1263,
     & 0.1258,0.1252,0.1245,0.1238,0.1229,0.1220,0.1212,0.1203,0.1195,
     & 0.1188,0.1180,0.1173,0.1167,0.1161,0.1155,0.1149,0.1144,0.1140,
     & 0.1135,0.1131,0.1127,0.1124,0.1121,0.1118,0.1115,0.1113,0.1111,
     & 0.1109,0.1107,0.1105,0.1104,0.1103,0.1102,0.1101,0.1100,0.1099,
     & 0.1099,0.1098,0.1098,0.1098,0.1098,0.1098,0.1098,0.1099,0.1099,
     & 0.1100,0.1100,0.1101,0.1101,0.1102,0.1103,0.1104,0.1105,0.1106,
     & 0.1107,0.1108,0.1109,0.1110,0.1111,0.1112,0.1113,0.1115,0.1116,
     & 0.1117,0.1119,0.1120,0.1121,0.1123,0.1124,0.1125,0.1127,0.1128,
     & 0.1130,0.1131,0.1133,0.1134,0.1136,0.1137,0.1138,0.1140,0.1141,
     & 0.1143,0.1144/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SC;sw;pulp
C SubRegion index I = 1
C  DataType index K = 3 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      DATA (FAPROP(1,J,3,1,1), J= 1,101) /
     & 0.2660,0.2897,0.3116,0.3303,0.3464,0.3602,0.3725,0.3834,0.3936,
     & 0.4030,0.4110,0.4177,0.4230,0.4274,0.4309,0.4337,0.4361,0.4381,
     & 0.4397,0.4413,0.4426,0.4436,0.4445,0.4453,0.4459,0.4465,0.4470,
     & 0.4475,0.4480,0.4483,0.4487,0.4490,0.4493,0.4495,0.4498,0.4500,
     & 0.4501,0.4503,0.4504,0.4505,0.4506,0.4507,0.4507,0.4508,0.4508,
     & 0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,
     & 0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,
     & 0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,
     & 0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,
     & 0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,
     & 0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,0.4508,
     & 0.4508,0.4508/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SC;sw;saw
C SubRegion index I = 1
C  DataType index K = 1 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      DATA (FAPROP(1,J,1,2,1), J= 1,101) /
     & 0.6288,0.5943,0.5634,0.5360,0.5114,0.4894,0.4691,0.4506,0.4331,
     & 0.4168,0.4020,0.3887,0.3767,0.3660,0.3562,0.3472,0.3388,0.3311,
     & 0.3238,0.3168,0.3102,0.3040,0.2981,0.2924,0.2870,0.2818,0.2768,
     & 0.2720,0.2673,0.2628,0.2584,0.2542,0.2501,0.2461,0.2422,0.2385,
     & 0.2348,0.2313,0.2278,0.2245,0.2212,0.2180,0.2149,0.2119,0.2089,
     & 0.2060,0.2032,0.2005,0.1978,0.1952,0.1926,0.1901,0.1876,0.1852,
     & 0.1829,0.1806,0.1783,0.1761,0.1740,0.1718,0.1698,0.1677,0.1657,
     & 0.1638,0.1619,0.1600,0.1581,0.1563,0.1545,0.1528,0.1511,0.1494,
     & 0.1477,0.1461,0.1445,0.1429,0.1413,0.1398,0.1383,0.1368,0.1354,
     & 0.1339,0.1325,0.1311,0.1298,0.1284,0.1271,0.1258,0.1245,0.1232,
     & 0.1220,0.1207,0.1195,0.1183,0.1171,0.1160,0.1148,0.1137,0.1126,
     & 0.1115,0.1104/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SC;sw;saw
C SubRegion index I = 1
C  DataType index K = 2 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      DATA (FAPROP(1,J,2,2,1), J= 1,101) /
     & 0.0000,0.0160,0.0303,0.0431,0.0545,0.0648,0.0741,0.0826,0.0905,
     & 0.0977,0.1043,0.1102,0.1155,0.1203,0.1246,0.1286,0.1322,0.1356,
     & 0.1388,0.1418,0.1446,0.1472,0.1496,0.1520,0.1542,0.1563,0.1584,
     & 0.1603,0.1622,0.1640,0.1657,0.1674,0.1690,0.1706,0.1720,0.1735,
     & 0.1749,0.1763,0.1776,0.1789,0.1801,0.1813,0.1825,0.1836,0.1848,
     & 0.1858,0.1869,0.1879,0.1890,0.1900,0.1909,0.1919,0.1928,0.1937,
     & 0.1946,0.1955,0.1963,0.1972,0.1980,0.1988,0.1996,0.2004,0.2012,
     & 0.2019,0.2027,0.2034,0.2041,0.2048,0.2055,0.2062,0.2069,0.2076,
     & 0.2082,0.2089,0.2095,0.2102,0.2108,0.2114,0.2120,0.2126,0.2132,
     & 0.2138,0.2144,0.2150,0.2155,0.2161,0.2166,0.2172,0.2177,0.2182,
     & 0.2188,0.2193,0.2198,0.2203,0.2208,0.2213,0.2218,0.2223,0.2227,
     & 0.2232,0.2237/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SC;sw;saw
C SubRegion index I = 1
C  DataType index K = 3 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      DATA (FAPROP(1,J,3,2,1), J= 1,101) /
     & 0.2278,0.2370,0.2458,0.2536,0.2605,0.2667,0.2723,0.2775,0.2823,
     & 0.2869,0.2909,0.2945,0.2977,0.3004,0.3029,0.3051,0.3071,0.3090,
     & 0.3107,0.3123,0.3138,0.3152,0.3166,0.3178,0.3190,0.3201,0.3212,
     & 0.3222,0.3231,0.3241,0.3250,0.3258,0.3266,0.3274,0.3282,0.3289,
     & 0.3295,0.3302,0.3308,0.3314,0.3320,0.3325,0.3330,0.3335,0.3340,
     & 0.3344,0.3349,0.3353,0.3357,0.3360,0.3364,0.3367,0.3370,0.3373,
     & 0.3376,0.3378,0.3381,0.3383,0.3385,0.3387,0.3389,0.3391,0.3393,
     & 0.3394,0.3396,0.3397,0.3398,0.3399,0.3400,0.3401,0.3402,0.3402,
     & 0.3403,0.3404,0.3404,0.3404,0.3405,0.3405,0.3405,0.3405,0.3405,
     & 0.3405,0.3405,0.3405,0.3405,0.3405,0.3405,0.3405,0.3405,0.3405,
     & 0.3405,0.3405,0.3405,0.3405,0.3405,0.3405,0.3405,0.3405,0.3405,
     & 0.3405,0.3405/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SC;hw;pulp
C SubRegion index I = 1
C  DataType index K = 1 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      DATA (FAPROP(1,J,1,1,2), J= 1,101) /
     & 0.5808,0.5130,0.4553,0.4063,0.3647,0.3292,0.2976,0.2699,0.2442,
     & 0.2208,0.2008,0.1845,0.1713,0.1608,0.1524,0.1456,0.1400,0.1353,
     & 0.1314,0.1277,0.1246,0.1220,0.1199,0.1179,0.1162,0.1146,0.1130,
     & 0.1116,0.1102,0.1088,0.1075,0.1063,0.1051,0.1039,0.1027,0.1016,
     & 0.1005,0.0994,0.0984,0.0974,0.0963,0.0954,0.0944,0.0934,0.0925,
     & 0.0916,0.0906,0.0898,0.0889,0.0880,0.0872,0.0863,0.0855,0.0847,
     & 0.0839,0.0831,0.0823,0.0815,0.0808,0.0800,0.0793,0.0786,0.0779,
     & 0.0771,0.0765,0.0758,0.0751,0.0744,0.0738,0.0731,0.0725,0.0718,
     & 0.0712,0.0706,0.0699,0.0693,0.0687,0.0681,0.0676,0.0670,0.0664,
     & 0.0658,0.0653,0.0647,0.0642,0.0636,0.0631,0.0626,0.0620,0.0615,
     & 0.0610,0.0605,0.0600,0.0595,0.0590,0.0585,0.0580,0.0576,0.0571,
     & 0.0566,0.0562/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SC;hw;pulp
C SubRegion index I = 1
C  DataType index K = 2 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      DATA (FAPROP(1,J,2,1,2), J= 1,101) /
     & 0.0000,0.0233,0.0427,0.0587,0.0718,0.0826,0.0919,0.0996,0.1066,
     & 0.1126,0.1175,0.1210,0.1235,0.1250,0.1259,0.1263,0.1264,0.1261,
     & 0.1257,0.1253,0.1248,0.1241,0.1234,0.1226,0.1219,0.1212,0.1205,
     & 0.1198,0.1192,0.1186,0.1181,0.1176,0.1171,0.1167,0.1162,0.1159,
     & 0.1155,0.1152,0.1149,0.1146,0.1144,0.1142,0.1140,0.1138,0.1137,
     & 0.1136,0.1134,0.1134,0.1133,0.1132,0.1132,0.1132,0.1131,0.1131,
     & 0.1132,0.1132,0.1132,0.1133,0.1133,0.1134,0.1134,0.1135,0.1136,
     & 0.1137,0.1138,0.1139,0.1140,0.1142,0.1143,0.1144,0.1146,0.1147,
     & 0.1148,0.1150,0.1151,0.1153,0.1154,0.1156,0.1158,0.1159,0.1161,
     & 0.1163,0.1164,0.1166,0.1168,0.1170,0.1171,0.1173,0.1175,0.1177,
     & 0.1178,0.1180,0.1182,0.1184,0.1186,0.1187,0.1189,0.1191,0.1193,
     & 0.1195,0.1197/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SC;hw;pulp
C SubRegion index I = 1
C  DataType index K = 3 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      DATA (FAPROP(1,J,3,1,2), J= 1,101) /
     & 0.2284,0.2493,0.2682,0.2845,0.2985,0.3105,0.3212,0.3307,0.3396,
     & 0.3477,0.3547,0.3605,0.3652,0.3691,0.3722,0.3747,0.3768,0.3786,
     & 0.3801,0.3815,0.3826,0.3836,0.3844,0.3851,0.3858,0.3863,0.3868,
     & 0.3873,0.3877,0.3881,0.3885,0.3888,0.3891,0.3893,0.3896,0.3898,
     & 0.3900,0.3901,0.3903,0.3904,0.3905,0.3906,0.3907,0.3908,0.3909,
     & 0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,
     & 0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,
     & 0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,
     & 0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,
     & 0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,
     & 0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,0.3909,
     & 0.3909,0.3909/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SC;hw;saw
C SubRegion index I = 1
C  DataType index K = 1 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      DATA (FAPROP(1,J,1,2,2), J= 1,101) /
     & 0.5872,0.5427,0.5034,0.4683,0.4369,0.4088,0.3831,0.3598,0.3383,
     & 0.3185,0.3006,0.2845,0.2700,0.2570,0.2452,0.2345,0.2247,0.2156,
     & 0.2072,0.1994,0.1921,0.1853,0.1790,0.1730,0.1674,0.1621,0.1571,
     & 0.1524,0.1479,0.1436,0.1395,0.1356,0.1319,0.1283,0.1249,0.1217,
     & 0.1186,0.1156,0.1127,0.1099,0.1072,0.1047,0.1022,0.0998,0.0975,
     & 0.0953,0.0931,0.0910,0.0890,0.0871,0.0852,0.0834,0.0816,0.0799,
     & 0.0782,0.0766,0.0750,0.0735,0.0720,0.0706,0.0692,0.0678,0.0665,
     & 0.0652,0.0639,0.0627,0.0615,0.0604,0.0592,0.0581,0.0571,0.0560,
     & 0.0550,0.0540,0.0530,0.0521,0.0512,0.0503,0.0494,0.0485,0.0477,
     & 0.0468,0.0460,0.0453,0.0445,0.0437,0.0430,0.0423,0.0416,0.0409,
     & 0.0402,0.0396,0.0389,0.0383,0.0377,0.0371,0.0365,0.0359,0.0353,
     & 0.0348,0.0342/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SC;hw;saw
C SubRegion index I = 1
C  DataType index K = 2 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      DATA (FAPROP(1,J,2,2,2), J= 1,101) /
     & 0.0000,0.0243,0.0455,0.0644,0.0811,0.0961,0.1095,0.1215,0.1324,
     & 0.1422,0.1510,0.1589,0.1658,0.1720,0.1775,0.1824,0.1869,0.1909,
     & 0.1945,0.1979,0.2009,0.2037,0.2062,0.2085,0.2107,0.2126,0.2144,
     & 0.2161,0.2177,0.2192,0.2205,0.2218,0.2230,0.2241,0.2252,0.2262,
     & 0.2271,0.2280,0.2289,0.2297,0.2305,0.2312,0.2319,0.2325,0.2332,
     & 0.2338,0.2344,0.2350,0.2355,0.2360,0.2365,0.2370,0.2375,0.2380,
     & 0.2384,0.2389,0.2393,0.2397,0.2401,0.2405,0.2409,0.2412,0.2416,
     & 0.2420,0.2423,0.2427,0.2430,0.2433,0.2436,0.2440,0.2443,0.2446,
     & 0.2449,0.2452,0.2454,0.2457,0.2460,0.2463,0.2465,0.2468,0.2471,
     & 0.2473,0.2476,0.2478,0.2481,0.2483,0.2485,0.2488,0.2490,0.2492,
     & 0.2494,0.2496,0.2499,0.2501,0.2503,0.2505,0.2507,0.2509,0.2511,
     & 0.2513,0.2514/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SC;hw;saw
C SubRegion index I = 1
C  DataType index K = 3 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      DATA (FAPROP(1,J,3,2,2), J= 1,101) /
     & 0.2371,0.2473,0.2567,0.2653,0.2730,0.2799,0.2863,0.2921,0.2976,
     & 0.3027,0.3074,0.3116,0.3153,0.3187,0.3218,0.3246,0.3272,0.3296,
     & 0.3318,0.3340,0.3359,0.3378,0.3395,0.3412,0.3427,0.3442,0.3456,
     & 0.3469,0.3482,0.3494,0.3505,0.3516,0.3527,0.3537,0.3546,0.3555,
     & 0.3564,0.3572,0.3580,0.3588,0.3595,0.3602,0.3609,0.3615,0.3621,
     & 0.3627,0.3632,0.3637,0.3642,0.3647,0.3652,0.3656,0.3660,0.3664,
     & 0.3668,0.3671,0.3675,0.3678,0.3681,0.3684,0.3686,0.3689,0.3691,
     & 0.3694,0.3696,0.3698,0.3700,0.3702,0.3703,0.3705,0.3706,0.3708,
     & 0.3709,0.3710,0.3711,0.3713,0.3713,0.3714,0.3715,0.3716,0.3716,
     & 0.3717,0.3718,0.3718,0.3718,0.3719,0.3719,0.3719,0.3719,0.3719,
     & 0.3719,0.3719,0.3719,0.3719,0.3719,0.3719,0.3719,0.3719,0.3719,
     & 0.3719,0.3719/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SE;sw;pulp
C SubRegion index I = 2
C  DataType index K = 1 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      DATA (FAPROP(2,J,1,1,1), J= 1,101) /
     & 0.5533,0.4820,0.4216,0.3704,0.3269,0.2900,0.2572,0.2286,0.2020,
     & 0.1780,0.1575,0.1408,0.1276,0.1171,0.1088,0.1023,0.0970,0.0927,
     & 0.0892,0.0858,0.0831,0.0810,0.0792,0.0778,0.0765,0.0753,0.0741,
     & 0.0731,0.0721,0.0712,0.0703,0.0695,0.0686,0.0678,0.0671,0.0663,
     & 0.0656,0.0649,0.0642,0.0635,0.0628,0.0621,0.0615,0.0609,0.0602,
     & 0.0596,0.0590,0.0584,0.0578,0.0573,0.0567,0.0562,0.0556,0.0551,
     & 0.0545,0.0540,0.0535,0.0530,0.0525,0.0520,0.0515,0.0511,0.0506,
     & 0.0501,0.0497,0.0492,0.0488,0.0483,0.0479,0.0475,0.0470,0.0466,
     & 0.0462,0.0458,0.0454,0.0450,0.0446,0.0442,0.0438,0.0434,0.0431,
     & 0.0427,0.0423,0.0420,0.0416,0.0413,0.0409,0.0406,0.0402,0.0399,
     & 0.0395,0.0392,0.0389,0.0386,0.0382,0.0379,0.0376,0.0373,0.0370,
     & 0.0367,0.0364/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SE;sw;pulp
C SubRegion index I = 2
C  DataType index K = 2 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      DATA (FAPROP(2,J,2,1,1), J= 1,101) /
     & 0.0000,0.0242,0.0441,0.0605,0.0739,0.0849,0.0942,0.1019,0.1088,
     & 0.1147,0.1194,0.1227,0.1249,0.1261,0.1267,0.1267,0.1264,0.1257,
     & 0.1249,0.1242,0.1233,0.1222,0.1211,0.1200,0.1190,0.1179,0.1169,
     & 0.1159,0.1150,0.1141,0.1133,0.1125,0.1118,0.1110,0.1104,0.1098,
     & 0.1092,0.1086,0.1081,0.1076,0.1072,0.1067,0.1063,0.1060,0.1056,
     & 0.1053,0.1050,0.1048,0.1045,0.1043,0.1041,0.1039,0.1037,0.1036,
     & 0.1034,0.1033,0.1032,0.1031,0.1030,0.1029,0.1029,0.1028,0.1028,
     & 0.1027,0.1027,0.1027,0.1027,0.1027,0.1027,0.1027,0.1027,0.1027,
     & 0.1028,0.1028,0.1029,0.1029,0.1030,0.1030,0.1031,0.1031,0.1032,
     & 0.1033,0.1034,0.1034,0.1035,0.1036,0.1037,0.1038,0.1038,0.1039,
     & 0.1040,0.1041,0.1042,0.1043,0.1044,0.1045,0.1046,0.1047,0.1048,
     & 0.1049,0.1050/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SE;sw;pulp
C SubRegion index I = 2
C  DataType index K = 3 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      DATA (FAPROP(2,J,3,1,1), J= 1,101) /
     & 0.2760,0.3003,0.3228,0.3420,0.3585,0.3727,0.3853,0.3965,0.4069,
     & 0.4165,0.4247,0.4314,0.4369,0.4412,0.4448,0.4476,0.4500,0.4519,
     & 0.4535,0.4550,0.4562,0.4572,0.4580,0.4587,0.4593,0.4599,0.4603,
     & 0.4607,0.4611,0.4614,0.4617,0.4619,0.4621,0.4623,0.4625,0.4626,
     & 0.4627,0.4628,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,
     & 0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,
     & 0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,
     & 0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,
     & 0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,
     & 0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,
     & 0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,0.4629,
     & 0.4629,0.4629/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SE;sw;saw
C SubRegion index I = 2
C  DataType index K = 1 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      DATA (FAPROP(2,J,1,2,1), J= 1,101) /
     & 0.6365,0.6013,0.5696,0.5413,0.5160,0.4931,0.4721,0.4528,0.4347,
     & 0.4177,0.4023,0.3884,0.3759,0.3645,0.3542,0.3447,0.3359,0.3276,
     & 0.3199,0.3125,0.3055,0.2990,0.2927,0.2868,0.2811,0.2757,0.2704,
     & 0.2654,0.2605,0.2558,0.2512,0.2469,0.2426,0.2385,0.2345,0.2307,
     & 0.2269,0.2233,0.2198,0.2163,0.2130,0.2098,0.2066,0.2036,0.2006,
     & 0.1977,0.1949,0.1921,0.1894,0.1868,0.1843,0.1818,0.1793,0.1770,
     & 0.1746,0.1724,0.1702,0.1680,0.1659,0.1638,0.1617,0.1597,0.1578,
     & 0.1559,0.1540,0.1522,0.1504,0.1486,0.1469,0.1452,0.1435,0.1419,
     & 0.1403,0.1387,0.1371,0.1356,0.1341,0.1326,0.1312,0.1298,0.1284,
     & 0.1270,0.1256,0.1243,0.1230,0.1217,0.1204,0.1192,0.1179,0.1167,
     & 0.1155,0.1143,0.1132,0.1120,0.1109,0.1098,0.1087,0.1076,0.1066,
     & 0.1055,0.1045/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SE;sw;saw
C SubRegion index I = 2
C  DataType index K = 2 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      DATA (FAPROP(2,J,2,2,1), J= 1,101) /
     & 0.0000,0.0167,0.0317,0.0452,0.0573,0.0681,0.0780,0.0871,0.0954,
     & 0.1032,0.1102,0.1165,0.1222,0.1273,0.1320,0.1363,0.1402,0.1438,
     & 0.1472,0.1505,0.1535,0.1563,0.1589,0.1614,0.1638,0.1660,0.1682,
     & 0.1702,0.1722,0.1741,0.1758,0.1776,0.1792,0.1808,0.1823,0.1838,
     & 0.1852,0.1866,0.1880,0.1892,0.1905,0.1917,0.1929,0.1940,0.1951,
     & 0.1962,0.1972,0.1982,0.1992,0.2002,0.2011,0.2020,0.2029,0.2038,
     & 0.2047,0.2055,0.2063,0.2071,0.2079,0.2087,0.2095,0.2102,0.2109,
     & 0.2117,0.2124,0.2131,0.2137,0.2144,0.2151,0.2157,0.2164,0.2170,
     & 0.2176,0.2182,0.2188,0.2194,0.2200,0.2206,0.2212,0.2217,0.2223,
     & 0.2228,0.2234,0.2239,0.2245,0.2250,0.2255,0.2260,0.2265,0.2270,
     & 0.2275,0.2280,0.2285,0.2289,0.2294,0.2299,0.2303,0.2308,0.2312,
     & 0.2317,0.2321/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SE;sw;saw
C SubRegion index I = 2
C  DataType index K = 3 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 1 (1=Soft;  2=Hard)

      DATA (FAPROP(2,J,3,2,1), J= 1,101) /
     & 0.2599,0.2696,0.2795,0.2883,0.2961,0.3031,0.3095,0.3154,0.3209,
     & 0.3261,0.3308,0.3349,0.3385,0.3417,0.3446,0.3471,0.3495,0.3516,
     & 0.3536,0.3555,0.3572,0.3589,0.3604,0.3618,0.3632,0.3644,0.3657,
     & 0.3668,0.3680,0.3690,0.3700,0.3710,0.3719,0.3728,0.3736,0.3744,
     & 0.3752,0.3759,0.3766,0.3773,0.3779,0.3785,0.3791,0.3796,0.3801,
     & 0.3806,0.3810,0.3815,0.3819,0.3823,0.3826,0.3830,0.3833,0.3836,
     & 0.3839,0.3841,0.3844,0.3846,0.3848,0.3850,0.3852,0.3853,0.3855,
     & 0.3856,0.3858,0.3859,0.3860,0.3861,0.3861,0.3862,0.3862,0.3863,
     & 0.3863,0.3863,0.3864,0.3864,0.3864,0.3864,0.3864,0.3864,0.3864,
     & 0.3864,0.3864,0.3864,0.3864,0.3864,0.3864,0.3864,0.3864,0.3864,
     & 0.3864,0.3864,0.3864,0.3864,0.3864,0.3864,0.3864,0.3864,0.3864,
     & 0.3864,0.3864/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SE;hw;pulp
C SubRegion index I = 2
C  DataType index K = 1 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      DATA (FAPROP(2,J,1,1,2), J= 1,101) /
     & 0.5907,0.5240,0.4674,0.4192,0.3781,0.3431,0.3119,0.2845,0.2591,
     & 0.2360,0.2162,0.1999,0.1868,0.1763,0.1678,0.1609,0.1552,0.1504,
     & 0.1463,0.1425,0.1392,0.1365,0.1342,0.1321,0.1301,0.1284,0.1267,
     & 0.1250,0.1235,0.1220,0.1206,0.1192,0.1178,0.1165,0.1152,0.1139,
     & 0.1127,0.1115,0.1103,0.1092,0.1080,0.1069,0.1058,0.1048,0.1037,
     & 0.1027,0.1016,0.1006,0.0996,0.0987,0.0977,0.0968,0.0959,0.0949,
     & 0.0940,0.0932,0.0923,0.0914,0.0906,0.0897,0.0889,0.0881,0.0873,
     & 0.0865,0.0857,0.0849,0.0842,0.0834,0.0827,0.0819,0.0812,0.0805,
     & 0.0798,0.0791,0.0784,0.0777,0.0771,0.0764,0.0757,0.0751,0.0744,
     & 0.0738,0.0732,0.0726,0.0719,0.0713,0.0707,0.0701,0.0695,0.0690,
     & 0.0684,0.0678,0.0673,0.0667,0.0662,0.0656,0.0651,0.0645,0.0640,
     & 0.0635,0.0630/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SE;hw;pulp
C SubRegion index I = 2
C  DataType index K = 2 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      DATA (FAPROP(2,J,2,1,2), J= 1,101) /
     & 0.0000,0.0230,0.0422,0.0580,0.0711,0.0819,0.0911,0.0989,0.1059,
     & 0.1120,0.1169,0.1205,0.1231,0.1247,0.1258,0.1263,0.1265,0.1264,
     & 0.1261,0.1259,0.1255,0.1249,0.1243,0.1237,0.1231,0.1225,0.1220,
     & 0.1214,0.1209,0.1204,0.1200,0.1196,0.1192,0.1188,0.1185,0.1182,
     & 0.1180,0.1177,0.1175,0.1173,0.1172,0.1170,0.1169,0.1168,0.1167,
     & 0.1167,0.1166,0.1166,0.1166,0.1166,0.1166,0.1167,0.1167,0.1168,
     & 0.1168,0.1169,0.1170,0.1171,0.1172,0.1173,0.1174,0.1176,0.1177,
     & 0.1178,0.1180,0.1181,0.1183,0.1185,0.1186,0.1188,0.1190,0.1192,
     & 0.1193,0.1195,0.1197,0.1199,0.1201,0.1203,0.1205,0.1207,0.1209,
     & 0.1211,0.1213,0.1215,0.1217,0.1219,0.1221,0.1223,0.1225,0.1228,
     & 0.1230,0.1232,0.1234,0.1236,0.1238,0.1240,0.1242,0.1244,0.1246,
     & 0.1248,0.1251/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SE;hw;pulp
C SubRegion index I = 2
C  DataType index K = 3 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 1 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      DATA (FAPROP(2,J,3,1,2), J= 1,101) /
     & 0.2247,0.2447,0.2632,0.2791,0.2928,0.3045,0.3151,0.3243,0.3331,
     & 0.3410,0.3479,0.3536,0.3583,0.3620,0.3651,0.3676,0.3697,0.3715,
     & 0.3729,0.3744,0.3755,0.3765,0.3774,0.3781,0.3787,0.3793,0.3799,
     & 0.3803,0.3808,0.3812,0.3816,0.3819,0.3822,0.3825,0.3828,0.3830,
     & 0.3833,0.3835,0.3836,0.3838,0.3840,0.3841,0.3842,0.3843,0.3844,
     & 0.3845,0.3845,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,
     & 0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,
     & 0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,
     & 0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,
     & 0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,
     & 0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,0.3846,
     & 0.3846,0.3846/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SE;hw;saw
C SubRegion index I = 2
C  DataType index K = 1 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      DATA (FAPROP(2,J,1,2,2), J= 1,101) /
     & 0.6092,0.5650,0.5259,0.4908,0.4592,0.4308,0.4048,0.3811,0.3593,
     & 0.3391,0.3208,0.3042,0.2893,0.2757,0.2633,0.2520,0.2416,0.2320,
     & 0.2230,0.2146,0.2068,0.1996,0.1927,0.1863,0.1803,0.1746,0.1692,
     & 0.1640,0.1592,0.1545,0.1501,0.1459,0.1419,0.1380,0.1343,0.1308,
     & 0.1274,0.1242,0.1210,0.1180,0.1152,0.1124,0.1097,0.1071,0.1046,
     & 0.1022,0.0999,0.0977,0.0955,0.0934,0.0914,0.0894,0.0875,0.0856,
     & 0.0838,0.0821,0.0804,0.0788,0.0772,0.0756,0.0741,0.0726,0.0712,
     & 0.0698,0.0685,0.0672,0.0659,0.0646,0.0634,0.0623,0.0611,0.0600,
     & 0.0589,0.0578,0.0568,0.0558,0.0548,0.0538,0.0528,0.0519,0.0510,
     & 0.0501,0.0493,0.0484,0.0476,0.0468,0.0460,0.0453,0.0445,0.0438,
     & 0.0430,0.0423,0.0417,0.0410,0.0403,0.0397,0.0390,0.0384,0.0378,
     & 0.0372,0.0366/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SE;hw;saw
C SubRegion index I = 2
C  DataType index K = 2 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      DATA (FAPROP(2,J,2,2,2), J= 1,101) /
     & 0.0000,0.0248,0.0466,0.0661,0.0835,0.0990,0.1130,0.1256,0.1370,
     & 0.1473,0.1566,0.1649,0.1723,0.1790,0.1850,0.1903,0.1952,0.1996,
     & 0.2036,0.2073,0.2107,0.2138,0.2166,0.2192,0.2216,0.2238,0.2259,
     & 0.2278,0.2296,0.2313,0.2328,0.2343,0.2356,0.2369,0.2381,0.2392,
     & 0.2403,0.2413,0.2423,0.2432,0.2441,0.2449,0.2457,0.2465,0.2472,
     & 0.2479,0.2485,0.2492,0.2498,0.2504,0.2510,0.2515,0.2521,0.2526,
     & 0.2531,0.2536,0.2540,0.2545,0.2550,0.2554,0.2558,0.2562,0.2566,
     & 0.2570,0.2574,0.2578,0.2582,0.2585,0.2589,0.2592,0.2596,0.2599,
     & 0.2602,0.2605,0.2609,0.2612,0.2615,0.2618,0.2620,0.2623,0.2626,
     & 0.2629,0.2632,0.2634,0.2637,0.2639,0.2642,0.2645,0.2647,0.2649,
     & 0.2652,0.2654,0.2656,0.2659,0.2661,0.2663,0.2665,0.2667,0.2669,
     & 0.2671,0.2673/

C DATA Statement Debug Information
C         Variant   = SN
C        Interval   = 1 yrs
C      Field tags   = SE;hw;saw
C SubRegion index I = 2
C  DataType index K = 3 (1=InUse; 2=Landfill; 3=Energy)
C  Pulp/Saw index M = 2 (1=Pulp;  2=Saw)
C     Sw/Hw index N = 2 (1=Soft;  2=Hard)

      DATA (FAPROP(2,J,3,2,2), J= 1,101) /
     & 0.2247,0.2343,0.2433,0.2515,0.2590,0.2657,0.2720,0.2777,0.2831,
     & 0.2881,0.2927,0.2969,0.3007,0.3041,0.3072,0.3101,0.3128,0.3153,
     & 0.3176,0.3199,0.3219,0.3239,0.3257,0.3274,0.3291,0.3306,0.3321,
     & 0.3336,0.3349,0.3362,0.3374,0.3386,0.3397,0.3408,0.3418,0.3428,
     & 0.3437,0.3446,0.3455,0.3463,0.3471,0.3479,0.3486,0.3493,0.3499,
     & 0.3505,0.3511,0.3517,0.3523,0.3528,0.3533,0.3537,0.3542,0.3546,
     & 0.3550,0.3554,0.3558,0.3562,0.3565,0.3568,0.3571,0.3574,0.3577,
     & 0.3580,0.3582,0.3585,0.3587,0.3589,0.3591,0.3593,0.3594,0.3596,
     & 0.3598,0.3599,0.3600,0.3602,0.3603,0.3604,0.3605,0.3606,0.3607,
     & 0.3608,0.3608,0.3609,0.3609,0.3610,0.3610,0.3611,0.3611,0.3611,
     & 0.3612,0.3612,0.3612,0.3612,0.3612,0.3612,0.3612,0.3612,0.3612,
     & 0.3612,0.3612/

      END
