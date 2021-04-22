import pywavefront
from pywavefront import visualization

obj = pywavefront.Wavefront('roche_archer_2.obj')

visualization.draw(obj)
