import sys
from antlr4 import CommonTokenStream, FileStream
from QueryBitLexer import QueryBitLexer
from QueryBitParser import QueryBitParser


def main():
    if len(sys.argv) != 2:
        print("Uso: python main.py <archivo.qb>")
        sys.exit(1)

    archivo = sys.argv[1]
    input_stream = FileStream(archivo, encoding='utf-8')

    lexer  = QueryBitLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = QueryBitParser(stream)
    tree   = parser.program()      # regla inicial

    # imprimir el árbol sintáctico en formato texto
    print(tree.toStringTree(recog=parser))


main()
