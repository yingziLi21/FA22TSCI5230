# import python libraries
import pandas as pd 
import zipfile
import pickle
import requests

from tqdm import tqdm

# set the download url to 'https://physionet.org/static/published-projects/mimic-iv-demo/mimic-iv-clinical-database-demo-1.0.zip';
InputDate='https://physionet.org/static/published-projects/mimic-iv-demo/mimic-iv-clinical-database-demo-1.0.zip'
#Create a data directory if it doesn't already exist (don't give an error if it does)
os.makedirs('Data',exist_ok =True)

# Platform-independent code for specifying where the raw downloaded data will go
DownloadPath =os.path.join('Data', 'TempData.zip')

# Download the file from the location specified by the Input_Data variable
# as per https://stackoverflow.com/a/37573701/945039
Request=requests.get(InputDate,stream=True)
SizeInBytes=Request.headers.get('content-length',0)
BlockSize=1024
ProgressBar=tqdm(total=int(SizeInBytes),unit='i8',unit_scale=True)
with open(DownloadPath, 'wb') as file:
  for data in Request.iter_content(BlockSize):
    ProgressBar.update(len(data))
    file.write(data)
    ProgressBar.close()

ProgressBar.close()
assert ProgressBar.n==int(SizeInBytes), 'Download_notfinish_notdone'
to_unzip = zipfile.ZipFile(DownloadPath)
dd={}

#R list is Python dictionary. 3==[3] in
#R these are equivalent, in python they are not. In R a vector is one dimensional
#in python you can put vectors in vectors. ex:[1,2,3,4,5, ['a','b','c']]
#the attribute ~ data is the method is ~ the function.

for ii in to_unzip.namelist():
  if ii.endswith('csv.gz'):
    dd[os.path.split(ii)[1].replace(".csv.gz", "")] = pd.read_csv(to_unzip.open(ii), compression = 'gzip', low_memory = False) 
  
  
#dd.keys() #obtain names of all tables under dd
pickle.dump(dd, file=open('data.pickle','wb'))

# Save the downloaded file to the data directory # ... but the concise less readable way to do the same thing is:

# open(Zipped_Data, 'wb').write(requests.get(Input_data))

# Unzip and read the downloaded data into a dictionary named dd

# full names of all files in the zip

# look for only the files ending in csv.gz

# when found, create names based on the stripped down file names and

# assign to each one the corresponding data frame which will be uncompressed

# as it is read. The low_memory argument is to avoid a warning about mixed data types 

# Use pickle to save the processed data


