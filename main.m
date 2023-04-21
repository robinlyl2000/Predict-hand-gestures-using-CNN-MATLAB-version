clear;
close all;
clc;

total_file_num = 1; % 檔案總數
signal_len = 1050; % 單一訊號長度
X_data = zeros(total_file_num * 12, signal_len, 8, 1);
Y_data = zeros(1, total_file_num * 12);
count_index = 1;

% 針對每筆csv檔
for t = 1 : total_file_num
    fprintf("Loading dataset %d\n", t);
    % 載入csv
    rawData = readtable(sprintf("./data/S%.2d.csv", t));

    % 找出不同手勢之Data groups
    split_point = [];
    for index = 2 : height(rawData)
        % 排出 Gesture 0 與 7
        if (rawData{index,"class"} ~= 0) && (rawData{index,"class"} ~= 7)
            if (rawData{index,"class"} ~= rawData{index-1,"class"})
                 split_point = cat(1, split_point, index);
            end
        end
    end
    plotImage = zeros(6, 1050, 8);
    % 針對不同手勢之 Dataset
    for p = 1:length(split_point)-1
        
        dataset = rawData(split_point(p):split_point(p) + signal_len-1, :);

        showFilteringProcess = false;
        if (t == 1) && (p == 1)
            showFilteringProcess = true;
        end

        % 資料丟入前處理函式
        [output, label] = preprocessing(dataset, signal_len, showFilteringProcess);
        % 將 array 轉成 image，並 resize 成 1000*8 的格式
        tmp = mat2gray(output);
        if(p==1)
            xx = tmp;
        end
        image = imresize(tmp, [1000, 8]);

        if (t == 1) && (p >= 1 && p <= 6)
            plotImage(p, :, :) = tmp;
        end

        % 儲存image
%         path = fullfile(tempdir, sprintf("%d", label), sprintf("%.3d.png", count_index));
%         imwrite(image, path, 'png');
        count_index = count_index + 1;
    end
    figure;
    for i = 1:6
        subplot(2, 3, i);
        
        xx = reshape(plotImage(i, :, :), [1050, 8]);
        re = [];
        for j = 1:8
            target = xx(j, :);
            combined_res = [];
            for k = 1:70
                
                combined_res = cat(1, combined_res, target .* 1000);
            end
            tmp = mat2gray(combined_res);
            re = cat(2, re, tmp.');
        end
        image = imresize(re, [1000, 560]);
        imshow(image);
        title(sprintf("Gesture %d", i));
    end
end
