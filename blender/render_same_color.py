import os
import sys
import numpy as np
import bpy
import bmesh
import trimesh
sys.path.append(os.getcwd()) # for some reason the working directory is not in path
import warnings
warnings.filterwarnings("ignore")


point_radius = 0.01
result_type = 'orig'

def load_objv(fn, face = False):
    fin = open(fn, 'r')
    lines = [line.rstrip() for line in fin]
    fin.close()

    vertices = []; faces = [];
    # print(lines)
    for line in lines:
        if line.startswith('v '):
            vertices.append(np.float32(line.split()[1:4]))
        if face and line.startswith('f '):
            faces.append(np.int32([item.split('/')[0] for item in line.split()[1:4]]))
    v = np.vstack(vertices)
    if face:
        f = np.vstack(faces)
        return v, f
    else:
        return v, v

def read_textfile_list(filename):
    object_names = []
    with open(filename) as f:
        object_names = f.readlines()
    object_names = [x.strip() for x in object_names]
    object_names = list(filter(lambda x: x is not None, object_names))
    #
    return object_names

def hex2rgb(h):
    return tuple(int(h.lstrip('#')[i:i+2], 16) for i in (0, 2, 4))

def sample_pc(v, f, n_points=2048):
    mesh = trimesh.Trimesh(vertices=v, faces=f-1)
    points = trimesh.sample.sample_surface(mesh=mesh, count=n_points)
    return points

colors = [
    '#1f77b4',  # muted blue
    '#ff7f0e',  # safety orange
    '#2ca02c',  # cooked asparagus green
    '#d62728',  # brick red
    '#9467bd',  # muted purple
    '#8c564b',  # chestnut brown
    '#e377c2',  # raspberry yogurt pink
    '#7f7f7f',  # middle gray
    '#bcbd22',  # curry yellow-green
    '#17becf'   # blue-teal
]

colors = np.array([[float(c)/255.0 for c in hex2rgb(color)] for color in colors])

# blender --background point_clouds.blend --python render_one_pc_same_color.py -- example_pc.pts example_pc_same_color.png

pts_filename = sys.argv[6]
output_filename = sys.argv[7]

# def render_one_object(pts_filename, output_filename):
pts, pts_f = load_objv(pts_filename, face = True)
pts = sample_pc(pts, pts_f, 5000)
# pts = pts[range(0,len(pts),len(pts)//10000)]
# rotate for blender
coord_rot = np.array([[-1, 0, 0], [0, 0, 1], [0, 1, 0]])
pts = np.matmul(pts, coord_rot.transpose())

if 'object' in bpy.data.objects:
    bpy.data.objects.remove(bpy.data.objects['object'], do_unlink=True)

if 'sphere' in bpy.data.meshes:
    bpy.data.meshes.remove(bpy.data.meshes['sphere'], do_unlink=True)

if 'object' in bpy.data.meshes:
    bpy.data.meshes.remove(bpy.data.meshes['object'], do_unlink=True)

sphere_mesh = bpy.data.meshes.new('sphere')
sphere_bmesh = bmesh.new()
bmesh.ops.create_icosphere(sphere_bmesh, subdivisions=1, diameter=point_radius*2)
sphere_bmesh.to_mesh(sphere_mesh)
sphere_bmesh.free()

sphere_verts = np.array([[v.co.x, v.co.y, v.co.z] for v in sphere_mesh.vertices])
sphere_faces = np.array([[p.vertices[0], p.vertices[1], p.vertices[2]] for p in sphere_mesh.polygons])

verts = (np.expand_dims(sphere_verts, axis=0) + np.expand_dims(pts, axis=1)).reshape(-1, 3)
faces = (np.expand_dims(sphere_faces, axis=0) + (np.arange(pts.shape[0]) * sphere_verts.shape[0]).reshape(-1, 1, 1)).reshape(-1, 3)

verts[:, 2] -= verts.min(axis=0)[2]

verts = verts.tolist()
faces = faces.tolist()

scene = bpy.context.scene
mesh = bpy.data.meshes.new('object')
mesh.from_pydata(verts, [], faces)
mesh.validate()

mesh.vertex_colors.new(name='Col') # named 'Col' by default

for i, c in enumerate(mesh.vertex_colors['Col'].data):
    c.color = colors[0]

obj = bpy.data.objects.new('object', mesh)
obj.data.materials.append(bpy.data.materials['sphere_material'])
scene.objects.link(obj)

scene.render.image_settings.file_format = 'PNG'
scene.render.filepath = output_filename
# redirect output to log file
logfile = 'blender_render.log'
open(logfile, 'a').close()
old = os.dup(1)
sys.stdout.flush()
os.close(1)
os.open(logfile, os.O_WRONLY)

bpy.ops.render.render(write_still=True)

# disable output redirection
os.close(1)
os.dup(old)
os.close(old)
