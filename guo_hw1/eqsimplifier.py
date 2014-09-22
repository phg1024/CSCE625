import copy
import rules
import heapq

def BFS(node, visitor):
	# BFS on the tree of equation
	Q = []
	Q.append((0, node))
	while Q:
		lev, cur = Q.pop(0)
		visitor.visit(cur, level=lev)

		if isinstance(cur.children, list):
			for c in cur.children:
				Q.append((lev+1, c))
		else:
			Q.append((lev+1, cur.children))

def height(p):
	if p.type in ['VARIABLENAME', 'SYMBOL', 'FLOAT', 'INT']:
		return 1
	else:
		if isinstance(p.children, list):
			return 1 + max([height(c) for c in p.children])
		else:
			return 1 + height(p.children)

def VariableDepth(p, x):
	class DepthAccumulator(object):
		def __init__(self, x):
			self.depthSum = 0
			self.x = x

		def visit(self, node, level):
			if node.type == 'VARIABLENAME' and node.leaf == self.x:
				self.depthSum = max(self.depthSum, level)

	visitor = DepthAccumulator(x)
	BFS(p, visitor)
	return visitor.depthSum


def FindVariable(p, x):
	#print p.type, str(p)
	if p.type == 'VARIABLENAME':
		return p.leaf == x
	elif p.type in ['SYMBOL', 'FLOAT', 'INT', 'EQUALS']:
		return False

	if isinstance(p.children, list):
		if p.children == []:
			return False

		for child in p.children:
			if FindVariable(child, x):
				return True
		return False
	else:
		return FindVariable(p.children, x)

def CountVariables(p):
	class Counter(object):
		def __init__(self):
			self.count = 0

		def visit(self, node, level):
			if node.type == 'VARIABLENAME':
				self.count += 1

	counter = Counter()
	BFS(p, counter)
	return counter.count

def CountLeafs(p):
	class Counter(object):
		def __init__(self):
			self.count = 0

		def visit(self, node, level):
			self.count += 1

	counter = Counter()
	BFS(p, counter)
	return counter.count

class State(object):
	alpha = 0.0
	def __init__(self, p, x, key, g=0):
		self.p = p
		self.x = x
		self.key = key
		self.h = State.alpha * self.heuristic() + (1.0-State.alpha) * self.heuristic2()
		self.g = g
		self.f = self.g + self.h

	def heuristic(self):
		# sum of max depth in both side of eqution
		h = height(self.p.children[0]) + height(self.p.children[1])

		# if the variable appears on RHS, add one to h
		if FindVariable(self.p.children[1], self.x):
			h += 1
		return h

	def heuristic2(self):
		h = VariableDepth(self.p.children[0], self.x) + VariableDepth(self.p.children[1], self.x)

		# if the variable appears on RHS, add one to h
		if FindVariable(self.p.children[1], self.x):
			h += 1
		return h

	def __eq__(self, other):
		return (isinstance(other, self.__class__)
			and self.key == other.key)

	def __ne__(self, other):
		return not self.__eq__(other)

def simplify(p, x, method='AStar', restart=True, alpha_val=0.0):
	if p.type != 'EQUALS':
		return 'Not a valid equation!'

	State.alpha = alpha_val
	if method == 'AStar':
		specs = {'maxSteps': 32, 'restart':restart}
		simplified = simplify_with_AStar_Search(p, x, specs)
	else:
		specs = {'maxLevel':32}
		simplified = simplify_with_BFS(p, x, specs)		

	return simplified

def isBetter(equ_new, equ, x):
	#print 'Comparing', equ_new.p, 'and', equ.p

	if equ_new.p.children[0].leaf == x and not FindVariable(equ_new.p.children[1], x):
		if FindVariable(equ.p.children[1], x):
			return True
		if equ.p.children[0].leaf != x:
			return True

	if equ.p.children[0].leaf == x and not FindVariable(equ.p.children[1], x):
		if FindVariable(equ_new.p.children[1], x):
			return False
		if equ_new.p.children[0].leaf != x:
			return False

	# compare number of leafs
	leafCount_new = CountLeafs(equ_new.p)
	leafCount = CountLeafs(equ.p)
	if leafCount_new < leafCount:
		return True
	elif leafCount_new > leafCount:
		return False
	
	# compare h
	if equ_new.h < equ.h:
		return True
	elif equ_new.h > equ.h:
		return False

	# compare number of variables
	vcount_new = CountVariables(equ_new.p)
	vcount = CountVariables(equ.p)
	if vcount_new < vcount:
		return True
	elif vcount_new > vcount:
		return False

	# compare number of leafs on the left
	leafCount_left_new = CountLeafs(equ_new.p.children[0])
	leafCount_left = CountLeafs(equ.p.children[0])
	if leafCount_left_new < leafCount_left:
		return True
	elif leafCount_left_new > leafCount_left:
		return False

	return False

def isGoalState(p, x):
	#print 'checking goal'
	if p.children[0].leaf ==  x:
		#print 'left okay'
	 	if not FindVariable(p.children[1], x):
	 		#print 'right okay'
			if rules.is_number(p.children[1]) or rules.is_fraction(p.children[1]):
				#print 'Goal state'
				return True
		else:
			#print 'right not okay'
			pass
	else:
		#print 'left not okay'
		pass
	
	return False

def transform(p, x):
	res = []
	for rule in rules.Rules:
		res.extend(rules.apply(rule, p))

	return res

def simplify_with_AStar_Search(p, x, specs):
	s = State(p, x, repr(p))
	Q = []
	visited = {}
	frontier = {}

	maxSteps = specs['maxSteps']
	doRestart = specs['restart']
	best = s

	Q.append((s.f, s))
	frontier[s.key] = s
	while Q:
		f, cur = heapq.heappop(Q)
		#print 'f = %d, g = %d, h = %d, expr: %s' % (cur.f, cur.g, cur.h, repr(cur.p))
		del frontier[cur.key]
		visited[cur.key] = True

		if isBetter(cur, best, x):
			best = copy.deepcopy(cur)
			print 'Best:', str(best.p)
			if isGoalState(best.p, x):
				#print 'Goal'
				break
			elif doRestart:
				Q = []
				visited = {}
				frontier = {}
				Q.append((best.f, best))
				frontier[best.key] = best
				continue

		if cur.g < maxSteps:
			variations = transform(cur.p, x)
			for v in variations:
				#print repr(v), 'visited = ', repr(v) in visited
				v_key = repr(v)
				if v_key not in visited and v_key not in frontier:
					vs = State(v, x, v_key, cur.g+1)
					heapq.heappush(Q, (vs.f, vs))
					frontier[vs.key] = vs
				elif v_key in frontier:
					for i, (fval, item) in enumerate(Q):
						if item.key == v_key:
							fval, vs = Q.pop(i)
							heapq.heapify(Q)
							vs.g = min(vs.g, cur.g+1)
							vs.f = vs.g + vs.h
							heapq.heappush(Q, (vs.f, vs))	

	return best.p

def simplify_with_BFS(p, x, specs):
	s = State(p, x, repr(p))
	Q = []
	visited = {}
	frontier = {}

	maxLev = specs['maxLevel']
	best = s

	Q.append((s, 0))
	frontier[s.key] = True
	while Q:
		cur, lev = Q[0]
		#print repr(cur.p)
		Q.pop(0)

		del frontier[cur.key]
		visited[cur.key] = True

		if isBetter(cur, best, x):
			best = copy.deepcopy(cur)
			print 'Best:', str(best.p)
			if isGoalState(best.p, x):
				break

		if lev < maxLev:
			variations = transform(cur.p, x)
			for v in variations:
				#print repr(v), 'visited = ', repr(v) in visited
				v_repr = repr(v)
				if v_repr not in visited and v_repr not in frontier:
					Q.append((State(v, x, v_repr), lev+1))
					frontier[v_repr] = True

	return best.p



