#!/usr/bin/env python
__author__ = 'Peihong Guo'

import argparse
import minmax
import alpha_beta_prune

generators = {'minmax': minmax, 'ab':alpha_beta_prune}

show_tree = False

def print_game_tree(node):
    if show_tree:
        print node.lev*'    ', repr(node)
    nc = 1  # node count of this sub tree
    if node.children:
        for child in node.children:
            nc += print_game_tree(child)
    return nc


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('-n', type=int, nargs='+',
                       help='the number of matches')
    parser.add_argument('-m', type=str, nargs='+', default=['ab'],
                       help='method for generating game tree')
    parser.add_argument('-t', action='store_true', help='display the game tree or not')

    args = parser.parse_args()
    show_tree = args.t
    for n in args.n:
        print 'number of matches:', n
        for method in args.m:
            generator = generators[method]
            print 'using', generator.__name__, 'algorithm'
            tree = generator.generate_game_tree(n)
            nodecount = print_game_tree(tree)
            if tree.utility == 1:
                print 'player 1 wins'
            else:
                print 'player 2 wins'

            print 'node count = ', nodecount
