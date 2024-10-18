import os, re
import pandas as pd

# read XLSX file, read folder ans images files (JPG)
# run different magick-image filters 
# to extract the sickle blades
# see: https://github.com/eamena-project/eamena-arches-dev/blob/main/projects/apaame/convert_from_dng.py

# cd C:/Rprojects/_coll/LaMarmotta/
diroot = "c:\\Rprojects\\_coll\\LaMarmotta\\01_Geometricos_Marmotta\\"
os.chdir(diroot)
df = pd.read_excel(open('inventary.xlsx','rb'), sheet_name = 2)
df = df.reset_index()  # make sure indexes pair with number of rows
df = df.head() # limit
for index, row in df.iterrows():
    print("read carpeta: " + row['carpeta'])
    fold = diroot + row['carpeta']
    # fold = "c:\\\\Rprojects\\\\_coll\\\\LaMarmotta\\\\" + row['carpeta']
    imgin = row['objecto']
    imgout = re.sub(".JPG", "", row['objecto']) + "_shape.png"
    os.chdir(fold)
    # colors
    cmd_colors = "magick %s -color-threshold sRGB(20,20,20)-sRGB(255,255,255) %s" % (imgin, imgout) 
    os.system(cmd_colors)
    print("      ... color threshold done")
    # Open (ovewrite)
    cmd_open = "magick %s -morphology Open Plus %s" % (imgout, imgout) 
    os.system(cmd_open)
    print("      ... Open done")
    # remove small areas (ovewrite)
    cmd_area = "magick %s -define connected-components:area-threshold=1000 -connected-components 4 -auto-level %s" % (imgout, imgout) 
    os.system(cmd_area)
    print("      ... areas done")
    # select item CC (ovewrite)
    cmd_cc = "magick %s -define connected-components:keep-ids=1 -define connected-components:mean-color=true -connected-components 4 %s" % (imgout, imgout) 
    os.system(cmd_cc)
    print("      ... select item done")
    # thresold b/w
    cmd_bw = "magick %s -threshold 20%% %s" % (imgout, imgout)
    os.system(cmd_bw)
    print("      ... to black and white done")
    # invert b/w
    cmd_inv = "magick %s -negate %s" % (imgout, imgout)
    os.system(cmd_inv)
    print("      ... inverted done")
print("*Finished")