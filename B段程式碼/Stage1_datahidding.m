function Stage1_datahidding

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
    
    
    %------移動直方圖然後開始藏資料-----
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
    max_hide = 1;
    total_hide = 1;
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
    %輸出藏資料資料完成之直方圖
    Stage1_test = uint8(Stage1_pixel_shift)-1;
    imhist(Stage1_test);
        
    %--------------------------------第一階段解密復原程式碼--------------------------------
    Stage1_decoding_data = [];
    decode = 1;
    %掃描藏密圖片，解密同時復原
    for x = 1:512
        for y = 1:512
            %峰值取出來為0
            if Stage1_pixel_shift(x,y)== Ori_peakpoint
                Stage1_decoding_data(decode) = 0;
                decode = decode + 1;
            end
            %峰值+1取出來為1
            if Stage1_pixel_shift(x,y)== Ori_peakpoint + 1
                Stage1_pixel_shift(x,y)= Stage1_pixel_shift(x,y) - 1;
                Stage1_decoding_data(decode) = 1;
                decode = decode + 1;
            end
        end
    end
    
    %把直方圖向左移動一個單位回來(peak_point和zero_point之間)
    for x=1:512
        for y=1:512
            if Stage1_pixel_shift(x,y) > Ori_peakpoint && Stage1_pixel_shift(x,y) < Ori_zeropoint;
                Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) - 1;
            end
        end
    end
    
    %若一開始最低點的pixel，出現次數不是0，則把它復原
    for x=1:512
        for y=1:512
            if Stage1_pixel_shift(x,y) == Ori_zeropoint
                Stage1_pixel_shift(x,y)= Stage1_renew;
            end
        end
    end
    
    %輸出解密後直方圖
    Stage1_test = uint8(Stage1_pixel_shift)-1;
    imhist(Stage1_test);
        
end
    