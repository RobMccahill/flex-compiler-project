%option caseless
%option noyywrap
%option yylineno
%{
	#include <stdio.h>
	#include "parser.tab.h"
%}

%%

[X]+ {
	yylval.number = yyleng; 
	return VARIABLE_SIZE;
}

BEGINING {
	return BEGINING;
}

BODY {
	return BODY;
}

END {
	return END;
}

MOVE {
	return MOVE;
}

ADD {
	return ADD;
}

TO {
	return TO;
}

INPUT {
	return INPUT;
}

PRINT {
	return PRINT;
}

\"([^\\\"]|\\.)*\" {
	yylval.string = strdup(yytext); 
	return STRING;
}

[a-z][a-z0-9-]* {
	yylval.string = strdup(yytext);
	return IDENTIFIER;
}

-[1-9][0-9]*|[0-9]+ {
	yylval.number = atoi(yytext);
	return NUMBER;
}

\; {
	return SEPARATOR;
}

\. {
	return TERMINATOR;
}

[\t\n ] {

}

%%