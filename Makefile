.PHONY: run sim

run: TUIO_Simulator TUIO
	@echo "1. Copy TUIO to libraries dir, eg:"
	@echo "    cp -r TUIO/ ~/sketchbook/libraries/"
	@echo "2. Install the video library in processing:"
	@echo "    Sketch -> Import Library -> Add Library: Video"
	@echo "3. Copy video 'example.mp4' to a folder here named 'data'"
	@echo "4. Copy background image 'bg.jpg' to the same folder"
	@echo "5. Adjust the size() in the sketch to match background image dimensions"
	@echo "6. Run 'make sim' to start simulator"

sim: TUIO_Simulator
	cd TUIO_Simulator; java -jar TuioSimulator.jar &

TUIO_Simulator:
	curl -O -L https://sourceforge.net/projects/reactivision/files/TUIO%201.0/TUIO-Clients%201.4/TUIO_Simulator-1.4.zip
	unzip TUIO_Simulator-1.4.zip

TUIO:
	curl -L -O http://prdownloads.sourceforge.net/reactivision/TUIO11_Processing-1.1.5.zip
	unzip TUIO11_Processing-1.1.5.zip
