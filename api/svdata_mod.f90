module svdata_mod
    use prgprm_mod,only: maxtre,maxplt
    implicit none
    !CODE SEGMENT SVDATA
    !----------
    !  **SVDATA   DATE OF LAST REVISION:  03/06/13
    !----------
          INTEGER  MXSVOB
          PARAMETER (MXSVOB=15000)

          INTEGER JSVOUT,JSVPIC,IOBJTP(MXSVOB),NIMAGE,IS2F(MXSVOB), &
                  NSVOBJ,IPLGEM,ISVINV,IMORTCNT,IRPOLES,IDPLOTS,ICOLIDX, &
                  IGRID,IMETRIC
          REAL    XSLOC(MXSVOB),YSLOC(MXSVOB),X1R1S(MAXPLT),X2R2S(MAXPLT), &
                  Y1A1S(MAXPLT),Y2A2S(MAXPLT),SVMSAVE(MAXTRE)
          COMMON /SVDATA/ JSVOUT,JSVPIC,XSLOC,YSLOC,IOBJTP,NIMAGE,IS2F, &
                          NSVOBJ,X1R1S,X2R2S,Y1A1S,Y2A2S,IPLGEM,ISVINV, &
                          SVMSAVE,IMORTCNT,IRPOLES,IDPLOTS,ICOLIDX,IGRID, &
                          IMETRIC
    !
    !     COMMON AREA FOR STAND VISULIZATION (SV) DATA.
    !
    !     JSVOUT= 0 IF NOT USING SV, OTHERWISE IT IS THE FILE NUMBER
    !             USED TO WRITE THE .svs FILES.
    !     JSVPIC= FILE NUMBER USED TO WRITE THE INDEX FILE.
    !     XSLOC = A VECTOR OF X LOCATIONS
    !     YSLOC = A VECTOR OF Y LOCATIONS
    !     NIMAGE= IMAGE SEQUENCE NUMBER.
    !     IOBJTP= A VECTOR THAT DEFINES THE KINDS OF OBJECTS WHERE
    !             0 = THE SLOT IS OPEN
    !             1 = AN FVS TREE, SVS TREE CLASS WILL BE 99 (LIVE)
    !             2 = A SNAG RECORD
    !             3 = A TREE THAT WILL BE REMOVED AT THE END OF THE
    !                 SVOUT.  CURRENTLY A TREE THAT WILL BE REMOVED
    !                 AFTER YARDING.
    !             4 = CWD OBJECT (EXCLUSIVE OF FALLEN SNAGS)
    !             5 = A SNAG THAT WILL BE REMOVED AT THE END OF SVOUT.
    !                 CURRENTLY USED TO FLAG SALVAGED SNAGS.
    !             IOBJTP CANNOT BE A NEGATIVE VALUE, AS BEING NEGATIVE
    !             IS USED TO STORE INFORMATION FOR A SHORT TIME
    !     ICOLIDX=THE COLOR INDEX VALUE, SEE SVGRND FOR DEFINITIONS.
    !     IGRID = THE GRID RESOLUTION FOR THE GROUND FILES (ZERO=NONE MADE).
    !     NSVOBJ= THE NUMBER OF OBJECTS DEFINED.
    !     IS2F  = IF IOBJTP=1,IS2F POINTS TO TREE RECORD.
    !             IF IOBJTP=2,IS2F POINTS TO A SNAG RECORD.
    !             IF IOBJTP=4,IS2F POINTS TO A CWD RECORD.
    !             IF ZERO, THEN THE OBJECT IS ONE OF THE OBJ TYPES,
    !             BUT IT IS NOT REGISTERED WITH A ATTRIBUTE LIST.
    !     X1R1S,X2R2S,Y1A1S,Y2A2S = MAX,MIN COORDINATES FOR RECTANGULAR
    !             PLOTS AND MAX, MIN RADII AND ANGLES FOR CIRCULAR PLOTS
    !     IPLGEM= PLOT GEOMETRY CODE, WHERE
    !            0 = SQUARE ACRE, IGNORE POINT IDENTIFICATIONS
    !            1 = A SUBDIVIDED SQUARE ACRE
    !            2 = ROUND PLOTS, IGNORE PLOT IDENTIFICATIONS
    !            3 = A SUBDIVIDED ROUND ACRE
    !     ISVINV= MAX OF ITRE() OR IPTINV, WHICH EVER IS GREATER
    !     SVMSAVE= STORAGE LIST FOR PREVIOUSLY PROCESSED MORTALITY
    !     IMORTCNT= STORES THE COUNT OF TIMES SVMORT HAS BEEN CALLED THIS CYCLE.
    !     IRPOLES= CONTROLS DRAWING SCALE POLES, 0=NONE, 1=DRAW THEM.
    !     IDPLOTS= CONTROLS DRAWING PLOT BOUNDARIES, 0=NONE, 1=DRAW THEM.
    !     IDPLOTS= CONTROLS DRAWING PLOT BOUNDARIES, 0=NONE, 1=DRAW THEM.
    !     IMETRIC= CONTROLS SENDING METRIC OR IMPERIAL INFO TO SVS,
    !              0= NO (CLASSIC IMPERIAL), 1=YES (METRIC)
    !-----END SEGMENT
end module svdata_mod
