s%{
#include <stdio.h>
#include <stdlib.h>
#define YYDEBUG 1
extern int yydebug;
extern char *yytext;

void yyerror(const char *s);
int yylex();
%}

%union {
    char *string;
}

%token <string> INT FLOAT CHAR IDENTIFIER NUMBER
%token SCANF PRINTF FORMAT_STRING IF ELSE WHILE
%token GREATER_EQUAL LESS_EQUAL EQUAL NOT_EQUAL

%%

// Declarations
DECLARATION_LIST: DECLARATION DECLARATION_LIST
                 | /* epsilon */
                 ;

DECLARATION: TYPE IDENTIFIER OPTIONAL_INITIALIZER ';' 
           | TYPE IDENTIFIER ';'

TYPE: INT 
    | FLOAT 
    | CHAR 
    ;


OPTIONAL_INITIALIZER: '=' EXPRESSION
                    | /* epsilon */
                    ;

// Expressions
EXPRESSION: SIMPLE_EXPRESSION
          | SIMPLE_EXPRESSION REL_OP SIMPLE_EXPRESSION
          ;

SIMPLE_EXPRESSION: TERM SIMPLE_EXPRESSION_TAIL
                 ;

SIMPLE_EXPRESSION_TAIL: '+' TERM SIMPLE_EXPRESSION_TAIL
                      | '-' TERM SIMPLE_EXPRESSION_TAIL
                      | /* epsilon */
                      ;

REL_OP: '>'
      | '<'
      | GREATER_EQUAL
      | LESS_EQUAL
      | EQUAL
      | NOT_EQUAL
      ;
EXPRESSION_TAIL: '+' TERM EXPRESSION_TAIL
               | '-' TERM EXPRESSION_TAIL
               | /* epsilon */
               ;

TERM: FACTOR TERM_TAIL 
    ;

TERM_TAIL: '*' FACTOR TERM_TAIL
         | '/' FACTOR TERM_TAIL
         | /* epsilon */
         ;

FACTOR: IDENTIFIER 
      | NUMBER 
      | '(' EXPRESSION ')' 
      ;

// Statements
STATEMENT: EXPRESSION ';'
         | COMPOUND_STATEMENT
         | IF_STATEMENT
         | WHILE_STATEMENT
         | IOS_STMT ';'
         ;

COMPOUND_STATEMENT: '{' STATEMENT_LIST '}'
                  ;

STATEMENT_LIST: STATEMENT STATEMENT_LIST
              | /* epsilon */
              ;

IF_STATEMENT: IF '(' EXPRESSION ')' STATEMENT OPTIONAL_ELSE
            ;

OPTIONAL_ELSE: ELSE STATEMENT 
             | /* epsilon */
             ;

WHILE_STATEMENT: WHILE '(' EXPRESSION ')' STATEMENT 
               ;

// Input/Output Statements
IOS_STMT: IN_STMT
        | OUT_STMT
        ;

IN_STMT: SCANF '(' FORMAT_STRING ',' IDENTIFIER ')' 
       ;

OUT_STMT: PRINTF '(' FORMAT_STRING ',' IDENTIFIER ')' 
        ;

%%

// Error handler
void yyerror(const char *s) {
    fprintf(stderr, "Error near '%s': %s\n", s, yytext); 

    exit(1);
}


int main() {
    yydebug = 1;	
    if (yyparse() == 0) {
        printf("Parsing completed successfully!\n");
    }
    return 0;
}
