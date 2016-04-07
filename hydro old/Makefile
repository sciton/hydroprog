CC=nvcc
PARAMSGL= -lGL -lGLU -lglut
all: hydro

hydro: main.o params.o calCU.o
	$(CC) -o hydro main.o params.o calCU.o $(PARAMSGL)

main.o: main.c definitions.h
	$(CC) -c main.c $(PARAMSGL) -lm

params.o: params.cu
	$(CC) -c params.cu -lm

calCU.o: calCU.cu
	$(CC) -c calCU.cu -lm

clean:
	rm *.o hydro

run: clean all
