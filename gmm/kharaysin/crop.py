import os, re
import pandas as pd

# crop images for OutlineR
# see: https://stackoverflow.com/questions/46320574/remove-white-background-and-crop-to-fit-foreground

diroot = "C:\\Rprojects\\Rdev\\gmm\\kharaysin\\img\\out"
diroot_out = "C:\\Rprojects\\Rdev\\gmm\\kharaysin\\img\\out_cropped"
os.chdir(diroot)
imgs = os.listdir()
for img in imgs[1:5]:
    print("read: " + img)
    img_path = diroot + "\\" + img
    imgout = diroot_out + "\\" + img # re.sub(".jpg", "", img) + "_shape.jpg"
    # cmd_cropped = "magick convert %s -bordercolor white -border 10x10 -trim %s" % (img_path, imgout)
    # cmd_cropped = "magick convert %s -bordercolor white -border 10x10 -fuzz 20%% -trim %s" % (img_path, imgout)
    # remove small areas (ovewrite)
    cmd_area = "magick %s -define connected-components:area-threshold=25 -connected-components 4 -auto-level %s" % (img_path, img_path)
    os.system(cmd_area)
    print("      ... rm small areas done")
    cmd_cropped = "magick convert %s -background white -trim %s" % (img_path, imgout)
    os.system(cmd_cropped)
    print("      ... crop done")
    # invert b/w
    cmd_inv = "magick %s -negate %s" % (imgout, imgout)
    os.system(cmd_inv)
    print("      ... inverted done")
print("*Finished")