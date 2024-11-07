%{

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "calculadora.tab.h" 
#define YYLMAX 100

extern FILE *yyout;
extern int yylineno;
extern int yylex();
/*extern void yyerror(char*);*/
char *value_info_to_str(sym_value_type value);
void printExpr(sym_value_type expresio);
char* concatenarCadenas(sym_value_type s1, sym_value_type s2);

sym_value_type sumar(sym_value_type op1,  sym_value_type op2);
sym_value_type restar(sym_value_type op1,  sym_value_type op2);
sym_value_type invertir_signe(sym_value_type op);
sym_value_type multiplicar(sym_value_type op1, sym_value_type op2);
sym_value_type dividir(sym_value_type op1, sym_value_type op2);
sym_value_type modul(sym_value_type op1, sym_value_type op2);
sym_value_type potencia(sym_value_type op1, sym_value_type op2);

int len_func(char *cadena);
char *substr_func(char *cadena, int ini, int longitud);
char *binari(int num);

%}

%code requires {
	#include "calculadora_funcions.h"
	#include "symtab.h"
}

%union{

	struct{
		char *lexema;
		sym_value_type value;
	} id;
	
	sym_value_type expr;
	
	int entero;
	float real;
	char *cadena;
	bool boolean;

}

%token <id> ID ID_ARITM ID_BOOL
%token <entero> INTEGER 
%token <real> FLOAT
%token <cadena> STRING
%token <boolean> BOOL
%token ASSIGN SUMA RESTA MULT DIV MOD POT
%token MAJOR MENOR MAJOR_IGUAL MENOR_IGUAL IGUAL DIFERENT
%token NOT AND OR
%token FI_SENT ABRIR_PAR CERRAR_PAR
%token SIN COS TAN
%token LEN SUBSTR COMA
%token PI E
%token HEX OCT BIN
 
%type <expr> expresion expr_aritmetica expr_booleana
%type <expr> expre_prec1_arit expre_prec2_arit expre_base_arit
%type <expr>  expre_prec1_booleana expre_prec2_booleana expre_base_booleana

%%

programa: llista_sentencies;

llista_sentencies: llista_sentencies sentencia | sentencia;

sentencia: FI_SENT 
         | expresion FI_SENT { printExpr($1); }
         | assignacio FI_SENT;

assignacio: ID ASSIGN expresion {
                $1.value = $3;
                sym_enter($1.lexema, &$1.value);
                fprintf(yyout, "ID: %s es %s\n", $1.lexema, value_info_to_str($1.value));
            };

expresion: expr_aritmetica | expr_booleana;

expr_aritmetica:
		expre_prec1_arit
		| expr_aritmetica SUMA expre_prec1_arit{
			if ($1.tipus == CADENA || $3.tipus == CADENA) {
				$$.tipus = CADENA;
				$$.valor.cadena = concatenarCadenas($1, $3);
			}
			else {
				$$ = sumar($1, $3);
			}
		}
        | expr_aritmetica RESTA expre_prec1_arit { $$ = restar($1, $3); }
	    | SUMA expre_prec1_arit { $$ = $2; }
		| RESTA expre_prec1_arit { $$ = invertir_signe($2); }
;

expre_prec1_arit: expre_prec2_arit
		| expre_prec1_arit MULT expre_prec2_arit { $$ = multiplicar($1, $3); }
        | expre_prec1_arit DIV expre_prec2_arit { $$ = dividir($1, $3); }
        | expre_prec1_arit MOD expre_prec2_arit { $$ = modul($1, $3); }
;

expre_prec2_arit:
		expre_base_arit 
		| expre_prec2_arit POT expre_base_arit { $$ = potencia($1, $3); }
;

expre_base_arit:		
		ABRIR_PAR expr_aritmetica CERRAR_PAR { $$ = $2; }
        | INTEGER { $$.tipus = ENTERO; $$.valor.entero = $1; }
        | FLOAT { $$.tipus = REAL; $$.valor.real = $1; }
        | STRING { $$.tipus = CADENA; $$.valor.cadena = $1; }
        | ID_ARITM {
            sym_lookup($1.lexema, &$1.value);
            $$.tipus = $1.value.tipus;
            $$.valor = $1.value.valor;
        }
		| SIN ABRIR_PAR expr_aritmetica CERRAR_PAR {
			$$.tipus = REAL;
			$$.valor.real = sin(($3.tipus == ENTERO) ? (float)$3.valor.entero : $3.valor.real);
		}
		| COS ABRIR_PAR expr_aritmetica CERRAR_PAR {
			$$.tipus = REAL;
			$$.valor.real = cos(($3.tipus == ENTERO) ? (float)$3.valor.entero : $3.valor.real); 
		}
		| TAN ABRIR_PAR expr_aritmetica CERRAR_PAR {
			$$.tipus = REAL;
			$$.valor.real = tan(($3.tipus == ENTERO) ? (float)$3.valor.entero : $3.valor.real);
		}
		| LEN ABRIR_PAR expr_aritmetica CERRAR_PAR {
			$$.tipus = ENTERO;
			$$.valor.entero = len_func($3.valor.cadena);
		}
		| SUBSTR ABRIR_PAR expr_aritmetica COMA INTEGER COMA INTEGER CERRAR_PAR {
			$$.tipus = CADENA;
			$$.valor.cadena = substr_func($3.valor.cadena, $5, $7); 
		}
		| PI {
			$$.tipus = REAL;
			$$.valor.real = M_PI;
		}
		| E {
			$$.tipus = REAL;
			$$.valor.real = M_E;
		}
		| HEX ABRIR_PAR expr_aritmetica CERRAR_PAR {
			$$.tipus = CADENA;
			$$.valor.cadena = (char *)malloc(sizeof(char) * 9);
			sprintf($$.valor.cadena, "%X", $3.valor.entero);
		}
		| OCT ABRIR_PAR expr_aritmetica CERRAR_PAR {
			$$.tipus = CADENA;
			$$.valor.cadena = (char *)malloc(sizeof(char) * 12);
			sprintf($$.valor.cadena, "%o", $3.valor.entero);
		}
		| BIN ABRIR_PAR expr_aritmetica CERRAR_PAR {
			$$.tipus = CADENA;
			$$.valor.cadena = binari($3.valor.entero);
		}
		
;			   
expr_booleana: expre_prec1_booleana
		| expr_booleana OR expre_prec1_booleana { 
			$$.tipus = BOOLEAN;
			$$.valor.boolean = $1.valor.boolean || $3.valor.boolean;
		}
;

expre_prec1_booleana: expre_prec2_booleana
		| expre_prec1_booleana AND expre_prec2_booleana {
			$$.tipus = BOOLEAN;
			$$.valor.boolean = $1.valor.boolean && $3.valor.boolean;
		}
;

expre_prec2_booleana: expre_base_booleana
		| NOT expre_prec2_booleana {
			$$.tipus = BOOLEAN;
			$$.valor.boolean = !($2.valor.boolean);
		}
;

expre_base_booleana:
		ABRIR_PAR expr_booleana CERRAR_PAR { $$ = $2 }
		| BOOL {
			$$.tipus = BOOLEAN;
			$$.valor.boolean = $1; 
		}
		| ID_BOOL {
			sym_lookup($1.lexema, &$1.value); 
			$$.tipus = $1.value.tipus;
			$$.valor = $1.value.valor;
		}
		| expr_aritmetica MAJOR expr_aritmetica {
			$$.tipus = BOOLEAN;
			if (($1.tipus == ENTERO) && ($3.tipus == ENTERO)) $$.valor.boolean = $1.valor.entero > $3.valor.entero;
			else if (($1.tipus == REAL) && ($3.tipus == REAL)) $$.valor.boolean = $1.valor.real > $3.valor.real;
			else if (($1.tipus == ENTERO) && ($3.tipus == REAL)) $$.valor.boolean = $1.valor.entero > $3.valor.real;
			else if (($1.tipus == REAL) && ($3.tipus == ENTERO)) $$.valor.boolean = $1.valor.real > $3.valor.entero;
			else yyerror("Només es poden realitzar operacions boolenas sobre enters i reals"); 
		}
		| expr_aritmetica MENOR expr_aritmetica {
			$$.tipus = BOOLEAN;
			if (($1.tipus == ENTERO) && ($3.tipus == ENTERO)) $$.valor.boolean = $1.valor.entero < $3.valor.entero;
			else if (($1.tipus == REAL) && ($3.tipus == REAL)) $$.valor.boolean = $1.valor.real < $3.valor.real;
			else if (($1.tipus == ENTERO) && ($3.tipus == REAL)) $$.valor.boolean = $1.valor.entero < $3.valor.real;
			else if (($1.tipus == REAL) && ($3.tipus == ENTERO)) $$.valor.boolean = $1.valor.real < $3.valor.entero;
			else yyerror("Només es poden realitzar operacions boolenas sobre enters i reals"); 
		}
		| expr_aritmetica MAJOR_IGUAL expr_aritmetica {
			$$.tipus = BOOLEAN;
			if (($1.tipus == ENTERO) && ($3.tipus == ENTERO)) $$.valor.boolean = $1.valor.entero >= $3.valor.entero;
			else if (($1.tipus == REAL) && ($3.tipus == REAL)) $$.valor.boolean = $1.valor.real >= $3.valor.real;
			else if (($1.tipus == ENTERO) && ($3.tipus == REAL)) $$.valor.boolean = $1.valor.entero >= $3.valor.real;
			else if (($1.tipus == REAL) && ($3.tipus == ENTERO)) $$.valor.boolean = $1.valor.real >= $3.valor.entero;
			else yyerror("Només es poden realitzar operacions boolenas sobre enters i reals"); 
		}
		| expr_aritmetica MENOR_IGUAL expr_aritmetica {
			$$.tipus = BOOLEAN;
			if (($1.tipus == ENTERO) && ($3.tipus == ENTERO)) $$.valor.boolean = $1.valor.entero <= $3.valor.entero;
			else if (($1.tipus == REAL) && ($3.tipus == REAL)) $$.valor.boolean = $1.valor.real <= $3.valor.real;
			else if (($1.tipus == ENTERO) && ($3.tipus == REAL)) $$.valor.boolean = $1.valor.entero <= $3.valor.real;
			else if (($1.tipus == REAL) && ($3.tipus == ENTERO)) $$.valor.boolean = $1.valor.real <= $3.valor.entero;
			else yyerror("Només es poden realitzar operacions boolenas sobre enters i reals"); 
		}
		| expr_aritmetica IGUAL expr_aritmetica {
			$$.tipus = BOOLEAN;
			if (($1.tipus == ENTERO) && ($3.tipus == ENTERO)) $$.valor.boolean = $1.valor.entero == $3.valor.entero;
			else if (($1.tipus == REAL) && ($3.tipus == REAL)) $$.valor.boolean = $1.valor.real == $3.valor.real;
			else if (($1.tipus == ENTERO) && ($3.tipus == REAL)) $$.valor.boolean = $1.valor.entero == $3.valor.real;
			else if (($1.tipus == REAL) && ($3.tipus == ENTERO)) $$.valor.boolean = $1.valor.real == $3.valor.entero;
			else yyerror("Només es poden realitzar operacions boolenas sobre enters i reals"); 
		}
		| expr_aritmetica DIFERENT expr_aritmetica {
			$$.tipus = BOOLEAN;
			if (($1.tipus == ENTERO) && ($3.tipus == ENTERO)) $$.valor.boolean = $1.valor.entero != $3.valor.entero;
			else if (($1.tipus == REAL) && ($3.tipus == REAL)) $$.valor.boolean = $1.valor.real != $3.valor.real;
			else if (($1.tipus == ENTERO) && ($3.tipus == REAL)) $$.valor.boolean = $1.valor.entero != $3.valor.real;
			else if (($1.tipus == REAL) && ($3.tipus == ENTERO)) $$.valor.boolean = $1.valor.real != $3.valor.entero;
			else yyerror("Només es poden realitzar operacions boolenas sobre enters i reals"); 
		}
;

		
	

%%

char *binari(int num) {
	char *binary = (char *)malloc(sizeof(char) * 33);
	if (binary == NULL) return NULL;
	binary[32] = '\0';
	for (int i=0; i<32; i++){
		binary[31-i] = (num & (1 << i)) ? '1' : '0';
	}
	return binary;
}


int len_func(char *cadena) {
	return strlen(cadena);
}

char *substr_func(char *cadena, int ini, int longitud) {
	int cadena_len = strlen(cadena);
	
	if (ini < 0 || ini >= cadena_len || longitud < 0) {
		fprintf(stderr, "Error: Indexs fora de ran en SUBSTR\n");
		return strdup("");
	}
	
	int max_len = (ini + longitud > cadena_len) ? cadena_len - ini : longitud;
	char *resultat = (char*)malloc((max_len + 1) * sizeof(char));
	strncpy(resultat, cadena + ini, max_len);
	resultat[max_len] = '\0';
	return resultat;
}

char* concatenarCadenas(sym_value_type s1, sym_value_type s2){
	char* buffer;
	int buffer_size;
	
	char *str1;
	switch (s1.tipus) {
		case CADENA:
			str1 = strdup(s1.valor.cadena);
			break;
		case ENTERO:
			buffer_size = snprintf(NULL, 0, "%d", s1.valor.entero);
			str1 = malloc(buffer_size + 1);
			snprintf(str1, buffer_size + 1, "%d", s1.valor.entero);
			break;
		case REAL:
			buffer_size = snprintf(NULL, 0, "%f", s1.valor.real);
			str1 = malloc(buffer_size + 1);
			snprintf(str1, buffer_size + 1, "%f", s1.valor.real);
			break;
		case BOOLEAN:
			str1 = strdup(s1.valor.boolean ? "true" : "false");
			break;
		case UNKNOWN:
			break;
	}
	
	char *str2;
	switch (s2.tipus) {
		case CADENA:
			str2 = strdup(s2.valor.cadena);
			break;
		case ENTERO:
			buffer_size = snprintf(NULL, 0, "%d", s2.valor.entero);
			str2 = malloc(buffer_size + 1);
			snprintf(str2, buffer_size + 1, "%d", s2.valor.entero);
			break;
		case REAL:
			buffer_size = snprintf(NULL, 0, "%f", s2.valor.real);
			str2 = malloc(buffer_size + 1);
			snprintf(str2, buffer_size + 1, "%f", s2.valor.real);
			break;
		case BOOLEAN:
			str2 = strdup(s2.valor.boolean ? "true" : "false");
			break;
		case UNKNOWN:
			break;
	}
	
	buffer_size = strlen(str1) + strlen(str2) + 1;
	buffer = malloc(buffer_size);
	snprintf(buffer, buffer_size, "%s%s", str1, str2);
	
	free(str1);
	free(str2);

	return buffer;
}

sym_value_type sumar(sym_value_type op1, sym_value_type op2) {
	sym_value_type result;
	
	if (op1.tipus == ENTERO && op2.tipus == ENTERO) {
		result.tipus = ENTERO;
		result.valor.entero = op1.valor.entero + op2.valor.entero;
	} else if (op1.tipus == REAL || op2.tipus == REAL) {
		result.tipus = REAL;
		float val1 = (op1.tipus == REAL) ? op1.valor.real : (float)op1.valor.entero;
		float val2 = (op2.tipus == REAL) ? op2.valor.real : (float)op2.valor.entero; 
		result.valor.real = val1 + val2;
	} else {
		result.tipus = UNKNOWN;
	}
	return result;
}

sym_value_type restar(sym_value_type op1,  sym_value_type op2) {
	sym_value_type result;
	
	if (op1.tipus == ENTERO && op2.tipus == ENTERO) {
		result.tipus = ENTERO;
		result.valor.entero = op1.valor.entero - op2.valor.entero;
	} else if (op1.tipus == REAL || op2.tipus == REAL) {
		result.tipus = REAL;
		float val1 = (op1.tipus == REAL) ? op1.valor.real : (float)op1.valor.entero;
		float val2 = (op2.tipus == REAL) ? op2.valor.real : (float)op2.valor.entero;
		result.valor.real = val1 - val2;
	} else {
		result.tipus = UNKNOWN;
	}
	
	return result;
}


sym_value_type invertir_signe(sym_value_type op){
	sym_value_type result;
	
	if (op.tipus == ENTERO) {
		result.tipus = ENTERO;
		result.valor.entero = -op.valor.entero;
	} else if (op.tipus == REAL) {
		result.tipus = REAL;
		result.valor.real = -op.valor.real;
	} else {
		result.tipus = UNKNOWN;
	}
	
	return result;
}

sym_value_type multiplicar(sym_value_type op1, sym_value_type op2){
	sym_value_type result;
	
	if(op1.tipus == ENTERO && op2.tipus == ENTERO) {
		result.tipus = ENTERO;
		result.valor.entero = op1.valor.entero * op2.valor.entero; 
	} else if (op1.tipus == REAL || op2.tipus == REAL) {
		result.tipus = REAL;
		float val1 = (op1.tipus == REAL) ? op1.valor.real : (float)op1.valor.entero;
		float val2 = (op2.tipus == REAL) ? op2.valor.real : (float)op2.valor.entero;
		result.valor.real = val1 * val2;
	} else {
		result.tipus = UNKNOWN;
	}
	
	return result;
}

sym_value_type dividir(sym_value_type op1, sym_value_type op2){
	sym_value_type result;
	
	if ((op2.tipus == ENTERO && op2.valor.entero == 0) || (op2.tipus == REAL && op2.valor.real == 0.0)) {
		fprintf(stderr, "Error: Divisio per 0\n");
		result.tipus = UNKNOWN;
	} else if (op1.tipus == ENTERO && op2.tipus == ENTERO) {
		result.tipus = ENTERO;
		result.valor.entero = op1.valor.entero / op2.valor.entero;
	} else if (op1.tipus == REAL || op2.tipus == REAL) {
        result.tipus = REAL;
        float val1 = (op1.tipus == REAL) ? op1.valor.real : (float)op1.valor.entero;
        float val2 = (op2.tipus == REAL) ? op2.valor.real : (float)op2.valor.entero;
        result.valor.real = val1 / val2;
    } else {
        result.tipus = UNKNOWN;
	}
	
	return result;
}

sym_value_type modul(sym_value_type op1, sym_value_type op2){
	sym_value_type result;
	
	if (op1.tipus == ENTERO && op2.tipus == ENTERO) {
		result.tipus = ENTERO;
		result.valor.entero = op1.valor.entero % op2.valor.entero;
	} else {
		result.tipus = UNKNOWN;
		fprintf(stderr, "Error: El operador modul nomes aplica a enters\n");
	}	
	
	return result;
}

sym_value_type potencia(sym_value_type op1, sym_value_type op2){
	sym_value_type result;
	
	if (op1.tipus == ENTERO && op2.tipus == ENTERO) {
		result.tipus = ENTERO;
		result.valor.entero = pow(op1.valor.entero, op2.valor.entero);
	} else {
		result.tipus = REAL;
		float val1 = (op1.tipus == REAL) ? op1.valor.real : (float)op1.valor.entero;
        float val2 = (op2.tipus == REAL) ? op2.valor.real : (float)op2.valor.entero;
        result.valor.real = pow(val1, val2);
	}
	
	return result;
}



void printExpr(sym_value_type expressio){
	fprintf(yyout, "Expressio: %s\n", value_info_to_str(expressio));
}

char *value_info_to_str(sym_value_type value)
{
	char *buffer = malloc(sizeof(char)*YYLMAX);
	
	switch (value.tipus){
		case 0: sprintf(buffer, "Enter amb valor: %d", value.valor.entero); break;
		case 1: sprintf(buffer, "Real amb valor: %.3f", value.valor.real); break;
		case 2: sprintf(buffer, "Cadena amb valor: %s", value.valor.cadena); break;
		case 3: sprintf(buffer, "Boolea amb valor: %s", value.valor.boolean ? "true" : "false");break;
		default: sprintf(buffer, "Tipus no identificat");
	}
	
	return buffer;
}