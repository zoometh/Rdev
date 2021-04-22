import bpy
scn = bpy.context.scene

bpy.ops.import_scene.obj(filepath='obj1.obj')
target = bpy.context.selected_objects[0]
scn.objects.active = target
# centring the origin gives a better bounding box and rotation point
bpy.ops.object.origin_set(type='ORIGIN_GEOMETRY')

cam_x_pos = max([v[0] for v in target.bound_box]) * 2.5
cam_y_pos = max([v[1] for v in target.bound_box]) * 2.5
cam_z_pos = max([v[2] for v in target.bound_box]) * 2.5

rot_centre = bpy.data.objects.new('rot_centre', None)
scn.objects.link(rot_centre)
rot_centre.location = target.location

camera = bpy.data.objects.new('camera', bpy.data.cameras.new('camera'))
scn.objects.link(camera)
camera.location = (cam_x_pos, cam_y_pos, cam_z_pos)
camera.parent = rot_centre
m = camera.constraints.new('TRACK_TO')
m.target = target
m.track_axis = 'TRACK_NEGATIVE_Z'
m.up_axis = 'UP_Y'

rot_centre.rotation_euler.z = 0.0
rot_centre.keyframe_insert('rotation_euler', index=2, frame=1)
rot_centre.rotation_euler.z = radians(360.0)
rot_centre.keyframe_insert('rotation_euler', index=2, frame=101)
# set linear interpolation for constant rotation speed
for c in rot_centre.animation_data.action.fcurves:
    for k in c.keyframe_points:
        k.interpolation = 'LINEAR'
scn.frame_end = 100
