LIBDIR = /l/lib/idl/hyades2d
HTTPDIR = /l/web_home

SRC = data__define.pro \
      dim__define.pro \
      h2d__define.pro \
      h2d_gui.pro \
      h2d_shell.pro \
      ncdf_readdata.pro \
      read_h2d.pro \
      irrtv.pro \
      irrgrid.pro

all: install dist

install:
	/usr/um/gnu/bin/cp -f ${SRC} ${LIBDIR}

dist:
	/usr/um/gnu/bin/cp -f ${SRC} ${HTTPDIR}
