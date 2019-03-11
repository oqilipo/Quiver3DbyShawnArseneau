function arrowHandle = arrow3D(pos, deltaValues, colorCode, stemRatio, varargin)
%ARROW3D Plot a single 3D arrow with a cylindrical stem and cone arrowhead
%
% Inputs:
%   pos: [X,Y,Z] spatial location of the starting point of the arrow
%   deltaValues: [QX,QY,QZ] delta parameters denoting the magnitude of the
%       arrow along the x,y,z-axes (relative to 'pos')
%   colorCode: Color parameters as per the 'surf' command.  For example,
%       'r', 'red', [1 0 0] are all examples of a red-colored arrow
%   stemRatio: The ratio of the length of the stem in proportion to the
%       arrowhead.  For example, a call of a value of 0.82) will produce a
%       red arrow of magnitude of 100%, with the arrowstem spanning a
%       distance of 82% while the arrowhead (cone) spans 18%.
%
% Example:
%    arrow3D([0,0,0], [4,3,7]);  % arrow with default parameters
%    axis equal;
%
% Author: Shawn Arseneau
%   Created: 2006-14-09
%   Updated: 2018-01-11
%


%% Initial verification of input parameters
if nargin<2 || nargin>5
    error('Invalid number of input arguments.');
end

if numel(pos) == 1 && ishghandle(pos, 'axes')
    hAx = pos;
    pos=deltaValues;
    deltaValues=colorCode;
    switch nargin
        case 4
            colorCode=stemRatio;
        case 5
            colorCode=stemRatio;
            stemRatio=varargin{1};
    end
    NoIA=nargin-1;
else
    hAx = gca;
    NoIA=nargin;
end

if numel(pos)~=3 || numel(deltaValues)~=3
    error('pos and/or deltaValues have incorrect dimensions (should be three)');
end

if NoIA<3
    colorCode = 'interp';
end
if NoIA<4
    stemRatio = 0.75;
end

%% Create Arrow

X = pos(1); Y = pos(2); Z = pos(3);

[~, ~, srho] = cart2sph(deltaValues(1), deltaValues(2), deltaValues(3));

%************************* CYLINDER == STEM ***************************
cylinderRadius = 0.025*srho;
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
newEll = rotatePoints(deltaValues, [CX(:), CY(:), CZ(:)]);
stemX = reshape(newEll(:,1), row, col);
stemY = reshape(newEll(:,2), row, col);
stemZ = reshape(newEll(:,3), row, col);

% Translate cylinder
stemX = stemX + X;
stemY = stemY + Y;
stemZ = stemZ + Z;

%************************** CONE == ARROWHEAD *************************
coneLength = srho*(1-stemRatio);
coneRadius = cylinderRadius*1.5;
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

newEll = rotatePoints(deltaValues, [coneX(:), coneY(:), coneZ(:)]);
headX = reshape(newEll(:,1), row, col);
headY = reshape(newEll(:,2), row, col);
headZ = reshape(newEll(:,3), row, col);

% Translate cone
% centerline for cylinder: the multiplier is to set the cone 'on the rim' of the cylinder
V = [0, 0, srho*stemRatio];
Vp = rotatePoints([0 0 -1], V);
Vp = rotatePoints(deltaValues, Vp);
headX = headX + Vp(1) + X;
headY = headY + Vp(2) + Y;
headZ = headZ + Vp(3) + Z;

% Draw cylinder & cone
hStem = patch(hAx, surf2patch(stemX, stemY, stemZ), 'FaceColor', colorCode, 'EdgeColor', 'none');
hold(hAx,'on')
hHead = patch(hAx, surf2patch(headX, headY, headZ), 'FaceColor', colorCode, 'EdgeColor', 'none');

if nargout==1
    arrowHandle = [hStem, hHead];
end

end
