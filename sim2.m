% Define Slices and Priorities
slices = {'eMBB', 'URLLC', 'mMTC'};
bandwidth = [50e6, 10e6, 5e6]; % Bandwidths in Hz
latency = [20e-3, 1e-3, 50e-3]; % Latency requirements in seconds
dataRate = [100e6, 1e6, 500e3]; % Data rates in bps
priorities = [1, 3, 2]; % Higher value indicates higher priority (URLLC > mMTC > eMBB)

% Initialize Resource Grid for each slice
resourceGrids = cell(1, length(slices));
noiseLevel = 0.05; % Base noise level for interference
for i = 1:length(slices)
    resourceGrids{i} = struct('Bandwidth', bandwidth(i), ...
                              'Latency', latency(i), ...
                              'DataRate', dataRate(i), ...
                              'NoiseLevel', noiseLevel * randn(1, 10)); % Random noise
end

% Simulate User Mobility: Users move between cells
cellCount = 3; % Number of base stations
usersPerSlice = randi([5, 15], length(slices), cellCount); % Random user count per slice

% Function to Simulate Complex Traffic Patterns
function traffic = generateComplexTraffic(dataRate, userCount)
    % Simulate variable traffic over time considering user count
    timeSlots = 10;
    traffic = dataRate * userCount * (0.8 + 0.4 * rand(1, timeSlots)); % Traffic variation
end

% Function to Allocate Resources Considering Priority and Interference
function allocatedResources = allocateResourcesWithPriority(grid, traffic, priority)
    % Adjust allocation based on interference and slice priority
    interference = traffic .* grid.NoiseLevel;
    adjustedTraffic = traffic - interference;
    priorityFactor = priority / sum(priority); % Normalize priority
    allocatedResources = adjustedTraffic .* (grid.Bandwidth / sum(adjustedTraffic)) * priorityFactor;
end

% Function to Simulate Latency Impact
function latencyPenalty = calculateLatencyImpact(sliceLatency, traffic)
    % Penalty for exceeding latency threshold
    delayImpact = (traffic > sliceLatency) .* (traffic - sliceLatency);
    latencyPenalty = sum(delayImpact);
end

% Simulate Traffic, Interference, Mobility, and Allocation
results = struct();
totalLatencyPenalties = zeros(1, length(slices));
for i = 1:length(slices)
    traffic = generateComplexTraffic(dataRate(i), sum(usersPerSlice(i, :))); % Total users in all cells
    allocatedResources = allocateResourcesWithPriority(resourceGrids{i}, traffic, priorities(i));
    latencyPenalty = calculateLatencyImpact(latency(i), traffic);
    totalLatencyPenalties(i) = latencyPenalty;
    results.(slices{i}) = struct('Traffic', traffic, ...
                                 'Allocated', allocatedResources, ...
                                 'Interference', resourceGrids{i}.NoiseLevel .* traffic, ...
                                 'LatencyPenalty', latencyPenalty);
end

% Plot Results for Visualization
figure;

% Plot Allocated Bandwidth
subplot(3, 1, 1);
hold on;
for i = 1:length(slices)
    plot(1:10, results.(slices{i}).Allocated, '-o', 'DisplayName', [slices{i} ' Allocated']);
end
hold off;
xlabel('Time Slot');
ylabel('Allocated Bandwidth (Hz)');
title('Network Slicing Bandwidth Allocation with Priority');
legend;
grid on;

% Plot Interference Impact
subplot(3, 1, 2);
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

% Plot Latency Penalty
subplot(3, 1, 3);
bar(categorical(slices), totalLatencyPenalties);
xlabel('Slice');
ylabel('Latency Penalty');
title('Latency Impact on Each Slice');
grid on;
