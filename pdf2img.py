import numpy as np
import io
import os
import random
import  cv2
from shutil import copyfile
from PIL import Image
from pdf2image import convert_from_path, convert_from_bytes


input_folder = ''
output_folder = ''
img_format = 'png'

pdf_list = []
def record(folder):
    # print(os.listdir(folder))
    # global folderin
    for name in os.listdir(folder):
        if os.path.isdir(folder+'/'+name):
            record(folder+'/'+name)
        elif name.endswith('pdf'):
            # file_name = os.path.join(output_folder, os.path.relpath(os.path.join(folder, name), folderin))
            # path_out_list.append(file_name)
            pdf_list.append('{}'.format(folder+'/'+name))

record(input_folder)

path_out_list = []
for f in pdf_list:
    file_name = output_folder+'/'+os.path.relpath(f, input_folder)
    # fname,ext = os.path.splitext(fullflname)
    # file_name = os.path.join(filepath, fname + '_'+str(i)+'.'+oext)
    path_out_list.append(file_name)
    filepath,fullflname = os.path.split(file_name)
    # print(path_out_list)
        # fname,ext = os.path.splitext(fullflname)
        # file_name = os.path.join(filepath, fname + '_'+str(i)+'.'+oext)
    if not os.path.exists(filepath):
        os.makedirs(filepath)


for idx, pdfname in enumerate(pdf_list):
    print(pdfname)
    filepath,fullflname = os.path.split(path_out_list[idx])
    fname, ext = os.path.splitext(fullflname)
    # images = convert_from_path(pdfname, dpi=200, output_folder=filepath, fmt='png')
    images = convert_from_path(pdfname, dpi=50, output_folder=filepath, output_file=fname, fmt=img_format)

    save_name = os.path.join(filepath, fname+'0001-1.'+img_format)
    change_name = os.path.join(filepath, fname+'.'+img_format)
    os.system('mv %s %s' % (save_name, change_name))


    # print(images.shape)
    # print(images.shape)
    # cv2.imwrite(,images,[cv2.IMWRITE_JPEG_QUALITY,70])

