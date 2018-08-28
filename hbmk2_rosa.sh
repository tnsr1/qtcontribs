export HB_QT_MAJOR_VER=5
export HB_WITH_QT=/opt/Qt/5.10.1/gcc_64/include
export HB_QTPATH=/opt/Qt/5.10.1/gcc_64/bin
export LD_LIBRARY_PATH=/opt/Qt/5.10.1/gcc_64/lib
#-std=c++11
export HB_USER_CFLAGS=-std=c++11
#export QTCONTRIBS_REBUILD=yes
#/usr/local/bin/hbmk2 ./qtcontribs57.hbp -pic -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -L../lib/linux/gcc/ -L/opt/Qt/5.10.1/gcc_64/lib >log.txt
/usr/local/bin/hbmk2 ./qtcontribs57.hbp -pic -I/usr/local/share/harbour/addons/hbqt -I/usr/include/glib-2.0 -I/usr/lib64/glib-2.0/include -i/home/alex/workspace/qtcontribs/hbqtwidgets -i/home/alex/workspace/qtcontribs/hbxbp -L/opt/Qt/5.10.1/gcc_64/lib >log.txt
