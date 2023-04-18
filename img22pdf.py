import numpy as np
import io
import os
import random
import cv2
from shutil import copyfile
from PIL import Image
from pdf2image import convert_from_path, convert_from_bytes
from tqdm import tqdm
import img2pdf as i2p

if 0:
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


# convert all files ending in .jpg in a directory and its subdirectories
dirname = "/mnt/h/yangjie/sig2021/result_new/inter/select/74dbc810-1bbb-43b6-9a26-714b3742c631--Library--206d8aff-ccfc-4120-b5d8-d63c5578796e--Library/png/crop"
# dirname = "/mnt/h/tmp"
save_path = dirname + 'pdf'
if not os.path.exists(save_path):
    os.makedirs(save_path)

def remove_alpha(img_path):
    png = Image.open(img_path)
    png.load() # required for png.split()

    background = Image.new("RGB", png.size, (255, 255, 255))
    if len(png.split()) > 3:
        background.paste(png, mask=png.split()[3]) # 3 is the alpha channel
    else:
        background.paste(png)

    background.save(img_path.replace('.png','.jpg'), 'JPEG', quality=100)

imgs = []
for r, _, f in os.walk(dirname):
    for fname in f:
        print(fname)
        if not fname.endswith(".png"):
            continue
        # imgs.append(os.path.join(r, fname))
        save_name = os.path.join(r.replace(dirname, save_path), fname.replace('.png', '.pdf'))
        sub_path, _ =  os.path.split(save_name)
        if not os.path.exists(sub_path):
            os.makedirs(sub_path)
        # print(dir(i2p))
        remove_alpha(os.path.join(r, fname))
        with open(save_name,"wb") as f:
            f.write(i2p.convert(os.path.join(r, fname).replace('.png','.jpg')))


