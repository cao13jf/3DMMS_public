E = vigraGaussianGradientMagnitude(double(M), struct('sigmas', [3, 3, 3]));
M = E > 0.05;

[X, Y, Z] = ind2sub(size(M), find(M(:) ~= 0));
pts = [X(:), Y(:), Z(:)];
pts = pts(randsample(length(pts), 2.5e3), :);

figure; 
scatter3(pts(:, 1), pts(:, 2), pts(:, 3), '.'); axis equal;
xlabel('x'); ylabel('y'); zlabel('z');


x = pts(:, 1); y = pts(:, 2); z = pts(:, 3);
% do the fitting
[ center, radii, evecs, v ] = ellipsoid_fit( pts );
fprintf( 'Ellipsoid center: %.3g %.3g %.3g\n', center );
fprintf( 'Ellipsoid radii : %.3g %.3g %.3g\n', radii );
fprintf( 'Ellipsoid evecs :\n' );
fprintf( '%.3g %.3g %.3g\n%.3g %.3g %.3g\n%.3g %.3g %.3g\n', ...
    evecs(1), evecs(2), evecs(3), evecs(4), evecs(5), evecs(6), evecs(7), evecs(8), evecs(9) );
fprintf( 'Algebraic form  :\n' );
fprintf( '%.3g ', v );
fprintf( '\n' );


% RANSAC
E = vigraGaussianGradientMagnitude(double(M), struct('sigmas', [3, 3, 3]));
M = E > 0.05;
pts = [X(:), Y(:), Z(:)];
pts = pts(randsample(length(pts), 2.5e3), :);

[L, inliers] = ransacfitellipse3d(pts', 9, 0.05, true);
v = L{end};

% draw data
figure;
x = pts(:, 1); y = pts(:, 2); z = pts(:, 3);
plot3( x, y, z, '.r' ); axis equal
hold on;

%draw fit
x = -2*size(M, 1):16:2*size(M, 1);
y = -2*size(M, 2):16:2*size(M, 2);
z = -2*size(M, 3):16:2*size(M, 3);
[ x, y, z ] = meshgrid(x, y, z);

Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
          2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
          2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
p = patch( isosurface( x, y, z, Ellipsoid, 1 ) );
set( p, 'FaceColor', 'none', 'EdgeColor', 'b' );

% p = patch( isosurface( x, y, z, Ellipsoid, 0.99 ) );
% set( p, 'FaceColor', 'none', 'EdgeColor', 'r' );

title(sprintf('percentage of inliers: %g', length(inliers)/length(pts)));

view( -70, 40 );
axis vis3d;
camlight;
lighting phong;



% random sample
% x = -2*size(M, 1):16:2*size(M, 1);
% y = -2*size(M, 2):16:2*size(M, 2);
% z = -2*size(M, 3):16:2*size(M, 3);
x = 1:size(M, 1);
y = 1:size(M, 2);
z = 1:size(M, 3);
[ x, y, z ] = meshgrid(x, y, z);
Ellipsoid = zeros(size(x));
nTrails = 10;
for i = 1:nTrails
    [X, Y, Z] = ind2sub(size(M), find(M(:) ~= 0));
    pts = [X(:), Y(:), Z(:)];
    pts = pts(randsample(length(pts), 1e3), :);
    pts = pts ./ max(size(I));

%     [L, inliers] = ransacfitellipse3d(pts', 27, 0.025, false);
%     v = L{end};
%     [ center, radii, evecs, v ] = ellipsoid_fit(pts_);
%     Ellipsoid = Ellipsoid + ...
%         (v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
%         2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
%         2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z < 1);    
    
    nu = 0.1;
    params = {20, 1:3, eye(size(pts, 2))};
    ocsvm = LearnOneClassSVM(pts(:, 1:3), nu, @KernelGaussian, params, 'libqp_gsmo');
    
    
    [C, R] = PredictOneClassSVM([ X(:), Y(:), Z(:) ] ./ max(size(I)), ocsvm);
%     Ellipsoid = Ellipsoid + (reshape(C, size(Ellipsoid))+1)/2;
    Ellipsoid(M ~= 0) = Ellipsoid(M ~= 0) + (C+1)/2;
end
ctSliceExplorer(Ellipsoid);

% draw data
figure;
x = pts(:, 1); y = pts(:, 2); z = pts(:, 3);
plot3( x, y, z, '.r' ); axis equal
hold on;

x = 1:size(M, 1);
y = 1:size(M, 2);
z = 1:size(M, 3);
p = patch( isosurface( x, y, z, Ellipsoid, nTrails/2 ) );
set( p, 'FaceColor', 'none', 'EdgeColor', 'b' );

% p = patch( isosurface( x, y, z, Ellipsoid, 0.99 ) );
% set( p, 'FaceColor', 'none', 'EdgeColor', 'r' );

view( -70, 40 );
axis vis3d;
camlight;
lighting phong;


























% test ellipsoid fit

% create the test data:
% radii
a = 8;
b = 6;
c = 10;
[ s, t ] = meshgrid( 0 : 0.3 : pi/2, 0 : 0.3 : pi );
x = a * cos(s) .* cos( t );
y = b * cos(s) .* sin( t );
z = c * sin(s);
% rotation
ang = pi/6;
xt = x * cos( ang ) - y * sin( ang );
yt = x * sin( ang ) + y * cos( ang );
% translation
shiftx = 1;
shifty = 2;
shiftz = 3;
x = xt + shiftx;
y = yt + shifty;
z = z  + shiftz;

% add testing noise:
noiseIntensity = 0.;
x = x + randn( size( s ) ) * noiseIntensity;
y = y + randn( size( s ) ) * noiseIntensity;
z = z + randn( size( s ) ) * noiseIntensity;
x = x(:);
y = y(:);
z = z(:);

% do the fitting
[ center, radii, evecs, v ] = ellipsoid_fit( [x y z ] );
fprintf( 'Ellipsoid center: %.3g %.3g %.3g\n', center );
fprintf( 'Ellipsoid radii : %.3g %.3g %.3g\n', radii );
fprintf( 'Ellipsoid evecs :\n' );
fprintf( '%.3g %.3g %.3g\n%.3g %.3g %.3g\n%.3g %.3g %.3g\n', ...
    evecs(1), evecs(2), evecs(3), evecs(4), evecs(5), evecs(6), evecs(7), evecs(8), evecs(9) );
fprintf( 'Algebraic form  :\n' );
fprintf( '%.3g ', v );
fprintf( '\n' );

% draw data
plot3( x, y, z, '.r' );
hold on;

%draw fit
maxd = max( [ a b c ] );
step = maxd / 50;
[ x, y, z ] = meshgrid( -maxd:step:maxd + shiftx, -maxd:step:maxd + shifty, -maxd:step:maxd + shiftz );

Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
          2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
          2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
p = patch( isosurface( x, y, z, Ellipsoid, 1 ) );
set( p, 'FaceColor', 'g', 'EdgeColor', 'none' );
view( -70, 40 );
axis vis3d;
camlight;
lighting phong;