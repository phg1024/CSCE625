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

        @staticmethod
        def getColor(name):
            if name == 'blue':
                return bcolors.BLUE
            elif name == 'green':
                return bcolors.GREEN
            elif name == 'red':
                return bcolors.RED
            elif name == 'cyan':
                return bcolors.CYAN
            elif name == 'white':
                return bcolors.WHITE
            elif name == 'yellow':
                return bcolors.YELLOW
            elif name == 'magenta':
                return bcolors.MAGENTA
            elif name == 'grey':
                return bcolors.GREY
            elif name == 'black':
                return bcolors.BLACK
            else:
                return bcolors.DEFAULT

    def colorize(s, color):
        return bcolors.getColor(color) + s + bcolors.ENDC

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

    def colorize(self, s, color):
        return self.getColor(color) + s + bcolors.ENDC
