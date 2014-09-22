
enable_colors = True 

if enable_colors: 

    class bcolors:
        BLUE = '\033[94m'
        GREEN = '\033[92m'
        RED = '\033[91m'
        CYAN = '\033[96m'
        WHITE = '\033[97m'
        YELLOW = '\033[93m'
        MAGENTA = '\033[95m'
        GREY = '\033[90m'
        BLACK = '\033[90m'
        DEFAULT = '\033[99m'
        ENDC = '\033[0m'

else:

    class bcolors:
        BLUE = ''
        GREEN = ''
        RED = ''
        CYAN = ''
        WHITE = ''
        YELLOW = ''
        MAGENTA = ''
        GREY = ''
        BLACK = ''
        DEFAULT = ''
        ENDC = ''

