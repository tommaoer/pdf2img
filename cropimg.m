function cropimg(ModelFolder)

tarfolder = [ModelFolder,'\crop'];
if ~exist(tarfolder,'file')
    mkdir(tarfolder);
end
pnglist = dir(fullfile(ModelFolder,'*.png'));
[~,i] = sort_nat({pnglist.name});
pnglist = pnglist(i);
allim = 0;
for i =1:length(pnglist)
imset{i} = im2double(imread(fullfile(ModelFolder,pnglist(i).name)));
allim = allim+imset{i};
end
img = imshow(allim/max(allim(:)));

[rows, columns, numberOfColorChannels] = size(allim/max(allim(:)));
hold on;
for row = 1 : 100 : rows
  line([1, columns], [row, row], 'Color', 'r');
end
for col = 1 : 100 : columns
  line([col, col], [1, rows], 'Color', 'r');
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
for i =1:length(pnglist)
    [~,name,suffix] = fileparts(pnglist(i).name);
    if strcmp(suffix,'.png')
        [Y,~,transparency] = imread(fullfile(ModelFolder,pnglist(i).name));
        if isempty(transparency)
            transparency = ones(size(Y));
            transparency = squeeze(transparency(:,:,1));
        end
        alpha=imcrop(transparency,[xmin,ymin,xmax-xmin+1,ymax-ymin+1]);
        imCropped=imcrop(Y,[xmin,ymin,xmax-xmin+1,ymax-ymin+1]);        
    else
        Y = imread(fullfile(ModelFolder,pnglist(i).name));
        imCropped=imcrop(Y,[xmin,ymin,xmax-xmin+1,ymax-ymin+1]);
        %     set(0,'DefaultAxesColor','none')
        alpha=ones(size(imCropped));
        alpha = squeeze(alpha(:,:,1));
        idx = double(sum(imCropped,3)==255*3);
        alpha(logical(idx))=0;
    end
    
    imwrite(imCropped,fullfile(tarfolder,[name,'.png']), 'Alpha', alpha)
%         imwrite(imCropped,fullfile(tarfolder,[name,'.png']))
end

clear

end