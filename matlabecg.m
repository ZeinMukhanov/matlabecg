% This program generates labels for apnea and not apnea
% for every minute of 4 hours data set 

% Task 1
% Prompt a ser to enter the name of the data file for analysis
dataFileName = input('Please, enter the data file name: ', 's');
fid = fopen(dataFileName,'r');
% Since we need to read only the first 4 hours of data, we specify the size
% of the input data to be 100 samples/second * 4 hours * 60 minutes * 60
% seconds = 1,440,000 samples.
freq = 100;
duration = 4 * 3600;
mainNumOfSamples = freq * duration;
initInterval = 1/freq : 1/freq : duration;
% Read samples for 4 hours from the file specified by the  user
data = fread(fid, mainNumOfSamples, 'int16');
% We need to convert A/D data to the corresponding voltage measurement.
% Since we know that rate of conversion is 200 A/D units per milivolt, we
% multiply each value in the dataset by 200 to get measurements in milivolts
% and divide by 1000 to convert them to volts
data = data.*0.2;
% Code for plotting two seconds of data before resampling
newDuration = 2;
newInterval = 1/freq : 1/freq : newDuration;
newNumOfSamples = freq * newDuration;
newData = data(1:newNumOfSamples);
figure(1);
plot(newInterval, newData);
title('Two seconds of data before resampling');
xlabel('Time (s)');
ylabel('Hear rate voltage (V)');
% Code for plotting two seconds of data before resampling
newFreq = 500;
newInterval = 1/newFreq : 1/newFreq : duration;
% Resampling the data for the new frequency of 500 Hz using spline
% interpolation
resampledData = interp1(initInterval, data, newInterval, 'spline');
newNumOfSamples = newFreq * newDuration;
newInterval = 1/newFreq : 1/newFreq : newDuration;
newData = resampledData(1:newNumOfSamples);
figure(2);
plot(newInterval, newData);
title('Two seconds of data after resampling');
xlabel('Time (s)');
ylabel('Hear rate voltage (V)');

% Task 2
% Creating a low pass filter with a cutoff frequency of 0.5 Hz 
% corresponding to the frequency of heart beats for the resampled data
lowPassFilt = designfilt('lowpassfir', 'Filterorder', 10, 'CutoffFrequency', 0.5, 'SampleRate', 500);
filteredData = filter(lowPassFilt, resampledData);
newData = filteredData(1:newNumOfSamples);
% Plot resampled and filtered data for two seconds
figure(3);
plot(newInterval, newData);
title('Two seconds of filtered data after resampling');
xlabel('Time (s)');
ylabel('Hear rate voltage (V)');

% Task 3
newDuration = 60;
newNumOfSamples = newFreq * newDuration;
newData = filteredData(1:newNumOfSamples);
peakTimings = []; 
% Finding the time at which the peaks occur. The sample is considered to be
% a peak value when it is greater than 15 volts (value obtained from 
% observation of the previous graph for 2 seconds) and greater than 
% two neighbouring samples
for i=2:length(newData)-1
   if ((newData(i)>15) && (newData(i)>newData(i+1)) && (newData(i)>newData(i-1)))
      peakTimings = [peakTimings, i];
   end
end
rrIntervals = [];
peakTimingsLength = length(peakTimings);
% Finding the differences between successive peaks
for i = 2:peakTimingsLength
   diff = peakTimings(i) - peakTimings(i-1);
   rrIntervals = [rrIntervals, diff];
end
% Convert time domain and RR intervals to seconds
peakTimings = peakTimings ./ newFreq;
peakTimings = peakTimings(1:end-1);
rrIntervals = rrIntervals ./ newFreq;
% Plot RR intervals for the first 60 seconds of the filtered data
figure(4);
plot(peakTimings, rrIntervals);
title('RR intervals for the first 60 seconds');
xlabel('Time (s)');
ylabel('RR interval (s)');
firstMinuteAverageRR = mean(rrIntervals);
firstMinuteMinimumRR = min(rrIntervals);
firstMinuteMaximumRR = max(rrIntervals);

% Task 4
averageRR = [];
minimumRR = [];
maximumRR = [];
% Calculating RR intervals for 4 hours
previousNumOfSamples = 1;
maxSampleNum = length(filteredData);
while previousNumOfSamples-1 < maxSampleNum
    newData = filteredData(previousNumOfSamples:previousNumOfSamples+newNumOfSamples-1);
    peakTimings = []; 
    % Finding the time at which the peaks occur. The sample is considered to be
    % a peak value when it is greater than 15 volts (value obtained from 
    % observation of the previous graph for 2 seconds) and greater than 
    % two neighbouring samples
    for i=2:length(newData)-1
       if (newData(i)>15 && (newData(i)>newData(i+1)) && (newData(i)>newData(i-1)))
          peakTimings = [peakTimings, i];
       end
    end
    rrIntervals = [];
    peakTimingsLength = length(peakTimings);
    % Finding the differences between successive peaks
    for i = 2:peakTimingsLength
       diff = peakTimings(i) - peakTimings(i-1);
       rrIntervals = [rrIntervals, diff];
    end
    % Convert time domain and RR intervals to seconds
    rrIntervals = rrIntervals ./ newFreq;
    averageRR = [averageRR, mean(rrIntervals)];
    minimumRR = [minimumRR, min(rrIntervals)];
    maximumRR = [maximumRR, max(rrIntervals)];
    previousNumOfSamples = previousNumOfSamples+newNumOfSamples;
end
averageRRInterval = newDuration:newDuration:duration;
% Plot RR intervals for 4 hours of the filtered data
figure(5)
plot(averageRRInterval, averageRR);
title('Average RR intervals for 4 hours');
xlabel('Time (s)');
ylabel('RR interval (s)');

% Task 4
% Conducting analysis for the frequency domain for 60 seconds
newDuration = 60;
% Resampling data from 100 Hz to 4 Hz for the first 60 seconds
Fs = 4;
resampledData = resample(data, initInterval,Fs);
newNumOfSamples = Fs * newDuration;
newData = resampledData(1:newNumOfSamples);
N = length(newData);
% Applying Fourier Transformation to the resampled data and computing 
% power spectral density
dataFourierTransformed = fft(newData);
dataPowerDensity = (1/(Fs*N))* abs(dataFourierTransformed).^2;
dataPowerDensity = dataPowerDensity(1:N/2);
freq = 1/N:Fs/N:Fs/2;
% Plot the resulting spectrum (frequency versus power) 
% for the first 60 seconds
figure(6);
plot(freq(), dataPowerDensity());
title ('Power Spectral Density for the first 60 seconds');
xlabel('Frequency (Hz)');
ylabel('Power (g2/Hz)');
grid on

% Task 5
% Conducting analysis for the frequency domain for every 
% 60 seconds of 4 hours
powerDensityInterval = newDuration:newDuration:duration;
% Resampling data from 100 Hz to 4 Hz for every 
% 60 seconds of 4 hours
resampledData = resample(data, initInterval,Fs);
resampledData= resampledData';
previousNumOfSamples = 1;
maxSampleNum = length(resampledData);
totalDataPowerDensity = [];
while previousNumOfSamples-1 < maxSampleNum
     newData = resampledData(previousNumOfSamples:previousNumOfSamples+newNumOfSamples-1);
     N = length(newData);
     % Applying Fourier Transformation to the resampled data and computing 
     % power spectral density
     dataFourierTransformed = fft(newData);
     dataPowerDensity = (1/(Fs*N))* abs(dataFourierTransformed).^2;
     dataPowerDensity = dataPowerDensity(N/2+1:end);
     totalDataPowerDensity = [totalDataPowerDensity, dataPowerDensity'];
     previousNumOfSamples = previousNumOfSamples+newNumOfSamples;
end
freq = 1/N:Fs/N:Fs/2;
% Plot the resulting spectogram (power density) 
% for the every 60 seconds for 4 hours
figure(7);
% Using surface to plot 3D graph, where Z-axis is power density
surf(powerDensityInterval, freq, totalDataPowerDensity);
title ('Power Spectral Density for 4 hours');
xlabel('Time (s)');
ylabel('Frequency (Hz)');
colormap('jet');
% Establish view from top to see how power density vary
view(2);
shading interp;
hold on;
[heightRows, heightCols] = size(totalDataPowerDensity);
maxHeight = ones(heightRows, heightCols).*max(max(totalDataPowerDensity));
% Plot RR intervals on top of the power density graph to see the
% correlation
plot3(averageRRInterval, averageRR, maxHeight,'red');
colorbar;

% Task 6
testResults = fopen('testResults.txt', 'wt');
% After analyzing several data sets, it has been found that after the heart
% rate exceeds expressed in RR intervals exceeds 0.9 seconds, apnea begins
% Write the results of apnea analysis into the file
numOfSamples = length(averageRR);
for i=1:numOfSamples
    if averageRR(i)>0.9
        state = 'A\n';
    else
        state = 'N\n';
    end
    fprintf(testResults, state);
end
fclose(testResults);
% Open the file with actual results to compare them with the test results
dataFileName = input('Please, enter the actual apnea labels file name: ', 's');
actualResults = fopen(dataFileName);
header=fgetl(actualResults);
% Get labels from the actual results
c = textscan(actualResults,'%s%s');
totalLabels = c{2};
totalLabels = [totalLabels{:}];
requiredLabels = totalLabels(1:numOfSamples);
fclose(actualResults);
% Open the file with the test results
testResults = fopen('testResults.txt', 'rt');
accuracyCounter = 0;
% Compare the actual results with the test results to get the accuracy rate 
for i=1:numOfSamples
    label = fgetl(testResults);
    if label == requiredLabels(1, i)
        accuracyCounter = accuracyCounter + 1;
    end
end
accuracy = accuracyCounter/numOfSamples*100;
fprintf('The accuracy of the test %.2f percent', accuracy)




