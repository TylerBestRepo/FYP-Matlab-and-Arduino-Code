clear all;
close all;
clc;

%This is the matlab file i will use to do the first test on the user where
%I wille monitor readings and determine their total step count and no
%feedback will be provided




%Variable definition
v = 200;
L_or_R = 2*ones(1,v);
x_acc = zeros(1,v); 
y_acc = zeros(1,v);  
z_acc = zeros(1,v);  
x_gyro = zeros(1,v);  
y_gyro = zeros(1,v);  
z_gyro = zeros(1,v); 
time = zeros(1,v);
test = zeros(1,v);
%Variables so incoming data from left and right legs will be separated
x_accel_right = zeros(1,v);
y_accel_right = zeros(1,v);
z_accel_right = zeros(1,v);
x_accel_left = zeros(1,v);
y_accel_left = zeros(1,v);
z_accel_left = zeros(1,v);
time_left  = zeros(1,v);
time_right = zeros(1,v);

x_gyro_left = zeros(1,v);
y_gyro_left = zeros(1,v);
z_gyro_left = zeros(1,v);
x_gyro_right = zeros(1,v);
y_gyro_right = zeros(1,v);
z_gyro_right = zeros(1,v);
right =1;
left =1;
stored = [""];
axis_change = 0;
sent = 0;
did_it_send =0;
messages = 0;
noOf = 0;
%While loop counter 
number = 0;
%Opening up serial port connection to receive data
%  x=serial('/dev/cu.usbmodem1301','BAUD', 230400);
x=serial('COM5','BAUD', 230400);
fopen(x);
%%we want this loop to go for seven minutes (420 seconds)
start_time = datetime('now');
comparison_time = datetime('now');
time_elapsed = datenum(comparison_time - start_time)*3600*24;
seconds_Running = 420+1.6; %How many seconds it runs for. + 1.5 is to take into account the initial 1.5 second starting delay
zeroVibration = 199;
fprintf(x, "%d\n",  zeroVibration);
while time_elapsed < seconds_Running
test = fscanf(x);
stored(number+1) = test;
while (length(test) < 1 || length(test) < 10)
   test = fscanf(x); 
   noOf = noOf +1;
end
%%Need some sort of prevention if the sensor loses connection to skip the
%%NULL data
[L_or_R(number + 1),x_acc(number+1),y_acc(number+1),z_acc(number+1), x_gyro(number+1),y_gyro(number+1),z_gyro(number+1)] = stringToIntegers(test);

time_temp = datetime('now') - start_time;
time(number +1) = datenum(time_temp)*3600*24; %% need to convert from whatever my current format is to seconds
%Having the separation being done on the fly here allows me more room to
%perform other actions on the data
if (L_or_R(number+1) == 0)
    x_accel_left(left) = x_acc(number+1);
    y_accel_left(left) = y_acc(number+1);
    z_accel_left(left) = z_acc(number+1);
    time_left(left) = time(number+1);
    x_gyro_left(left) = x_gyro(number+1);
    y_gyro_left(left) = y_gyro(number+1);
    z_gyro_left(left) = z_gyro(number+1);
    left = left +1;
end
if (L_or_R(number+1) == 1)
    x_accel_right(right) = x_acc(number+1);
    y_accel_right(right) = y_acc(number+1);
    z_accel_right(right) = z_acc(number+1);
    time_right(right) = time(number+1);
    x_gyro_right(right) = x_gyro(number+1);
    y_gyro_right(right) = y_gyro(number+1);
    z_gyro_right(right) = z_gyro(number+1);
    right = right +1;
end

if (time_elapsed == 120)
    fprintf("The number of right results is: %d/t Left: %d\n", length(x_accel_right), length(x_accel_left))
end

if (time_elapsed == 280)
    fprintf("The number of right results is: %d/t Left: %d\n", length(x_accel_right), length(x_accel_left))
end

number = number +1;
    if (time(number) > 5)
        a_l.XLim = datenum([time(number) - 5 time(number)+5]);
        a_r.XLim = datenum([time(number) - 5 time(number)+5]);
    end 
    comparison_time = datetime('now');
    time_elapsed = datenum(comparison_time - start_time)*3600*24;
end
fprintf(x, "%d\n",  zeroVibration);
close all


[cadence_left, steps_left] = findCadence(x_gyro_left,time_left);
[cadence_right, steps_right] = findCadence(x_gyro_right,time_right);

%Total Steps 
total_steps = steps_right + steps_left % +  steps_left;   % x2 because only using one device
cadence = cadence_right + cadence_left %Gives answer in steps per minute x2 because only using one device

% %%Plots for Gyro data
 figure
   subplot(1,2,1)
%  plot(time_left(1,1:left-1),x_gyro_left(1,1:left-1),'r')
%  findpeaks(x_gyro_left(1,:),'MinPeakHeight',110,'MinPeakDistance',80)
 hold on
%  ylim([-400 400])
 %xlim([1 seconds_Running])
 title("Left leg data")
 legend('x Gyro')
 xlabel('seconds')
 ylabel('degrees/sec')
% 
 subplot(1,2,2)
plot(time_right(1,1:right-1),x_gyro_right(1,1:right-1),'g')
% findpeaks(x_gyro_right(1,:),'MinPeakHeight',110,'MinPeakDistance',80)
% hold on
% % plot(time_right(1,1:right-1),y_gyro_right(1,1:right-1),'b')
% % plot(time_right(1,1:right-1),z_gyro_right(1,1:right-1),'m')
% ylim([-300 300])
% title("Right leg data Gyro")
% legend('x Gyro')
% xlabel('seconds')
% xlim([1 seconds_Running])

%tranpose first for visual helpfulness

 readings_left = [time_left.', x_gyro_left.'];
 readings_right = [time_right.',x_gyro_right.'];
 
 readings_combined = [time.',x_gyro.'];
% writematrix(readings_combined,'Bernie Backup and combined.csv')
% writematrix(readings_left,'Bernie Test 1-Left.csv') % make sure not to overwrite
% %useful data
 writematrix(readings_right,'One leg no movement bias test on the floor-Right.csv') % make sure not to overwrite
%useful data


%%%%%%%%use this to reset port communication
if ~isempty(instrfind)
fclose(instrfind);
delete(instrfind)
end

sound(sin(1:3000));