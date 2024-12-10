%{
#include "y.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%%


"int"           { return INT; }
"float"         { return FLOAT; }
"char"          { return CHAR; }

"if"            { return IF; }
"else"          { return ELSE; }
"while"         { return WHILE; }

"scanf"         { return SCANF; }
"printf"        { return PRINTF; }
"%d"            { return FORMAT_STRING; }
"%f"            { return FORMAT_STRING; }
"%c"            { return FORMAT_STRING; }
"%s"            { return FORMAT_STRING; }
[a-zA-Z][a-zA-Z0-9]* { yylval.string = strdup(yytext); return IDENTIFIER; }
[0-9]+          { yylval.number = atoi(yytext); return NUMBER; }
[0-9]+(\.[0-9]+)? { yylval.number = atof(yytext); return NUMBER; }

"="             { return '='; }
"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }

";"             { return ';'; }
"("             { return '('; }
")"             { return ')'; }
"{"             { return '{'; }
"}"             { return '}'; }
">"             { return '>'; }
"<"             { return '<'; }
">="            { return GREATER_EQUAL; }
"<="            { return LESS_EQUAL; }
"=="            { return EQUAL; }
"!="            { return NOT_EQUAL; }
"&"             { return '&'; } 

\"[^\"]*\"      { yylval.string = strdup(yytext); return STRING_LITERAL; }  // Handle string literals
\'[^\']\'       { yylval.string = strdup(yytext); return CHAR; }  // Handle character literals


","             { return ','; }
[ \t\n]+        { /* Skip whitespace */ }
.               { printf("Unknown character: %s\n", yytext); return YYUNDEF; }

%%

int yywrap() {
    return 1;
}
