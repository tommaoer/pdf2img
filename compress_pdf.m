function compress_pdf(infolder,outfolder)
if ~exist(outfolder,'file')
    mkdir(outfolder)
end
addpath('./utils')
[Files,Bytes,Names]=dirr([infolder,'\*.pdf'],'name');
for i=1:length(Names)
%     if isempty(strfind(Names{i},'crop'))
%     continue
%     end
    tmp=Names{i};
    tmp(1:length(infolder))=[];
    savename=[outfolder,tmp(1:end-3),'pdf'];
    [ex,name,suffix]=fileparts(savename);
    if ~exist(ex,'file')
%         ex
        mkdir(ex)
    end
if ~exist(savename,'file')
%     cmd = ['-sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -dNOPAUSE -dQUIET -dBATCH -sOutputFile=',savename,' ',Names{i}];
    cmd = ['-sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dDownsampleColorImages=true ',...
            '-dDownsampleGrayImages=true ',...
            '-dDownsampleMonoImages=true ',...
            '-dColorImageResolution=100 ',...
            '-dGrayImageResolution=100 ',...
            '-dMonoImageResolution=100 -dNOPAUSE -dQUIET -dBATCH -sOutputFile=',savename,' ',Names{i}];
    ghostscript(cmd);
end

end

end