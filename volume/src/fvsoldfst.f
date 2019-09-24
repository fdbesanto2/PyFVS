      SUBROUTINE FVSOLDFST(ISPC,VN,D,H)
      IMPLICIT NONE
C----------
C VOLUME $Id$
C----------
C
C  FSTGRO COMPUTES CUBIC FOOT VOLUMES FOR TREES WITH (D LT 4 OR H LT 18)
C----------
      INTEGER ISPC
      REAL H,D,VN,TERM1,TERM2,FORM
C
      IF(H .LE. 4.5)THEN
        VN=0.
        GO TO 10
      ENDIF
C
      IF(H .LE. 18.0)THEN
         TERM1=((H-0.9)*(H-0.9)) / ((H-4.5)*(H-4.5))
         TERM2=TERM1*(H-0.9)/(H-4.5)
         FORM=0.406098*TERM1 - 0.0762998*D*TERM2 + 0.00262615*D*H*TERM2
         GO TO 130
      ENDIF
      FORM=0.480961 + 42.46542/(H*H) - 10.99643*D/(H*H)
     &     - 0.107809*D/H - 0.00409083*D
  130 VN=0.005454154*FORM*D*D*H
      IF(VN .LT. 0.0)VN=0.0
   10 CONTINUE
      RETURN
      END