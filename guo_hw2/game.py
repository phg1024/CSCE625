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


def write_game_tree(root, filename):
    f = open(filename, 'w')
    f.write('digraph{\n')
    Q = list()
    Q.append((0, 0, root))
    nc = 0
    ranks = dict()
    gametree_str = ''
    while Q:
        lev, label, cur = Q.pop(0)
        if lev in ranks:
            ranks[lev].append(label)
        else:
            ranks[lev] = list()
            ranks[lev].append(label)

        gametree_str += str(label) + '[' + 'label=' + str(cur.n) + '];\n'
        for child in cur.children:
            nc += 1
            Q.append((lev+1, nc, child))
            gametree_str += str(label) + '->' + str(nc) + ';\n'

    ranks_graph = []
    ranks_info_str = ''
    for rank in ranks:
        if rank % 2 == 0:
            player = '"max' + str(rank // 2) + '"'
        else:
            player = '"min' + str(rank // 2) + '"'
        ranks_graph.append(player)
        nodes = ';'.join([str(x) for x in ranks[rank]])
        ranks_info_str += '{rank = same; ' + player + '; ' + nodes + '}\n'

    f.write('{\n')
    f.write('node [shape=plaintext];\n')
    f.write('->'.join(ranks_graph) + '\n')
    for rank_node in ranks_graph:
        f.write(rank_node + '[label=' + rank_node[0:4] + '"];\n')
    f.write('}\n')

    f.write('{\n')
    f.write(gametree_str)
    f.write('}\n')

    f.write(ranks_info_str)
    f.write('}')

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('-n', type=int, nargs='+',
                       help='the number of matches', default=[7])
    parser.add_argument('-m', type=str, nargs='+', default=['ab'],
                       help='method for generating game tree')
    parser.add_argument('-o', type=str,
                       help='output file for game tree')
    parser.add_argument('-t', action='store_true', help='display the game tree or not')

    args = parser.parse_args()
    print args
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

            if args.o:
                write_game_tree(tree, args.o)
