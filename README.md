# Welcome to shmCLI !

A command line tool for generating Java Spring Boot boilerplate code. It was built with the help of lex/yacc and C. 

The project was started as a laboratory work for UTCN Calculatoare, LFT course. The purpose was to implement something with the help of lexx/yacc.

To clone:

    git clone https://github.com/SamuelAierizer/shmCLI.git

How to build if you made changes:

    lex shmCLI.l
    yacc -d shmCLI.y
    gcc lex.yy.c y.tab.c -ll -o shmCLI


How to run: 

    ./shmCLI

For the list of options type:

    shm -help


There are 2 tests built in:

    ./shmCLI < test1		-> will build a "new" folder with a basic class and main function
    ./shmCLI < test2		-> builds "project" with multiple examples of how commands work
    ./shmCLI < purge		-> remove "project" folder and all of it's contents


[alt text](https://github.com/SamuelAierizer/shmCLI/blob/main/Screenshots/Screenshot-1.png)
[alt text](https://github.com/SamuelAierizer/shmCLI/blob/main/Screenshots/Screenshot-2.png)
[alt text](https://github.com/SamuelAierizer/shmCLI/blob/main/Screenshots/Screenshot-3.png)
[alt text](https://github.com/SamuelAierizer/shmCLI/blob/main/Screenshots/Screenshot-4.png)
