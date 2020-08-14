
import os
import sys
import multiprocessing
from itertools import product
from functools import partial
from subprocess import call
from contextlib import contextmanager

# blender 2.79, install pip, reinstall numpy, install trimesh

@contextmanager
def poolcontext(*args, **kwargs):
    pool = multiprocessing.Pool(*args, **kwargs)
    yield pool
    pool.terminate()

inputpath = sys.argv[1]
output = sys.argv[2]

objlist = []
def record(folder):

    for name in os.listdir(folder):
        if os.path.isdir(folder+'/'+name):
            record(folder+'/'+name)
        elif name.endswith('.obj'):
            objlist.append('{}'.format(folder+'/'+name))


def blender_render(inputshape, output = 'no'):
    print(inputshape)
    if output == 'no':
        outputpng = inputshape.replace('.obj','.png')
    else:
        if os.path.isfile(output):
            outputpng = output
        if os.path.isdir(output):
            outputfile_name = output+'/'+os.path.relpath(inputshape, inputpath)
            filepath, _ = os.path.split(outputfile_name)
            if not os.path.exists(filepath):
                os.makedirs(filepath)
            outputpng = outputfile_name
    cmd = "blender --background point_clouds.blend --python render_same_color.py -- %s %s" % (inputshape, outputpng)
    call(cmd, shell=True)


def test(inputshape):
    print(inputshape)

def main(objlist):
    with poolcontext(processes=16) as pool:
        results = pool.map(partial(blender_render, output='no'), objlist)

record(inputpath)
print(len(objlist))
# print(objlist[:10])
main(objlist)
