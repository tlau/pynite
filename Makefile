CPPARGS=-Wno-format-security
PRIMESENSE=/home/tlau/apps/primesense
NITELIB=$(PRIMESENSE)/NiTE-2.0.0/Redist
OPENNILIB=$(PRIMESENSE)/OpenNI-2.1.0-x64/Redist
LIBDIR=-L$(NITELIB) -L$(OPENNILIB)
LINK_ARGS=-Wl,-rpath -Wl,$(NITELIB):$(OPENNILIB)
LIBS=-lOpenNI2 -lNiTE2

all:
	swig -c++ -python nite.i
	g++ $(CPPARGS) -fpic -c -I/usr/include/python2.7 -I/home/tlau/apps/primesense/NiTE-2.0.0/Include -I/home/tlau/apps/primesense/OpenNI-2.1.0-x64/Include nite_wrap.cxx
	g++ -shared nite_wrap.o $(LIBDIR) -o _nite.so $(LIBS) $(LINK_ARGS)
