%在使用前，請先宣告全域變數
%全域變數 傳遞於GUI 和.m檔之間
%此程式為按下decode按鈕後所執行的程式
%
% global user_input_data    GUI 使用者所要藏入的密碼
% global user_input_image   GUI 使用者所要藏資料的圖片
% global user_hide_data     GUI 使用者解密出來的資料
% global user_input_round    GUI 使用者所需要的層數
% global user_input_block   GUI 使用者所需要的區塊大小
% global block_pass         interpolation中，可使用的block數，為額外資訊
% global hideImage          interpolation中，藏完資料的圖片
% global Overflow_point     interpolation中，OverFlow數，為額外資訊
% global image_PSNR         印出照片的PSNR值

function NewInterDecode

 global block_pass
 global hideImage
 global Overflow_point
 global user_hide_data
 global user_input_round
 global user_input_block
 Ori_imagePixel_double = [];    %original imgae (double)
 bound_hiding_data = [];        %the data we hidding
 %hideImage = [];                %the image we code
 %Overflow_point = [];           %will overflowpoint   
 %block_pass = [];               %stage2's hide data count < 9
 

 %save Decode's data
 DecodeData = [];
 %Round's Decode data
 RDcodeData = [];
 %input the count of round
 dataround = user_input_round;
 %desion the block's side length
 xy_block = user_input_block;
 ref_Pixel = xy_block/2;
 
 %compute the area we cut
 cut_side = (length(Ori_imagePixel_double)/xy_block);
 Area_Number = cut_side*cut_side;
 
 %desion the interplortion's x y
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

    %------------------------recover program-----------------
    Stage1_decoding_data = [];
    Stage2_decoding_data = [];
    decode = 1;
    decode2 = 1;
    decode_pixel_shift = hideImage;
    nowRound=1;
    index = dataround;
    
    while(nowRound<=dataround)
        blk=1;
        %first we recover the overflow_point
        for x=1:512
            for y=1:512
                if Overflow_point(index,x,y)<1 || Overflow_point(index,x,y)>256
                    decode_pixel_shift(x,y)=Overflow_point(index,x,y);
                end
            end
        end  
        
        %second start to cut blk we choose
        for yy=1:xy_block:512
            for xx=1:xy_block:512
                
                block = decode_pixel_shift(xx:xx+xy_block-1,yy:yy+xy_block-1);
                
                %---------------------------stage interploation---------------------------
                %find out the reference pixle
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
                
                %because the periphery's pixle doen's product,we simulation
                %by myself
                Z=[];
                iterCount=1;
                for b=1:xy_block
                    for a=1:xy_block
                        if a==xy_block || b==xy_block
                            if a-xy_block==0 && b-xy_block==0
                                Z(iterCount)=ref_block(ref_Pixel,ref_Pixel);
                                iterCount = iterCount+1;
                            elseif mod(a,2)==0 && b-xy_block==0
                                Z(iterCount)=round((ref_block(ref_Pixel,a/2)+ref_block(ref_Pixel,(a/2)+1))/2);
                                iterCount = iterCount+1;
                            elseif a-xy_block==0 && mod(b,2)==0
                                Z(iterCount)=round((ref_block(b/2,ref_Pixel)+ref_block((b/2)+1,ref_Pixel))/2);
                                iterCount = iterCount+1;
                            else
                                if a==xy_block
                                    Z(iterCount)=ref_block(floor(b/2)+1,ref_Pixel); 
                                    iterCount = iterCount+1;
                                else
                                    Z(iterCount)=ref_block(ref_Pixel,floor(a/2)+1);
                                    iterCount = iterCount+1;
                                end
                            end
                        end
                    end
                end
                
                %iter_len is for function 'interp2'
                iter_len = length(ref_block)-1;
                output_toal = interp2([0:iter_len], [0:iter_len], ref_block, X1, Y1); 
                ouput = round(output_toal);
            
                %product the interpolation image(xy_block * xy_block)
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
                
                %product the subtraction matrix
                %block: original image
                %inter_block: we simulation's image
                sub_block = block-inter_block;
                
                %---------------------------stage B to recover---------------------------
                Stage1_pixel_shift = sub_block;
                
                %first to change block to 1 dimensions
                Ori_1Dimensions = reshape(Stage1_pixel_shift,1,numel(Stage1_pixel_shift));
                
                %second to  del the refrenece point to  sort pixel
                del = 0;
                for x=1:length(Ori_1Dimensions)
                    ref_Num = mod(x,xy_block);
                    ref_Num2 = mod(x,(xy_block*2));
                    if mod(ref_Num,2)~=0 && ref_Num2<=xy_block
                        Ori_1Dimensions(x-del)=[];
                        del = del+1;
                    end
                end   
                
                %find out the peakpoint of stage1's hostogram
                Ori_peakpoint_array2 = mode(Ori_1Dimensions(:));
                
                leftpeakpoint_array = Ori_peakpoint_array2 - 1;
                rightpeakpoint_array = Ori_peakpoint_array2 + 1;
                
                
                %compute the stage2's maxhide
                Stage2_blk_hide = 0;
                for x=1:xy_block
                    for y=1:xy_block
                        if mod(x-1,2)~=0 || mod(y-1,2)~=0
                            if (Stage1_pixel_shift(x,y)== leftpeakpoint_array)
                                Stage2_blk_hide = Stage2_blk_hide +1;
                            end
                            if (Stage1_pixel_shift(x,y)== leftpeakpoint_array-1)
                                Stage2_blk_hide = Stage2_blk_hide +1;
                            end
                            if (Stage1_pixel_shift(x,y)== rightpeakpoint_array)
                                Stage2_blk_hide = Stage2_blk_hide +1;
                            end
                            if (Stage1_pixel_shift(x,y)== rightpeakpoint_array+1)
                                Stage2_blk_hide = Stage2_blk_hide +1;
                            end
                        end
                    end
                end

                
                if (Stage2_blk_hide >= 9 && block_pass(index,blk)==1)
                    for y=1:xy_block
                        for x=1:xy_block
                            if mod(x-1,2)~=0 || mod(y-1,2)~=0
                                if Stage1_pixel_shift(x,y)==(leftpeakpoint_array-1)   
                                    Stage1_decoding_data(decode)=0;
                                    decode = decode + 1;
                                    
                                end
                                if Stage1_pixel_shift(x,y)==leftpeakpoint_array
                                    Stage1_decoding_data(decode)=1;
                                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)-1;
                                    decode = decode + 1;
                                    
                                end 
                                if Stage1_pixel_shift(x,y)==(rightpeakpoint_array+1)
                                    Stage1_decoding_data(decode)=0;
                                    decode = decode + 1;
                                    
                                end
                                if Stage1_pixel_shift(x,y)==rightpeakpoint_array
                                    Stage1_decoding_data(decode)=1;
                                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)+1;
                                    decode = decode + 1;
                                    
                                end
                            end    
                        end
                    end
                    
                    %find the stage1's peakpoint
                    peak_Plus = Stage1_decoding_data(1);
                    peak_array = Stage1_decoding_data(2:9);
                    peakpoint = int2str(peak_array);
                    hidedata_peakpoint = bin2dec(peakpoint);
                    if peak_Plus==1
                        hidedata_peakpoint = hidedata_peakpoint*(-1);
                    end
                    
                    %save decode data
                    Stage1_decoding_data(1:9) = [];
                                      
                    %because we finish the decode, we recover the image
                    for x=1:xy_block
                        for y=1:xy_block
                            if mod(x-1,2)~=0 || mod(y-1,2)~=0
                                if (Stage1_pixel_shift(x,y)<=leftpeakpoint_array)
                                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)+1;
                                end
                                if (Stage1_pixel_shift(x,y)>=rightpeakpoint_array)
                                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)-1;
                                end
                            end
                        end
                    end 
                    
                    
                    %finish the stage2's recover
                    
                    %---------------------------stage A to recover---------------------------
                    %decode the data that
                    for x=1:xy_block
                        for y=1:xy_block
                            if mod(x-1,2)~=0 || mod(y-1,2)~=0
                                if Stage1_pixel_shift(x,y)== hidedata_peakpoint
                                    Stage2_decoding_data(decode2)=0;
                                    decode2 = decode2 +1;
                                end
                                if Stage1_pixel_shift(x,y)== (hidedata_peakpoint+1)
                                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y)-1;
                                    Stage2_decoding_data(decode2)=1;
                                    decode2 = decode2 +1;
                                end
                            end  
                        end
                    end
                    
                    DecodeData = [DecodeData,Stage2_decoding_data,Stage1_decoding_data];
                    
                   
              
%                     if error~=0
%                         fprintf('blk: %d error \n', blk);
%                     end
                    
                    
                    
                    Stage1_decoding_data = [];
                    Stage2_decoding_data = [];
                    decode=1;
                    decode2=1;
                    %recover the peakpoint to last one point
                    for x=1:xy_block
                        for y=1:xy_block
                            if mod(x-1,2)~=0 || mod(y-1,2)~=0
                                if Stage1_pixel_shift(x,y)> hidedata_peakpoint 
                                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) -1;
                                end
                            end
                        end
                    end
                                
                end
                
                %%for debug
%                 test_len = length(DecodeData);
%                 if test_len ~= test_total(index,blk)-1
%                     fprintf('blk: %d, 1:%d; 2:%d \n', blk,test_total(nowRound,blk),test_len);
%                 end
                
                Stage1_pixel_shift = inter_block + Stage1_pixel_shift;
                decode_pixel_shift(xx:xx+xy_block-1,yy:yy+xy_block-1) = Stage1_pixel_shift;
                blk = blk+1;  
                
            end
        end
        %one round finished
        nowRound = nowRound +1;
        index = index -1;
        RDcodeData = [DecodeData,RDcodeData]; 
        %fprintf('%d\n', length(RDcodeData));
        DecodeData = [];
    end
    
%     len = length(RDcodeData);
%     err = 0;
%     for x = 1:len
%        if  RDcodeData(x)~= bound_hiding_data(x)
%           err=err+1;
%        end
%     end
%     if err~=0
%        fprintf('error'); 
%     end
    
    decode_i = [];
    for z=1:length(RDcodeData)
        char_data(z) = RDcodeData(z)+48;
    end
    
    out_char = char(char_data);
    datacount = length(out_char)/8;
    
    for x=1:datacount
        decode_i(x) = bin2dec(out_char(1:8));
        out_char(1:8)=[];
    end
    
    fin = char(decode_i);
    user_hide_data = fin;
    fprintf('%c',fin);
end