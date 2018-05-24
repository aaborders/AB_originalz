N= 15;                                  % Number Of Sides To Polygon
a = sort(rand(N,1))*2*pi;
r = randi(9, N, 1);
x = cos(a).*r;
y = sin(a).*r;
figure(1)
plot([x; x(1)], [y; y(1)])

 % Self-intersecting polygon
        xv = rand(6,1); yv = rand(6,1);
        xv = [xv ; xv(1)]; yv = [yv ; yv(1)];
        x = rand(1000,1); y = rand(1000,1);
        in = inpolygon(x,y,xv,yv);
        plot(xv,yv,x(in),y(in),'.r',x(~in),y(~in),'.b')
        
        
        % Multiply-connected polygon - a square with a square hole.
        % Counterclockwise outer loop, clockwise inner loop.
        xv = [0 3 3 0 0 NaN 1 1 2 2 1];
        yv = [0 0 3 3 0 NaN 1 2 2 1 1];
        x = rand(1000,1)*3; y = rand(1000,1)*3;
        in = inpolygon(x,y,xv,yv);
        plot(xv,yv,x(in),y(in),'.r',x(~in),y(~in),'.b')
        

x=rand(12,1);
y=rand(12,1);
K = convhull(x,y) ;

figure
plot(x(K),y(K),'r-')