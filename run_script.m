function run_script(img_path)
% input: the image path with '*.png'
cropimg(img_path, [img_path, '_crop'])
png2pdf([img_path, '_crop'], [img_path, '_crop_pdf'])
end