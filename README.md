# Predict hand gestures using CNN (MATLAB version)
## 前言
* 此版本與 Python 版概念差不多，只是有些部分在 MATLAB 中不好執行，那些部分下方會提到
## 研究目的
* 在VR、AR等技術發揚光大的現代，預測手勢是缺一不可之要素。而若想要實做手勢識別的功能，目前有許多方式可以達到此效果，EMG就是其中一項。
* EMG(肌電圖；英文全名為Electromyography)，是一種診斷醫學技術，主要用於評估和記錄骨骼肌產生的電位活動。當肌肉細胞被電或神經刺激時，EMG可以檢測它們產生的電位，進而可以對訊號進行分析以檢測醫療異常或進行運動力學分析。在現今科技中，肌電圖也被用作手勢識別的中間元素，透過將手部動作訊號輸入電腦並加以分析，可以達到許多實際功能，例如可運用在 VR、AR等領域中。
* 本研究將透過分析EMG訊號，加以過濾與處理，最後導入CNN中預測其代表之手勢，希望能達到僅透過EMG訊號就能預測手勢的目標。
## 資料來源
* 此研究之資料是由Kaggle網頁之 “[EMG Signal for gesture recognition](https://www.kaggle.com/datasets/sojanprajapati/emg-signal-for-gesture-recognition)" 資料集獲取；而網頁中的Induction中有提到，該資料集是源自於Sergey et al .(2018) 之 “[Latent Factors Limiting the Performance of sEMG-Interfaces](https://www.mdpi.com/1424-8220/18/4/1122/htm)”一文研究過程產生的資料。
* 在上述提到之論文中，研究者要求受試者配戴一手環，該手環上配有8個EMG感測器(如下圖)。接著，研究者會讓受試者比劃出不同手勢，藉此蒐集到8項來自不同感測器的訊號。
<p align="center"><img src="README_image/68747470733a2f2f692e696d6775722e636f6d2f5178596678376a2e706e67.png"/></p>

## 原始資料分析
* 資料筆數 : 共420萬筆資料左右
* 資料欄位 : 
    | 欄位名稱 | 資料屬性 | 說明 |
    | :------: | :------: | :------: |
    | time | integer | 偵測到該筆資料的時間點 |
    |channel 1 ~ 8|float|各個感測器讀取到的EMG訊號值|
    |class|string|0 : 未標記之資料<br>1 : 手靜止<br>2 : 手握拳頭<br>3 : 手腕彎曲<br>4 : 手腕伸展<br>5 : 手腕內傾<br>6 : 手腕外傾<br>7 : 手掌伸展 (不是每筆訊號都有)|
    |label|string|受試者編號|
## 資料前處理
1. 首先，由於原始資料過大，Colab無法處理，因此我自己將依照36位受試者分割成`S01.csv`至`S36.csv`。
2. 接著，每筆原始訊號包含了所有手勢，因此要根據不同手勢將訊號個別抓出來。
    * 下圖為單一訊號不同手勢之情況<p align="center"><img height="70%" width="70%" src="README_image/RLRN31A.png"/></p>
3. 因為同一手勢的訊號長度不同，因此統一取訊號的前1050筆資料點，並依序透過調整基準線、使用帶通濾波器、取絕對值與使用低通濾波器來過濾訊號。
    <p align="center"><img height="60%" width="60%" src="README_image/SE3zCcE.png" style="display:block; margin:auto;" /> </p>
4. 由於本研究將採用 2D 的 CNN，因此我將每次測試 Channel 1 至 Channel 8 的訊號串在一起，進而產生出一筆 $1050\times 8$ 的 X data。
    * 下圖為隨意取六種手勢各一筆訊號出來，並將其視覺化
    <p align="center"><img src="README_image/CxCOe0A.png"/></p>
5. 最後將資料整理成適合丟入 CNN model 的模式 : 
    * 利用 `train_test_split()` 將資料切割成 `X_train`、`X_test`、`Y_train` 與 `Y_test` (切割比例為 train = 80%、test = 20%)
    * 再對 `Y_train` 與 `Y_test` 做 One-hot encoding
## 建立 & 訓練 CNN Model
* CNN 結構如下 : 
    <p align="center"><img height="40%" width="40%" src="README_image/68747470733a2f2f692e696d6775722e636f6d2f655131303359772e706e67.png"/></p>
* 模型建立細節 : 
    * Total parameters : 54,498
    * Optimizer 採用 Adam
    * Loss fucntion 使用 categorical_crossentropy
    * Metrics 使用 accuracy
* 模型訓練細節 : 
    * Validation_split = 0.2
    * Epochs = 40
    * Batch_size = 15
## 評估訓練結果
* 比較訓練過程中，Epochs 數與 Accuracy 的關係 : 
    <p align="center"><img height="40%" width="40%" src="README_image/68747470733a2f2f692e696d6775722e636f6d2f326659365530442e706e67.png"/></p>
* 比較訓練過程中，Epochs 數與 Loss 的關係 : 
    <p align="center"><img height="40%" width="40%" src="README_image/68747470733a2f2f692e696d6775722e636f6d2f6a6479365371452e706e67.png"/></p>
* 混淆矩陣 : 
    <p align="center"><img height="40%" width="40%" src="README_image/68747470733a2f2f692e696d6775722e636f6d2f496e56657642792e706e67.png"/></p>
## MATLAB 獨有問題
* 檔案執行順序: 
    1. 執行 `main.m`，其作用是將 data 資料夾中的 csv 檔，經過資料前處理，轉變成圖片的表示方式，並依照其 class value 存入 image 資料夾中
    2. 執行 `cnn.m`，其作用是將所有圖片檔案轉換成 ImageDatastore 的格式，並切割成三部分: Training/Testing/Validation set，接著建立 CNN model並訓練，最後進行 model 之效能評估
* 檔案小問題 : 
    * 在 `main.m` 中需要將圖片檔寫入到本地端，此步驟原本應使用 `imwrite()` 函式去執行，然而在執行的時候發現它需要開放寫入之權限，但我找了很久仍不知道該如何解決。因此當前 image 資料夾中的圖片是利用 Python 去產生的，但程式的順序與邏輯皆與 `main.m` 相同，所以應該不會有太大的影響
    * 雖說如此，`main.m` 只是無法執行儲存圖片的功能而已(在實際程式中先將其轉為註解)，其他像讀取 rawData、資料前處理、濾波與顯示轉換完圖片等功能仍可執行，此部分要再留意一下
