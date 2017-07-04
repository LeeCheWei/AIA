%在使用前，請先宣告全域變數
%全域變數 傳遞於GUI 和.m檔之間
%此程式為按下start hide data按鈕後所執行的程式
%此程式碼分為三階段
%第一階段: 選取特定的參考點，並模擬一張新影像
%第二階段: 根據我們模擬的影像，做直方圖位移方法
%第三階段: 接著值方圖位移方法後，再接續哨兵位移方法
% global user_input_data    GUI 使用者所要藏入的密碼
% global user_input_image   GUI 使用者所要藏資料的圖片
% global user_hide_data     GUI 使用者解密出來的資料
% global user_input_round    GUI 使用者所需要的層數
% global user_input_block   GUI 使用者所需要的區塊大小
% global block_pass         interpolation中，可使用的block數，為額外資訊
% global hideImage          interpolation中，藏完資料的圖片
% global Overflow_point     interpolation中，OverFlow數，為額外資訊
% global image_PSNR         印出照片的PSNR值

function interpolation2

 global user_input_round 
 global user_input_data
 global user_input_image
 global hideImage
 global block_pass
 global user_input_block
 global Overflow_point
 global image_PSNR
 
 %GUI中使用者輸入的層數
 dataround = user_input_round;
 %GUI中使用者輸入的區塊大小
 xy_block = user_input_block;
 
 %宣告一空陣列，放置binary型態的資料
 hiding_data_i = [];
 %將使用者所要藏入的資料從char轉成double型態，並儲存
 msg_double = double(user_input_data);

 %將double型態的資料轉成binary，並全部放至到hiding_data_i中
 for x=1:length(user_input_data)
     msg_bin = dec2bin(msg_double(x),8);
     hiding_data_i = [hiding_data_i,msg_bin(1:8)];
 end
 
 %再將binary中的資料一一存放至double_data中，型態為double
 %因為從使用者原來輸入型態是char，所以轉成double時，0會表示成48，1會表示成49
 %所以我們將轉出來的值一一扣掉48並存入變數中，使得主程式可以正常執行
 for y=1:length(hiding_data_i)
     double_data(y) = double(hiding_data_i(y))-48;
 end
 %將所要藏入的資料轉換完成後，存入bound_hiding_data
 bound_hiding_data = double_data;
 
 %為什麼要轉型態?
 %GUI中使用者輸入的是char型態
 %我們在程式中所要藏入的是double型態的100101010101矩陣
 %所以從char轉成double再轉成binary(此時所有的資料會再同一個index中，所以我們必須一一分離)
 %ex: '101101'
 %最後再將binary轉成double，並將所有的1010101001分離
 %ex: '1','0','1','1','0','1'
 
 %------------------------------------------------------------------------
 
 %GUI中，使用者所選擇的圖片，讀進Ori_imagePixel_array中
 %注意圖片型態為uint8
 Ori_imagePixel_array = user_input_image;
 %將圖片型態轉至double
 %轉至double後要記得+1(因為轉成double後會像素會介於0~255間)
 %我們實際執行程式所需要的範圍是1~256，所以要加1
 Ori_imagePixel_double = double(Ori_imagePixel_array)+1;
 
 %自動抓取相片大小，此程式沒有用到，若有需要可自行使用
 %[imgy, imgx] = size(Ori_imagePixel_array);
 

 
 %設計我們interpolation所需要的X,Y(根據我們區塊大小決定)
 X1 = [];
 Y1 = [];
 z = 1;
 for b=1:xy_block
    for a=1:xy_block 
        if mod(a-1,2)~=0 || mod(b-1,2)~=0
            if (a~=xy_block)&&(b~=xy_block)
                X1(z) = a - (0.5*(a+1));
                Y1(z) = b - (0.5*(b+1));
                z = z+1;
            end
        end
    end
 end
 
 ref_Pixel = xy_block/2;

 %計算我們到底切成多少塊
 cut_side = (length(Ori_imagePixel_array)/xy_block);
 Area_Number = cut_side*cut_side;
    
 
 %以下為我們執行程式所需要的變數
    

 total_hide = 1;                                                    %總藏量(做為矩陣的indexd所以一開始設為1)
 total_hide_stage1 = 0;                                             %第一階段總藏量
 total_hide_stage2 = 0;                                             %第二階段總藏量
  
 EveryDataHide = [];                                                %每一層的藏量
 OverFlow = [];                                                     %每一層的OverFlow
 
 Ori_peakpoint_array = zeros(dataround,Area_Number);                %記錄每一次第一階段的peakpoint(deBUG用)
 Ori_peakpoint_array2 = zeros(dataround,Area_Number);               %記錄每一次第二階段的peakpoint(deBUG用)
 
 leftpeakpoint_array = zeros(dataround,Area_Number);                %記錄每一次第二階段的leftpeakpoint(deBUG用)
 rightpeakpoint_array = zeros(dataround,Area_Number);               %記錄每一次第二階段的rightpeakpoint(deBUG用)

 small_blk = zeros(dataround+1,Area_Number);                        %區塊太小導致無法藏資料，記錄下來

 Overflow_point = ones(dataround,512,512);                          %OverFlow的層數、區塊，為額外資訊，需額外記錄 
 block_pass = zeros(dataround,Area_Number);                         %可以使用的區塊，為額外資訊，需額外記錄
        
 test_total = [];                                                   %測試用變數
  
 
 %以下為印出最終結果的變數  
 OF = 0;
 TH = 0;
 re_t = 0;
 re_t_st1 = 0;
 re_t_st2 = 0;
 
 %------------------------------------------------------------------------
 CountNumber=1;                                                     %第一次開始執行，數值設定為1
 hideImage = Ori_imagePixel_double;                                 %宣告一新變數，存放我們的影像，保護原影像不受損
 Stage1_max_hide = zeros(dataround);                                %第一階段每層的總藏量
 Stage2_max_hide = zeros(dataround);                                %第二階段每層的總藏量
 
 while(CountNumber<=dataround)
     
     blk=1;                                                         %區塊從第一塊開始執行
     effective_block = 0;                                           %每層有效區塊先初始化為0
     overflow = 0;                                                  %每層OverFlow數先初始化為0
     
    for yy = 1:xy_block:512
        for xx = 1:xy_block:512
            add_hide = 1;
            
            if small_blk(CountNumber,blk) ~= 1                              %如果區塊太小，則不執行，初始值設定為都可以執行
                                                                            %若後面發現區塊太小，則會跳至下一個區塊並復原   
            block = hideImage(xx:xx+xy_block-1,yy:yy+xy_block-1);           %一塊一塊區塊輪替下去藏使用者的資料
            
 %---------------------------stage interpolation---------------------------
 
            %找出每個區塊的參考點(參考點為後續要模擬新影像的點，不能做任何的修改)
            ref_x = 1;
            ref_y = 1;
            
            for x = 1:xy_block
                for y = 1:xy_block
                    if mod(x-1,2)==0 && mod(y-1,2)==0
                        if ref_x <= ref_Pixel && ref_y <= ref_Pixel
                            ref_block(ref_x,ref_y) = block(x,y);
                            ref_y = ref_y + 1;
                        else
                            ref_y = 1;
                            ref_x = ref_x +1;
                            ref_block(ref_x,ref_y) = block(x,y);
                            ref_y = ref_y +1;
                        end
                    end
                end
            end 
            
            Z=[];
            index=1;
            for b=1:xy_block
                for a=1:xy_block
                    if a==xy_block || b==xy_block
                        if a-xy_block==0 && b-xy_block==0
                            Z(index)=ref_block(ref_Pixel,ref_Pixel);
                            index = index+1;
                        elseif mod(a,2)==0 && b-xy_block==0
                            Z(index)=round((ref_block(ref_Pixel,a/2)+ref_block(ref_Pixel,(a/2)+1))/2);
                            index = index+1;
                        elseif a-xy_block==0 && mod(b,2)==0
                            Z(index)=round((ref_block(b/2,ref_Pixel)+ref_block((b/2)+1,ref_Pixel))/2);
                            index = index+1;
                        else
                            if a==xy_block
                                Z(index)=ref_block(floor(b/2)+1,ref_Pixel); 
                                index = index+1;
                            else
                                Z(index)=ref_block(ref_Pixel,floor(a/2)+1);
                                index = index+1;
                            end
                        end
                    end
                end
            end
            
            %'interp2'是一個interpolatio的函數
            %給定參考點，會自動幫我們模擬周圍的像素值
            iter_len = length(ref_block)-1;
            output_toal = interp2([0:iter_len], [0:iter_len], ref_block, X1, Y1); 
            ouput = round(output_toal);
            
            %將我們模擬出來的像素存入inter_block中
            %產生一個新的模擬區塊
            inter_block = zeros(xy_block,xy_block);
            i=1;
            j=1;
            for x=1:xy_block
                for y=1:xy_block
                    if mod(x-1,2)==0 && mod(y-1,2)==0
                        inter_block(x,y)= ref_block(floor(x/2)+1,floor(y/2)+1);
                    elseif x~=xy_block && y~=xy_block
                        inter_block(x,y)= ouput(i);
                        i=i+1;
                    else
                        inter_block(x,y)= Z(j);
                        j=j+1;
                    end
                end
            end
            
            %將原來的區塊 減去 我們模擬的新區塊 會得到一差值矩陣
            %sub_block為差值矩陣
            sub_block = block-inter_block;
            
            
 %---------------------------------stage A---------------------------------
            %首先我們先將差值矩陣，轉換成一為陣列
            %方便我們找出peakpoint
            Ori_1Dimensions = reshape(sub_block,1,numel(block));
            
            %第二步，我們刪除參考點(因為不可以對參考點做任何的修改)
            %接下來排序此一維陣列
            del = 0;
            for x=1:length(Ori_1Dimensions)
                ref_Num = mod(x,xy_block);
                ref_Num2 = mod(x,(xy_block*2));
                 if mod(ref_Num,2)~=0 && ref_Num2<=xy_block
                     Ori_1Dimensions(x-del)=[];
                     del = del+1;
                 end
            end
            
            %找出peakpoint
            Ori_peakpoint_array(CountNumber,blk) = mode(Ori_1Dimensions(:));
            
            %如果找出來的peakpoint是負數，我們把第一個為元改成1
            if Ori_peakpoint_array(CountNumber,blk) <0
                peakpoint = Ori_peakpoint_array(CountNumber,blk)*(-1);
                %把型態轉成Binary
                Ori_peakpoint_binary = dec2bin(peakpoint,8);
                
                %把Binary型態的peakpoint寫入到char_array中(準備藏入到第二階段中)
                for bin_i = 1:8
                    Ori_peakpoint_char(1,bin_i) = bin2dec(Ori_peakpoint_binary(1,bin_i));    
                end
                Ori_peakpoint_char = [1,Ori_peakpoint_char(1:8)];
            else
                %把型態轉成Binary
                Ori_peakpoint_binary = dec2bin(Ori_peakpoint_array(CountNumber,blk),8);
                
                %把Binary型態的peakpoint寫入到char_array中(準備藏入到第二階段中)
                for bin_i = 1:8
                    Ori_peakpoint_char(1,bin_i) = bin2dec(Ori_peakpoint_binary(1,bin_i));    
                end
                Ori_peakpoint_char = [0,Ori_peakpoint_char(1:8)];
            end
            
            
            %接下來我們要找出peakppoint的值(以便計算藏量)
            %correspond array
            X = Ori_1Dimensions(:);
            X = sort(X);                         %排序X矩陣
            d = diff([X;max(X)+1]);
            count = diff(find([1;d])) ;

            Y = [X(find(d)) count];              %relative frequency
            Y_Translate = Y';  
            
            %%找出像素值與其對應的累積量
            ref_peak_count = 0;
            for x=1:length(count)
                if count(x)>ref_peak_count
                    ref_peak_count = count(x);
                end
            end
            
            %shift the histgram between the peakpoint and zeropoint
            Stage1_pixel_shift = sub_block;
            for x=1:xy_block
                for y=1:xy_block
                    if mod(x-1,2)~=0 || mod(y-1,2)~=0
                        if Stage1_pixel_shift(x,y)> Ori_peakpoint_array(CountNumber,blk) 
                            Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) +1;
                        end
                    end
                end
            end
            
            %hide data to  stage 1
            sg1_maxhide = 0; 
            for x=1:xy_block
                for y=1:xy_block
                    if Stage1_pixel_shift(x,y) == Ori_peakpoint_array(CountNumber,blk)
                    %if the data don't hide finishde,and the max hiddding is smaller than Ori_pixel_count(Ori_peakpoint), and then keep hidding continue
                        if (total_hide <= length(bound_hiding_data) && sg1_maxhide <= ref_peak_count)
                            if mod(x-1,2)~=0 || mod(y-1,2)~=0
                                if bound_hiding_data(total_hide) == 1
                                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) + 1;
                                    sg1_maxhide = sg1_maxhide + 1;
                                    total_hide = total_hide + 1;
                                    total_hide_stage1 = total_hide_stage1 +1;
                                else
                                    sg1_maxhide = sg1_maxhide + 1;
                                    total_hide = total_hide + 1;
                                    total_hide_stage1 = total_hide_stage1 +1;
                                end
                            end
                        end
                    end
                end 
            end
            
            %this is record everyround's datahidding
            Stage1_max_hide(CountNumber) = Stage1_max_hide(CountNumber) + sg1_maxhide;
            
            
 %---------------------------------stage B---------------------------------
            %首先我們先將第一階段的結果，轉換成一為陣列
            %方便我們找出peakpoint
            Ori_1Dimensions = reshape(Stage1_pixel_shift,1,numel(Stage1_pixel_shift)); 
            
            %第二步，我們刪除參考點(因為不可以對參考點做任何的修改)
            %接下來排序此一維陣列
            del = 0;
            for x=1:length(Ori_1Dimensions)
                ref_Num = mod(x,xy_block);
                ref_Num2 = mod(x,(xy_block*2));
                 if mod(ref_Num,2)~=0 && ref_Num2<=xy_block
                     Ori_1Dimensions(x-del)=[];
                     del = del+1;
                 end
            end   
                
            %找出peakpoint
            Ori_peakpoint_array2(CountNumber,blk) = mode(Ori_1Dimensions(:));   
            
            %接下來我們要找出peakppoint的值(以便計算藏量)
            %correspond array
            X = Ori_1Dimensions(:);
            X = sort(X);                         %sort x array
            d = diff([X;max(X)+1]);
            count = diff(find([1;d])) ;

            Y = [X(find(d)) count];              %relative frequency
            Y_Translate = Y';  
            
            %找出像素值與其對應的累積量
            ref_peak_count = 0;
            for x=1:length(count)
                if count(x)>ref_peak_count
                    ref_peak_count = count(x);
                end
            end
            
            leftpeakpoint_array(CountNumber,blk) = Ori_peakpoint_array2(CountNumber,blk) - 1;
            rightpeakpoint_array(CountNumber,blk) = Ori_peakpoint_array2(CountNumber,blk) + 1;
            
                %移動值方圖(哨兵位移)
                for x=1:xy_block
                    for y=1:xy_block
                        if mod(x-1,2)~=0 || mod(y-1,2)~=0
                            if (Stage1_pixel_shift(x,y)<=leftpeakpoint_array(CountNumber,blk))
                                Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)-1;
                            end
                            if (Stage1_pixel_shift(x,y)>=rightpeakpoint_array(CountNumber,blk))
                                Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)+1;
                            end
                        end
                    
                    end
                end
            
                %計算第二層的藏量
                Stage2_blk_hide = 0;
                for x=1:xy_block
                    for y=1:xy_block
                        if mod(x-1,2)~=0 || mod(y-1,2)~=0
                            if (Stage1_pixel_shift(x,y)== (leftpeakpoint_array(CountNumber,blk)-1))
                                Stage2_blk_hide = Stage2_blk_hide +1;
                            end
                            if (Stage1_pixel_shift(x,y)== (rightpeakpoint_array(CountNumber,blk)+1))
                                Stage2_blk_hide = Stage2_blk_hide +1;
                            end
                        end
                    end
                end
                
                %如果第二層藏入量小於9，則不使用此區塊
                %同時將之後的區塊做標記，必免不必要的執行
                %隨後將我們在stage1和stage2所移動的像素值做復原
                if Stage2_blk_hide < 9
                    
                    for i = CountNumber:dataround
                        small_blk(i+1,blk) = 1;
                    end  
                    
                    %recover the stage2's we shift
                    for x=1:xy_block
                        for y=1:xy_block
                            if mod(x-1,2)~=0 || mod(y-1,2)~=0
                                if (Stage1_pixel_shift(x,y)<=leftpeakpoint_array(CountNumber,blk))
                                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)+1;
                                end
                                if (Stage1_pixel_shift(x,y)>=rightpeakpoint_array(CountNumber,blk))
                                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)-1;
                                end
                            end
                        end
                    end
                    
                    %recover the stage1's image,because the stage2 doesn't hide peakpoint 
                    
                    for x=1:xy_block
                        for y=1:xy_block
                            if mod(x-1,2)~=0 || mod(y-1,2)~=0
                                
                                if Stage1_pixel_shift(x,y)== Ori_peakpoint_array(CountNumber,blk)+1
                                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)-1;
                                end
                            end  
                        end
                    end
                    
                    %復原我們stage1，所移動的直方圖
                    %因為我們沒辦法再stage2中藏入資訊
                    %所以必須復原我們在stage1所移動的直方圖
                    for x=1:xy_block
                        for y=1:xy_block
                            if mod(x-1,2)~=0 || mod(y-1,2)~=0
                                if Stage1_pixel_shift(x,y)> Ori_peakpoint_array(CountNumber,blk) 
                                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) -1;
                                end
                            end
                        end
                    end
                    
                    %因為復原我們所藏入的資料
                    %所以之前記入的藏量資訊必須扣除
                    total_hide = total_hide - sg1_maxhide;
                    total_hide_stage1 = total_hide_stage1 - sg1_maxhide;
                    
                else
                    %如果stage2的藏量有大於9的話
                    %開始stage2，哨兵位移
                    effective_block = effective_block +1;
                    block_pass(CountNumber,blk)=1;
                    Stage2_max_hide(CountNumber) = Stage2_max_hide(CountNumber) + Stage2_blk_hide;
                    
                    %開始藏資料
                    for y=1:xy_block
                        for x=1:xy_block
                            if mod(x-1,2)~=0 || mod(y-1,2)~=0
                                                          
                                if Stage1_pixel_shift(x,y) == (leftpeakpoint_array(CountNumber,blk)-1)      
                                    %如果第一階段的peakpoint還沒藏完
                                    if (add_hide<=length(Ori_peakpoint_char) && add_hide<=Stage2_blk_hide)
                                        if Ori_peakpoint_char(add_hide)==1
                                            Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)+1;
                                            add_hide = add_hide + 1;
                                        else
                                            add_hide = add_hide + 1;
                                        end
                                    else
                                        if total_hide <= length(bound_hiding_data) 
                                            if bound_hiding_data(total_hide)==1
                                                Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)+1;
                                                total_hide = total_hide +1; 
                                                total_hide_stage2 = total_hide_stage2 +1;
                                            else
                                                total_hide = total_hide +1;
                                                total_hide_stage2 = total_hide_stage2 +1;
                                                
                                            end  
                                        end
                                    end
                                end
             
                                if Stage1_pixel_shift(x,y) == (rightpeakpoint_array(CountNumber,blk)+1)    
                                    %%如果第一階段的peakpoint還沒藏完
                                    if (add_hide<=length(Ori_peakpoint_char) && add_hide<=Stage2_blk_hide)
                                        if Ori_peakpoint_char(add_hide)==1
                                            Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) - 1;
                                            add_hide = add_hide + 1; 
                                        else
                                            add_hide = add_hide + 1;
                                        end
                                    else
                                        if total_hide <= length(bound_hiding_data) 
                                            if bound_hiding_data(total_hide)==1
                                                Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)-1;
                                                total_hide = total_hide +1;
                                                total_hide_stage2 = total_hide_stage2 +1;
                                                
                                            else
                                                total_hide = total_hide +1;
                                                total_hide_stage2 = total_hide_stage2 +1;
                                                
                                            end  
                                        end
                                    end
                                end     
                            end
                        end
                    end
              
                end 
                
                Stage1_pixel_shift = inter_block + Stage1_pixel_shift;
            else
                
                Stage1_pixel_shift = hideImage(xx:xx+xy_block-1,yy:yy+xy_block-1);
            end
           
                    
           %換下一個區塊
           hideImage(xx:(xx+xy_block-1),yy:(yy+xy_block-1)) = Stage1_pixel_shift;
           test_total(CountNumber,blk) = total_hide;
           blk = blk+1;
        end
    end   
    
        %處理overflow的問題，如果有overflow則記錄下來
        for x = 1:512
            for y = 1:512
                if hideImage(x,y)>256
                     Overflow_point(CountNumber,x,y) = hideImage(x,y);
                     hideImage(x,y) = 256;
                     overflow = overflow + 1;
                end
                if hideImage(x,y)<1
                    Overflow_point(CountNumber,x,y) = hideImage(x,y);
                    hideImage(x,y) = 1; 
                    overflow = overflow +1;
                end
            end
        end
        
        EveryDataHide(CountNumber) = Stage1_max_hide(CountNumber)+Stage2_max_hide(CountNumber);
        
        OverFlow(CountNumber) = overflow;
        OF = OF + overflow;
        
        %PSNR
         Stage1_test = uint8(hideImage)-1;
         ref = user_input_image;
         [peaksnr, snr] = psnr(Stage1_test,ref);
         ORHDS1 = total_hide_stage1-re_t_st1;
         ORHDS2 = total_hide_stage2-re_t_st2-1;
         ORHD = total_hide-re_t-1;
         ORHP = effective_block*9;
         ORHT = ORHD + (effective_block*9);
         TH = TH + ORHT;
         
         fprintf('\n The count is %d', CountNumber);
         %fprintf('\n The block is %d * %d', xy_block,xy_block);
         %fprintf('\n The total block is %d', Area_Number);
         %fprintf('\n The effective block is %d', effective_block);
         fprintf('\n One Round Hiding Data in Stage1 is %d', ORHDS1);
         fprintf('\n One Round Hiding Data in Stage2 is %d', ORHDS2+ORHP);
         fprintf('\n One Round Hiding Total is %d', ORHT);
         fprintf('\n One Round Hiding Data is %d', ORHD);
         %fprintf('\n One Round Hiding Peskpoint is %d', ORHP);
         fprintf('\n Total Hide is %d\n', TH);
         %fprintf('\n One Round OverflowPoint is %d',OverFlow(CountNumber));
         fprintf('\n Total OverFlow point is %d',OF);
         fprintf('\n The disable block is %d\n', Area_Number-effective_block);
         fprintf('\n The Peak-SNR value is %0.4f', peaksnr);
         fprintf('\n -------------------------- \n');
         image_PSNR = peaksnr;
         CountNumber = CountNumber + 1;
         re_t = total_hide;
         re_t_st1 = total_hide_stage1;
         re_t_st2 = total_hide_stage2;
 end
 %顯示藏完資料的直方圖
 %imhist(Stage1_test);
 %顯示藏完資料的影像
 imshow(Stage1_test);
 end