%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "calculadora.tab.h"
#include "calculadora_funcions.h"

%}

%option yylineno
%option noyywrap
%option noinput
%option nounput

%x comment

lletra	[a-zA-Z]
digit	[0-9]
endline "\n"
space [ \t\r]
line_comment "//"
open_block_comment "/*"
close_block_comment "*/"


%%

"("								{ return ABRIR_PAR; }
")"								{ return CERRAR_PAR; }

":=" 							{ return ASSIGN; }
"+" 							{ return SUMA; }
"-" 							{ return RESTA; }
"*"								{ return MULT; }
"/"								{ return DIV; }
"**"							{ return POT; }
"%"								{ return MOD; }

">" 							{ return MAJOR; }
">=" 							{ return MAJOR_IGUAL; }
"<" 							{ return MENOR; }
"<=" 							{ return MENOR_IGUAL; }
"=" 							{ return IGUAL; }
"<>"							{ return DIFERENT; }

"not"							{ return NOT; }
"and"							{ return AND; }
"or"							{ return OR; }

"true"							{
									yylval.boolean = true;
									return BOOL;
								}

"false"							{
									yylval.boolean = false;
									return BOOL;
								}
"PI"							{ return PI; }								
"E"								{ return E; }
"sin"							{ return SIN; }
"cos"							{ return COS; }
"tan"							{ return TAN; }
"LEN"							{ return LEN; }
"SUBSTR"						{ return SUBSTR; }
","								{ return COMA; }
"HEX"							{ return HEX; }
"OCT"							{ return OCT; }
"BIN"							{ return BIN; }

{lletra}({lletra}|{digit})*		{
									sym_value_type valor;
									yylval.id.lexema = (char *)malloc(sizeof(char)*(yyleng +1));
									strncpy(yylval.id.lexema, yytext, yyleng);
									yylval.id.lexema[yyleng] = '\0';
									if (sym_lookup(yytext, &valor) == SYMTAB_OK) {
										if (valor.tipus == BOOLEAN) return ID_BOOL;
										else return ID_ARITM;
									} else return ID;
								}

{endline} 						{ return FI_SENT; }

{line_comment}(.)*{endline}		{}
{open_block_comment} 			{ BEGIN(comment); }
<comment>[^*]*  				{}
<comment>"*"+[^*/]* 			{}	
<comment>{close_block_comment}{endline}? {BEGIN(INITIAL);} 

"-"?{digit}({digit})*			{
									yylval.entero = atoi(yytext);
									return INTEGER;
								}
								
"-"?{digit}+"."{digit}+((?i:e)"-"?{digit}*)?	{
									yylval.real = atof(yytext);
									return FLOAT;
								}
								
\"[^\n\"]+\"				{
									yylval.cadena = (char *)malloc(sizeof(char)*(yyleng + 1));
									strncpy(yylval.cadena,yytext,yyleng);
									yylval.cadena[yyleng] = '\0';
									return STRING;
								}	

%%