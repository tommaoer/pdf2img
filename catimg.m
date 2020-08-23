function catimg(folder, img_type)
if nargin <2
    img_type = 'png';
end
pnglist = dir(fullfile(folder, ['*.',img_type]));
col = 10;
row = ceil(length(pnglist)/col);

w=0;
h=0;
for i =1:length(pnglist)
img = imread(fullfile(folder, pnglist(i).name));
[im_w,im_h,c] = size(img);
if im_w>w
    w = im_w;
end
if im_h>h
    h = im_h;
end
end
bg = ones(w,h,c);
big = [];
for i=1:row
    row_img= [];
    for j=1:col
        if (i-1)*col +j>length(pnglist)
            background_img = ones(w,h,c);
        else
            background_img = 255*ones(w,h,c);
            currnet_img = imread(fullfile(folder, pnglist((i-1)*col +j).name));
            [ci_w,ci_h,~] = size(currnet_img);
            row = floor((w-ci_w)/2):(floor((w-ci_w)/2)+ci_w-1);
            column = floor((h-ci_h)/2):(floor((h-ci_h)/2)+ci_h-1);
            background_img(row+1,column+1,:) = currnet_img;
        end
        row_img = [row_img,background_img];
    end
    big = [big;row_img];
end
imwrite(uint8(big),fullfile(folder,['_whole.png']))
end