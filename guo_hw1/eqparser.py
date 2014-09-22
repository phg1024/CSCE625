# -----------------------------------------------------------------------------
# A parser for simple algebraic equations using David Beazley's PLY.
#
# It is based on the calc.py example provided in the PLY-3.4 distribution.
#
# -----------------------------------------------------------------------------
from printingcolors import *

pretty_printing_colors = {
    'FLOAT'          : bcolors.CYAN,
    'INT'            : bcolors.BLUE,
    'VARIABLENAME'   : bcolors.YELLOW,
    'SYMBOL'         : bcolors.GREEN,
    'EQUALS'         : bcolors.WHITE,
    'BINARYOP'       : bcolors.WHITE,
    'UNARYOP'        : bcolors.RED,
    'UNARYFUNCTION'  : bcolors.MAGENTA,
    }

reserved = {
   'log'  : 'LOG',
   'ln'   : 'LN',
   'sqrt' : 'SQRT',
   'root' : 'ROOT',
   'sin'  : 'SINE',
   'asin' : 'INVSINE',
   'cos'  : 'COSINE',
   'acos' : 'INVCOSINE',
   'tan'  : 'TAN',
   'atan' : 'INVTAN',
   'Diff' : 'DIFFERENTIATION',
   'Integrate'  : 'INTEGRATE'
               }

tokens = [
    'SYMBOL',
    'VARIABLENAME','INT','FLOAT',
    'PLUS','MINUS','TIMES','DIVIDE','EXPONENT','EQUALS',
    'LPAREN','RPAREN', 'COMMA']  + list(reserved.values()) 

binops = {
    '+' : 'PLUS',
    '-' : 'MINUS',
    '*' : 'TIMES',
    '/' : 'DIVIDE',
    '^' : 'EXPONENT',
    }

# Tokens

t_PLUS         = r'\+'
t_MINUS        = r'-'
t_TIMES        = r'\*'
t_DIVIDE       = r'/'
t_EXPONENT     = r'\^'
t_EQUALS       = r'='
t_LPAREN       = r'\('
t_RPAREN       = r'\)'
t_COMMA        = r','
t_VARIABLENAME = r'[a-zA-Z_][a-zA-Z0-9_]*'

def t_SYMBOL(t):
    r'e|pi'
    return t

def t_ID(t):
   r'[a-zA-Z_][a-zA-Z_0-9]*'
   t.type = reserved.get(t.value,'VARIABLENAME')    # Check for reserved words
   return t

# Read in a float. This rule has to be done before the int rule.
def t_FLOAT(t):
    r'-?\d+\.\d*(e-?\d+)?'
    t.value = float(t.value)
    return t

def t_INT(t):
    r'\d+'
    t.value = int(t.value)
    return t


# Ignored characters
t_ignore = " \t"

def t_newline(t):
    r'\n+'
    t.lexer.lineno += t.value.count("\n")
    
def t_error(t):
    print("Illegal character '%s'" % t.value[0])
    t.lexer.skip(1)
    
# Build the lexer
import ply.lex as lex
lex.lex()


# Define a Node class in order to permit explicit construction of a parse tree
class Node:
    def __init__(self,type,children=None,leaf=None):
         self.type = type
         if children:
              self.children = children
         else:
              self.children = [ ]
         self.leaf = leaf
    
    def __str__(self):
        # Produce the Parse Tree in infix form
        if ((self.type == "FLOAT") or
            (self.type == "INT") or 
            (self.type == "VARIABLENAME") or 
            (self.type == "SYMBOL")):
                return pretty_printing_colors[self.type] + str(self.leaf) + bcolors.ENDC

        if (self.type == "EQUALS"):
            return str(self.children[0]) + pretty_printing_colors[self.type] + " " + self.leaf + " " + bcolors.ENDC + str(self.children[1])

        if self.type == "BINARYOP":
            if self.leaf is '^': 
                return str(self.children[0]) + pretty_printing_colors[self.type] + self.leaf + bcolors.ENDC + str(self.children[1])
            elif self.leaf is 'Diff':
                return pretty_printing_colors[self.type] + self.leaf + bcolors.ENDC + '(' + str(self.children[0]) + ', ' + str(self.children[1]) + ')'
            else:
                # space these binary operators out
                return "(" + str(self.children[0]) + pretty_printing_colors[self.type] + " " + self.leaf + " " + bcolors.ENDC + str(self.children[1]) + ")"

        if (self.type == "UNARYOP"):
            return  "(" + pretty_printing_colors[self.type] + self.leaf + bcolors.ENDC + str(self.children) + ")"
        if (self.type == "UNARYFUNCTION"):
            return  pretty_printing_colors[self.type] + self.leaf + bcolors.ENDC + "(" + str(self.children) + ")"


    def __repr__(self):
        # Produce the Parse Tree in prefix form
        if ((self.type == "FLOAT") or
            (self.type == "INT") or 
            (self.type == "VARIABLENAME") or 
            (self.type == "SYMBOL")):
                return pretty_printing_colors[self.type] + str(self.leaf) + bcolors.ENDC

        s = "(" + pretty_printing_colors[self.type] 
        if (self.type == "EQUALS"):
            s+="=" + bcolors.ENDC 
        elif (self.type == "BINARYOP"):
            s+=self.leaf + bcolors.ENDC 
        elif (self.type == "UNARYOP"):
            s+=self.leaf + bcolors.ENDC 
        elif (self.type == "UNARYFUNCTION"):
            s+=self.leaf + bcolors.ENDC 

        s+=" "
        if type(self.children) is list:
            for child in self.children:
                s+=repr(child)
                s+=" "
            s = s[0:-1] # Gobble the extra space
        else:
                s+=repr(self.children)

        s +=  ")"
        return s

    def __eq__(self, other):
        if isinstance(other, self.__class__):
            if self.type == other.type and self.leaf == other.leaf:
                if isinstance(self.children, list) and isinstance(other.children, list):
                    for a, b in zip(self.children, other.children):
                        if a != b:
                            return False
                    return True
                elif (not isinstance(self.children, list)) and (not isinstance(other.children, list)):
                    return True
        else:
            return False

    def __ne__(self, other):
        return not self.__eq__(other)

# Precedence rules for the arithmetic operators
precedence = (
    ('left','PLUS','MINUS'),
    ('left','TIMES','DIVIDE'),
    ('right','UMINUS'),
    ('left','EXPONENT'),
    )

def p_statement_assign(p):
    'statement : expression EQUALS expression'
    p[0] = Node('EQUALS', [p[1], p[3]], '=')

# We only allow equations, if we were to uncomment this, we'd parse algebraic expressions more generally
def p_statement_expr(p):
    'statement : expression'
    p[0] = p[1] 

def p_expression_binop(p):
    '''expression : expression PLUS expression
                  | expression MINUS expression
                  | expression TIMES expression
                  | expression DIVIDE expression
                  | expression EXPONENT expression'''
    p[0] = Node('BINARYOP', [p[1], p[3]], p[2])

def p_expression_uminus(p):
    'expression : MINUS expression %prec UMINUS'
    p[0] = Node('UNARYOP', p[2], p[1])

def p_expression_binary_fun(p):
    '''expression : ROOT LPAREN expression COMMA expression RPAREN
                  | DIFFERENTIATION LPAREN expression COMMA expression RPAREN
                  | INTEGRATE LPAREN expression COMMA expression RPAREN'''
    p[0] = Node('BINARYOP', [p[3], p[5]], p[1])

def p_expression_single_fun(p):
    '''expression : LOG LPAREN expression RPAREN
                  | LN LPAREN expression RPAREN
                  | SQRT LPAREN expression RPAREN
                  | SINE LPAREN expression RPAREN
                  | COSINE LPAREN expression RPAREN
                  | TAN LPAREN expression RPAREN
                  | INVSINE LPAREN expression RPAREN
                  | INVCOSINE LPAREN expression RPAREN
                  | INVTAN LPAREN expression RPAREN'''
    p[0] = Node('UNARYFUNCTION', p[3], p[1])

def p_expression_group(p):
    'expression : LPAREN expression RPAREN'
    p[0] = p[2]

def p_expression_float(p):
    'expression : FLOAT'
    p[0] = Node('FLOAT', [], p[1])

def p_expression_int(p):
    'expression : INT'
    p[0] = Node('INT', [], p[1])

def p_expression_name(p):
    'expression : VARIABLENAME'
    p[0] = Node('VARIABLENAME', [], p[1])

def p_expression_symbol(p):
    'expression : SYMBOL'
    p[0] = Node('SYMBOL', [], p[1])

def p_error(p):
    try:
        print("Syntax error at '%s'" % p.value)
    except:  
        print("Syntax error. An equation is expected.")

import ply.yacc as yacc
yacc.yacc()

def parse(s):
    return yacc.parse(s)

