import time
import math

def load(fileName):
    '''Load a text file into memory.'''
    out = []
    with open(fileName) as txt:
        for line in txt:
            line_str = line.split(',')
            line_num = [float(i) for i in line_str]
            out.append(line_num)

    return out

def RMS(vec):
    '''Computes the RMS value of signal'''
    if type(vec[0])!=float and type(vec[0])!=int:
        raise TypeError('Error: Input is not a list containing numbers')
    
    sums = 0
    for x in vec:
        sqr = x**2
        sums+=sqr
    
    RMS_out = math.sqrt(sums/len(vec))
    return RMS_out

def LL(vec,t_len=0.02):
    '''Computes the line length of a signal'''
    n = len(vec)
    if type(vec[0])!=float and type(vec[0])!=int:
        raise TypeError('Error: Input is not a list containing numbers')
    dX = t_len
    dX_2 = dX**2
    sums = 0
    for i in range(1,len(vec)):
        
        dY = vec[i] - vec[i-1]
        dist = math.sqrt(dX_2 + dY**2)
        sums+=dist
    return sums
    

def bun(A,B):
    '''Computes the nonlinear operator of two vectors, A and B.
    Currently, the nonlinear operator is simply the euclidean distance
    between the two vectors-- |A-B|'''
    if len(A) != len(B):
        raise IndexError('Error: Matrices are not identical in length!')

    sum_full = 0
    for i in range(0,len(A)):
        sum_i = (A[i] - B[i])**2
        sum_full += sum_i
    
    return (sum_full)**0.5

def bun_mat(A,B):
    '''Computes the nonlinear operator of two matrices, A and B.
    Note that if A or B is simply a vector/list, it must be made
    into a list of lists of length 1, ie [[1,2,3]]'''
    out_mat = []
    for i in range(0,len(A)):
        A_vec = A[i]
        row_i = []
        for j in range(0,len(B)):
            B_vec = B[j]

            bun_i_j = bun(A_vec,B_vec)
            row_i.append(bun_i_j)
        
        if len(row_i)==1:
            row_i=row_i[0]
        out_mat.append(row_i)
    
    return out_mat

def mult_mat_vec(mat,vec):
    '''Compute the operation OUT = Mat*Vec, where OUT is the output,
    Mat is an m-by-n matrix, and vec is an n-by-1 vector.'''
    if len(mat[0]) != len(vec):
        raise IndexError('Error: Matrix and vector cannot be multiplied - Dimensions do not match')

    out = []
    for i in range(0,len(mat)):
        mat_row = mat[i]
        sum = 0
        for j in range(0,len(vec)):
            sum+=mat_row[j]*vec[j]
        out.append(sum)
    
    return out
        

def transp(mat):
    '''Compute the transpose of an m-by-n matrix.'''
    i_len = len(mat)
    j_len = len(mat[0])

    #Form output matrix
    out = []
    for j in range(0,j_len):
        out.append([])
        for i in range(0,i_len):
            out[j].append(0)

    for i in range(0,i_len):
        for j in range(0,j_len):
            out[j][i]=mat[i][j]

    return out

def estimate(D,inv,X_obs):
    
    rhs = bun_mat(transp(D),[X_obs])
    wght = mult_mat_vec(inv,rhs)
    X_est = mult_mat_vec(D,wght)

    return X_est

class NSET:
    '''Creates an NSET object to simplify calculating the residual.
    The __init__ function requires 3 arguments: D, invDbunDm and est_num.
        D:        The filename for the memory matrix. Must be a comma-delimited file;
                  designed for a .txt and will probably work with a .csv. A string is expected.

        invDbunD: The filename for the operation inverse[D_transpose (bun) D].
                  Same input requirements as D.
     
        est_num:  The row of the memory matrix and observed state vector to estimate.
        
        nrml:     The array to normalize observed data vectors by (NOTE: This MUST be identical to
                  the training model.)'''


    def __init__(self,D,invDbunD,est_num,nrml):
        self.D = load(D)
        self.invDbunD = load(invDbunD)
        self.est_num = est_num
        self.nrml = nrml

        self.fault_flag = False
        self.has_tested = False
        self.last_five = [0,0,0,0,0]
    
    def calc_resid(self,X_obs_big):
        X_obs = [X/n for X,n in zip(X_obs_big,self.nrml)]
        X_est = estimate(self.D,self.invDbunD,X_obs)
        resid = X_est[self.est_num] - X_obs[self.est_num]
        return resid
    

test = False
if test == True:

    D = load('memory.txt')
    inv = load('inverse.txt')
    X_obs = [0.736, 0.1646, 0.0243, 0.106, 0.1845, 0.8941, 0.3301, 0.3389, 0.4399]


    estimate(D,inv,X_obs)
