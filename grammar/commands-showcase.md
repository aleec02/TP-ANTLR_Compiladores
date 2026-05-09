# QueryBit – Commands Showcase

Conjunto mínimo de comandos para regenerar el lexer y el parser desde la gramática y ejecutar las pruebas incluidas en `tests/`.

## Setup: regenerar lexer y parser desde la gramática

```bash
cd grammar
make
```

El `Makefile` busca primero un ejecutable `antlr4` en el `PATH`. Si lo encuentra, lo usa directamente. Si no existe, recurre al invocador `java -jar $(ANTLR_JAR)`, donde `ANTLR_JAR=/usr/local/lib/antlr-4.13.1-complete.jar` por defecto.

```bash
# usar otra ubicación del .jar
make ANTLR_JAR=/ruta/personalizada/antlr-4.13.1-complete.jar

# forzar un ejecutable o invocación explícita
make ANTLR4="java -jar $HOME/lib/antlr-4.13.1-complete.jar"
```

Importante: los aliases de Bash (`alias antlr4='...'`) no se heredan en las sub-shells que invoca `make`. Si la única forma del comando es un alias, el fallback `java -jar $(ANTLR_JAR)` se activa automáticamente, y como ambos apuntan al mismo `.jar`, el resultado es idéntico.

En Windows, ejecutar el equivalente con `java` directamente:

```powershell
java -jar C:\ruta\a\antlr-4.13.1-complete.jar -Dlanguage=Python3 QueryBit.g4
```

## Ejecución del driver

El driver imprime el árbol sintáctico en formato textual (`toStringTree`) sobre la regla inicial `program`.

### Entradas válidas

```bash
# Consulta original del informe .docx
python3 main.py tests/entrada0.txt
```

```bash
# Consulta básica: SELECT *  desde un archivo CSV
python3 main.py tests/entrada1.txt
```

```bash
# WHERE con AND/OR (se valida la precedencia AND > OR)
python3 main.py tests/entrada2.txt
```

```bash
# ORDER BY multi-columna y LIMIT
python3 main.py tests/entrada3.txt
```

```bash
# Múltiples consultas, paréntesis y palabras clave insensibles a mayúsculas
python3 main.py tests/entrada4.txt
```

```bash
# Comentarios de bloque /* ... */ multi-línea, intercalados dentro de la consulta
python3 main.py tests/entrada5.txt
```

### Entradas con errores

```bash
# Falta de ';' al final de la consulta
python3 main.py tests/error1.txt
```

```bash
# Operador '=' no soportado (la gramática usa '==')
python3 main.py tests/error2.txt
```

```bash
# ORDER sin BY (la gramática exige la pareja 'ORDER BY')
python3 main.py tests/error3.txt
```

```bash
# Identificador inválido: no puede comenzar con dígito
python3 main.py tests/error4.txt
```

```bash
# Comentario de bloque /* sin cierre */; el lexer no encuentra el fin
python3 main.py tests/error5.txt
```

## Limpieza

```bash
make clean
```

Elimina los artefactos generados por ANTLR (`*Lexer.py`, `*Parser.py`, `*Listener.py`, `*.tokens`, `*.interp`) y `__pycache__/`.
