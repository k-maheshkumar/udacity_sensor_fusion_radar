r_max = 300 % radar's max range
range_resolution = 1 % range resolution in meters
c = 3 * 1e8 % speed to light in m/s


% sweep calculation
b_sweep = c / (2 * range_resolution)

time_to_travel_max_range = 5.5

% Calculation of the chirp time based on the Radar's Max Range
t_s = time_to_travel_max_range * 2 * r_max / c % time_to_travel_max_range * trip time for max range

% frequency shifts for four targets
fbs = [0, 1.1 * 1e6, 13 * 1e6, 24 * 1e6]


% Display the calculated range
calculated_range = c * t_s * fbs / (2 * b_sweep)
  