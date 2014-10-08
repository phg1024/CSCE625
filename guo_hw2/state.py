__author__ = 'Peihong Guo'

from printcolors import *


class State(object):
    valid_actions = [1, 2, 3]

    def __init__(self, player, n, lev=0, parent=None):
        self.player = player
        self.n = n      # remaining matches after taking k matches
        self.parent = parent
        self.children = []
        self.utility = -1
        self.lev = lev

    def __eq__(self, other):
        return self.player == other.player and self.n == other.n

    def k(self):
        # returns the number of matches taken in previous by the opponent
        if self.parent:
            return self.parent.n - self.n
        else:
            return 0

    def act(self, x):
        if self.n >= x:
            child = State(self.next_player(), self.n-x, self.lev+1, self)
            return child
        else:
            return None

    def is_terminal(self):
        return self.n == 0

    def compute_utility(self):
        if self.player == 'max':
            self.utility = 1
        else:
            self.utility = 0

    def next_player(self):
        if self.player == 'max':
            return 'min'
        else:
            return 'max'

    def __repr__(self):
        return str(self.player) + ' ' + colorize(str(self.k()), 'blue') + ' ' + colorize(str(self.n), 'green') + ' ' + colorize(str(self.utility), 'red')

    def generate_children(self):
        if self.is_terminal():
            return list()

        self.children = list()
        for a in State.valid_actions:
            child = self.act(a)
            if child:
                self.children.append(child)
