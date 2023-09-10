.PHONY: all clean

all: 
	cd libcs50 && make
	cd support && make
	cd server && make
	cd client && make

clean:
	cd server && make clean
	cd client && make clean
	cd libcs50 && make clean
	cd support && make clean
	rm -rf logging_output.txt