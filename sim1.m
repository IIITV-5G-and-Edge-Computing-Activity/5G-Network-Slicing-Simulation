% Define Slices
slices = {'eMBB', 'URLLC', 'mMTC'};
bandwidth = [50e6, 10e6, 5e6]; % Bandwidths in Hz
latency = [20e-3, 1e-3, 50e-3]; % Latency requirements in seconds
dataRate = [100e6, 1e6, 500e3]; % Data rates in bps

% Initialize Resource Grid for each slice with added noise for interference
resourceGrids = cell(1, length(slices));
noiseLevel = 0.05; % Noise level representing interference
for i = 1:length(slices)
    resourceGrids{i} = struct('Bandwidth', bandwidth(i), ...
                              'Latency', latency(i), ...
                              'DataRate', dataRate(i), ...
                              'NoiseLevel', noiseLevel * randn(1, 10)); % Random noise for interference
end

% Function to Simulate Complex Traffic Pattern
function traffic = generateComplexTraffic(dataRate)
    % Simulate variable traffic over time
    timeSlots = 10;
    traffic = dataRate * (0.8 + 0.4 * rand(1, timeSlots)); % Traffic variation
end

% Function to Allocate Resources considering interference
function allocatedResources = allocateResourcesWithInterference(grid, traffic)
    % Interference-adjusted allocation
    interference = traffic .* grid.NoiseLevel;
    adjustedTraffic = traffic - interference;
    allocatedResources = adjustedTraffic .* (grid.Bandwidth / sum(adjustedTraffic));
end

% Simulate Traffic, Interference, and Allocation
results = struct();
for i = 1:length(slices)
    traffic = generateComplexTraffic(dataRate(i));
    allocatedResources = allocateResourcesWithInterference(resourceGrids{i}, traffic);
    results.(slices{i}) = struct('Traffic', traffic, 'Allocated', allocatedResources, 'Interference', resourceGrids{i}.NoiseLevel .* traffic);
end

% Plot Results for Visualization
figure;
subplot(2,1,1);
hold on;
for i = 1:length(slices)
    plot(1:10, results.(slices{i}).Allocated, '-o', 'DisplayName', [slices{i} ' Allocated']);
end
hold off;
xlabel('Time Slot');
ylabel('Allocated Bandwidth (Hz)');
title('Network Slicing Bandwidth Allocation with Interference');
legend;
grid on;

subplot(2,1,2);
hold on;
for i = 1:length(slices)
    plot(1:10, results.(slices{i}).Interference, '--', 'DisplayName', [slices{i} ' Interference']);
end
hold off;
xlabel('Time Slot');
ylabel('Interference Level');
title('Interference Impact on Each Slice');
legend;
grid on;
