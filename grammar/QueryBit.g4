grammar QueryBit;

// ========== REGLAS DEL PARSER ==========

// ---------- PUNTO DE ENTRADA
//  Una o más consultas terminadas en ';'
program : query+ EOF ;

// ---------- CONSULTA
//  SELECT <columnas> FROM <tabla>
//    [ WHERE   <condicion>      ]
//    [ ORDER BY <lista_orden>   ]
//    [ LIMIT   <numero>         ] ;
query
    : SELECT columnList
      FROM source
      whereClause?
      orderClause?
      limitClause?
      SEMI
    ;

// ---------- CLÁUSULAS OPCIONALES
whereClause : WHERE condition ;
orderClause : ORDER BY orderList ;
limitClause : LIMIT NUMBER ;

// ---------- COLUMNAS
//  '*'  o  col1, col2, ...
columnList
    : STAR
    | column (COMMA column)*
    ;

column : ID ;

// ---------- ORIGEN DE DATOS
//  ruta entre comillas ("clientes.csv") o identificador
source : STRING | ID ;

// ---------- CONDICIONES
//  Precedencia (de menor a mayor):
//    1. OR
//    2. AND
//    3. paréntesis y predicados primarios
//
//  La estratificación garantiza que 'a AND b OR c' se interprete
//  como '(a AND b) OR c', alineado con la semántica de SQL.
condition : orCondition ;

orCondition  : andCondition (OR  andCondition)* ;
andCondition : primaryCondition (AND primaryCondition)* ;

primaryCondition
    : LPAREN condition RPAREN
    | predicate
    ;

// ---------- PREDICADO
//  columna  <op>  valor   (ej. edad >= 18)
predicate : ID compOp value ;

compOp : GT | LT | EQ | NEQ | GTE | LTE ;

value : NUMBER | STRING ;

// ---------- ORDEN
//  ORDER BY col1 ASC, col2 DESC
orderList : orderItem (COMMA orderItem)* ;
orderItem : ID (ASC | DESC)? ;


// ========== REGLAS DEL LEXER ==========

// ---------- PALABRAS CLAVE
//  Insensibles a mayúsculas (estilo SQL).
//  Deben ir ANTES que ID para tener mayor prioridad.
SELECT  : [sS][eE][lL][eE][cC][tT] ;
FROM    : [fF][rR][oO][mM] ;
WHERE   : [wW][hH][eE][rR][eE] ;
ORDER   : [oO][rR][dD][eE][rR] ;
BY      : [bB][yY] ;
LIMIT   : [lL][iI][mM][iI][tT] ;
AND     : [aA][nN][dD] ;
OR      : [oO][rR] ;
ASC     : [aA][sS][cC] ;
DESC    : [dD][eE][sS][cC] ;

// ---------- OPERADORES RELACIONALES
//  >= y <= van ANTES que > y < para que '<=' no se
//  tokenice como '<' seguido de '='.
GTE : '>=' ;
LTE : '<=' ;
NEQ : '!=' ;
EQ  : '==' ;
GT  : '>'  ;
LT  : '<'  ;

// ---------- DELIMITADORES
SEMI    : ';' ;
COMMA   : ',' ;
STAR    : '*' ;
LPAREN  : '(' ;
RPAREN  : ')' ;

// ---------- LITERALES
//  NUMBER admite enteros y decimales (3, 3.14).
NUMBER  : [0-9]+ ('.' [0-9]+)? ;
STRING  : '"' ~["\r\n]* '"' ;

// ---------- IDENTIFICADORES
//  Va al final para no capturar palabras clave.
ID : [a-zA-Z_] [a-zA-Z_0-9]* ;

// ---------- COMENTARIOS
//  -- comentario de una línea (estilo SQL)
LINE_COMMENT : '--' ~[\r\n]* -> skip ;

// ---------- IGNORADOS: espacios en blanco
WS : [ \t\r\n]+ -> skip ;
