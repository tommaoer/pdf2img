function cropimg(ModelFolder, tarfolder)
addpath('./utils')
if nargin < 2
    
    tarfolder = [ModelFolder,'\crop'];
end
if ~exist(tarfolder,'file')
    mkdir(tarfolder);
end

[Files,Bytes,Names1]=dirr(fullfile(ModelFolder,'*.png'),'name');

[Files,Bytes,Names2]=dirr(fullfile(ModelFolder,'*.jpg'),'name');
Names = [Names1, Names2];


if exist(fullfile(ModelFolder,'mask.mat'),'file')
    load(fullfile(ModelFolder,'mask.mat'))
    %     mask.Position = mask.Position + [-150, 840, 400, 400];
    img = imshow(im2double(imread(Names{1})));
else
    allim = 0;
    for i =1:length(Names)
        if strfind(Names{i},'\crop')
            continue
        end
        img = im2double(imread(Names{i}));
        if length(size(img))<3
            img = repmat(img, 1,1,3);
        end
        %         allim = allim+img;
        if i == 1
            allim = allim+img;
        else
            allim = do2_1(allim, img);
        end
    end
    %     img = imshow(allim/max(allim(:)));
    img = imshow(min(allim, 1));
    
    [rows, columns, numberOfColorChannels] = size(allim/max(allim(:)));
    hold on;
    for row = 1 : 100 : rows
        line([1, columns], [row, row], 'Color', 'r');
    end
    for col = 1 : 100 : columns
        line([col, col], [1, rows], 'Color', 'r');
    end
    mask = drawrectangle(gca);
    if (mask.Position(4)-mask.Position(2))*(mask.Position(3)-mask.Position(1))/(rows*columns) > 0.1
        save(fullfile(ModelFolder,'mask.mat'), 'mask')
    end
end

BW = createMask(mask,img);
okind=find(BW>0);
[ii,jj]=ind2sub(size(BW),okind);
ymin=min(ii);ymax=max(ii);xmin=min(jj);xmax=max(jj);
close(gcf)
for i =1:length(Names)
    tmp=Names{i};
    tmp(1:length(ModelFolder))=[];
    savename=[tarfolder,tmp(1:end-3),'png'];
    if exist(savename,'file')
        continue
    end
    [ex,name,suffix]=fileparts(savename);
    if ~exist(ex,'file')
        mkdir(ex)
    end
    [~,name,suffix] = fileparts(Names{i});
    if strcmp(suffix,'.png') || strcmp(suffix,'.jpg')
        [Y,~,transparency] = imread(Names{i});
        if isempty(transparency)
            transparency = ones(size(Y));
            transparency = squeeze(transparency(:,:,1));
        end
        alpha=imcrop(transparency,[xmin,ymin,xmax-xmin+1,ymax-ymin+1]);
        imCropped=imcrop(Y,[xmin,ymin,xmax-xmin+1,ymax-ymin+1]);
    else
        Y = imread(Names{i});
        imCropped=imcrop(Y,[xmin,ymin,xmax-xmin+1,ymax-ymin+1]);
        %     set(0,'DefaultAxesColor','none')
        alpha=ones(size(imCropped));
        alpha = squeeze(alpha(:,:,1));
        idx = double(sum(imCropped,3)==255*3);
        alpha(logical(idx))=0;
    end
    
    imwrite(imCropped,savename, 'Alpha', alpha)
    %         imwrite(imCropped,fullfile(tarfolder,[name,'.png']))
end

clear

end

% 变暗
function out = do2_1(bg,mix)
R = min(cat(3,bg(:,:,1),mix(:,:,1)),[],3);
G = min(cat(3,bg(:,:,2),mix(:,:,2)),[],3);
B = min(cat(3,bg(:,:,3),mix(:,:,3)),[],3);
out = cat(3,R,G,B);
end
