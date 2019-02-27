import pandas as pd
import numpy as np
import sys
import os
import re

from scipy.stats import f,skew # Import F-distribution for significance calculation.
import statsmodels.formula.api as sm
import statsmodels.stats.outliers_influence as inf


def armonic(t,m,f,merr):
    ws = pd.DataFrame({
    'x': m,
    'y1': np.sin(2*np.pi*t*f),
    'y2': np.cos(2*np.pi*t*f),
    'y3': np.sin(4*np.pi*t*f),
    'y4': np.cos(4*np.pi*t*f),
    'y5': np.sin(6*np.pi*t*f),
    'y6': np.cos(6*np.pi*t*f),
    'y7': np.sin(8*np.pi*t*f),
    'y8': np.cos(8*np.pi*t*f)
    })
    weights = pd.Series(merr)
    wls_fit = sm.wls('x ~ y1+y2+y3+y4+y5+y6+y7+y8-1', data=ws, weights=1 / weights).fit()
    pred = wls_fit.predict()
    r = m - pred
    A=np.zeros(4)
    PH=np.zeros(4)
    A[0] = np.sqrt(wls_fit.params[0]**2+wls_fit.params[1]**2)
    A[1] = np.sqrt(wls_fit.params[2]**2+wls_fit.params[3]**2)
    A[2] = np.sqrt(wls_fit.params[4]**2+wls_fit.params[5]**2)
    A[3] = np.sqrt(wls_fit.params[6]**2+wls_fit.params[7]**2)
    PH[0] = np.arctan2(wls_fit.params[1],wls_fit.params[0])-(1*f/f)*np.arctan2(wls_fit.params[1],wls_fit.params[0])
    PH[1] = np.arctan2(wls_fit.params[3],wls_fit.params[2])-(2*f/f)*np.arctan2(wls_fit.params[1],wls_fit.params[0])
    PH[2] = np.arctan2(wls_fit.params[5],wls_fit.params[4])-(3*f/f)*np.arctan2(wls_fit.params[1],wls_fit.params[0])
    PH[3] = np.arctan2(wls_fit.params[7],wls_fit.params[6])-(4*f/f)*np.arctan2(wls_fit.params[1],wls_fit.params[0])
    influence=inf.OLSInfluence(wls_fit)
    dffits=influence.dffits
    cook=influence.cooks_distance
    leverage=influence.hat_matrix_diag
    inf1 = np.where(dffits[0]>dffits[1])
    inf2 = np.where(cook[1]<0.05)
    inffin= np.concatenate((inf1,inf2), axis=1)
    return pred, r, A, PH, inffin

fout = open("Aux3.dat",'w')
datafile='gls_results.dat'
with open(datafile,'r') as f:
    #next(f) # skip first row
    datagls = pd.DataFrame(l.rstrip().split() for l in f)

data3=[]

for i in range(np.shape(datagls)[0]):
    data3=np.hstack((data3,datagls[0][i].replace('.fdat',"").rsplit('/', 1)[-1]))

file = sys.argv[1]

(t,m,merr) = np.genfromtxt(file, unpack=True,filling_values=np.nan,skip_header=1)
ws = pd.DataFrame({
'x': m,
'y': t
})
weights = pd.Series(merr)
wls_fit = sm.wls('x ~ y', data=ws, weights=1 / weights).fit()
y1 = m - wls_fit.predict()
intercept=wls_fit.params[0]
slope=wls_fit.params[1]
dy2=np.vstack((t,y1,merr))
np.savetxt('Aux2.txt',dy2.T)
f1=np.float(datagls[2])
Pe1=np.float(datagls[3])
A=np.zeros(shape=(1,4))
PH=np.zeros(shape=(1,4))
pred2, y2, A[0,], PH[0,], inf1 = armonic(t,y1,f1,merr)
PH2 = np.arctan2(np.sin(PH),np.cos(PH))
s=skew(m)
arreglo = np.hstack((intercept,slope,f1,Pe1,s))
arreglo2 = np.hstack((PH2[0].tolist()))
arreglo3 = np.hstack((A[0].tolist()))
arreglo = ' '.join(map(str, arreglo))
arreglo2 = ' '.join(map(str, arreglo2))
arreglo3 = ' '.join(map(str, arreglo3))
fout.write("{} {} {} \n".format(arreglo,arreglo3,arreglo2))
