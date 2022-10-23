import os, re
import pandas as pd

# read XLSX file, read folder ans images files (JPG)
# run different magick-image filters 
# to extract the sickle blades

# cd C:/Rprojects/Rdev/gmm
os.chdir("c:\\Rprojects\\Rdev\\gmm\\")
df = pd.read_excel(open('inventary.xlsx','rb'), sheet_name = 0)
df = df.reset_index()  # make sure indexes pair with number of rows
for index, row in df.iterrows():
    print("read carpeta: " + row['carpeta'])
    fold = "c:\\\\Rprojects\\\\Rdev\\\\gmm\\\\" + row['carpeta']
    imgin = row['objecto']
    imgout = re.sub(".JPG", "", row['objecto']) + "_shape.png"
    imgfin = re.sub(".JPG", "", row['objecto']) + "_shape.jpg"
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
    cmd_inv = "magick %s -negate %s" % (imgout, imgfin)
    os.system(cmd_inv)
    print("      ... inverted done")