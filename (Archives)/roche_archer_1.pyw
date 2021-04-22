#!/usr/bin/env python
"""This script shows an example of using the PyWavefront module."""
import ctypes, os, sys, pyglet, pywavefront
from pyglet.gl import *
from pywavefront import visualization 

rotation = 90
meshes = pywavefront.Wavefront('roche_archer_2.obj')
window = pyglet.window.Window(resizable=True)
lightfv = ctypes.c_float * 4

@window.event
def on_resize(width, height):
    viewport_width, viewport_height = window.get_framebuffer_size()
    glViewport(0, 0, viewport_width, viewport_height)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluPerspective(60., float(width)/height, 1., 100.)
    glMatrixMode(GL_MODELVIEW)
    return True


@window.event
def on_draw():
    window.clear()
    glLoadIdentity()

    glLightfv(GL_LIGHT0, GL_POSITION, lightfv(-1.0, 1.0, 1.0, 0.0))
    glEnable(GL_LIGHT0)

    glTranslated(0.0, 0.0, -3.0)
    glRotatef(rotation, 0, 1, 0)
    glRotatef(-180, 0, 0, 1) # intervertit z
    # glRotatef(45.0, 0.0, 0.0, 1.0)
    # glRotatef(0, 1,  1, 1)
    # glRotatef(0, 1, 1, 1)

    glEnable(GL_LIGHTING)

    visualization.draw(meshes)


def update(dt):
    global rotation
    rotation += 90.0 * dt
    if rotation > 200.0:
    # if rotation > 720.0:
        rotation = 90

pyglet.clock.schedule(update)
pyglet.app.run()
