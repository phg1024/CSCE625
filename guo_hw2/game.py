#!/usr/bin/env python
__author__ = 'Peihong Guo'

import argparse

class State(object):
    def __init__(self, player, n, parent=None):
        self.player = player
        self.n = n      # remaining matches after taking k matches
        self.parent = parent
        self.children = []
        self.utility = -1

    def __eq__(self, other):
        return self.player == other.player and self.k == other.k and self.n == other.n

    def k(self):
        # returns the number of matches taken in previous by the opponent
        if self.parent:
            return self.n - self.parent.n
        else:
            return 0

    def is_terminal(self):
        return self.n == 0

    def next_player(self):
        if self.player == 'max':
            return 'min'
        else:
            return 'max'

def generate_children(n):
    if n.is_terminal():
        return []

    children = []
    next_player = n.next_player()
    for c in [1, 2, 3]:
        if n.n - c >= 0:
            children.append(State(next_player, n.n - c, n))
    return children

def print_game_tree(n):
    print n.player, n.n, n.utility
    if n.children:
        for child in n.children:
            print_game_tree(child)

def generate_game_tree(n):
    print 'generating game tree for %d matches ...' % n
    # each one can remove 1, 2 or 3 matches

    root = State('max', n)
    s = list()
    s.append((root, 0))

    while s:
        node, c = s.pop(0)

        if c == 0:
            # first visit, just add its children
            s.append((node, 1))
            node.children = generate_children(node)
            for child in node.children:
                s.append((child, 0))
        else:
            # second visit, update the utility value
            if node.is_terminal():
                if node.player == 'max':
                    node.utility = 1
                else:
                    node.utility = 0
            else:
                if node.player == 'min':
                    node.utility = min([child.utility for child in node.children])
                else:
                    node.utility = max([child.utility for child in node.children])

    print 'generated'
    return root

if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('nmatches', metavar='n', type=int, nargs='+',
                       help='the number of matches')

    args = parser.parse_args()
    for n in args.nmatches:
        tree = generate_game_tree(n)
        print_game_tree(tree)
