function forAB_datahiding

    %輸入要跑幾次迴圈
    dataround = 10;
    %存放變數
    rand_hiding_data = rand(1,100000);
    bound_hiding_data = round(rand_hiding_data);

    ref2 = imread('lena.jpg'); 
    A = imnoise(ref2,'salt & pepper', 0.02);
    [peaksnr, snr] = psnr(A, ref2);
    fprintf('\n The Peak-SNR value is %0.4f', peaksnr);
    fprintf('\n The SNR value is %0.4f \n', snr);
    fprintf('\n ------------------ \n');
    
    Ori_imagePixel_array = imread('lena.jpg');                  %把影像寫入陣列
    Ori_imagePixel_double = double(Ori_imagePixel_array)+1;     %uint8 轉成 double型態
    
    CountNumber = 1;
    total_hide = 1;   %總藏量
    
    %用陣列紀錄每一層藏入量
    EveryDataHide = [];
    %用陣列記錄每一次的peakpoint
    Ori_peakpoint_array = []; 
    %用陣列記錄每一次的zeropoint
    Ori_zeropoint = [];
    
    %stage2 用陣列記錄每一次的peakpoint
    Ori_peakpoint_array2 = []; 
    %stage2 用陣列記錄每一次的leftpeakpoint
    leftpeakpoint_array = [];
    %stage2 用陣列記錄每一次的rightpeakpoint
    rightpeakpoint_array = [];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    while(CountNumber<=dataround)
        
        %把Ori_imagePixel_double轉為1維陣列
        Ori_1Dimensions = reshape(Ori_imagePixel_double,1,numel(Ori_imagePixel_array)); 
        %初始圖的峰值(double)   p.s 峰值為出現最多次的pixel
        Ori_peakpoint_array(CountNumber) = mode(Ori_1Dimensions(:));
        %初始圖的峰值(Binary)
        Ori_peakpoint_binary = dec2bin(Ori_peakpoint_array(CountNumber),8);
        
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%
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
        %Ori_zeropoint = 0;
        Ori_zero_pixel = 256;
        for i = Ori_peakpoint_array(CountNumber):length(Ori_pixel_count)
            if Ori_pixel_count(i)< Ori_zero_pixel
                Ori_zero_pixel = Ori_pixel_count(i);
                Ori_zeropoint(CountNumber) = i;
            end
        end
        
        %移動直方圖然後開始藏資料
        %如果zeropoint不是0則設為0
        %記錄下來之後復原
        Stage1_renew(1:15) = 0;
        if Ori_zero_pixel > 0
            Ori_pixel_count(Ori_zeropoint(CountNumber))=Stage1_renew(1,CountNumber);    %最低點不是0先指定給一變數
            Ori_pixel_count(Ori_zeropoint(CountNumber))=0;               %設定為0
        end
        
        %把直方圖向右移動一個單位(peak_point和zero_point之間)
        Stage1_pixel_shift = Ori_imagePixel_double;
        for x=1:512
            for y=1:512
                if Stage1_pixel_shift(x,y) > Ori_peakpoint_array(CountNumber) && Stage1_pixel_shift(x,y) < Ori_zeropoint(CountNumber);
                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) + 1;
                end
            end
        end
        
        %hide data to hstogram
        max_hide = 1;     %stage1最大藏量
        for x=1:512
            for y=1:512
                if Stage1_pixel_shift(x,y) == Ori_peakpoint_array(CountNumber)
                    %如果還有資料沒藏完，而且比最大藏量Ori_pixel_count(Ori_peakpoint)還要小就繼續藏
                    if (total_hide <= length(bound_hiding_data) && max_hide <= Ori_pixel_count(Ori_peakpoint_array(CountNumber)))
                        tmp2 = Ori_pixel_count(Ori_peakpoint_array(CountNumber));
                        if bound_hiding_data(total_hide) == 1
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
        
        %---------------------------------stageB-----------------------------------
        
        %把Stage1的結果轉換成一維陣列
        Stage2_1Dimensions = reshape(Stage1_pixel_shift,1,numel(Ori_imagePixel_array));  
        %find out the peakpoint of stage1's hostogram
        Ori_peakpoint_array2(CountNumber) = mode(Stage2_1Dimensions(:));     
        
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
        leftpeakpoint_array(CountNumber) = Ori_peakpoint_array2(CountNumber) - 1;
        rightpeakpoint_array(CountNumber) = Ori_peakpoint_array2(CountNumber) + 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Overflow_point = zeros(dataround,512,512);
        
        for x=1:512
            for y=1:512
                if (Stage1_pixel_shift(x,y) == 1)   %轉回unit8時會overflow
                    Overflow_point(CountNumber,x,y)=1;
                end
                if (Stage1_pixel_shift(x,y) == 256) %轉回unit8時會overflow
                    Overflow_point(CountNumber,x,y)=256;
                end
                if (Stage1_pixel_shift(x,y)<=leftpeakpoint_array(CountNumber) && Stage1_pixel_shift(x,y)~=1)
                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)-1;
                end
                if (Stage1_pixel_shift(x,y)>=rightpeakpoint_array(CountNumber) && Stage1_pixel_shift(x,y)~=256)
                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)+1;
                end
            end
        end
        
        %輸出直方圖
        Stage1_test = uint8(Stage1_pixel_shift)-1;
        imhist(Stage1_test);
        
        %算第二階段的最大藏量
        Stage2_maxhide = 0;
        for x=1:512
            for y=1:512
                if (Stage1_pixel_shift(x,y)== (leftpeakpoint_array(CountNumber)-1))
                    Stage2_maxhide = Stage2_maxhide +1;
                end
                if (Stage1_pixel_shift(x,y)== (rightpeakpoint_array(CountNumber)+1))
                    Stage2_maxhide = Stage2_maxhide +1;
                end
            end
        end
        
        %先藏第一階段的峰值[0,1,1,0,0,0,1]
        %再繼續藏資料
        add_hide = 1;
        for x=1:512
            for y=1:512
                if Stage1_pixel_shift(x,y) == (leftpeakpoint_array(CountNumber)-1)      %24
                    %第一階段的peakpoint還沒藏完，繼續藏
                    if (add_hide<=length(Ori_peakpoint_char) && add_hide<=Stage2_maxhide)
                        if Ori_peakpoint_char(add_hide)==1
                            Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)+1;
                            add_hide = add_hide + 1;
                        else
                            add_hide = add_hide + 1;
                        end
                    else
                        if total_hide <= length(bound_hiding_data) && add_hide <= Stage2_maxhide
                            if bound_hiding_data(total_hide)==1
                                Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)+1;
                                add_hide = add_hide + 1;
                                total_hide = total_hide +1;
                            else
                                total_hide = total_hide +1;
                                add_hide = add_hide + 1;
                            end  
                        end
                    end
                end
            
                if Stage1_pixel_shift(x,y) == (rightpeakpoint_array(CountNumber)+1)     %26
                    %第一階段的peakpoint還沒藏完，繼續藏
                    if (add_hide<=length(Ori_peakpoint_char) && add_hide<=Stage2_maxhide)
                        if Ori_peakpoint_char(add_hide)==1
                            Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) - 1;
                            add_hide = add_hide + 1; 
                        else
                            add_hide = add_hide + 1;
                        end
                    else
                        if total_hide <= length(bound_hiding_data) && add_hide <= Stage2_maxhide
                            if bound_hiding_data(total_hide)==1
                                Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)-1;
                                add_hide = add_hide + 1;
                                total_hide = total_hide +1;
                            else
                                total_hide = total_hide +1;
                                add_hide = add_hide + 1;
                            end  
                        end
                    end
                end
            end
        end
       
        %輸出直方圖
        Stage1_test = uint8(Stage1_pixel_shift)-1;
        imhist(Stage1_test);
        %imshow(Stage1_test);
        %計算PSNR
        ref = Stage1_test;
        A = imnoise(ref,'salt & pepper', 0.02);
        [peaksnr, snr] = psnr(A, ref);
        fprintf('\n The count is %d', CountNumber);
        fprintf('\n The Peak-SNR value is %0.4f', peaksnr);
        fprintf('\n The SNR value is %0.4f \n', snr);
        
        Ori_imagePixel_double = Stage1_pixel_shift;
        
        %計算每一層的藏量
        EveryDataHide(CountNumber) = max_hide + Stage2_maxhide;
        
        CountNumber = CountNumber +1;
    end
    
    %--------------------------------解密復原程式碼--------------------------------
    Stage1_decoding_data = [];
    decode = 1;
    d = 1;
    
    
    decode_pixel_shift = Stage1_pixel_shift;
    
    while(d<=dataround)
        
        %----------------------------stage2
        %%%%%%%%%%%%%%%%%%%%%%
        index = dataround+1-d;
        
        tmp = 0;
        for x=512:-1:1
            for y=512:-1:1
                if decode_pixel_shift(x,y)==leftpeakpoint_array(index)
                    Stage1_decoding_data(decode)=1;
                    decode = decode + 1;
                end
                if decode_pixel_shift(x,y)==(leftpeakpoint_array(index)-1)   
                    Stage1_decoding_data(decode)=0;
                    decode = decode + 1;
                end
                if decode_pixel_shift(x,y)==rightpeakpoint_array(index)
                    Stage1_decoding_data(decode)=1;
                    decode = decode + 1;
                end
                if decode_pixel_shift(x,y)==(rightpeakpoint_array(index)+1)
                    Stage1_decoding_data(decode)=0;
                    decode = decode + 1;
                end
            end
        end
        
        peak_array = Stage1_decoding_data(length(Stage1_decoding_data):-1:length(Stage1_decoding_data)-7);
        peakpoint = int2str(peak_array);               %矩陣轉字串
        hidedata_peakpoint = bin2dec(peakpoint);       %2進位轉10進位(double型態的peakpoint,若是uint8的要減一)
        Stage1_decoding_data(length(Stage1_decoding_data)-7:length(Stage1_decoding_data)) = [];          %刪除peakpoint陣列資料   
        decode = decode-8;
        
        
         %stage2復原程式碼
        for x=1:512
            for y=1:512
                if decode_pixel_shift(x,y)==leftpeakpoint_array(index)
                    decode_pixel_shift(x,y)=decode_pixel_shift(x,y)-1;
                end
                if decode_pixel_shift(x,y)==rightpeakpoint_array(index)
                    decode_pixel_shift(x,y)=decode_pixel_shift(x,y)+1;
                end
            end
        end
        
        %將哨兵移回去
        for x=1:512
            for y=1:512
                if Overflow_point(d,x,y)==1
                    decode_pixel_shift(x,y)=1;
                end
                if Overflow_point(d,x,y)==256
                    decode_pixel_shift(x,y)=256;
                end
                if(decode_pixel_shift(x,y) <= leftpeakpoint_array(index) && Overflow_point(d,x,y)~=1) 
                    decode_pixel_shift(x,y) = decode_pixel_shift(x,y)+1;
                end
                if(decode_pixel_shift(x,y) >= rightpeakpoint_array(index) && Overflow_point(d,x,y)~=256) 
                    decode_pixel_shift(x,y) = decode_pixel_shift(x,y)-1;
                end
            end
        end
        
        %輸出直方圖
        %Stage1_test = uint8(Stage1_pixel_shift)-1;
        %imhist(Stage1_test);
        
        %----------------------------stage1
        
        %掃描藏密圖片，解密同時復原
        for x = 512:-1:1
            for y = 512:-1:1
                %峰值取出來為0
                if decode_pixel_shift(x,y)== hidedata_peakpoint
                    Stage1_decoding_data(decode) = 0;
                    decode = decode + 1;
                end
                %峰值+1取出來為1
                if decode_pixel_shift(x,y)== hidedata_peakpoint + 1
                    decode_pixel_shift(x,y)= decode_pixel_shift(x,y) - 1;
                    Stage1_decoding_data(decode) = 1;
                    decode = decode + 1;
                end
            end
        end
        
        %把直方圖向左移動一個單位回來(peak_point和zero_point之間)
        for x=1:512
            for y=1:512
                if decode_pixel_shift(x,y) > hidedata_peakpoint && decode_pixel_shift(x,y) < Ori_zeropoint(index);
                    decode_pixel_shift(x,y) = decode_pixel_shift(x,y) - 1;
                end
            end
        end
        
        %若一開始最低點的pixel，出現次數不是0，則把它復原
        for x=1:512
            for y=1:512
                if Stage1_pixel_shift(x,y) == Ori_zeropoint(index)
                    Stage1_pixel_shift(x,y)= Stage1_renew(index);
                end
            end
        end
        
         %%%%%%%%%%%%%%%%
        %把解密矩陣轉置回來
        
        final_decode = [];
        for x=1:length(Stage1_decoding_data)
            final_decode(x) = Stage1_decoding_data(length(Stage1_decoding_data)+1-x);
        end
    
        %驗證
        t=0;
        for x=1:length(final_decode)
            if final_decode(x)~=bound_hiding_data(x)
                xx = x;
                t =t + 1;
            end
        end
        d = d+1;
    end
end