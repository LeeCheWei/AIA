function data_hidding_2017

    %存放變數
    rand_hiding_data = rand(1,10000);
    bound_hiding_data = round(rand_hiding_data);


    %-------------------------------------第一階段-------------------------------------
    Ori_imagePixel_array = imread('lena.jpg');                  %把影像寫入陣列
    Ori_imagePixel_double = double(Ori_imagePixel_array)+1;     %uint8 轉成 double型態
    %imhist(Ori_imagePixel_array);                               %產生直方圖
    
    %把Ori_imagePixel_double轉為1維陣列
    Ori_1Dimensions = reshape(Ori_imagePixel_double,1,numel(Ori_imagePixel_array)); 
    
    % 初始圖的峰值(double)   p.s 峰值為出現最多次的pixel
    Ori_peakpoint = mode(Ori_1Dimensions(:));
    %初始圖的峰值(Binary)
    Ori_peakpoint_binary = dec2bin(Ori_peakpoint,8);
    
    % writing Binary to char_array(prepare writing to stage2 peakpoint)
    for bin_i = 1:8
        Ori_peakpoint_char(1,bin_i) = bin2dec(Ori_peakpoint_binary(1,bin_i));    
    end
    
    %以下程式碼為產生出pixel和出現次數的相對應矩陣
    X = Ori_1Dimensions(:);
    X = sort(X);                         %排序Ｘ陣列
    d = diff([X;max(X)+1]);
    count = diff(find([1;d])) ;

    Y = [X(find(d)) count];              %列出相對應次數
    Y_Translate = Y';                    %轉置Ｙ矩陣
    
    %考慮若有pixel值未出現之情況
    Ori_pixel_count(1:256) = 0;          %宣告一空陣列，存放pixel相對出現之次數
    for i = 1:256
        for j = 1:size(Y_Translate,2)
            if i == Y_Translate(1,j)
                Ori_pixel_count(1,i) = Y_Translate(2,j);
            end
        end
    end
    
    %找出zeropoint和相對應的pixel值
    Ori_zeropoint = 0;
    Ori_zero_pixel = 256;
    for i = Ori_peakpoint:length(Ori_pixel_count)
        if Ori_pixel_count(i)< Ori_zero_pixel
            Ori_zero_pixel = Ori_pixel_count(i);
            Ori_zeropoint = i;
        end
    end
    
    
    %移動直方圖然後開始藏資料
    %如果zeropoint不是0則設為0
    %記錄下來之後復原
    Stage1_renew = 0;
    if Ori_zero_pixel > 0
        Ori_pixel_count(Ori_zeropoint)=Stage1_renew;    %最低點不是0先指定給一變數
        Ori_pixel_count(Ori_zeropoint)=0;               %設定為0
    end
    
    
    %把直方圖向右移動一個單位(peak_point和zero_point之間)
    Stage1_pixel_shift = Ori_imagePixel_double;
    for x=1:512
        for y=1:512
            if Stage1_pixel_shift(x,y) > Ori_peakpoint && Stage1_pixel_shift(x,y) < Ori_zeropoint;
                Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) + 1;
            end
        end
    end
    
    %hide data to hstogram
    max_hide = 1;     %stage1最大藏量
    total_hide = 1;   %總藏量
    for x=1:512
        for y=1:512
            if Stage1_pixel_shift(x,y) == Ori_peakpoint
                %如果還有資料沒藏完，而且比最大藏量Ori_pixel_count(Ori_peakpoint)還要小就繼續藏
                if (total_hide <= length(bound_hiding_data) && max_hide <= Ori_pixel_count(Ori_peakpoint))
                    if bound_hiding_data(max_hide) == 1
                        Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) + 1;
                        max_hide = max_hide + 1;
                        total_hide = total_hide + 1;
                    else
                        max_hide = max_hide + 1;
                        total_hide = total_hide + 1;
                    end
                end
            end
        end 
    end
    
    %輸出藏資完成之直方圖
    Stage1_test = uint8(Stage1_pixel_shift)-1;
    imhist(Stage1_test);
    
    %-------------------------------------第二階段-------------------------------------
    %把Stage1的結果轉換成一維陣列
    Stage2_1Dimensions = reshape(Stage1_pixel_shift,1,numel(Ori_imagePixel_array));  
    %find out the peakpoint of stage1's hostogram
    Stage2_peakpoint = mode(Stage2_1Dimensions(:));            
        
    %以下程式碼為產生出pixel和出現次數的相對應矩陣
    X = Stage2_1Dimensions(:);
    X = sort(X);                         %排序Ｘ陣列
    d = diff([X;max(X)+1]);
    count = diff(find([1;d])) ;

    Y = [X(find(d)) count];              %列出相對應次數
    Y_Translate = Y';                    %轉置Ｙ矩陣
    
    %考慮若有pixel值未出現之情況
    Stage2_pixel_count(1:256) = 0;          %宣告一空陣列，存放pixel相對出現之次數
    for i = 1:256
        for j = 1:size(Y_Translate,2)
            if i == Y_Translate(1,j)
                Stage2_pixel_count(1,i) = Y_Translate(2,j);
            end
        end
    end
    
    %移動peak_point兩旁衛兵同時將會overflow的點記錄下來
    Stage2_leftpeakpoint = Stage2_peakpoint - 1;
    Stage2_rightpeakpoint = Stage2_peakpoint + 1;
    Overflow_point = zeros(512,512);
    for x=1:512
        for y=1:512
            if (Stage1_pixel_shift(x,y) == 1)   %轉回unit8時會overflow
                Overflow_point(x,y)=1;
            end
            if (Stage1_pixel_shift(x,y) == 256) %轉回unit8時會overflow
                Overflow_point(x,y)=2;
            end
            if (Stage1_pixel_shift(x,y)<=Stage2_leftpeakpoint && Stage1_pixel_shift(x,y)~=1)
                Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)-1;
            end
            if (Stage1_pixel_shift(x,y)>=Stage2_rightpeakpoint && Stage1_pixel_shift(x,y)~=256)
                Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)+1;
            end
        end
    end
    %輸出直方圖
    %Stage1_test = uint8(Stage1_pixel_shift)-1;
    %imhist(Stage1_test);
    
    %算第二階段的最大藏量
    Stage2_maxhide = 0;
    for x=1:512
        for y=1:512
            if (Stage1_pixel_shift(x,y)== (Stage2_leftpeakpoint-1))
                Stage2_maxhide = Stage2_maxhide +1;
            end
            if (Stage1_pixel_shift(x,y)== (Stage2_rightpeakpoint+1))
                Stage2_maxhide = Stage2_maxhide +1;
            end
        end
    end
    
    %先藏第一階段的峰值[0,1,1,0,0,0,1]
    %再繼續藏資料
    add_hide = 1;
    for x=1:512
        for y=1:512
            if (Stage1_pixel_shift == (Stage2_leftpeakpoint-1))
                %第一階段的peakpoint還沒藏完，繼續藏
                if (addhide<=length(Ori_peakpoint_char) && addhide<=maxhide)
                    if Ori_peakpoint_char(addhide)==1
                        Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) + 1;
                        add_hide = add_hide + 1;
                    else
                        add_hide = add_hide + 1;
                    end
                %藏完之後，藏我們所要藏的資料
                else
                    if (total_hide<length(bound_hiding_data) && addhide<=maxhide)
                        if bound_hiding_data(total_hide)==1
                            Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) + 1;
                            add_hide = add_hide + 1;
                            total_hide = total_hide + 1;
                        else
                            add_hide = add_hide + 1;
                            total_hide = total_hide + 1;
                        end 
                    end
                end
            end
            
            if (Stage1_pixel_shift == (Stage2_rightpeakpoint+1))
                %第一階段的peakpoint還沒藏完，繼續藏
                if (addhide<=length(Ori_peakpoint_char) && addhide<=maxhide)
                    if Ori_peakpoint_char(addhide)==1
                        Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) - 1;
                        add_hide = add_hide + 1;
                    else
                        add_hide = add_hide + 1;
                    end
                %藏完之後，藏我們所要藏的資料
                else
                    if (total_hide<length(bound_hiding_data) && addhide<=maxhide)
                        if bound_hiding_data(total_hide)==1
                            Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) - 1;
                            add_hide = add_hide + 1;
                            total_hide = total_hide + 1;
                        else
                            add_hide = add_hide + 1;
                            total_hide = total_hide + 1;
                        end 
                    end
                end
            end
        end
    end
    
    %輸出直方圖
    Stage1_test = uint8(Stage1_pixel_shift)-1;
    imhist(Stage1_test);
    
end
    