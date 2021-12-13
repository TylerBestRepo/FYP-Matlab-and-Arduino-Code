# How to operate

To run this code everything must be connected according to the documentation in the final report.

All data from the worn devices are transmitted to a home arduino connected to a computer running MATLAB. This computer depending on the script being run, will either store all
the data after running for 7 minutes, or for test 2/3 calculations will be performed on the fly to determine if the user is within a specified target cadence range and send
a signal to output vibrational feedback. Variable for the total time the program runs for have been created as well as commented out code to plot data on the fly, as well as
plotting after the test ends.

In the matlab scripts the USB com port will likely need to be changed to read data from the corrrect port the Arduino is plugged into.

'Test 1' is for storing data with no vibrational feedback

'Test 2' is for storing data and outputting vibrational feedback for ramplign or constant max amplitude feedback.

# Arduino code

There are a few libraries in the github repository that should be added so that it functions properly. There are 5 scripts that will be ran. They dont have the best most
straight forward names but are explained below.

'LeftMoreSimpleV2' - Left leg device outputting maximum amplitude vibrations
'RightMoreSimpleV2' - Right leg device outputting maximum amplitude vibrations
'LeftWithRamping'- Left leg code for ramping amplitude
'RightWithRamping'- Right leg code for ramping amplitude

'ReceiverBoth_VibrationMakingChanges' - The receiving arduino runs this code and the serial outputs should be used to test the connection between the 3 devices.

