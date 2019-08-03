function arrowHandle = arrow3D(pos, mag, varargin)
%ARROW3D Plot a single 3D arrow with a cylindrical stem and cone arrowhead
%
% Inputs:
%   pos: [X,Y,Z] spatial location of the starting point of the arrow
%   mag: [QX,QY,QZ] delta parameters denoting the magnitude of the arrow 
%       along the x,y,z-axes (relative to 'pos')
%
% Optional, positional arguments:
%   arrowColor: Color parameters as per the 'surf' command.  For example,
%       'r', 'red', [1 0 0] are all examples of a red-colored arrow
%   stemRatio: ratio of the length of the stem in proportion to the
%       arrow head. For example, a call of a value of 0.82 will produce a
%       arrow of magnitude of 100%, with the arrow stem spanning a
%       distance of 82% while the arrowhead (cone) spans 18%. 
%       Values above 0 and below 1 are valid. Default is 0.75.
%
% Optional name-value pair arguments:
%   'arrowRadius': changes the radius of the arrowstem. Percentage of the
%       lenght of the arrow. Values between 0.01 and 0.01 are valid. 
%       Default is 0.025.
%
% Example:
%    arrow3D([0,0,0], [4,3,7]);  % arrow with default parameters
%    axis equal;
%
% Author: Shawn Arseneau
%   Created: 2006-09-14 by Shawn Arseneau
%   Updated: 2019-08-03 by oqilipo


%% Initial verification of input parameters
if nargin<2 || nargin>7
    error('Invalid number of input arguments.');
end

% Check if first argument is an axes handle
if numel(pos) == 1 && ishghandle(pos, 'axes')
    hAx = pos;
    pos=mag;
    mag=varargin{1};
    varargin(1)=[];
else
    hAx = gca;
end

% Parsing
p = inputParser;
isPoint3d = @(x) validateattributes(x,{'numeric'},...
    {'nonempty','nonnan','real','finite','size',[1,3]});
addRequired(p,'pos',isPoint3d)
addRequired(p,'mag',isPoint3d);
isArrowColor = @(x) validateattributes(x,{'numeric'},{'size',[1,3], '>=', 0, '<=', 1});
addOptional(p,'arrowColor', [0 0 0], isArrowColor);
isStemRatio = @(x) validateattributes(x,{'numeric'},{'scalar','>', 0, '<', 1});
addOptional(p,'stemRatio', 0.75, isStemRatio);
isArrowRadius = @(x) validateattributes(x,{'numeric'},{'scalar','>=', 0.01, '<=', 0.1});
addParameter(p,'arrowRadius',0.025, isArrowRadius);

parse(p,pos,mag,varargin{:});
pos = p.Results.pos;
mag = p.Results.mag;
arrowColor = p.Results.arrowColor;
stemRatio = p.Results.stemRatio;
arrowRadius = p.Results.arrowRadius;

%% Create Arrow
X = pos(1); Y = pos(2); Z = pos(3);

[~, ~, srho] = cart2sph(mag(1), mag(2), mag(3));

%% ************************* CYLINDER == STEM ************************** %%
cylinderRadius = arrowRadius*srho;
cylinderLength = srho*stemRatio;
[CX,CY,CZ] = cylinder(cylinderRadius);
CZ = CZ.*cylinderLength; % lengthen

% Rotate Cylinder
[row, col] = size(CX); % initial rotation to coincide with x-axis

newEll = rotatePoints([0 0 -1], [CX(:), CY(:), CZ(:)]);
CX = reshape(newEll(:,1), row, col);
CY = reshape(newEll(:,2), row, col);
CZ = reshape(newEll(:,3), row, col);

[row, col] = size(CX);
newEll = rotatePoints(mag, [CX(:), CY(:), CZ(:)]);
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
newEll = rotatePoints([0 0 -1], [coneX(:), coneY(:), coneZ(:)]);
coneX = reshape(newEll(:,1), row, col);
coneY = reshape(newEll(:,2), row, col);
coneZ = reshape(newEll(:,3), row, col);

newEll = rotatePoints(mag, [coneX(:), coneY(:), coneZ(:)]);
headX = reshape(newEll(:,1), row, col);
headY = reshape(newEll(:,2), row, col);
headZ = reshape(newEll(:,3), row, col);

% Translate cone
% centerline for cylinder: the multiplier is to set the cone 'on the rim' of the cylinder
V = [0, 0, srho*stemRatio];
Vp = rotatePoints([0 0 -1], V);
Vp = rotatePoints(mag, Vp);
headX = headX + Vp(1) + X;
headY = headY + Vp(2) + Y;
headZ = headZ + Vp(3) + Z;

% Draw cylinder & cone
hStem = patch(hAx, surf2patch(stemX, stemY, stemZ), 'FaceColor', arrowColor, 'EdgeColor', 'none');
hold(hAx,'on')
hHead = patch(hAx, surf2patch(headX, headY, headZ), 'FaceColor', arrowColor, 'EdgeColor', 'none');

if nargout==1
    arrowHandle = [hStem, hHead];
end

end
