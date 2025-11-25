% enu_xyz_llh_circle_demo.m
% Demo: ENU -> ECEF -> ENU consistency check using a circular trajectory
clear; clc; close all;

% Origin LLH (radians)
orgllh = [25.150335*pi/180, 121.778380*pi/180, 0];  % [lat lon h]
orgxyz = llh2xyz(orgllh);                           % ECEF origin
fprintf('||orgxyz|| = %.3f m\n', norm(orgxyz));     % sanity check

% Circular trajectory in ENU (radius 5 km)
radius = 5e3;              % [m]
a = 360;                   % number of samples
dtheta = 2*pi/a;
imax = a - 1;

east  = zeros(1,imax);
north = zeros(1,imax);
up    = zeros(1,imax);

for i = 1:imax
    theta    = (i-1)*dtheta;
    east(i)  = radius*cos(theta);
    north(i) = radius*sin(theta);
    up(i)    = 0;
end

% ENU -> ECEF
usrx = zeros(1,imax);
usry = zeros(1,imax);
usrz = zeros(1,imax);

for i = 1:imax
    usrenu = [east(i), north(i), up(i)];
    usrxyz = enu2xyz(usrenu, orgxyz);
    usrx(i) = usrxyz(1);
    usry(i) = usrxyz(2);
    usrz(i) = usrxyz(3);
end

% Plot 2D ECEF projection (x–y)
figure;
plot(usrx, usry);
xlabel('X [m]'); ylabel('Y [m]');
title('User trajectory in ECEF (XY projection)');
axis equal; grid on;

% Plot 3D ECEF trajectory
figure;
plot3(usrx, usry, usrz);
xlabel('X [m]'); ylabel('Y [m]'); zlabel('Z [m]');
title('User trajectory in ECEF (3D)');
grid on;

% ECEF -> ENU (round-trip check)
usre = zeros(1,imax);
usrn = zeros(1,imax);
usru = zeros(1,imax);

for i = 1:imax
    usrxyz      = [usrx(i), usry(i), usrz(i)];
    usrenu_back = xyz2enu(usrxyz, orgxyz);
    usre(i) = usrenu_back(1);
    usrn(i) = usrenu_back(2);
    usru(i) = usrenu_back(3);
end

% Compare original ENU circle and recovered ENU
figure;
plot(east, north, 'r--', 'DisplayName','Original ENU');
hold on;
plot(usre, usrn, 'b', 'DisplayName','Recovered ENU');
xlabel('East [m]'); ylabel('North [m]');
title('ENU -> ECEF -> ENU Consistency Check');
axis equal; grid on; legend;

% ENU height error over the circle
figure;
plot(1:imax, usru);
xlabel('Sample index'); ylabel('Up error [m]');
title('Round-trip Up-component error (ENU -> ECEF -> ENU)');
grid on;
