# Compiler Project

This is a basic compiler created for an assignment, created using flex and bison, which are open source tools optimized for compiler creation.

The lex file, lex.l, reads an input from either the command line or a file, and uses regular expressions to return tokens.

The parser then takes these tokens, validates it against a given grammar, and carries out various steps to validate that the given input is a valid file by comparing it to an arbitrary specification

The source files are lex.l and parser.y, and the others are generated files created by flex and bison. The lexer and the parser are linked through the y.tab.h file.