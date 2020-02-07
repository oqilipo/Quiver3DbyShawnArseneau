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
% 
% Optional name-value pair arguments:
%   'stemRatio': Ratio of the arrow head (cone) to the arrow stem (cylinder)
%       For example, setting this value to 0.94 will produce arrows with 
%       arrow stems 94% of the length and short, 6% cones as arrow heads.
%       Values above 0 and below 1 are valid. Default is 0.75.
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
p.KeepUnmatched = true;
isPointArray3d = @(x) validateattributes(x,{'numeric'},...
    {'nonempty','nonnan','real','finite','size',[nan,3]});
addRequired(p,'posArray',isPointArray3d)
addRequired(p,'magnitudeArray',isPointArray3d);
addOptional(p,'arrowColors', 'k', @(x) validateArrowColors(x, numArrows));
isStemRatio = @(x) validateattributes(x,{'numeric'},{'vector','>', 0, '<', 1});
addParameter(p,'stemRatio', 0.75, isStemRatio);
isArrowRadius = @(x) validateattributes(x,{'numeric'},{'scalar','>=', 0.01, '<=', 0.1});
addParameter(p,'arrowRadius',0.025, isArrowRadius);

parse(p,posArray,magnitudeArray,varargin{:});
posArray = p.Results.posArray;
magnitudeArray = p.Results.magnitudeArray;
[~, arrowColors] = validateArrowColors(p.Results.arrowColors, numArrows);
stemRatio = p.Results.stemRatio;
if numel(stemRatio) == 1
    stemRatio = repmat(stemRatio,numArrows,1);
end
arrowRadius = p.Results.arrowRadius;
if numel(arrowRadius) == 1
    arrowRadius = repmat(arrowRadius,numArrows,1);
end
drawOptions=p.Unmatched;

%% Loop through all arrows and plot in 3D
hold(hAx,'on')
qHandle=nan(numArrows,2);
for i=1:numArrows
    qHandle(i,:) = drawSingleVector3d(hAx, posArray(i,:), ...
        magnitudeArray(i,:), arrowColors(i,:), stemRatio(i),arrowRadius(i),...
        drawOptions);
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
        arrowColors=repmat(arrowColors,numArrows,1);
    else
        if arrowCol~=3
            error('arrowColors in RGBvalue must be of the form 1x3.');
        end
        arrowColors=repmat(arrowColors,numArrows,1);
    end
elseif arrowRow~=numArrows
    error('arrowColors in RGBvalue must be of the form Nx3.');
end

end

function arrowHandle = drawSingleVector3d(hAx, pos, mag, arrowColor, stemRatio, arrowRadius, drawOptions)
%ARROW3D Plot a single 3D arrow with a cylindrical stem and cone arrowhead
%
% Inputs:
%   pos: [X,Y,Z] spatial location of the starting point of the arrow
%   mag: [QX,QY,QZ] delta parameters denoting the magnitude of the arrow 
%       along the x,y,z-axes (relative to 'pos')
%   arrowColor: Color parameters as per the 'surf' command.  For example,
%       'r', 'red', [1 0 0] are all examples of a red-colored arrow
%   stemRatio: ratio of the length of the stem in proportion to the
%       arrow head. For example, a call of a value of 0.82 will produce a
%       arrow of magnitude of 100%, with the arrow stem spanning a
%       distance of 82% while the arrowhead (cone) spans 18%. 
%       Values above 0 and below 1 are valid. Default is 0.75.
%   'arrowRadius': changes the radius of the arrowstem. Percentage of the
%       lenght of the arrow. Values between 0.01 and 0.01 are valid. 
%       Default is 0.025.

% Create Arrow
X = pos(1); Y = pos(2); Z = pos(3);

[~, ~, srho] = cart2sph(mag(1), mag(2), mag(3));

%% ************************* CYLINDER == STEM ************************** %%
cylinderRadius = arrowRadius*srho;
cylinderLength = srho*stemRatio;
[CX,CY,CZ] = cylinder(cylinderRadius);
CZ = CZ.*cylinderLength; % lengthen

% Rotate Cylinder
[row, col] = size(CX); % initial rotation to coincide with x-axis

newEll = transformPoint3d([CX(:), CY(:), CZ(:)],createRotationVector3d([1 0 0],[0 0 -1]));
CX = reshape(newEll(:,1), row, col);
CY = reshape(newEll(:,2), row, col);
CZ = reshape(newEll(:,3), row, col);

[row, col] = size(CX);
newEll = transformPoint3d([CX(:), CY(:), CZ(:)],createRotationVector3d([1 0 0],mag));
stemX = reshape(newEll(:,1), row, col);
stemY = reshape(newEll(:,2), row, col);
stemZ = reshape(newEll(:,3), row, col);

% Translate cylinder
stemX = stemX + X;
stemY = stemY + Y;
stemZ = stemZ + Z;

%% ************************* CONE == ARROWHEAD ************************* %%
RADIUS_RATIO = 1.5;
coneLength = srho*(1-stemRatio);
coneRadius = cylinderRadius*RADIUS_RATIO;
incr = 4;  % Steps of cone increments
coneincr = coneRadius/incr;
[coneX, coneY, coneZ] = cylinder(cylinderRadius*2:-coneincr:0); % Cone
coneZ = coneZ.*coneLength;

% Rotate cone
[row, col] = size(coneX);
newEll = transformPoint3d([coneX(:), coneY(:), coneZ(:)],createRotationVector3d([1 0 0],[0 0 -1]));
coneX = reshape(newEll(:,1), row, col);
coneY = reshape(newEll(:,2), row, col);
coneZ = reshape(newEll(:,3), row, col);

newEll = transformPoint3d([coneX(:), coneY(:), coneZ(:)],createRotationVector3d([1 0 0],mag));
headX = reshape(newEll(:,1), row, col);
headY = reshape(newEll(:,2), row, col);
headZ = reshape(newEll(:,3), row, col);

% Translate cone
% centerline for cylinder: the multiplier is to set the cone 'on the rim' of the cylinder
V = [0, 0, srho*stemRatio];
Vp = transformPoint3d(V,createRotationVector3d([1 0 0],[0 0 -1]));
Vp = transformPoint3d(Vp,createRotationVector3d([1 0 0],mag));
headX = headX + Vp(1) + X;
headY = headY + Vp(2) + Y;
headZ = headZ + Vp(3) + Z;

% Draw cylinder & cone
hStem = patch(hAx, surf2patch(stemX, stemY, stemZ), 'FaceColor', arrowColor, 'EdgeColor', 'none', drawOptions);
hold(hAx,'on')
hHead = patch(hAx, surf2patch(headX, headY, headZ), 'FaceColor', arrowColor, 'EdgeColor', 'none', drawOptions);

if nargout==1
    arrowHandle = [hStem, hHead];
end

end