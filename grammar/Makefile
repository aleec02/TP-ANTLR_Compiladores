FILENAME = QueryBit.g4
# Derivamos el nombre base quitando la extensión .g4
PREFIX = $(basename $(FILENAME))

# Ruta al jar de ANTLR4. Se puede sobrescribir desde la línea de comandos:
#   make ANTLR_JAR=/ruta/a/antlr-4.13.1-complete.jar
ANTLR_JAR ?= /usr/local/lib/antlr-4.13.1-complete.jar

# Si 'antlr4' está disponible como ejecutable en PATH (script, symlink o
# binario instalado por un paquete), lo usamos. Si NO existe, caemos al
# invocador explícito 'java -jar <jar>' usando ANTLR_JAR.
#
# Nota: los aliases de Bash (alias antlr4='java -jar ...') NO se propagan
# a las sub-shells que invoca make. Si solamente existe el alias, el
# fallback se activa, y dado que apunta al mismo .jar produce el mismo
# resultado.
ANTLR4 := $(shell command -v antlr4 2>/dev/null)
ifeq ($(ANTLR4),)
ANTLR4 := java -jar $(ANTLR_JAR)
endif

all:
	$(ANTLR4) -Dlanguage=Python3 $(FILENAME)

clean:
	rm -f $(PREFIX)*.py $(PREFIX)*.tokens $(PREFIX)*.interp
	rm -rf __pycache__
