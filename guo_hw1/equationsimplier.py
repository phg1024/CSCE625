#!/usr/bin/env python
import eqparser
import eqsimplifier
import time
import sys

restart = True  # True to enable restarting, False to disable it
alpha_val = 0   # 0 for H2, 1 for H1, 0.5 for 0.5 * (H1 + H2)

def interactive():
    while 1:
        try:
            s = raw_input('Eq >. ')
            x = raw_input('Var >. ')
        except EOFError:
            print
            break
        p = eqparser.parse(s)
        print 'This is parsed at: ' + repr(p)
        print 'This is parsed at: ' + str(p)
        print 'Variable to evaluate: ' + x

        print 'Simplifying with AStar search:'
        start = time.time()
        res = eqsimplifier.simplify(p, x, restart=restart, alpha_val=alpha_val)
        end = time.time()
        print 'Simplified in ', end-start, ' seconds'
        print res

def processFiles(files):
    for f in files:
        print 'Processing file', f
        with open(f, 'r') as fhandle:
            equations = fhandle.read().split('\n')
            print equations
            for equation in equations:
                if equation[0] == '#':
                    continue
                varequ = equation.split('|')
                if len(varequ) == 2:
                    var, equ = varequ
                else:
                    var = 'x'
                    equ = varequ[0]

                var = var.strip()
                equ = eqparser.parse( equ.strip() )

                print 'var: %s, equ: %s' % (var, equ)
                print 'Simplifying with AStar search:'
                start = time.time()
                res = eqsimplifier.simplify(equ, var, restart=restart, alpha_val=alpha_val)
                end = time.time()
                print 'Simplified in ', end-start, ' seconds'
                print res                

if __name__ == '__main__':
    if len(sys.argv) > 1:
        processFiles(sys.argv[1:])
    else:
        interactive()