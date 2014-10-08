__author__ = 'Peihong Guo'

from state import State
infinity = 1e10


def generate_game_tree(n):
    root = State('max', n)
    maxv = -infinity
    for a in State.valid_actions:
        child = root.act(a)
        if child:
            root.children.append(child)
            maxv = max(maxv, min_value(child))

    root.utility = maxv
    return root


def min_value(s):
    if s.is_terminal():
        s.compute_utility()
        return s.utility
    else:
        v = infinity
        for a in State.valid_actions:
            child = s.act(a)
            if child:
                s.children.append(child)
                v = min(v, max_value(child))
        s.utility = v
        return v


def max_value(s):
    if s.is_terminal():
        s.compute_utility()
        return s.utility
    else:
        v = -infinity
        for a in State.valid_actions:
            child = s.act(a)
            if child:
                s.children.append(child)
                v = max(v, min_value(child))
        s.utility = v
        return v
