#ifndef CALCULADORA_FUNCIONS_H
#define CALCULADORA_FUNCIONS_H

int init_analisi_lexica(char *);
int end_analisi_lexica();

int init_analisi_sintactica(char *);
int end_analisi_sintactica(void);

int analisi_semantica(void);

void yyerror(char *explanation);

#endif
