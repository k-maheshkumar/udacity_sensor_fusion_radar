% Doppler Velocity Calculation
c = 3 * 1e8         %speed of light
frequency = 77e9   %frequency in Hz

% TODO : Calculate the wavelength

wavelength = c / frequency

% doppler shifts in Hz

fds = [3e3, -4.5e3, 11e3, -3e3]


% Calculation of the velocity of the targets  -> fd = 2*vr/lambda

vr = fds * wavelength / 2