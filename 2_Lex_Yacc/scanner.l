%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int line = 1;        
    int column = 0;      
    FILE *pifFile;
    FILE *stFile;

    typedef struct {
        char symbol[100];
        int address;
    } SymbolTable;

    typedef struct {
        char token[100];
        int line;
        int column;
    } ProgramInternalForm;

    SymbolTable symbolTable[1000];
    int stIndex = 0;

    ProgramInternalForm pif[1000];
    int pifIndex = 0;

    int addToSymbolTable(char *symbol) {
        for (int i = 0; i < stIndex; i++) {
            if (strcmp(symbolTable[i].symbol, symbol) == 0) {
                return i;
            }
        }
        strcpy(symbolTable[stIndex].symbol, symbol);
        symbolTable[stIndex].address = stIndex;
        return stIndex++;
    }

    void addToPIF(char *token, int line, int column) {
        strcpy(pif[pifIndex].token, token);
        pif[pifIndex].line = line;
        pif[pifIndex].column = column;
        pifIndex++;
    }

    void printSymbolTable() {
        stFile = fopen("symbol_table.txt", "w");
        for (int i = 0; i < stIndex; i++) {
            fprintf(stFile, "Symbol: %s, Address: %d\n", symbolTable[i].symbol, symbolTable[i].address);
        }
        fclose(stFile);
    }

    void printPIF() {
        pifFile = fopen("pif.txt", "w");
        for (int i = 0; i < pifIndex; i++) {
            fprintf(pifFile, "Token: %s, Line: %d, Column: %d\n", pif[i].token, pif[i].line, pif[i].column);
        }
        fclose(pifFile);
    }
%}

%option noyywrap

DIGIT   [0-9]
LETTER  [a-zA-Z]
ID      {LETTER}({LETTER}|{DIGIT})*
NUMBER  {DIGIT}+

%%

"if"                    { addToPIF("IF", line, column); column += yyleng; }
"else"                  { addToPIF("ELSE", line, column); column += yyleng; }
"+"                     { addToPIF("PLUS", line, column); column += yyleng; }
"-"                     { addToPIF("MINUS", line, column); column += yyleng; }
"*"                     { addToPIF("MULT", line, column); column += yyleng; }
"/"                     { addToPIF("DIV", line, column); column += yyleng; }
"="                     { addToPIF("ASSIGN", line, column); column += yyleng; }
"("                     { addToPIF("LPAREN", line, column); column += yyleng; }
")"                     { addToPIF("RPAREN", line, column); column += yyleng; }
"{"             { addToPIF("LBRACE", line, column); column += yyleng; }
"}"             { addToPIF("RBRACE", line, column); column += yyleng; }
";"             { addToPIF("SEMICOLON", line, column); column += yyleng; }

{NUMBER}                { 
                            int pos = addToSymbolTable(yytext); 
                            addToPIF("NUMBER", line, column);   
                            column += yyleng; 
                        }
{ID}                    {
                            int pos = addToSymbolTable(yytext);
                            addToPIF("ID", line, column);
                            column += yyleng;
                        }

\n                      { line++; column = 0; }
[ \t]                   { column += yyleng; } 

.                       { fprintf(stderr, "Lexical error at line %d, column %d: Unexpected character '%s'\n", line, column, yytext); column += yyleng; }

%%

int main(int argc, char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input file>\n", argv[0]);
        return 1;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        perror("Could not open input file");
        return 1;
    }

    yyin = input;
    yylex();

    printSymbolTable();
    printPIF();

    fclose(input);
    return 0;
}


