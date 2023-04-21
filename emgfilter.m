function output = emgfilter(input, showProcess)

% 處理輸入資料
emg = table2array(input);

% 基準線歸0
normal_emg = emg - mean(emg);

% 使用 bandpass filter
fs = 1e3;
emg_filtered1 = bandpass(normal_emg, [20,450], fs);

% 取絕對值
emg_rectified = abs(emg_filtered1);

% 使用 Savitzky-Golay filter
emg_filtered2 = smooth(emg_rectified,'sgolay');

% 卷積
ker = (1 / 3) * ones(3, 1);
res = conv(emg_filtered2, ker, 'same');

if showProcess == true
    f = figure;
    f.Position = [389,75,560,594];
    subplot(7,1,1);
    plot(emg);
    title("Raw data");
    xlim([0 1070]);
    subplot(7,1,2);
    plot(normal_emg);
    title("Reset the baseline");
    xlim([0 1070]);
    subplot(7,1,3);
    plot(emg_filtered1);
    title("Using bandpass filter");
    xlim([0 1070]);
    subplot(7,1,4);
    plot(emg_rectified);
    title("Taking the abs value");
    xlim([0 1070]);
    subplot(7,1,5);
    plot(emg_filtered2);
    title("Smooothing the signal");
    xlim([0 1070]);
    subplot(7,1,6);
    plot(res);
    title("Convolution");
    xlim([0 1070]);
    subplot(7,1,7);
    combined_res = [];
    
    for i = 1:70
        combined_res = cat(1, combined_res, transpose(res) .* 1000);
    end
    tmp = mat2gray(combined_res);
    image = imresize(tmp, [70, 1000]);
    imshow(image);
    title("Convert matrix to grayscale image");
    axis on;
    yticks([]);
end

% 輸出
output = array2table(res);
end