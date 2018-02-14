%{
	/*Imports*/
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <math.h>

	/*Function Definitions*/
	int yylex();
	int yywrap();
	void setNextFileInput();

	int identifierExists(char* identifier);
	int getValueForIdentifier(char* identifier);
	void addVariableToList(int size, char* identifier);
	void moveNumberToVariable(int number, char *identifier);
	void addNumberToVariable(int number, char *identifier);
	void reassignVariable(char *identifier1, char *identifier2);
	void addVariables(char *identifier1, char *identifier2);
	int getNumberLength(int number);
	int getVariableSize(char* identifier);

	void yyerror(char* message);
	
	struct variable {
	char* name;
	int size;
	int value;
	};
%}

%union {
	char* string;
	int number;
}

%start program
%token <string> STRING IDENTIFIER
%token <number> NUMBER VARIABLE_SIZE
%token BEGINING BODY END INPUT PRINT MOVE ADD TO SEPARATOR TERMINATOR

%%
program: BEGINING 
		 TERMINATOR declarations 
		 BODY 
		 TERMINATOR statements 
		 END TERMINATOR {
		 	printf("\n\n****\nValid Language Instance!\n****\n\n");
		 };

declaration: VARIABLE_SIZE IDENTIFIER {
	addVariableToList($1, $2);
};

declarations: declaration TERMINATOR | 
			  declarations declaration TERMINATOR | ;

statement: move_operation  | 
		   add_operation   | 
		   input_operation | 
		   print_operation;

statements: statement TERMINATOR | 
			statements statement TERMINATOR | ;

move_operation: MOVE NUMBER TO IDENTIFIER {
					moveNumberToVariable($2, $4);
				} |
				MOVE IDENTIFIER TO IDENTIFIER {
					reassignVariable($2, $4);
				};

add_operation: ADD NUMBER TO IDENTIFIER {
					addNumberToVariable($2, $4);
				} | 
			   ADD IDENTIFIER TO IDENTIFIER {
			   		addVariables($2, $4);
			   	};

input_operation: INPUT input_items;

input_items: IDENTIFIER {
				if(!identifierExists($1))
					yyerror("variable does not exist!");
			} | 
			input_items SEPARATOR IDENTIFIER {
				if(!identifierExists($3))
					yyerror("variable does not exist!");
			};

print_operation: PRINT {
					printf("PRINT ");
				} 
				print_items {
					printf(".\n");
};

print_items: STRING {
				printf("%s", $1);
			} | 
			IDENTIFIER {
				printf("%d", getValueForIdentifier($1));
			} | 
			print_items SEPARATOR {
				printf(";");
			} 
			print_items;
%%

extern FILE* yyin;
extern int yylineno;

static struct variable variableList[1000000] = {"", 0, 0};
static int variableCount;


int main(int argc, char *argv[]) {

	yyin = fopen(argv[1], "r");
	do yyparse();
	while(!feof(yyin));
}

int identifierExists(char* identifier) {
	int identifierExists = 0;
	for(int i = 0; i < variableCount; i++)
	{
		if (strcasecmp(identifier, variableList[i].name) == 0) 
			identifierExists = 1;	
	}
	return identifierExists;
}

int getValueForIdentifier(char* identifier) {
	int value;

	if(identifierExists(identifier)) {
		for(int i = 0; i < variableCount; i++) 
			if (strcasecmp(identifier, variableList[i].name) == 0) 
				value = variableList[i].value;
	return value;

	} else {
		yyerror("Undeclared variable!");
	}
}

void addVariableToList(int size, char* identifier) {
	if(identifierExists(identifier)) {
		yyerror("Identifier is already declared!");
	} else {
		variableList[variableCount].name = identifier;
		variableList[variableCount].size = size;

		variableCount++;
	}
	
}

void moveNumberToVariable(int number, char *identifier) {
	if(!identifierExists(identifier)) 
		yyerror("Identifier does not exist!");
	
	else if(getNumberLength(number) > getVariableSize(identifier))
		yyerror("Number provided exceeds variable size!");
	
	/* variable exists and number provided has correct capacity */
	else {
		for(int i = 0; i < variableCount; i++) {
			if (strcasecmp(identifier, variableList[i].name) == 0) {
					variableList[i].value = number;
			}
		}
	}
}

void addNumberToVariable(int number, char *identifier) {
	if(!identifierExists(identifier)) 
		yyerror("Identifier does not exist!");
	
	else if(getNumberLength(number) > getVariableSize(identifier))
		yyerror("Number provided exceeds variable size!");
	
	/* variable exists and number provided has correct capacity*/
	for(int i = 0; i < variableCount; i++) {
		if (strcasecmp(identifier, variableList[i].name) == 0) {
			int addedNumber = variableList[i].value += number;

			if(getNumberLength(addedNumber) > variableList[i].size) 
				yyerror("Added number exceeds variable capacity!");
			
		else variableList[i].value = addedNumber;
		}
	}
}

void reassignVariable(char *identifier1, char *identifier2) {
	if(!identifierExists(identifier1) || !identifierExists(identifier2)) 
		yyerror("Identifier does not exist!");
	
	else if(getVariableSize(identifier1) > getVariableSize(identifier2))
		yyerror("First identifier size exceeds Second identifier capacity!");

	int identifierIndex1, identifierIndex2;
	
	for(int i = 0; i < variableCount; i++) {
		if (strcasecmp(identifier1, variableList[i].name) == 0)
			identifierIndex1 = i;
		
		if (strcasecmp(identifier2, variableList[i].name) == 0)
			identifierIndex2 = i;
	}

	variableList[identifierIndex2].value = variableList[identifierIndex1].value;
}

void addVariables(char *identifier1, char *identifier2) {
	if(!identifierExists(identifier1) || !identifierExists(identifier2)) 
		yyerror("Identifier does not exist!");
	
	else if(getVariableSize(identifier1) > getVariableSize(identifier2))
		yyerror("First identifier size exceeds second identifier capacity!");

	int identifierIndex1, identifierIndex2;

	for(int i = 0; i < variableCount; i++) {
		if (strcasecmp(identifier1, variableList[i].name) == 0)
			identifierIndex1 = i;
		
		if (strcasecmp(identifier2, variableList[i].name) == 0)
			identifierIndex2 = i;
	}

	int addedNumber = variableList[identifierIndex2].value += variableList[identifierIndex1].value;
	
	if(getNumberLength(addedNumber) > variableList[identifierIndex2].size) 
		yyerror("Combined number is too large to fit into initial variable!");
		
	else variableList[identifierIndex2].value = addedNumber;
}

int getNumberLength(int number) {
	if (number < 10) 
		return 1;
    
    return 1 + getNumberLength(number / 10);
}

int getVariableSize(char* identifier) {
	if(identifierExists(identifier)) {
		for(int i = 0; i < variableCount; i++)
			if (strcasecmp(identifier, variableList[i].name) == 0) 
				return variableList[i].size;
	}
}

void yyerror(char* message) {
	printf("\n\n****\nInvalid Language Instance!\n****\nError: %s on line %d\n", message, yylineno);
	exit(-1);
}