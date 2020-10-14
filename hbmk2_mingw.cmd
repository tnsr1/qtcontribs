SET HB_QT_MAJOR_VER=5

SET HB_WITH_QT=c:\Qt\5.10.0\mingw53_32\include\

SET HB_QTPATH=c:\Qt\5.10.0\mingw53_32\bin\

SET LD_LIBRARY_PATH=c:\Qt\5.10.0\mingw53_32\lib\

rem SET QTCONTRIBS_REBUILD=yes


SET OLD_PATH=%PATH%

SET HB_PLATFORM=win

SET HB_COMPILER=mingw

SET HB_USER_CFLAGS=-std=c++11

SET PATH=c:\harbour\bin\;c:\harbour\include\;c:\harbour\lib\win\mingw\;c:\Qt\Tools\mingw530_32\bin\;%PATH%


hbmk2.exe qtcontribs57.hbp -pic -Ic:\Qt\5.10.0\mingw53_32\include\ -Lc:\dev\lib\win\mingw -Lc:\Qt\5.10.0\mingw53_32\lib\ -trace >log.txt



SET PATH=%OLD_PATH%

