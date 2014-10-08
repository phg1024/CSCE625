__author__ = 'Peihong Guo'

from state import State
infinity = 1e10


def generate_game_tree(n):
    root = State('max', n)
    max_value(root, -infinity, infinity)
    return root


def max_value(s, alpha, beta):
    if s.is_terminal():
        s.compute_utility()
        return s.utility
    else:
        v = -infinity
        for a in State.valid_actions:
            child = s.act(a)
            if child:
                s.children.append(child)
                v = max(v, min_value(child, alpha, beta))
                if v >= beta:
                    break

                alpha = max(alpha, v)

        s.utility = v
        return v


def min_value(s, alpha, beta):
    if s.is_terminal():
        s.compute_utility()
        return s.utility
    else:
        v = infinity
        for a in State.valid_actions:
            child = s.act(a)
            if child:
                s.children.append(child)
                v = min(v, max_value(child, alpha, beta))

                if v <= alpha:
                    break

                beta = min(beta, v)

        s.utility = v
        return v

