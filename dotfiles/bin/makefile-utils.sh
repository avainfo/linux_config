mf() {
	varname=$1
	shift
	echo -n "$varname = " >> Makefile
	ls "$@" | sed ':a;N;$!ba;s/\n/ \\\n\t/g' >> Makefile
	echo >> Makefile
}

# mf : gera automaticamente uma lista de ficheiros formatada
# para um Makefile
#
# Utilização:
#   mf NOME_VARIAVEL padrão...
#     → escreve no Makefile:
# 		NOME_VARIAVEL = ficheiro1 \
# 			ficheiro2 \
# 			... (com quebras de linha e tabulações)
#
# Exemplos:
#   mf SOURCES *.c
#       SOURCES = main.c \
#           utils.c \
#           parser.c
#
#   mf OBJS *.o
#       OBJS = main.o \
#           utils.o \
#           parser.o
