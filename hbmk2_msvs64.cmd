rem .\copy_inc.sh

SET HB_QT_MAJOR_VER=5

SET HB_WITH_QT=c:\Qt\5.15.1\msvc2019_64\include\

SET HB_QTPATH=c:\Qt\5.15.1\msvc2019_64\bin\

SET LD_LIBRARY_PATH=c:\Qt\5.15.1\msvc2019_64\lib\

rem SET QTCONTRIBS_REBUILD=yes


SET OLD_PATH=%PATH%

rem c:\MinGW\bin\


SET HB_PLATFORM=win

SET HB_COMPILER=msvc64

rem cd "c:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\"
cd "c:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\"
call vcvarsall.bat x64 10.0.18362.0 -vcvars_ver=14.27 


SET PATH=c:\harbour\bin\;c:\harbour\include\;c:\harbour\lib\win\msvc64\;%PATH%
rem c:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\bin\";

cd c:\dev\qtcontribs


rem copy c:\dev\qtcontribs\hbqt\qtcore\hbqtcore.ch c:\dev\qtcontribs\hbqtwidgets\*.*

rem copy c:\dev\qtcontribs\hbqt\qtcore\hbqtcore.ch c:\dev\qtcontribs\hbxbp\*.*

rem copy c:\dev\qtcontribs\hbqt\qtgui\hbqt_version.ch c:\dev\qtcontribs\hbqtwidgets\*.*

rem copy c:\dev\qtcontribs\hbqt\qtgui\hbqt_version.ch c:\dev\qtcontribs\hbxbp\*.*

rem copy c:\dev\qtcontribs\hbqt\qtgui\hbqtgui.ch c:\dev\qtcontribs\hbqtwidgets\*.*

rem copy c:\dev\qtcontribs\hbqt\qtgui\hbqtgui.ch c:\dev\qtcontribs\hbxbp\*.*

rem copy c:\dev\qtcontribs\hbxbp\xbp.ch c:\dev\qtcontribs\hbide\*.*


hbmk2.exe qtcontribs57.hbp -pic -Lc:\dev\lib\win\msvc64 -Lc:\Qt\5.15.1\msvc2019_64\lib -trace >log.txt



SET PATH=%OLD_PATH%

rem .\copy_libs.sh

rem .\hbide\link.sh

rem -I\usr\include\glib-2.0