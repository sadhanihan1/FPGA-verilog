clc; clear; close all;

%% Step 1: Load and Preprocess Image
img = imread('input_image.jpg'); % Load image
img = imresize(img, [160 115]);  % Resize to fit FPGA memory constraints
gray_img = rgb2gray(img);        % Convert to grayscale

%% Step 2: Choose Image Processing Operation
operation = 'edge';  % Options: 'blur' or 'edge'

% Define Kernels
blur_kernel = (1/9) * [1 1 1; 1 1 1; 1 1 1];   % 3x3 Blurring filter
edge_kernel = [-1 -1 -1; -1 8 -1; -1 -1 -1];   % 3x3 Edge detection filter

% Apply Convolution
if strcmp(operation, 'blur')
    processed_img = conv2(double(gray_img), blur_kernel, 'same');
elseif strcmp(operation, 'edge')
    processed_img = conv2(double(gray_img), edge_kernel, 'same');
else
    error('Invalid operation. Use "blur" or "edge".');
end

% Normalize to 8-bit range
processed_img = uint8(processed_img);

%% Step 3: Display Results
figure;
subplot(1,2,1); imshow(gray_img); title('Original Grayscale Image');
subplot(1,2,2); imshow(processed_img); title(['Processed Image: ' operation]);

%% Step 4: Generate .coe File for FPGA
coe_filename = 'output_image.coe';
fileID = fopen(coe_filename, 'w');

% Write COE file header
fprintf(fileID, 'memory_initialization_radix=2;\n');
fprintf(fileID, 'memory_initialization_vector=\n');

% Convert Image to Binary and Write to File
[rows, cols] = size(processed_img);
for i = 1:rows
    for j = 1:cols
        pixel_bin = dec2bin(processed_img(i, j), 8); % Convert to 8-bit binary
        fprintf(fileID, '%s', pixel_bin);
        if (i == rows && j == cols)
            fprintf(fileID, ';\n'); % End of COE file
        else
            fprintf(fileID, ',\n');
        end
    end
end

% Close file
fclose(fileID);
disp(['COE file "' coe_filename '" generated successfully!']);

