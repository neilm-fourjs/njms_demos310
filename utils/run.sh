
export FGLSERVER=`who -m | cut -d'(' -f2 | cut -d')' -f1`

export FGLRESOURCEPATH=../etc
export FGLIMAGEPATH=../pics:../etc/fa5.txt
export FGLPROFILE=../etc/profile
export REPORTDIR=../etc
export DBPRINT=FGLSERVER
export DBDATE=DMY4/
export DBNAME=njm_demo310
export GDCUPDATEDIR=../gdcupdate
export SDIMDI=M
export FJS_GL_DBGLEV=0
export LOGDIR=../../logs
export LANG=en_GB.UTF-8

cd bin
fglrun menu.42r
