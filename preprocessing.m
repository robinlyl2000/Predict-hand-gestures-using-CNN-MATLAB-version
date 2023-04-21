function [output, label] = preprocessing(dataset, signal_len, showFilteringProcess)
showProcess = showFilteringProcess; 

% 取前 signal_len 筆資料
table1 = head(dataset, signal_len);
% 取出 class label
label = table1{1, "class"};
% 移除不需要之欄位
table1 = removevars(table1,["time", "class", "label"]);
% 針對每個channel之signel去做濾波的動作
for j = 1:8
    if (j ~= 1)
        showProcess = false;
    end
    table1(:, sprintf("channel%d", j)) = emgfilter(table1(:, sprintf("channel%d", j)), showProcess);
end
% 輸出結果
output = reshape(table2array(table1), [signal_len, 8, 1]);
end