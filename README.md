# RRabClassifier

HERE YOU CAN SEE THE INSTRUCTIONS TO RUN THE PIPELINE OF RRab CLASSIFIER OF THE PAPER "A MACHINE LEARNED CLASSIFIER FOR RR-LYRAE IN THE VVV SURVEY". (https://doi.org/10.1051/0004-6361/201628700)


FIRST THIS DIRECTORY CONTAINS THE FOLLOWING FILES:

  1: Boost1b295T.Rdata = Classifier of RRab performed by Adaboost.M1 using 12 Features (See Appendix)
  
  2: Pipeline.py = Python Code to compute the following features (A.1.1,A.1.2,A.1.3,PH.1.2.,PH.1.3.,PH.1.4 and skew)
 
  3: Pipeline.sh = Code to call the gls function of Fortran. The features computed by this code are f1 and P1.
 
  4: Pipeline3.R = R code which performed all the procedure to classify the variable Stars. This code call the python and Fortran codes internally.
  
  5: README.txt = Instructions to Run the Pipeline of RRab Classifier.
  
  6: gls = Directory Necessary to Run gls using Fortran.
  
  7: gls.par = In this file we setting the parameters of GLS.
  
  8: newfeatures.R = R code to compute the following features (p2p_spfom,p2p_s2p,R1)

REQUIREMENTS OF R AND PYTHON.

  1: adabag Package of R
  
  2: pandas, numpy, os, statsmodels and scipy  Packages of Python


TO RUN THE PIPELINE YOU NEED TO BE IN THIS DIRECTORY AND WRITE IN THE TERMINAL THE FOLLOWING CODE:

Rscript --vanilla Pipeline3.R “light_curves.path" "files.path" >&log.txt&

where,

  1:“light_curves.path" =  Directory that contains the information of each light curves in txt files following the format (time, magnitude, error).
  
  2:“files.path"        =  Directory where we find the files described previously and where be created the resulting files.

THE RESULTING FILES ARE THE FOLLOWINGS:

  1: Final.txt = This file contains the results of classifier in 15 columns following this structure:

        (namefile,f1,P1,skew,A.1.1.,A.1.2.,A.1.3.,PH.1.2.,PH.1.3.,PH.1.4.,p2p_s2p,p2p_spfom,R1,Score,isrrab)

     In the last column of this file (isrrab) you will find the classification of the variable stars using a threshold of 0.548 (th). If Score > th this variable Stars will be a 'RRab' else if Score <= the classification will be 'Other'.

  2: Log.txt = This file contains a print of the R console when we run the code. Here we can check if exists some error in the procedure.

Appendix:

The features used to classify the light curves of variable stars in RRab are denoted by:

  1: f1: First Frequency obtained by GLS.
  
  2: P1: Peak in the GLS periodogram of the First frequency
  
  3: skew: Skewness of magnitude
  
  4: A.i.j.: Amplitude of the i-th frequency and j-th harmonic.
  
  5: PH.i.j.: Phase of the i-th frequency and j-th harmonic.
  
  6: p2p_s2p: p2p_scatter_2praw Feature of Richards et al, (2012).
  
  7: p2p_s2fom: p2p_scatter_pfold_over_mad Feature of Richards et al, (2012).
  
  8: R1: Ratio of the phase difference between the first minimum and the first maximum to the phase difference between the first minimum and second maximum in the smoothed light curve.
