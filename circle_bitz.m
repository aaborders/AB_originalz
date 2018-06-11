%% Pick points around a circle

x0=10; % x0 and y0 are center coordinates
y0=20;  
r=1;  % radius
angle=-pi:0.1:pi;
angl=angle(randi(numel(angle),15,1));
x=r*cos(angl)+x0;
y=r*sin(angl)+y0;
scatter(x,y);
xlim([-r r]+x0);
ylim([-r r]+y0);
axis square


%% Create a logical image of a ring with specified
% inner diameter, outer diameter center, and image size.
% First create the image.
imageSizeX = 640;
imageSizeY = 480;
[columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = 320;
centerY = 240;
innerRadius = 100;
outerRadius = 140;
array2D = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2;
ringPixels = array2D >= innerRadius.^2 & array2D <= outerRadius.^2;
% ringPixels is a 2D "logical" array.
% Now, display it.
image(ringPixels) ;
colormap([0 0 0; 1 1 1]);
title('Binary Image of a Ring', 'FontSize', 25);


%% Create a logical image of a circle with specified
% diameter, center, and image size.

% First create the image.
imageSizeX = 640;
imageSizeY = 480;
[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = 320;
centerY = 240;
radius = 100;
circlePixels = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2 <= radius.^2;
% circlePixels is a 2D "logical" array.
% Now, display it.
image(circlePixels) ;
colormap([0 0 0; 1 1 1]);
title('Binary image of a circle');