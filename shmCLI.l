%{
	#include <stdlib.h>
	#include "y.tab.h"
%}

%%

[':,()]		return *yytext;

[0-9]+			{	yylval.intVal = atoi(yytext);
					return INTEGER; }

"\n"			return NL;

"shm"			return SHM;
"generate"		return GENERATE;
"purge"			return PURGE;

"start"			return START;
"controller"	return CONTROLLER;
"model"			return MODEL;
"repo"			return REPO;
"service"		return SERVICE;

"-help"			return HELP;
"-version"		return VERSION;
"-rest"			return REST;
"-mapping"		return MAPPING;
"-login"		return LOGIN;
"-constructor"	return CONSTRUCTOR;
"-getset"		return GETSET;
"-setCrud"		return SETCRUD;

((\/)|(\_)|[a-zA-Z])+		{	yylval.charVal = strdup(yytext);
							return WORD; }

[ \t]+			;
.				;

%%
