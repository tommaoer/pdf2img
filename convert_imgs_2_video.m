function [] = convert_imgs_2_video(pathName, fps)
% VideoFile=strcat(pathName,'Animation');
% writerObj = VideoWriter(VideoFile);
% writerObj = VideoWriter(VideoFile,'Uncompressed AVI');

videoRoute = [pathName, './Animation.mp4'];
writerObj = VideoWriter(videoRoute,'MPEG-4');
% fps= 20;
writerObj.FrameRate = fps;
open(writerObj);
fileNames = dir([pathName,'/*.png']);
[~,i] = sort_nat({fileNames.name});
fileNames = fileNames(i);
counts = size(fileNames, 1);
cmap = gray(256);
for i = 1:counts
    imgName = [pathName, '/', fileNames(i).name];
    Frame=imread(imgName);
    channel = size(Frame,3);
    if channel == 1    % gray img
        writeVideo(writerObj,im2frame(Frame,cmap));
    else
         writeVideo(writerObj,im2frame(Frame));
    end    
end
close(writerObj);
end