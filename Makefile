######################################################################
#
#                           Compiladors
#
######################################################################

CC = gcc
LEX = flex
YACC = bison
LIB = -lfl

SRC_LEX = calculadora.l
SRC_YACC = calculadora.y

LEX_OUT = lex.yy.c
YACC_OUT_C = calculadora.tab.c
YACC_OUT_H = calculadora.tab.h
YACC_OUT = $(YACC_OUT_C) $(YACC_OUT_H)

OTHERS = calculadora.output
OBJ = *.o

SRC = calculadora_main.c
BIN = calculadora.exe

SRC_EXTRA = calculadora_funcions.c symtab.c

LFLAGS =
YFLAGS = -d -v
CFLAGS = -Wall -g

EG_IN = ex_entrada.txt
EG_OUT = ex_sortida.txt



######################################################################

all : yacc lex
	$(CC) -o $(BIN) $(CFLAGS) $(SRC) $(SRC_EXTRA) $(YACC_OUT_C) $(LEX_OUT)

yacc : $(SRC_YACC)
	$(YACC) $(YFLAGS) $(SRC_YACC)

lex : $(SRC_LEX)
	$(LEX) $(LFLAGS) $(SRC_LEX)

clean :
	rm -f *~ $(BIN) $(OBJ) $(YACC_OUT) $(LEX_OUT) $(OTHERS) $(EG_OUT)

eg : $(EG_IN)
	./$(BIN) $(EG_IN) $(EG_OUT)
	cat $(EG_OUT)
