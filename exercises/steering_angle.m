f = 77e9
c = 3e8
phi = 45 * pi / 180
wavelength = c / f
d = wavelength / 2

steering_angle_theta = asind(phi * wavelength/ (360 * d)) * 180 / pi

