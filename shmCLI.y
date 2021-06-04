%{
	#define _XOPEN_SOURCE 500
	#define BUFFER	50
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <sys/types.h>
	#include <sys/stat.h>
	#include <unistd.h>
	#include <ftw.h>
	
    void yyerror(char *s);
	void printHelp();
	void printVersion();
	void create(char *name);
	void purge(char *name);
	void makeController(char *name, char *flag);
	void makeModel(char *name, char *flag);
	void makeRepo(char *name, char *flag);
	void makeService(char *name, char *flag);

	char currentPath[BUFFER];
%}

%union
{
    char *charVal;
    int intVal;
}

%start run;

%token NL;

%token SHM;
%token GENERATE;
%token PURGE;

%token START;
%token CONTROLLER;
%token MODEL;
%token REPO;
%token SERVICE;

%token HELP;
%token VERSION;
%token REST;
%token MAPPING;
%token LOGIN;
%token CONSTRUCTOR;
%token GETSET;
%token SETCRUD;

%token <intVal> INTEGER;
%token <charVal> WORD;

%type <charVal> controller_action model_action repo_action service_action
%type <charVal> flag_opt flags flag

%%

run: 	run line
		| line
		;

line:	NL
		| SHM NL			{ printf("Hello USER!\n For help, use -help\n"); }
		| SHM com NL
		;

com:	command
		| flag
		;

command:	make
			| do
			;

make: 	create
		| delete
		;

create:		START WORD { char *name = $2; create(name); } 
			;

delete:		PURGE WORD { char *name = $2; purge(name); } 
			;

do:		GENERATE gen_option ;

gen_option:		controller
				| model
				| repo
				| service
				;

controller:		controller_action			{ char *name = $1; makeController(name, ""); }
				| controller_action flags	{ char *name = $1; char *opt = $2; makeController(name, opt);}
				;

controller_action:		CONTROLLER			{ $$ = "default"; }
						| CONTROLLER WORD	{ $$ = $2; }
						;

model:	model_action			{ char *name = $1; makeModel("default", ""); }
		| model_action flags	{ char *name = $1; char *opt = $2; makeModel(name, opt); }
		;

model_action:	MODEL			{ $$ = "default"; }
				| MODEL WORD	{ $$ = $2; }
				;

repo:	repo_action				{ char *name = $1; makeRepo(name, ""); }
		| repo_action flags		{ char *name = $1; char *opt = $2; makeRepo(name, opt); }
		;

repo_action:	REPO			{ $$ = "default"; }
				| REPO WORD		{ $$ = $2; }
				;

service:	service_action			{ char *name = $1; makeService(name, ""); }
			| service_action flags	{ char *name = $1; char *opt = $2; makeService(name, opt); }
			;

service_action:		SERVICE				{ $$ = "default"; }
					| SERVICE WORD		{ $$ = $2; }
					;

flags:	flag
		| flags flag	{ 	char *val = $1; char *spec = $2; 
							char aux[100]; 
							strcpy(aux, val);
							strcat(aux, " ");
							strcat(aux, spec);
							$$ = aux; }
		;	

flag:	flag_opt 
		| flag_opt WORD		{ 	char *val = $1; char *spec = $2; 
								char aux[100]; 
								strcpy(aux, val);
								strcat(aux, " ");
								strcat(aux, spec);
								$$ = aux; }
		;

flag_opt:	HELP			{ printHelp(); }
			| VERSION		{ printVersion(); }
			| REST			{ $$ = "rest"; }
			| MAPPING		{ $$ = "mapping"; }
			| LOGIN			{ $$ = "login"; }
			| CONSTRUCTOR	{ $$ = "constructor"; }
			| GETSET		{ $$ = "getset"; }
			| SETCRUD		{ $$ = "setCrud"; }
			;

%%
void printHelp() {
	printf("\n");
	printf("shm start <project name>\n");
	printf("shm generate controller <name>\n");
	printf("shm shm generate model <name>\n");
	printf("shm generate repo <name>\n");
	printf("shm generate service <name>\n");
	printf("shm purge <project name>\n");
	printf("usefull flags:\n");
	printf("\t\033[0;36m -help: \033[0;0m list of commands\n");
	printf("\t\033[0;36m -version: \033[0;0m gives app version\n");
	printf("\t\033[0;36m -rest: \033[0;0m makes @RestController\n");
	printf("\t\033[0;36m -mapping <path>: \033[0;0m gives <path> mapping to controller\n");
	printf("\t\033[0;36m -login: \033[0;0m initiates login/logout methods\n");
	printf("\t\033[0;36m -contructor\033[0;0m\n");
	printf("\t\033[0;36m -getset: \033[0;0m Lombok getter and setter\n");
	printf("\t\033[0;36m -setCrud <type>: \033[0;0m sets type of CrudRepository\n");
	printf("\n");
}

void printVersion() {
	printf("You are using version: \033[0;32m%s\033[0;0m\n", "monkey (0.01)");
}

void create(char *name) {
	printf("\tshm:: starting project %s\n", name);

	struct stat st = {0};

	if (stat(name, &st) == -1) {
		mkdir(name, 0777);
	}

	strcpy(currentPath, name);
	strcat(currentPath, "/");

	char filePath[BUFFER];
	strcpy(filePath, name);
	strcat(filePath, "/Application.java");

	FILE *fp = fopen(filePath, "w");

	fputs("@SpringBootApplication\n", fp);
	fputs("public class Application {\n", fp);
	fputs("\tpublic static void main (String[] args) {\n", fp);
	fputs("\t\tSpringApplication.run(Application.class, args);\n", fp);
	fputs("\t\tSystem.out.println(\"Hello World!\");\n", fp);
	fputs("\t}\n", fp);
	fputs("}\n", fp);

	fclose(fp);
	printf ("\t\tshm:: started the project successfully!\n");
}

int unlink_cb(const char *fpath, const struct stat *sb, int typeflag, struct FTW *ftwbuf) {
    int rv = remove(fpath);

    if (rv)
        perror(fpath);

    return rv;
}

void purge(char *name) {
	printf("\tshm::\033[0;31m purging\033[0;0m project %s\n", name);

	if (strlen(name) > 2) {
		int stat = nftw(name, unlink_cb, 64, FTW_DEPTH | FTW_PHYS);
	}

	printf("\t\tshm::\033[0;31m purge\033[0;0m successful!\n");
}

void makeController(char *name, char *opt) {
	if(opt && !opt[0]) {
		printf("\tshm:: generate controller \033[0;36m%sController\033[0;0m\n", name);
	} else {
		printf("\tshm:: generate controller \033[0;36m%sController\033[0;0m with flag \033[0;36m%s\033[0;0m\n", name, opt);
	}

	char filePath[BUFFER];
	strcpy(filePath, currentPath);
	strcat(filePath, name);
	strcat(filePath, "Controller.java");
	FILE *fp = fopen(filePath, "w");

	if (strstr(opt, "rest") != NULL) {
		fputs("@RestController\n", fp);
	} else {
		fputs("@Controller\n", fp);
	}

	char *mapFlag = strstr(opt, "mapping");
	if (mapFlag) {
		strcpy(mapFlag, mapFlag+8);
		char map[BUFFER];
		int i = 0;
		while ((*mapFlag != ' ') && (*mapFlag != '\0') && (*mapFlag != '\n')) {
			map[i++] = *mapFlag;
			*mapFlag++;
		}
		
		fputs("@RequestMapping(\"", fp);
		fputs(map, fp);
		fputs("\")\n", fp);
	}

	fputs("public class ", fp);
	fputs(name, fp);
	fputs("Controller {\n", fp);

	if (strstr(opt, "login") != NULL) {
		fputs("\n\t@PostMapping(\"/login\")\n\t@ResponseBody\n", fp);
		fputs("\tpublic ResponseEntity<?> loginUser(@Valid @RequestBody LoginRequest loginRequest) {\n", fp);
		fputs("\t\treturn ResponseEntity.ok(response);\n", fp);
		fputs("\t}\n", fp);
	}

	fputs("}\n", fp);

	printf("\t\tshm:: generate \033[0;36m controller \033[0;0m successful\n");
}

void makeModel(char *name, char *opt) {
	if(opt && !opt[0]) {
		printf("\tshm:: generate model \033[0;32m%s\033[0;0m\n", name);
	} else {
		printf("\tshm:: generate model \033[0;32m%s\033[0;0m with flag \033[0;32m%s\033[0;0m\n", name, opt);
	}

	char filePath[BUFFER];
	strcpy(filePath, currentPath);
	strcat(filePath, name);
	strcat(filePath, ".java");
	FILE *fp = fopen(filePath, "w");

	if (strstr(opt, "constructor") != NULL) {
		fputs("@NoArgsConstructor\n@AllArgsConstructor\n", fp);
	}

	if (strstr(opt, "getset") != NULL) {
		fputs("@Getter\n@Setter\n", fp);
	}

	fputs("public class ", fp);
	fputs(name, fp);
	fputs(" {\n\n}\n", fp);

	printf("\t\tshm:: generate \033[0;32m model \033[0;0m successful\n");
}

void makeRepo(char *name, char *opt) {
	if(opt && !opt[0]) {
		printf("\tshm:: generate repository \033[0;35m%sRepository\033[0;0m\n", name);
	} else {
		printf("\tshm:: generate repository \033[0;35m%sRepository\033[0;0m with flag \033[0;35m%s\033[0;0m\n", name, opt);
	}

	char filePath[BUFFER];
	strcpy(filePath, currentPath);
	strcat(filePath, name);
	strcat(filePath, "Repository.java");
	FILE *fp = fopen(filePath, "w");

	fputs("@Repository\n", fp);
	fputs("public interface ", fp);
	fputs(name, fp);
	fputs("Repository extends CrudRepository<", fp);
	fputs(name, fp);
	fputs(",", fp);
	
	char *crudFlag = strstr(opt, "setCrud");
	if (crudFlag) {
		strcpy(crudFlag, crudFlag+8);
		char type[BUFFER];
		int i = 0;
		while ((*crudFlag != ' ') && (*crudFlag != '\0') && (*crudFlag != '\n')) {
			type[i++] = *crudFlag;
			*crudFlag++;
		}

		fputs(type, fp);

	} else {
		fputs("Int", fp);
	}

	fputs("> {\n\n}\n", fp);

	printf("\t\tshm:: generate \033[0;35m repository \033[0;0m successful\n");
}

void makeService(char *name, char *opt) {
	if(opt && !opt[0]) {
		printf("\tshm:: generate service \033[0;34m%sService\033[0;0m\n", name);
	} else {
		printf("\tshm:: generate service \033[0;34m%sService\033[0;0m with flag \033[0;34m%s\033[0;0m\n", name, opt);
	}

	char filePath[BUFFER];
	strcpy(filePath, currentPath);
	strcat(filePath, name);
	strcat(filePath, "Service.java");
	FILE *fp = fopen(filePath, "w");

	fputs("@Service\n", fp);
	fputs("public class ", fp);
	fputs(name, fp);
	fputs("Service {\n\n}\n", fp);

	printf("\t\tshm:: generate \033[0;34m service \033[0;0m successul\n");
}

void yyerror(char *s) { 
	fprintf(stdout, "%s\n", s); 
} 

int main(void) {
	yyparse();
	return 0; 
}
