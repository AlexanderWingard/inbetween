.PHONY: run


OS := $(shell uname)
ifeq ($(OS), Linux)
  CONDAURL := "https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh"
else ifeq ($(OS), Darwin)
  CONDAURL := "https://repo.continuum.io/miniconda/Miniconda-latest-MacOSX-x86_64.sh"
endif

.PHONY: run sim

run: miniconda/lib/python2.7/site-packages/tuio
	miniconda/bin/python inbetween.py


sim: TUIO_Simulator
	cd TUIO_Simulator; java -jar TuioSimulator.jar &

miniconda/bin/python:
	curl $(CONDAURL) -o miniconda.sh
	chmod a+x miniconda.sh
	./miniconda.sh -b -p ./miniconda
	rm miniconda.sh
	miniconda/bin/conda install -y -c https://conda.anaconda.org/menpo opencv

miniconda/lib/python2.7/site-packages/tuio: miniconda/bin/python
	curl -O http://pytuio.googlecode.com/files/pytuio-0.1.tar.gz
	miniconda/bin/pip install pytuio-0.1.tar.gz


TUIO_Simulator:
	curl -O -L https://sourceforge.net/projects/reactivision/files/TUIO%201.0/TUIO-Clients%201.4/TUIO_Simulator-1.4.zip
	unzip TUIO_Simulator-1.4.zip
