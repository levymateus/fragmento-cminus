/*
 * Parser para uma calculadora avancada
 */

%{
#include<stdio.h>
#include<stdlib.h>
#include"cminus.h"
%}

%union{
	int intcon; // INTCON
	struct SYMBOL *symbol;
	struct AST *ast;
	struct SYMBOL_LIST *symbol_list;
}

//declaracao de tokens

%token <intcon> INTCON
%token <symbol> ID  
%token CHARCON STRINGCON
%token ADD SUB MUL DIV 
%token GREATER_THAN LESSER_THAN DIFFERENT EQUAL GREATER_THAN_EQUAL LESSER_THAN_EQUAL
%token AND OR
%token CHAR EXTERN VOID RETURN
%token EOL
%token IF ELSE WHILE FOR


%right '='
%left '+' '-'
%left '*' '/'

%type <symbol_list> paramlist

%type <ast> expr stmt exprlist 

%start prog

%%

prog: 
| dcl ';' EOL prog { printf("<dcl>\n"); }
| func EOL prog { printf("<func>\n"); }
;

dcl: CHAR var_decl var_dcl_list { printf("<dcl>\n"); }
| EXTERN CHAR ID '(' param_types ')' param_types_list 				{ printf("<dcl>\n"); }
| EXTERN VOID ID '(' param_types ')' param_types_list 				{ printf("<dcl>\n"); }
| VOID ID '(' param_types ')' param_types_list 								{ printf("<dcl>\n"); }
| CHAR ID '(' param_types ')' param_types_list 								{ printf("<dcl>\n"); }
;

var_dcl_list: /*vazio*/
| ',' var_decl var_dcl_list { printf("<var_dcl_list>\n"); }
;

param_types_list: 
| ID '(' param_types ')' ',' param_types_list { printf("<param_types_list>\n"); }
;

var_decl: 
| ID { printf("<var_decl>\n"); }
| ID '[' INTCON ']' { printf("<var_decl>\n"); }
;

param_types: VOID { printf("<param_types>\n"); }
| CHAR ID '[' ']' paramlist { printf("<param_types>\n"); }
| CHAR ID paramlist { printf("<param_types>\n"); }
; 

func: CHAR ID '(' param_types ')' '{' funclist '}' { printf("<func>\n"); }
| INTCON ID '(' param_types ')' '{' funclist '}' { printf("<func>\n"); }
;

funclist: CHAR var_decl var_dcl_list ';' stmt { printf("<funclist>\n"); }
;

paramlist:	{ $$ = NULL; }
| ',' CHAR ID paramlist { printf("<paramlist>\n"); $$ = new_symbol_list($3, $4); }
| ',' CHAR ID '[' ']' paramlist { printf("<paramlist>\n"); $$ = new_symbol_list($3, $6); }
;

stmt: IF '(' expr ')' stmt 				{ printf("<IF>\n"); $$ = new_flow(IF, $3, $5, NULL); }
| IF '(' expr ')' stmt ELSE stmt	{ printf("<IF ELSE>\n"); $$ = new_flow(IF, $3, $5, $7); }
| WHILE '(' expr ')' stmt					{ printf("<stmt>\n"); $$ = new_flow(WHILE, $3, $5, NULL); }
| FOR '(' assg ';' expr ';' assg ')' stmt { printf("<stmt>\n"); }
| RETURN ';' 											{ printf("<return>\n"); }
| RETURN expr ';' 								{ printf("<return> <expr> ;\n"); }
| assg ';' 												{ printf("<assg> ;\n"); }
| expr 														{ printf("<stmt expr>\n"); }
;

expr: expr AND expr { printf("<AND>\n"); $$ = new_ast(AND, $1, $3); }
| expr OR expr { printf("<OR>\n"); $$ = new_ast(OR, $1, $3); }
| expr GREATER_THAN expr { printf("<GREATER_THAN>\n"); $$ = new_ast(GREATER_THAN, $1, $3);}
| expr LESSER_THAN expr { printf("<LESSER_THAN>\n"); $$ = new_ast(LESSER_THAN, $1, $3);}
| expr DIFFERENT expr { printf("<DIFERRENT>\n"); $$ = new_ast(DIFFERENT, $1, $3);}
| expr EQUAL expr { printf("<EQUAL>\n"); $$ = new_ast(EQUAL, $1, $3);}
| expr GREATER_THAN_EQUAL expr { printf("<GREATER_THAN_EQUAL>\n"); $$ = new_ast(GREATER_THAN_EQUAL, $1, $3);}
| expr LESSER_THAN_EQUAL expr { printf("<LESSER_THAN_EQUAL>\n"); $$ = new_ast(LESSER_THAN_EQUAL, $1, $3);}
| expr ADD expr { printf("<add>\n"); $$ = new_ast(ADD, $1, $3); } 
| expr SUB expr { printf("<sub>\n"); $$ = new_ast(SUB, $1, $3);} 
| expr MUL expr { printf("<mul>\n"); $$ = new_ast(MUL, $1, $3);} 
| expr DIV expr { printf("<div>\n"); $$ = new_ast(DIV, $1, $3);} 
| '(' expr ')' 	{ printf("<expr>\n"); $$ = $2; }
| ID '(' exprlist ')' { printf("<call> \n"); $$ = new_call($1, NULL); }// chamada de função. segundo argumento é temporariamente NULL 
| ID { printf("<new_ref>\n"); $$ = new_ref($1); }
| INTCON { $$ = new_number($1); }
| CHARCON { printf("<charcon>\n"); }
| STRINGCON { printf("<stringcon>\n"); }
;

exprlist: expr { printf("<exprlist>\n"); }
| expr ',' exprlist { printf("<exprlist>\n"); }
;

assg: ID '=' expr { printf("<assg>\n"); }
| ID '[' expr ']' '=' expr { printf("<assg>\n"); }
;

