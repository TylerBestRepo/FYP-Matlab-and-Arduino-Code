clear all;
close all;
clc;
%%%%%%TEST 2%%%%%%%%
%This is the matlab file I will use to trigger the second experimental
%condition where there will be a fixed vibrational amplitude cue.

%%%Step 1:
%Vibrate at users natural cadence for 1 minute
%%%Step 2:
%Vibrate at 110% of natural cadence for 1 minute
%%%Step 3:
%Vibrate at users natural cadence for 1 minute
%%%Step 4:
%Vibrate at 120% of natural cadence for 1 minute
%%%Step 5:
%Vibrate at users natural cadence for 1 minute
%%%Step 6:
%Vibrate at 130% of natural cadence for 1 minute
%%%Step 7:
%No Vibrations for 1 minute.
%Test over


%%%%%%%%%Defining important variables from Test 1
normal_cadence = 105;


%figure
b = 0;
n = 0;
%Plot for left leg data
% subplot(2,2,1)
% plot(b,n)
% hold on
% ylim([-300 300])
% set(gca,'xlim',[0 5]) %% GCA is a function that returns the handle of the current axis in the current figure
% title("Left leg Gyro data")
% a_l = gca;
% 
% x_a = animatedline;
% x_a.Color = 'r';
% y_a = animatedline;
% y_a.Color = 'b';
% z_a = animatedline;
% z_a.Color = 'm';

%legend('x acceleration', 'y acceleration', 'z acceleration')
%Gyroscope plotting
% subplot(2,2,2)
% plot(b,n)
% hold on
% title("Gyro data for right leg")
% ylim([-300 300])
% set(gca,'xlim',[0 5])
% a_r = gca;
% x_a_r = animatedline;
% x_a_r.Color = 'r';
% legend('x accel', 'y accel', 'z accel')


%While loop counter 
number = 0;
% Opening up serial port connection to receive data
% x=serial('/dev/cu.usbmodem1301','BAUD', 230400);
x=serial('COM5','BAUD', 230400);
fopen(x);
startTime = datetime('now');

%Variable definition
v = 50;
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

%%Booleans so that if feedback is off when the time changes then feedback
on = false; %Bool for if the motors are currently providing feedback
vibrate = true; %This is a trigger to start or stop the vibrations
%Alternating booleans to make for more efficient code and so that it doesnt
%re enter time frame ifs over and over again
first_swap = false;
next_swap = false;
%Multiplication factors
multipliers = [1,1.05,1,1.10,1,1.15,1];
g = 1;
cadence_off = false; %defining this as off to begin, so that it can send vibration data initially
%%we want this loop to go for seven minutes (420 seconds)
start_time = datetime('now');
comparison_time = datetime('now');
time_elapsed = datenum(comparison_time - start_time)*3600*24;
factor = 1; %This is used to reduce the time for a quick debug test (1 = normal)
seconds_Running = 420/factor; %How many seconds it runs for
zeroVibration = 199;
cadence_interval = 7;
interval_checker = datetime('now');
incremental_time_right = 1;
incremental_time_left = 1;%This goes into the cadence retrieving section and allows me to accurately take 5 seconds worth of data each time
actual_cadence = 300; %off the bat so that it doesnt trigger any problems
off = true;
target_range = 4; %4? %This is the +- target range for the users cadence compared to the target cadence
%%Array to store all of the cadence values passed through and how long they served there
feedback_cadence = zeros(1,100);

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

time_temp = datetime('now') - startTime;
time(number +1) = datenum(time_temp)*3600*24; %% need to convert from whatever my current format is to seconds

target_cadence = normal_cadence;
if (vibrate == true && on == false)
    fprintf(x,"%d\n",round(target_cadence*multipliers(g)));
    fprintf("Cadence output = %d\n", round(target_cadence*multipliers(g)))
    on = true;
    feedback_cadence(number +1) = target_cadence*multipliers(g);
    fprintf("The number of right results is: %d/t Left: %d\n", length(x_accel_right), length(x_accel_left))
end
if (vibrate == false && on == true)
    fprintf(x,"%d\n",zeroVibration);
    fprintf("Cadence stops here\n")
    on = false;
    feedback_cadence(number +1) = zeroVibration;
end

%Having the separation being done on the fly here allows me more room to
%perform other actions on the data

%%Maybe turn this into a function
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

    number = number +1;

    comparison_time = datetime('now');
    time_elapsed = datenum(comparison_time - start_time)*3600*24;
    %Getting cadence values to determine iff the feedback stays on 5 second
    %intervals
    if ((comparison_time - interval_checker)*86400 >= cadence_interval)
        if (length(time_right) - incremental_time_right > 80)
            [actual_cadence_right, stepsRight] = findCadence(x_gyro_right(1,incremental_time_right:length(x_gyro_right)),time_right(1,incremental_time_right:length(x_gyro_right)));
        end
        if (length(time_left) - incremental_time_right > 80)
            [actual_cadence_left, stepsLeft] = findCadence(x_gyro_left(1,incremental_time_left:length(x_gyro_left)),time_left(1,incremental_time_left:length(x_gyro_left)));
        end
       if (time_elapsed > 10)
           %%%make actual_cadence_left a matrix
           actual_cadence = actual_cadence_right + actual_cadence_left; %x2 for now while using results from one IMU
        fprintf("Cadence was found to be: %d\n",round(actual_cadence));
        incremental_time_right = length(x_gyro_right);
        incremental_time_left = length(x_gyro_left);%% This is causing some issues when being passed into cadence_right
        interval_checker = datetime('now');
       end
    end
    %If the difference between target and actual is less than or equal to 4
    %then the feedback turns off
    if (abs(target_cadence - actual_cadence) > target_range && on == false)
        if (time_elapsed < 360)
            vibrate = true;
            disp("Cadence turns back on")
        end
    end
    
    if (abs(target_cadence - actual_cadence) <= target_range && on == true)
        if (time_elapsed < 360)
            vibrate = false;
            disp("Cadence off")
        end
    end
    %Bool changes to fix sent# problems
    if (time_elapsed > 60/factor && time_elapsed < 120/factor && first_swap == false)
       on = false;
       vibrate = true;
       g = 2;
       first_swap = true;
    end
    if (time_elapsed > 120/factor && time_elapsed < 180/factor && next_swap == false)
       on = false;
       vibrate = true;
       g = 3;
       first_swap = false;
       next_swap = true;
    end
    if (time_elapsed > 180/factor && time_elapsed < 240/factor && first_swap == false)
       on = false;
       vibrate = true;
       g = 4;
       first_swap = true;
       next_swap = false;
    end
    if (time_elapsed > 240/factor && time_elapsed < 300/factor && next_swap == false)
       on = false;
       vibrate = true;
       g = 5;
       first_swap = false;
       next_swap = true;
    end
    if (time_elapsed > 300/factor && time_elapsed < 360/factor && first_swap == false)
       on = false;
       vibrate = true;
       g = 6;
       first_swap = true;
       next_swap = false;
    end
    if (time_elapsed > 360/factor && time_elapsed < 420/factor && next_swap == false)
       on = true;
       g = 7;
       vibrate = false;
       next_swap = true;
       normal_cadence = 199;
    end
end

close all

fprintf(x, "%d\n",  zeroVibration);
%Left Foot steps
[cadence_left, steps_left] = findCadence(x_gyro_left,time_left);
%Right foot
[cadence_right, steps_right] = findCadence(x_gyro_left,time_left);
%Total Steps 
total_steps = steps_left + steps_right;
cadence = total_steps/(time(length(time))-time(1))*60; %Gives answer in steps per minute
fprintf("Steps taken after averything: %f \nCadence after everything = %f\n",total_steps, cadence)
% %%Plots for Gyro data
 %figure
 subplot(1,2,1)
 plot(time_left(1,1:left-1),x_gyro_left(1,1:left-1),'r')
 hold on
 ylim([-300 300])
%  xlim([1 seconds_Running])
 title("Left leg data")
 legend('x Gyro')
 xlabel('seconds')
 ylabel('degrees/sec')
 title('Left leg data')
% 
 subplot(1,2,2)
plot(time_right(1,1:right-1),x_gyro_right(1,1:right-1),'g')
hold on
% plot(time_right(1,1:right-1),y_gyro_right(1,1:right-1),'b')
% plot(time_right(1,1:right-1),z_gyro_right(1,1:right-1),'m')
ylim([-300 300])
xlim([1 seconds_Running])
title("Right leg data")
legend('x Gyro')
xlabel('seconds')

figure
feedback_cadence(length(time)) = 0;
plot(time, feedback_cadence, 'g')
title("Feedback cadence vs time")

%tranpose first for visual helpfulness

readings_left = [time_left.', x_gyro_left.'];
readings_right = [time_right.',x_gyro_right.'];
readings_cadence_and_backups = [feedback_cadence.',time.',L_or_R.', x_gyro.'];
% 
%  writematrix(readings_left,'Jarryd Test3-Left.csv') % make sure not to overwrite
% %useful data
%  writematrix(readings_right,'Jarryd Test3-Right.csv') % make sure not to overwrite
% %useful data
%  writematrix(readings_cadence_and_backups,'Jarryd Test3-Cadence.csv')


%%%%%%%%use this to reset port communication
if ~isempty(instrfind)
fclose(instrfind);
delete(instrfind)
end
