function png2pdf(infolder,outfolder)
if ~exist(outfolder,'file')
    mkdir(outfolder)
end
setenv('GS_LIB', ['C:\Program Files\gs\gs9.26\Resource\Init;C:\Program Files\gs\gs9.26\iccprofiles'])
[Files,Bytes,Names_png]=dirr([infolder,'\*.png'],'name');
[Files,Bytes,Names_pdf]=dirr([infolder,'\*.pdf'],'name');
% png
for i=1:length(Names_png)
    %     if isempty(strfind(Names{i},'crop'))
    %     continue
    %     end
    tmp=Names_png{i};
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
        im=imread(Names_png{i},'BackgroundColor',[1,1,1]);
        imshow(im)
        %     saveas2(savename,600)
        export_fig(savename,'-pdf','-transparent')
        %     save2pdf(savename)
        close all
    end
    
end

% pdf
for i=1:length(Names_pdf)
    tmp=Names_pdf{i};
    tmp(1:length(infolder))=[];
    savename=[outfolder,tmp(1:end-3),'pdf'];
    [ex,name,suffix]=fileparts(savename);
    if ~exist(ex,'file')
        mkdir(ex)
    end
    copyfile(Names_pdf{i}, savename, 'f')
end

end