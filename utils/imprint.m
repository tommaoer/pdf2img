function imprint(Filename,varargin)
% imprint               % Print an image file
%
%   imprint(Filename,varargin)
%
%   Reads the image file 'Filename' and prints the image using the print
%   options in varargin. See the print command for more information on the 
%   available options.
%
%   Note
%       The printed image will use the resolution of the image. This can be
%       overrided by including the '-rXXX' print switch
%
%   Operation
%       Reads an image file using 'imread' and 'iminfo' and plot the data 
%       on an invisible figure using 'image'. The figure is then printted 
%       using the 'print' command.
%
%   Example
%       % Convert tiff file to pdf
%       Filename = 'Tester.tiff'
%       nFilename = 'Tester'
%       imprint(Filename,'-dpdf',nFilename,'-painters')
%
%       % Convert tiff file to eps
%       Filename = 'Tester.tiff'
%       nFilename = 'Tester'
%       imprint(Filename,'-depsc2',nFilename,'-painters')
%
%   See also
%       imprint print imread iminfo image
%
%% Author Information
% Pierce Brady
% Smart Systems Integration Group - SSIS
% Cork Institute of Technology, Ireland.
%
%%
I = imfinfo(Filename);                      % Read image info
P = imread(Filename);                       % Read image
W = I.Width/I.XResolution;                  % Width in inches
H = I.Height/I.YResolution;                 % Height in inches
cRes = strcat('-r',num2str(I.XResolution)); % Resolution command
h.figure = figure('Visible','off');         % Invisible figure
h.axes = axes('Parent',h.figure);           % Axes
h.image = image(P,'Parent',h.axes);         % Place image on figure
set(h.axes,'DataAspectRatio',[1 1 1]);      % Correct ratios
set(h.axes,'Visible','off');                % Invisible axes - !Must be done after image
% Fix position and units
set(h.figure,'Units','inches');
set(h.figure,'Position',[0 0 W H]);
set(h.figure,'PaperPosition',[0 0 W H]);
set(h.figure,'PaperSize',[W H]);
set(h.axes,'Units','inches')
set(h.axes,'Position',[0 0 W H])
% Save using print command
try
    print(h.figure,cRes,varargin{:})
catch
    close(h.figure);                        % Close figure
end
close(h.figure);                            % Close figure
end
