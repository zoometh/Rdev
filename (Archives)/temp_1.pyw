import ctypes
import sys

sys.path.append('..')
import pyglet
from pyglet.gl import *

from pywavefront import visualization
import pywavefront
import pywavefront.material

rotation = 0
#meshes = pywavefront.Wavefront('ex.obj')

meshes = pywavefront.Wavefront('roche_archer_2.obj')

window = pyglet.window.Window()
lightfv = ctypes.c_float * 4

@window.event
def on_resize(width, height):
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluPerspective(0, float(width)/height, 1, 20.)
    # gluPerspective(60., float(width)/height, 0.01, 100.)
    glMatrixMode(GL_MODELVIEW)
    return True

global rotatex, rotatey, zoom, outName
rotatex = 0
rotatey = 0
zoom=0
outName = "test.png"

@window.event
def on_draw():
    global rotatex, rotatey, outName
    lightfv = ctypes.c_float * 4
    window.clear()
    glLoadIdentity()
    #glLightfv(GL_LIGHT0, GL_POSITION, lightfv(-40.0, 200.0, 100.0, 0.0))
    glLightfv(GL_LIGHT0, GL_AMBIENT, lightfv(0.2, 0.2, 0.2, 1.0))
    glLightfv(GL_LIGHT0, GL_DIFFUSE, lightfv(0.5, 0.5, 0.5, 1.0))
    glEnable(GL_LIGHT0)
    glEnable(GL_LIGHTING)

    glEnable(GL_COLOR_MATERIAL)
    glEnable(GL_DEPTH_TEST)
    glShadeModel(GL_SMOOTH)

    glTranslated(0, -1, -6)
    glRotatef(-66.5, 0, 0, 1)
    glRotatef(rotation, 1, 0, 0)
    glRotatef(90, 0, 0, 1)
    glRotatef(0, 0, 1, 0)

    visualization.draw(meshes)

    # pyglet.image.get_buffer_manager().get_color_buffer().save(outName)

    #exit()

pyglet.app.run()
