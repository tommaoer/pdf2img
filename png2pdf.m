function png2pdf(infolder,outfolder)
if ~exist(outfolder,'file')
    mkdir(outfolder)
end
[Files,Bytes,Names]=dirr([infolder,'\*.png'],'name');
for i=1:length(Names)
%     if isempty(strfind(Names{i},'crop'))
%     continue
%     end
    tmp=Names{i};
    tmp(1:length(infolder))=[];
    savename=[outfolder,tmp(1:end-3),'pdf'];
    [ex,name,suffix]=fileparts(savename);
    if ~exist(ex,'file')
        mkdir(ex)
    end
if ~exist(savename,'file')
%     copyfile(Names{i},savename)
% %     delete(Names{i})
  figure('visible','off')
  im=imread(Names{i},'BackgroundColor',[1,1,1]);
    imshow(im)
%     saveas2(savename,600)
    export_fig(savename,'-pdf','-transparent')
%     save2pdf(savename)
    close all
end

end

end