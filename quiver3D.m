function varargout = quiver3D(posArray, magnitudeArray, arrowColors, stemRatio,varargin)
% QUIVER3D Plot a quiver of three-dimensional arrows
%
%   Given the posArray (position array) [x1 y1 z1; x2 y2 z2; ...] and their
%   relative magnitudes along the x,y,z-axes using magnitudeArray
%   [dx1 dy1 dz1; dx2 dy2 dz2; ...], with optional color and stem
%   ratios, output a quiver of arrows.
%
%   arrowColors: conforms to 'ColorSpec.'  For example, 'r','red',[1 0 0]
%       will all plot a quiver with all arrows as red. This can also be in
%       the form of Nx3 where 'N' is the number of arrows, and each column
%       corresponds to the R,G,B values
%   stemRatio: ratio of the arrowhead (cone) to the arrowstem (cylinder)
%       [default = 0.75]. For example, setting this value to 0.94 will
%       produce arrows with arrowstems 94% of the length and short, 6%
%       cones as arrowheads
%
% Example:
%   [X,Y] = meshgrid(1:5, -2:2);
%   Z = zeros(size(X));
%   posArray = [X(:),Y(:),Z(:)];
%
%   magnitudeArray = zeros(size(posArray));
%   magnitudeArray(:,1) = 1;
%   quiver3D(posArray, magnitudeArray, 'g', 0.6);
%
%
% Forms:
%   quiver3D(posArray, magnitudeArray)
%       plot a quiver of three-dimensional arrows with default color black
%
%   quiver3D(posArray, magnitudeArray, arrowColors)
%
%   quiver3D(..., arrowColors, stemRatio)
%       ratio of the arrowhead (cone) to the arrowstem (cylinder) [default = 0.75]
%
%   Author: Shawn Arseneau
%       Created: 2006-09-14
%       Updated: 2018-01-11

addpath(genpath([fileparts([mfilename('fullpath'), '.m']) '\' 'src']));

%% Initial verification of input parameters
if nargin<2 || nargin>5
    error('Invalid number of input arguments. Type ''help quiver3D'' for details');
end

if numel(posArray) == 1 && ishghandle(posArray, 'axes')
    hAx = posArray;
    posArray=magnitudeArray;
    magnitudeArray=arrowColors;
    switch nargin
        case 4
            arrowColors=stemRatio;
        case 5
            arrowColors=stemRatio;
            stemRatio=varargin{1};
    end
    NoIA=nargin-1;
else
    hAx = gca;
    NoIA=nargin;
end

numArrows = size(posArray,1);
if numArrows ~= size(magnitudeArray,1)
    error('Position and magnitude inputs do not agree. Type ''help quiver3D'' for details');
end

%% Default parameters
switch NoIA
    case 2
        % Default color
        arrowColors = zeros(numArrows, 3);
        % Default stem ratio
        stemRatio = 0.75;
    case 3
        arrowColors=validateArrowColors(arrowColors,numArrows);
        % Default stem ratio
        stemRatio = 0.75;
    case 4
        arrowColors=validateArrowColors(arrowColors,numArrows);
end


%% Loop through all arrows and plot in 3D
hold(hAx,'on')
qHandle=zeros(numArrows,2);
for i=1:numArrows
    qHandle(i,:) = arrow3D(hAx, posArray(i,:), magnitudeArray(i,:), ...
        arrowColors(i,:), stemRatio);
end

if nargout > 0
    varargout = {qHandle};
end

end

function arrowColors=validateArrowColors(arrowColors,numArrows)

[arrowRow, arrowCol] = size(arrowColors);
if arrowRow==1
    if ischar(arrowColors) %in ShortName or LongName color format
        if arrowCol==1
            RGBvalue = ColorSpec_ShortName_to_RGBvalue(arrowColors);
        else
            RGBvalue = ColorSpec_LongName_to_RGBvalue(arrowColors);
        end
    else
        if arrowCol~=3
            error('arrowColors in RGBvalue must be of the form 1x3');
        end
        RGBvalue = arrowColors;
    end
    arrowColors = [];
    arrowColors(1:numArrows,1) = RGBvalue(1);
    arrowColors(1:numArrows,2) = RGBvalue(2);
    arrowColors(1:numArrows,3) = RGBvalue(3);
elseif arrowRow~=numArrows
    error('arrowColors in RGBvalue must be of the form Nx3');
end

end