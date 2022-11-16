# import python libraries
import pandas as pd 
import numpy as np
import os
import pickle
#Ensure the exist of staged data
if not os.path.exists('data.pickle'):
  import runpy
  runpy.run_path('data.py')
# Load staged data
dd= pickle.load(open('data.pickle','rb'))

## dd.keys() #get names of individual tables
dd.keys()
## dd['admissions'] #get individual table

#Create table: demographics from admissions, patients
demographics=dd["admission"].copy() # create demographics table copy from admissions
  
