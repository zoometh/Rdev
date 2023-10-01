from qgis.core import QgsRasterLayer

# Get the list of all layers in the TOC
layers = QgsProject.instance().mapLayers().values()

# Filter and sort raster layers alphabetically by layer name
raster_layers = sorted([layer for layer in layers if isinstance(layer, QgsRasterLayer)], key=lambda layer: layer.name())

# Get the root group of the layer tree
root = QgsProject.instance().layerTreeRoot()

# Remove all layers from the root group
root.removeAllChildren()

# Add the sorted raster layers back to the root group
for layer in raster_layers:
    layer_item = root.addLayer(layer)

# Refresh the map canvas
iface.layerTreeView().refreshLayerSymbology()
iface.mapCanvas().refreshAllLayers()
