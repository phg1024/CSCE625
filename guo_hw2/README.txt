To display help for the program: python game.py -h

Usage: game.py [-h] [-n N [N ...]] [-m M [M ...]] [-o O] [-t]

optional arguments:
  -h, --help    show this help message and exit
  -n N [N ...]  the number of matches
  -m M [M ...]  method for generating game tree
  -o O          output file for game tree
  -t            display the game tree or not

Example:
1. Generate game tree for 7 matches with minmax algorithm
	python game.py -n 7 -m minmax

2. Generate game tree for 7 matches with alpha-beta algorithm, display the tree on screen
	python game.py -n 7 -m ab -t

3. Generate game tree for 7 matches with alpha-beta algorithm, display the tree on screen and output the tree as a dot file
	python game.py -n 7 -m ab -t -o tree7_ab.dot
	

Note:
1. The generated dot file can be used to produce game tree image directly with graphviz.
Example:
	dot tree7_ab.dot -Tpng -o 7_ab.png

2. Examples of game trees generated for 5 nodes and 7 nodes are included in the zip file:
	5_ab.png, 5_minmax.png, 7_ab.png, 7_minmax.png