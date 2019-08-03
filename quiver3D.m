function varargout = quiver3D(posArray, magnitudeArray, varargin)
% QUIVER3D Plot a quiver of three-dimensional arrows
%
%   Given the posArray (position array) [x1 y1 z1; x2 y2 z2; ...] and their
%   relative magnitudes along the x,y,z-axes using magnitudeArray
%   [dx1 dy1 dz1; dx2 dy2 dz2; ...], with optional color and stem
%   ratios, output a quiver of arrows.
%
% Optional, positional arguments:
%   arrowColors: conforms to 'ColorSpec.'  For example, 'r','red',[1 0 0]
%       will all plot a quiver with all arrows as red. This can also be in
%       the form of Nx3 where 'N' is the number of arrows, and each column
%       corresponds to the R,G,B values
%   stemRatio: Ratio of the arrow head (cone) to the arrow stem (cylinder)
%       For example, setting this value to 0.94 will produce arrows with 
%       arrow stems 94% of the length and short, 6% cones as arrow heads.
%       Values above 0 and below 1 are valid. Default is 0.75.
% 
% Optional name-value pair arguments:
%   'arrowRadius': changes the radius of the arrowstem. Percentage of the
%       lenght of the arrow. Values between 0.01 and 0.01 are valid. 
%       Default is 0.025.
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
% Forms:
%   quiver3D(posArray, magnitudeArray)
%       plot a quiver of three-dimensional arrows with default color black
%
%   quiver3D(posArray, magnitudeArray, arrowColors)
%
%   quiver3D(posArray, magnitudeArray, arrowColors, stemRatio)
%       ratio of the arrowhead (cone) to the arrowstem (cylinder) [default = 0.75]
%
%   quiver3D(AX,...) plots into AX instead of GCA.
%
% Author: Shawn Arseneau 
%   Created: 2006-09-14 by Shawn Arseneau
%   Updated: 2019-08-03 by oqilipo

addpath(genpath([fileparts([mfilename('fullpath'), '.m']) '\' 'src']));

%% Initial verification of input parameters
if nargin<2 || nargin>7
    error('Invalid number of input arguments. Type ''help quiver3D'' for details');
end

% Check if first argument is an axes handle
if numel(posArray) == 1 && ishghandle(posArray, 'axes')
    hAx = posArray;
    posArray=magnitudeArray;
    magnitudeArray=varargin{1};
    varargin(1)=[];
else
    hAx = gca;
end

numArrows = size(posArray,1);
if numArrows ~= size(magnitudeArray,1)
    error(['Number of rows of position and magnitude inputs do not agree. ' ...
        'Type ''help quiver3D'' for details']);
end

% Parsing
p = inputParser;
isPointArray3d = @(x) validateattributes(x,{'numeric'},...
    {'nonempty','nonnan','real','finite','size',[nan,3]});
addRequired(p,'posArray',isPointArray3d)
addRequired(p,'magnitudeArray',isPointArray3d);
addOptional(p,'arrowColors', 'k', @(x) validateArrowColors(x, numArrows));
isStemRatio = @(x) validateattributes(x,{'numeric'},{'vector','>', 0, '<', 1});
addOptional(p,'stemRatio', 0.75, isStemRatio);
isArrowRadius = @(x) validateattributes(x,{'numeric'},{'scalar','>=', 0.01, '<=', 0.1});
addParameter(p,'arrowRadius',0.025, isArrowRadius);

parse(p,posArray,magnitudeArray,varargin{:});
posArray = p.Results.posArray;
magnitudeArray = p.Results.magnitudeArray;
[~, arrowColors] = validateArrowColors(p.Results.arrowColors, numArrows);
stemRatio = p.Results.stemRatio;
arrowRadius = p.Results.arrowRadius;
if numel(stemRatio) == 1
    stemRatio = repmat(stemRatio,numArrows,1);
end

%% Loop through all arrows and plot in 3D
hold(hAx,'on')
qHandle=nan(numArrows,2);
for i=1:numArrows
    qHandle(i,:) = arrow3D(hAx, posArray(i,:), magnitudeArray(i,:), ...
        arrowColors(i,:), stemRatio(i),'arrowRadius',arrowRadius);
end

if nargout > 0
    varargout = {qHandle};
end

end

function [valid, arrowColors]=validateArrowColors(arrowColors,numArrows)
valid=true;
[arrowRow, arrowCol] = size(arrowColors);
if arrowRow==1
    if ischar(arrowColors) %in ShortName or LongName color format
        RGBvalue = ColorSpec2RGBvalue(arrowColors);
    else
        if arrowCol~=3
            error('arrowColors in RGBvalue must be of the form 1x3');
            valid=false;
        end
        RGBvalue = arrowColors;
    end
    arrowColors = [];
    arrowColors(1:numArrows,1) = RGBvalue(1);
    arrowColors(1:numArrows,2) = RGBvalue(2);
    arrowColors(1:numArrows,3) = RGBvalue(3);
elseif arrowRow~=numArrows
    error('arrowColors in RGBvalue must be of the form Nx3');
    valid=false;
end

end