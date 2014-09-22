Interactive mode:
./equationsimplifier.py

File mode:
./equationsimplifier.py full_path_to_file


File content format:
Each line contains a single test case. A test case can be defined in the following ways:
1. Equation
	for example: x + y = 2 * x
2. Variable to solve | Equation
	for example: y | x + y = 2 * x


Misc.:
1. By default, the solver runs with the variable depth heuristic and with restarting enabled. To enable it, change restart in equationsimplifier.py to False.
2. By default, H2, variable depth heuristic, is used. To used other heuristic, change alpha_val in equationsimplifier.py.