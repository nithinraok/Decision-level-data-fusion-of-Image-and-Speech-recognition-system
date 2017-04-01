import sys
def squared(a):
    b = a*a
    return b
if __name__ == '__main__':
    x = float(sys.argv[1])
    sys.stdout.write(str(squared(x)))