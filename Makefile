DIR = .
PROGRAM = program
SRC = pbp.c
FLAGS = -g -Wall `mysql_config --cflags --libs`
PROGS = program

.PHONY: all create trigger insert beauty dist progs


all: $(PROGRAM) create  insert trigger


create:
	mysql -u root -p <create.sql 

trigger: 
	mysql -u root -p  <triggers.sql
	
insert:
	mysql -u root -p <insert.sql

$(PROGRAM): $(SRC)
	gcc $(SRC) -o $(PROGRAM) $(FLAGS)
	
beauty:
	-indent $(PROGS).c

clean:
	-rm -f *~ $(PROGS)
	
dist: beauty clean
	-tar -czv -C .. -f ../$(DIR).tar.gz $(DIR)
	
