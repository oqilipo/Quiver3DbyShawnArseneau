clearvars; close all; opengl hardware

%% Syntax
% quiver3D(posArray, magnitudeArray)
% quiver3D(posArray, magnitudeArray, one_ColorName)
% quiver3D(posArray, magnitudeArray, one_RGBvalueColor)
% quiver3D(posArray, magnitudeArray, many_RGBvalueColor)
% quiver3D(ax, ...)
%
%% Description
% quiver3D(posArray, magnitudeArray)
%   plot an arrow for each row of posArray in form of (x,y,z) with delta 
%   values corresponding to the rows of magnitudeArray (u,v,w) using 
%   arrow3D, which allows for a three-dimensional arrow representation.  
%   Since arrow3D uses 'surf', you may use 'camlight' and 'lighting' to add
%   more powerful visual effects of the data.
%
% quiver3D(..., one_ColorName)
%   colors all arrows the same color using MATLAB's color convention
%   {'r' or 'red',...} as per ColorSpec.
%
% quiver3D(..., one_RGBvalueColor)
%   colors all arrows the same color using the three element vector 
%   representation. For example [0, 1, 0.5]
%
% quiver3D(..., many_RGBvalueColor)
%   a distinct color is assigned each of the individual arrows in the 
%   quiver in Nx3 format.
%

%% Output a collection of arrows with various color and shape options
figure('Color','w')
spH=arrayfun(@(x) subplot(2,2,x), 1:4);
for s=1:length(spH)
    axis(spH(s),'equal');
    grid(spH(s),'on');
    xlabel(spH(s),'X'); ylabel(spH(s),'Y'); zlabel(spH(s),'Z');
    view(spH(s),20,30);
    lighting(spH(s),'phong');
    camlight(spH(s),'head');
end

%% Examples
[X, Y] = meshgrid(0:3:9, 0:3:9);
Z = ones(size(X));
U = zeros(size(X));
V = U;
W = ones(size(X))*8;
posArray = [X(:),Y(:),Z(:)];
magnitudeArray = [U(:),V(:),W(:)];

%% Basic call
quiver3D(spH(1), posArray, magnitudeArray,'yellow');

%% Arrow-specific colors and change of stem ratio
arrowColors = jet(size(posArray,1));
quiver3D(spH(2), posArray, magnitudeArray, arrowColors, 'stemRatio',0.9);

%% Change of stem ratios and stem radius
qH = quiver3D(spH(3), posArray, magnitudeArray, arrowColors, ...
    'stemRatio',linspace(0.5,0.9,size(posArray,1)), 'arrowRadius', 0.01);
delete(qH(end,:))

%% Helix Example
radius = 7;   height = 1;  numRotations = 2;  numPoints = 25;  arrowScale = 0.8;
[posArray1, magnitudeArray1] = helix(radius, height, numRotations, numPoints, arrowScale);
quiver3D(posArray1, magnitudeArray1)

radius = 2;   height = 0.66;  numRotations = 3;
[posArray2, magnitudeArray2] = helix(radius, height, numRotations, numPoints, arrowScale);
arrowColors2 = autumn(numPoints);
quiver3D(posArray2, magnitudeArray2, arrowColors2, 'stemRatio',0.6)

