# TP-ANTLR\_Compiladores: QueryBit

Repositorio del Trabajo Parcial y Final del curso **Teoría de Compiladores (1ACC0236)**, UPC, ciclo 2026-1. Contiene el diseño e implementación progresiva de **QueryBit**, un lenguaje de dominio especifico (DSL) inspirado en SQL para consultar y filtrar archivos estructurados (`.csv`).

## 1. Contexto del proyecto

El proyecto se entrega en tres hitos. Este repositorio implementa el front-end del compilador (lexer + parser) y el analizador semántico.

| Hito | Semana | Alcance |
|------|--------|---------|
| Hito 1: Trabajo Parcial | 7 | Gramatica ANTLR4, archivos `.g4`, driver minimo, demo de la gramatica. |
| Hito 2: Segundo Avance | 12 | Arquitectura del compilador, analizador semántico, ~50% de la implementación. |
| Hito 3: Trabajo Final | 15 | Frontend y backend completos, generación de codigo intermedio con LLVM, validación y conclusiones. |


## 2. Problemática y motivacion

Muchas tareas de analisis de datos requieren filtrar y proyectar columnas sobre archivos `.csv`. Las herramientas actuales (motores SQL, hojas de calculo o lenguajes de proposito general) introducen una sobrecarga innecesaria cuando el caso de uso es realmente simple. **QueryBit** propone un DSL declarativo, minimo y autoejecutable, con una sintaxis cercana a SQL (`SELECT ... FROM ... WHERE ...`), pensado específicamente para ese escenario.

## 3. Objetivos

### 3.1. Objetivo general
Disenar e implementar QueryBit, un DSL para consultas y filtrado condicional sobre archivos estructurados, aplicando un flujo de compilación que incluya gramatica en ANTLR4, analisis sintactico, validación semántica y generación de codigo intermedio con LLVM.

### 3.2. Objetivos especificos
- Definir una sintaxis declarativa inspirada en SQL para operaciones `FROM`, `SELECT`, `WHERE`, `ORDER BY` y `LIMIT`.
- Construir una gramatica en ANTLR4 que reconozca correctamente las consultas válidas de QueryBit y reporte errores en las invalidas.
- Implementar un analizador semantico que detecte errores que escapan el poder expresivo de las CFGs.
- Implementar, en el hito final, generación de código intermedio mediante LLVM.

## 4. Estructura del repositorio

```text
TP-ANTLR_Compiladores/
├── README.md
├── .gitignore
├── grammar/
│   ├── QueryBit.g4          # gramatica combinada (lexer + parser)
│   ├── Makefile             # genera lexer y parser en Python3 dentro de gen/
│   ├── main.py              # driver: lexer -> parser -> semantico -> resumen
│   ├── SemanticVisitor.py   # analizador semantico (visitor sobre el AST)
│   ├── commands-showcase.md # comandos para reproducir las pruebas
│   ├── gen/                 # artefactos generados por ANTLR (ignorados por git)
│   └── tests/
│       ├── entrada0.txt
│       ├── entrada1.txt ... entrada5.txt
│       └── error1.txt   ... error5.txt
```

## 5. Gramatica

`grammar/QueryBit.g4` es una gramatica combinada (lexer + parser). Reconoce:

- Selección de columnas: `SELECT * | col1, col2, ...`
- Origen de datos: ruta entre comillas (`"clientes.csv"`) o identificador.
- Filtros booleanos con parentesis y operadores `AND`/`OR`, con **precedencia AND > OR** (estratificación explicita en `orCondition` / `andCondition`).
- Predicados de comparación con `>`, `<`, `==`, `!=`, `>=`, `<=`.
- `ORDER BY col [ASC|DESC], ...`
- `LIMIT n` con literal numerico.
- Palabras clave **insensibles a mayusculas** (estilo SQL).
- Comentarios de una linea con `--` y de bloque con `/* ... */`.

Todos los operadores EBNF (`?`, `*`, `+`) han sido eliminados de las reglas del parser y reemplazados con recursion explicita y producciones epsilon, para respetar el formalismo de las gramaticas libres de contexto. En las reglas del lexer si se usan operadores de Kleene, ya que el lexer opera sobre lenguajes regulares donde estos operadores son fundamentales.

### Ejemplo de consulta valida

```sql
SELECT nombre, edad
FROM "clientes.csv"
WHERE edad >= 18 AND pais == "Peru"
ORDER BY edad DESC, nombre ASC
LIMIT 10;
```

## 6. Analizador semantico

`grammar/SemanticVisitor.py` recorre el AST producido por el parser y valida restricciones que las CFGs no pueden expresar:

| Check | Descripción |
|-------|-------------|
| Columnas duplicadas en SELECT | `SELECT nombre, nombre FROM ...` es invalido |
| Columnas duplicadas en ORDER BY | `ORDER BY edad ASC, edad DESC` es invalido |
| Source FROM vacio | `FROM ""` no tiene sentido como ruta de archivo |
| Operador relacional con STRING | `>`, `<`, `>=`, `<=` requieren un valor numerico |
| LIMIT no entero o menor a 1 | `LIMIT 0`, `LIMIT 10.5` son invalidos |

## 7. Como ejecutar

### 7.1. Requisitos

- Python 3.11
- Java 17+ (para ejecutar el jar de ANTLR4)
- `antlr4-python3-runtime==4.13.2`
- ANTLR 4.13.1 (`antlr-4.13.1-complete.jar`)

---

### 7.2. Ubuntu (VM Oracle VirtualBox)

#### Instalación de dependencias (una sola vez)

```bash
sudo apt update
sudo apt install -y python3.11 python3.11-venv openjdk-17-jdk curl
```

Instalar `uv`:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
```

#### Configuracion del proyecto (una sola vez)

VBoxSF no soporta symlinks, por lo que el venv debe crearse fuera de la carpeta compartida. Se usa `~/envs/` como directorio central para todos los entornos uv:

```bash
mkdir -p ~/envs
uv venv ~/envs/querybit --python 3.11
source ~/envs/querybit/bin/activate
uv pip install antlr4-python3-runtime==4.13.2 antlr4-tools==0.2.2
```

#### Cada nueva sesion de shell

```bash
source ~/envs/querybit/bin/activate
cd TP-ANTLR_Compiladores
```

#### Regenerar lexer/parser (cada vez que se modifique `QueryBit.g4`)

```bash
cd grammar
make
```

Invoca `java -jar /usr/local/lib/antlr-4.13.1-complete.jar` directamente. Si el jar no esta en esa ruta, descargarlo con:

```bash
curl -o /usr/local/lib/antlr-4.13.1-complete.jar \
  https://www.antlr.org/download/antlr-4.13.1-complete.jar
```

Los archivos generados se depositan en `grammar/gen/`.

#### Ejecutar pruebas

```bash
cd grammar
export PYTHONPATH=gen
python3 main.py tests/entrada1.txt
```

Para todos los casos de una vez:

```bash
for f in tests/entrada*.txt tests/error*.txt; do
    echo "===== $(basename $f) ====="
    python3 main.py "$f"
done
```

---

### 7.3. Windows (PowerShell)

#### Instalación de dependencias (una sola vez)

```powershell
winget install Python.Python.3.11
winget install EclipseAdoptium.Temurin.17.JDK
winget install astral-sh.uv
```

#### Configuración del proyecto (una sola vez)

Desde la raíz del proyecto:

```powershell
cd TP-ANTLR_Compiladores
'3.11' | Out-File .python-version
uv venv --python 3.11
.\.venv\Scripts\Activate.ps1
uv pip install antlr4-python3-runtime==4.13.2 antlr4-tools==0.2.2
```

#### Cada nueva sesión de PowerShell

```powershell
cd TP-ANTLR_Compiladores
.\.venv\Scripts\Activate.ps1
```

#### Regenerar lexer/parser (cada vez que se modifique `QueryBit.g4`)

```powershell
cd grammar
java -jar C:\ruta\a\antlr-4.13.1-complete.jar -Dlanguage=Python3 -o gen QueryBit.g4
```

Si `antlr4` esta disponible como comando en el PATH:

```powershell
antlr4 -Dlanguage=Python3 -o gen QueryBit.g4
```

#### Ejecutar pruebas

```powershell
cd grammar
$env:PYTHONPATH = "gen"
python main.py tests\entrada1.txt
```

Para todos los casos de una vez:

```powershell
gci tests\entrada*.txt, tests\error*.txt | % {
    Write-Host "===== $($_.Name) ====="
    python main.py $_.FullName
}
```

---

### 7.4. Output del driver

Para una entrada válida:

```
Errores sintacticos:   ninguno

Errores semanticos:    ninguno

Consultas: 1  |  Total errores: 0  |  Estado: OK
```

Para una entrada con errores:

```
Errores sintacticos (1):
  [linea 2, col 0] mismatched input '<EOF>' expecting SEMI

Errores semanticos:    ninguno

Consultas: 1  |  Total errores: 1  |  Estado: con errores
```

## 8. Casos de prueba

Los casos de prueba viven en `grammar/tests/`. Los `entradaN.txt` deben parsear y pasar el analizador semantico sin errores. Los `sint_errorN.txt` deben fallar con error sintactico. Los `sem_errorN.txt` deben fallar con error semantico.

| Archivo | Tipo | Caracteristica que valida |
|---------|------|---------------------------|
| `entrada0.txt`    | valido | Forma minima: `SELECT * FROM "ruta.csv";` |
| `entrada1.txt`    | valido | `WHERE` con `AND`/`OR` y comentario `--` |
| `entrada2.txt`    | valido | Precedencia AND > OR |
| `entrada3.txt`    | valido | `ORDER BY` multi-columna + `LIMIT` |
| `entrada4.txt`    | valido | Multiples consultas, parentesis, palabras clave en mayusculas/minusculas mezcladas |
| `entrada5.txt`    | valido | Comentarios de bloque `/* ... */` multi-linea |
| `sint_error1.txt` | error sintactico | Falta el `;` final |
| `sint_error2.txt` | error sintactico | Operador `=` no soportado (se requiere `==`) |
| `sint_error3.txt` | error sintactico | `ORDER` sin `BY` |
| `sint_error4.txt` | error sintactico | Identificador que comienza con digito |
| `sint_error5.txt` | error sintactico | Comentario de bloque sin cerrar |
| `sem_error1.txt`  | error semantico | Columna duplicada en SELECT |
| `sem_error2.txt`  | error semantico | Operador relacional `>` con valor STRING |
| `sem_error3.txt`  | error semantico | LIMIT con valor decimal |
| `sem_error4.txt`  | error semantico | Columna duplicada en ORDER BY |
| `sem_error5.txt`  | error semantico | Ruta FROM vacia |
