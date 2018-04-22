import sys
def sum(a, b):
    answer = a+b
    print(answer)

if __name__== "__main__":
    sum(int(sys.argv[1]), int(sys.argv[2]))