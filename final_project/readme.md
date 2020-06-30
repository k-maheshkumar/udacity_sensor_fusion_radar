# Radar Target Generation and Detection

## Project Layout

- Configure the FMCW waveform based on the system requirements.
- Define the range and velocity of target and simulate its displacement.
- For the same simulation loop process the transmit and receive signal to determine the beat signal
- Perform Range FFT on the received signal to determine the Range
- Towards the end, perform the CFAR processing on the output of 2nd FFT to display the target.

![Project Layout](images/1.png)


## Radar System Requirements

- Frequency - 77 GHz
- Range resolution - 1 m
- Max range - 200 m
- Max velocity - 70 m/s
- Velocity resolution - 3 m/s
- User define initial range 100 m
- User define initial velocity of the Target - 60 m/s

## Calculations

- The sweep bandwidth can be determined according to the range resolution using `bw = c / (2 * range_resolution)`
- The chrip time can be calulated according to the max_range using `chrip_time = 5.5 * (2 * max_range)/c`

- The sweep slope is calculated using both sweep bandwidth and chrip time. `slope = bw / chrip_time`

- Target Generation and Detection: 

![Project Layout](images/2.png)


The beat signal can be calculated by multiplying the Transmit signal with Receive signal

```matlab
  Tx(i) = cos(2 * pi * (frequency_of_operation * t(i) + 0.5 * slope * t(i)^2));
  Rx(i)  = cos(2 * pi * (frequency_of_operation * (t(i) - td(i)) + 0.5 * slope * (t(i) - td(i))^2));
  Mix(i) = Tx(i) .* Rx(i);

```

- FFT Operation

```matlab
%reshape the vector into Nr*Nd array. Nr and Nd here would also define the size of
%Range and Doppler FFT respectively.
Mix = reshape(Mix, [Nr, Nd]);

 % *%TODO* :
%run the FFT on the beat signal along the range bins dimension (Nr) and
%normalize.
signal_fft = fft(Mix, Nr);

 % *%TODO* :
% Take the absolute value of FFT output
signal_fft = abs(signal_fft);
signal_fft = signal_fft ./ max(signal_fft); % Normalize


 % *%TODO* :
% Output of FFT is double sided signal, but we are interested in only one side of the spectrum.
% Hence we throw out half of the samples.
signal_fft = signal_fft(1 : Nr/2-1);
```

- Selection of Training, Guard cells and offset:

```matlab
%Select the number of Training Cells in both the dimensions.
Tr = 10;  % Training (range dimension)
Td = 8;  % Training cells (doppler dimension)

%Select the number of Guard Cells in both dimensions around the Cell under 
%test (CUT) for accurate estimation
Gr = 4;  % Guard cells (range dimension)
Gd = 4;  % Guard cells (doppler dimension)

% offset the threshold by SNR value in dB
offset = 1.4;

%Create a vector to store noise_level for each iteration on training cells
noise_level = zeros(1,1);
N_guard = (2 * Gr + 1) * (2 * Gd + 1) - 1;  % Remove CUT
N_training = (2 * Tr + 2 * Gr + 1) * (2 * Td + 2 * Gd + 1) - (N_guard + 1);
```

- Implementation steps for the 2D CFAR process:

 - Determine the number of Training cells for each dimension. Similarly, pick the number of guard cells.
- Slide the cell under test across the complete matrix. Make sure the CUT has margin for - Training and Guard cells from the edges.
- For every iteration sum the signal level within all the training cells. To sum convert the - value from logarithmic to linear using db2pow function.
- Average the summed values for all of the training cells used. After averaging convert it back to logarithmic using pow2db.
- Further add the offset to it to determine the threshold.
- Next, compare the signal under CUT against this threshold.
- If the CUT level > threshold assign it a value of 1, else equate it to 0.
- The process above will generate a thresholded block, which is smaller than the Range Doppler Map as the CUTs cannot be located at the edges of the matrix due to the presence of Target and Guard cells. Hence, those cells will not be thresholded.

To keep the map size same as it was before CFAR, equate all the non-thresholded cells to 0.

```matlab
RDM = RDM / max(RDM(:));

for r = Tr + Gr + 1 : Nr/2 - (Tr + Gr)
    for c = Td + Gd + 1 : Nd - (Td + Gd)
    %Create a vector to store noise_level for each iteration on training cells
    noise_level = zeros(1, 1);

    for row2 = r - (Tr + Gr) : r + (Tr + Gr)
      for col2 = c - (Td + Gd) : c + (Td + Gd)
        if (abs(r - row2) > Gr || abs(c - col2) > Gd)
          noise_level = noise_level + db2pow(RDM(row2, col2));
        end
      end
    end

    % Calculate threshold from noise average then add the offset
    threshold = pow2db(noise_level / (2 * (Td + Gd + 1) * 2 * (Tr + Gr + 1) - (Gr * Gd) - 1));
    threshold = threshold + offset;

    if (RDM(r,c) > threshold)
        RDM(r, c) = 1;
    else
        RDM(r, c) = 0;
    end

  end
end
```

- Steps taken to suppress the non-thresholded cells at the edges:

```matlab
% The process above will generate a thresholded block, which is smaller
%than the Range Doppler Map as the CUT cannot be located at the edges of
%matrix. Hence,few cells will not be thresholded. To keep the map size same
% set those values to 0.

RDM(RDM~=0 & RDM~=1) = 0;
```