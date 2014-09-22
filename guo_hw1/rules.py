import eqparser
import copy
import math

class RuleException(Exception):
	pass

Operators = ['BINARYOP', 'UNARYOP', 'UNARYFUNCTION']
BinaryOperators = eqparser.binops
UnaryOperators = ['-']
UnaryFunctions = ['sin', 'cos', 'tan', 'log', 'ln', 'sqrt', 'asin', 'acos', 'atan']
Numbers = ['FLOAT', 'INT']
NumberOrVariable = ['FLOAT', 'INT', 'VARIABLENAME']
InverseOperator = {'+':'-', '-':'+', '*':'/', '/':'*'}
InverseFunction = {'sin':'asin', 'cos':'acos', 'tan':'atan'}

def is_operator(c):
	return c.type in Operators

def is_number(c):
	return c.type in Numbers

def is_fraction(c):
	if c.leaf == '/' and is_number(c.children[0]) and is_number(c.children[1]):
		return (c.children[1].leaf != 0) and (c.children[0].leaf % c.children[1].leaf != 0)

def is_variable(c):
	return c.type == 'VARIABLENAME'

def is_number_or_variable(c):
	return c.type in NumberOrVariable

def proper_type(children):
	if any([c.type == 'FLOAT' for c in children]):
		return 'FLOAT'
	else:
		return 'INT'

def binary_operation(operator, operands):
	t = proper_type(operands)
	a, b = [o.leaf for o in operands]
	if a == 'undefined' or b == 'undefined':
		return t, 'undefined'
	if operator == '+':
		v = a + b
	elif operator == '-':
		v = a - b
	elif operator == '*':
		v = a * b
	elif operator == '/':
		if b == 0:
			v = 'undefined'
		else:
			v = a / b
	elif operator == '^':
		v = a ** b
	elif operator == 'root':
		v = math.pow(a, 1.0/b)
	return t, v

def eval_binary(equ):
	res = []
	Q = []
	Q.append(equ)
	while Q:
		cur = Q.pop(0)
		#print cur.leaf
		if( cur.type == 'BINARYOP' and is_number(cur.children[0]) and is_number(cur.children[1])):
			if cur.leaf == '/' and (cur.children[1].leaf != 0) and (cur.children[0].leaf % cur.children[1].leaf != 0):
				# not divisible
				pass
			else:
				tmpNode = cur

				cur.type, cur.leaf = binary_operation(cur.leaf, cur.children)
				cur.children = []
				#print repr(equ)
				res.append(copy.deepcopy(equ))

				cur = tmpNode
		elif cur.leaf == 'Diff' and is_number(cur.children[0]):
			tmpNode = cur

			cur.type, cur.leaf = 'INT', 0
			cur.children = []
			#print repr(equ)
			res.append(copy.deepcopy(equ))

			cur = tmpNode

		if isinstance(cur.children, list):
			for c in cur.children:
				Q.append(c)
		else:
			Q.append(cur.children)
	
	return res

def unary_operation(operator, operands):
	t = operands.type
	if operands.leaf == 'undefined':
		return t, 'undefined'
	if operator == '-':
		v = -operands.leaf
	return t, v

def eval_unary(equ):
	res = []
	Q = []
	Q.append(equ)
	while Q:
		cur = Q.pop(0)
		if cur.type == 'UNARYOP' and is_number(cur.children):
			tmpNode = cur

			cur.type, cur.leaf = unary_operation(cur.leaf, cur.children)
			cur.children = []
			#print repr(equ)
			res.append(copy.deepcopy(equ))

			cur = tmpNode
		if isinstance(cur.children, list):
			for c in cur.children:
				Q.append(c)
		else:
			Q.append(cur.children)

	return res

def unary_function_operation(operator, operands):
	t = operands.type
	if operands.leaf == 'undefined':
		return t, 'undefined'
	if operator == 'log':
		if operands.leaf <= 0:
			v = 'undefined'
		else:
			v = math.log10(operands.leaf)
	elif operator == 'ln':
		if operands.leaf <= 0:
			v = 'undefined'
		else:
			v = math.log(operands.leaf)
	elif operator == 'sqrt':
		if operands.leaf <= 0:
			v = 'undefined'
		else:
			v = math.sqrt(operands.leaf)
	elif operator == 'sin':
		v = math.sin(operands.leaf)
	elif operator == 'cos':
		v = math.cos(operands.leaf)
	elif operator == 'tan':
		v = math.tan(operands.leaf)
	elif operator == 'asin':
		if operands.leaf > 1 or operands.leaf < -1:
			v = 'undefined'
		else:
			v = math.asin(operands.leaf)
	elif operator == 'acos':
		if operands.leaf > 1 or operands.leaf < -1:
			v = 'undefined'
		else:
			v = math.acos(operands.leaf)
	elif operator == 'atan':
		v = math.atan(operands.leaf)
	return t, v

def eval_unary_function(equ):
	res = []
	Q = []
	Q.append(equ)
	while Q:
		cur = Q.pop(0)
		if cur.type == 'UNARYFUNCTION' and is_number(cur.children):
			tmpNode = cur

			cur.type, cur.leaf = unary_function_operation(cur.leaf, cur.children)
			cur.children = []
			#print repr(equ)
			res.append(copy.deepcopy(equ))

			cur = tmpNode
		if isinstance(cur.children, list):
			for c in cur.children:
				Q.append(c)
		else:
			Q.append(cur.children)
	
	return res

def match_pattern(node, pattern):
	p = pattern.pattern
	#print repr(p)
	#print 'matching', node, 'with', p
	#if repr(p) == repr(node):
	#	print 'matching...'

	D = {}
	Q = []
	Q.append((node, p))
	while Q:
		a, b = Q.pop(0)
		if b.leaf in pattern.keywords:
			#print 'reserved:', b.leaf, a
			if b.leaf in D:
				#print 'found'
				D[b.leaf].append(a)
			else:
				#print 'not found'
				D[b.leaf] = [a]
			continue

		if a.type != b.type or a.leaf != b.leaf:
			#print 'not match', a, b
			return False, {}
		if type(a.children) is not type(b.children):
			#print 'children not match', a, b
			return False, {}
		#print a, b
		if isinstance(a.children, list) and isinstance(b.children, list):
			for a, b in zip(a.children, b.children):
				Q.append((a, b))
		else:
			Q.append((a.children, b.children))

	# check the symbol table, make sure no constain on the symbols is violated
	for sym in D:
		tbl = D[sym]
		x = tbl[0]
		for y in tbl:
			if y != x:
				#print 'symbol', sym, 'have multiple matches'
				return False, {}

	return True, D

def modify_node(symbols, modifier):
	expr = copy.deepcopy(modifier)
	#print 'modifier', expr
	#for sym in symbols:
	#	print 'sym', sym, symbols[sym]	

	Q = []
	Q.append(expr)
	while Q:
		cur = Q.pop(0)
		
		#print 'node', cur.leaf
		if cur.leaf in symbols:
			#print 'found symbol', cur.leaf
			# replace this part of tree with the symbol
			sym = symbols[cur.leaf][0]
			cur.leaf = sym.leaf
			cur.type = sym.type
			cur.children = sym.children

		elif isinstance(cur.children, list):
			for c in cur.children:
				Q.append(c)
		else:
			Q.append(cur.children)

	#print 'expr = ', expr
	return expr	

class Pattern(object):
	def __init__(self, keywords, pattern, modifier):
		self.keywords = keywords
		self.pattern = eqparser.parse(pattern)
		self.modifier = eqparser.parse(modifier)
		print 'pattern:', self.pattern, ' -> ', self.modifier

Patterns = {
	# move
	'move': Pattern(['a', 'b'], 'a=b', 'b=a'),
	'move_pls': Pattern(['a', 'b', 'c'], 'a+b=c', 'a=c-b'),
	'move_mns': Pattern(['a', 'b', 'c'], 'a-b=c', 'a=c+b'),
	'move_mul': Pattern(['a', 'b', 'c'], 'a*b=c', 'a=c/b'),
	'move_div': Pattern(['a', 'b', 'c'], 'a/b=c', 'a=c*b'),
	'move_pwd': Pattern(['a', 'b', 'c'], 'a^b=c', 'a=root(c, b)'),

	# inverse function
	'inv_sqrt': Pattern(['x', 'y'], 'sqrt(x)=y', 'x=y^2'),
	'inv_sin': Pattern(['x', 'y'], 'sin(x)=y', 'x=asin(y)'),
	'inv_cos': Pattern(['x', 'y'], 'cos(x)=y', 'x=acos(y)'),
	'inv_tan': Pattern(['x', 'y'], 'tan(x)=y', 'x=atan(y)'),
	'inv_asin': Pattern(['x', 'y'], 'asin(x)=y', 'x=sin(y)'),
	'inv_acos': Pattern(['x', 'y'], 'acos(x)=y', 'x=cos(y)'),
	'inv_atan': Pattern(['x', 'y'], 'atan(x)=y', 'x=tan(y)'),
	'inv_log': Pattern(['x', 'y'], 'log(x)=y', 'x=10^y'),
	'inv_ln': Pattern(['x', 'y'], 'ln(x)=y', 'x=e^y'),
	'inv_exp': Pattern(['x', 'y'], 'e^x=y', 'x=ln(y)'),
	'inv_pwd10': Pattern(['x', 'y'], '10^x=y', 'x=log(y)'),

	# associativity
	'ass_pls': Pattern(['a', 'b', 'c'], '(a+b)+c', 'a+(b+c)'),
	'ass_pls_mns': Pattern(['a', 'b', 'c'], '(a+b)-c', '(a-c)+b'),
	'ass_mns': Pattern(['a', 'b', 'c'], '(a-b)-c', 'a-(b+c)'),
	'ass_mns2': Pattern(['a', 'b', 'c'], 'a-(b-c)', '(a-b)+c'),
	'ass_mns3': Pattern(['a', 'b', 'c'], 'a-(b+c)', '(a-b)-c'),
	'ass_mul': Pattern(['a', 'b', 'c'], '(a*b)*c', 'a*(b*c)'),
	'ass_mul_div': Pattern(['a', 'b', 'c'], '(a*b)/c', 'a*(b/c)'),
	'ass_mul_div2': Pattern(['a', 'b', 'c'], 'a*(b/c)', '(a*b)/c'),
	'ass_div': Pattern(['a', 'b', 'c'], '(a/b)/c', 'a/(b*c)'),
	'ass_div2': Pattern(['a', 'b', 'c'], 'a/(b/c)', '(a/b)*c'),
	'ass_div3': Pattern(['a', 'b', 'c'], 'a/(b*c)', '(a/b)/c'),
	'ass_pwd': Pattern(['a', 'b', 'c'], '(a^b)^c', 'a^(b*c)'),

	# commutivity
	'com_pls': Pattern(['a', 'b'], 'a+b', 'b+a'),
	'com_mul': Pattern(['a', 'b'], 'a*b', 'b*a'),

	# distribution
	'dist': Pattern(['a', 'b', 'c'], 'a*(b+c)', 'a*b+a*c'),
	'dist1': Pattern(['a', 'b', 'c'], 'a*(b-c)', 'a*b-a*c'),
	'dist2': Pattern(['a', 'b', 'c'], '(a+b)/c', 'a/c+b/c'),
	'dist2': Pattern(['a', 'b', 'c'], '(a-b)/c', 'a/c-b/c'),
	'inv_dist': Pattern(['a', 'b', 'c'], 'a*b+a*c', 'a*(b+c)'),
	'inv_dist1': Pattern(['a', 'b', 'c'], 'a*b-a*c', 'a*(b-c)'),
	'inv_dist2': Pattern(['a', 'b', 'c'], 'a/c+b/c', '(a+b)/c'),
	'inv_dist3': Pattern(['a', 'b', 'c'], 'a/c-b/c', '(a-b)/c'),
	'inv_dist4': Pattern(['a', 'b', 'c'], 'a+a*b', 'a*(1+b)'),
	'inv_dist5': Pattern(['a', 'b', 'c'], 'a+a', 'a*2'),
	'inv_dist6': Pattern(['a', 'b', 'c'], 'a-a*b', 'a*(1-b)'),
	'inv_dist7': Pattern(['a', 'b', 'c'], 'a*b-a', 'a*(b-1)'),
	'inv_dist8': Pattern(['a', 'b', 'c'], 'a-a', '0'),

	# 0, 1 rules
	'add_zero': Pattern(['a'], 'a+0', 'a'),
	'mns_zero': Pattern(['a'], 'a-0', 'a'),
	'mul_zero': Pattern(['a'], 'a*0', '0'),
	'pwd_zero': Pattern(['a'], 'a^0', '1'),
	'mul_one': Pattern(['a'], 'a*1', 'a'),
	'div_one': Pattern(['a'], 'a/1', 'a'),
	'pwd_one': Pattern(['a'], 'a^1', 'a'),

	# identities
	'sin2pcos2': Pattern(['x'], 'sin(x)^2+cos(x)^2', '1'),
	'expemx': Pattern(['a', 'b', 'x'], 'e^(a*x) * e^(b*x)', 'e^((a+b)*x)'),	

	# differentiation
	'diff_self': Pattern(['x'], 'Diff(x, x)', '1'),
	'diff_poly': Pattern(['x', 'y'], 'Diff(x^y, x)', 'y*x^(y-1)'),
	'diff_pls': Pattern(['x', 'y', 'z'], 'Diff(x+y, z)', 'Diff(x, z) + Diff(y, z)'),
	'diff_mns': Pattern(['x', 'y', 'z'], 'Diff(x-y, z)', 'Diff(x, z) - Diff(y, z)'),
	'diff_mul': Pattern(['x', 'y', 'z'], 'Diff(x*y, z)', 'Diff(x, z) * y + x * Diff(y, z)'),
	'diff_div': Pattern(['x', 'y', 'z'], 'Diff(x/y, z)', '(Diff(x, z) * y - x * Diff(y, z))/(y*y)'),

	# integration
	# not included yet

	# special rules
	'inv_inv': Pattern(['x'], '1/(1/x)', 'x'),
	'pwd_sum': Pattern(['x', 'a', 'b'], 'x^a * x^b', 'x^(a+b)'),
}

def tryMatchPattern(equ, node, pattern, S):
	#print 'equ = ', equ, 'trying pattern', pattern.pattern, ' -> ', pattern.modifier
	matched, symbols = match_pattern(node, pattern)
	if matched:
		#print 'match found'
		# keep the reference to original node
		tmpNode = eqparser.Node(node.type, node.children, node.leaf)

		# point node to the modified node
		mnode = modify_node(symbols, pattern.modifier)
		node.leaf = mnode.leaf
		node.children = mnode.children
		node.type = mnode.type

		#print 'modified node', node
		#print 'modified equation', equ
		# save the variation
		S.append(copy.deepcopy(equ))

		# recover the node
		node.type = tmpNode.type
		node.children = tmpNode.children
		node.leaf = tmpNode.leaf

def apply_patterns(equ):
	res = []
	Q = []
	Q.append(equ)
	while Q:
		cur = Q.pop(0)
		
		for p in Patterns:
			tryMatchPattern(equ, cur, Patterns[p], res)

		if isinstance(cur.children, list):
			for c in cur.children:
				if c.type in Operators:
					Q.append(c)
		else:
			Q.append(cur.children)
	
	return res	


Rules = {
	'eval_binary': eval_binary,
	'eval_unary': eval_unary,
	'eval_unary_function': eval_unary_function,
	'patterns': apply_patterns
}

def apply(rule, equ):
	return Rules[rule](equ)
