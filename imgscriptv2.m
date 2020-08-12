function imgscriptv2(ModelFolder)

tarfolder = [ModelFolder,'\..\fill'];
if ~exist(tarfolder,'file')
    mkdir(tarfolder);
end
background = [0,0,3];%w,h,channel
[Files,Bytes,Names]=dirr([ModelFolder,'\*.png'],'name');

for i =1:length(Names)
    pngname = Names{i};
    pngdata = imread(pngname);
    if size(pngdata,1)>background(1)
    background(1) = size(pngdata,1);
    end
    if size(pngdata,2)>background(2)
    background(2) = size(pngdata,2);
    end
end
background(1)=background(1)+100;
background(2)=background(2)+100;
allimg = 0;
store_pos_r = {};
store_pos_c = {};
for i =1:length(Names)
    pngname = Names{i};
    pngdata = imread(pngname);
    background_img = ones(background);
    [ci_w,ci_h,~] = size(pngdata);
    row = floor((background(1)-ci_w)/2):(floor((background(1)-ci_w)/2)+ci_w-1);
    column = floor((background(2)-ci_h)/2):(floor((background(2)-ci_h)/2)+ci_h-1);
    background_img(row,column,:) = im2double(pngdata);
    store_pos_r = [store_pos_r, row];
    store_pos_c = [store_pos_c, column];
    allimg = allimg+background_img;
end
allimg = allimg/max(allimg(:));
allimg(allimg<1) = 0;
img = imshow(allimg);

% slots on figure
[rows, columns, numberOfColorChannels] = size(allimg);
hold on;
for row = 1 : 100 : rows
  line([1, columns], [row, row], 'Color', 'r', 'LineWidth', 0.1);
end
for col = 1 : 100 : columns
  line([col, col], [1, rows], 'Color', 'r', 'LineWidth', 0.1);
end

if exist(fullfile(ModelFolder,'mask.mat'),'file')
    load(fullfile(ModelFolder,'mask.mat'))
else
    mask = drawrectangle(gca);
    save(fullfile(ModelFolder,'mask.mat'),'mask')
end

BW = createMask(mask,img);
okind=find(BW>0);
[ii,jj]=ind2sub(size(BW),okind);
ymin=min(ii);ymax=max(ii);xmin=min(jj);xmax=max(jj);
close(gcf)

% save
for i =1:length(Names)
    [path,name,suffix] = fileparts(Names{i});
    a = relpath(Names{i},ModelFolder);a(end)=[];a(1)=[];
    [path,~,~] = fileparts(fullfile(tarfolder,a));
    if ~exist(path,'dir')
    mkdir(path)
    end    
    if strcmp(suffix,'.png')
        [Y,~,transparency] = imread(Names{i});
        row = store_pos_r{i};
        column = store_pos_c{i};
        
        tp_img = ones(background);
        tp_img = tp_img(:,:,1);
        if ~isempty(transparency)
        tp_img(row,column) = transparency;
        end
        
        background_img = ones(background);
        background_img(row,column,:) = im2double(Y);
        
        alpha=imcrop(tp_img,[xmin,ymin,xmax-xmin+1,ymax-ymin+1]);
        imCropped=imcrop(background_img,[xmin,ymin,xmax-xmin+1,ymax-ymin+1]);        
    else
        % unshading to use
        Y = imread(fullfile(ModelFolder,pnglist(i).name));
        imCropped=imcrop(Y,[xmin,ymin,xmax-xmin+1,ymax-ymin+1]);
        %     set(0,'DefaultAxesColor','none')
        alpha=ones(size(imCropped));
        alpha = squeeze(alpha(:,:,1));
        idx = double(sum(imCropped,3)==255*3);
        alpha(logical(idx))=0;
    end
    
    imwrite(imCropped,fullfile(tarfolder,a), 'Alpha', alpha)
%         imwrite(imCropped,fullfile(tarfolder,[name,'.png']))
end

clear

end