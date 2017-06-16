function interpolation2

 rand_hiding_data = rand(1,1000000);
 bound_hiding_data = round(rand_hiding_data);

 %load file
 Ori_imagePixel_array = imread('barbara.bmp'); 
 Ori_imagePixel_double = double(Ori_imagePixel_array)+1;
 
 %first height and then side
 [imgy, imgx] = size(Ori_imagePixel_array);
 
 %input the count of round
 dataround = 1;
 
 %desion the block's side length
 xy_block = 16;
 
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
 
 ref_Pixel = xy_block/2;

 %compute the area we cut
 cut_side = (length(Ori_imagePixel_array)/xy_block);
 Area_Number = cut_side*cut_side;
    
 %check the block can hidding over 8 bits
 block_pass = zeros(dataround,Area_Number);
 
 %This is A+B's varible
    
        %total hiding
        total_hide = 1; 
        %every round's dataHiding 
        EveryDataHide = [];
        %every round's overflow
        OverFlow = [];
        %record every time's peakpoint 
        Ori_peakpoint_array = zeros(dataround,Area_Number);
    
        %stage2 record every time's peakpoint
        Ori_peakpoint_array2 = zeros(dataround,Area_Number);
        %stage2 record every time's leftpeakpoint
        leftpeakpoint_array = zeros(dataround,Area_Number);
        %stage2 record every time's rightpeakpoint
        rightpeakpoint_array = zeros(dataround,Area_Number);
        %record the storage too small point
        small_blk = zeros(dataround+1,Area_Number);
        %handle the overflow's problem
        Overflow_point = ones(dataround,512,512);
        
        test_total = [];
  
  OF = 0;
  TH = 0;
  re_t = 0;
  CountNumber=1;
  hideImage = Ori_imagePixel_double;
  Stage1_max_hide = zeros(dataround);     %stage1's total max hidding
  Stage2_max_hide = zeros(dataround);     %stage2's total max hidding
 
 while(CountNumber<=dataround)
     blk=1;
     effective_block = 0;
     overflow = 0;
     
    for yy = 1:xy_block:512
        for xx = 1:xy_block:512
            add_hide = 1;
            if small_blk(CountNumber,blk) ~= 1
                
            block = hideImage(xx:xx+xy_block-1,yy:yy+xy_block-1);
            
            %???????????????????stage interpolation%???????????????????
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
            
            %iter_len is for function 'interp2'
            iter_len = length(ref_block)-1;
            output_toal = interp2([0:iter_len], [0:iter_len], ref_block, X1, Y1); 
            ouput = round(output_toal);
            
            %product the interpolation image
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
            sub_block = block-inter_block;
            
            
            %%??????????????????? stageA %???????????????????
            %first to change block to 1 dimensions
            Ori_1Dimensions = reshape(sub_block,1,numel(block));
            
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
            
            %find the orginal peakpoint
            Ori_peakpoint_array(CountNumber,blk) = mode(Ori_1Dimensions(:));
            
            %if the peakpoint<0 ,let first unit change to 1
            if Ori_peakpoint_array(CountNumber,blk) <0
                peakpoint = Ori_peakpoint_array(CountNumber,blk)*(-1);
                %translate to Binary
                Ori_peakpoint_binary = dec2bin(peakpoint,8);
                
                % writing Binary to char_array(prepare writing to stage2 peakpoint)
                for bin_i = 1:8
                    Ori_peakpoint_char(1,bin_i) = bin2dec(Ori_peakpoint_binary(1,bin_i));    
                end
                Ori_peakpoint_char = [1,Ori_peakpoint_char(1:8)];
            else
                %translate to Binary
                Ori_peakpoint_binary = dec2bin(Ori_peakpoint_array(CountNumber,blk),8);
                
                % writing Binary to char_array(prepare writing to stage2 peakpoint)
                for bin_i = 1:8
                    Ori_peakpoint_char(1,bin_i) = bin2dec(Ori_peakpoint_binary(1,bin_i));    
                end
                Ori_peakpoint_char = [0,Ori_peakpoint_char(1:8)];
            end
            
            
            %the following program is the count and the pixel
            %correspond array
            X = Ori_1Dimensions(:);
            X = sort(X);                         %sort x array
            d = diff([X;max(X)+1]);
            count = diff(find([1;d])) ;

            Y = [X(find(d)) count];              %relative frequency
            Y_Translate = Y';  
            
            %find the peakpoint's count
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
                                else
                                    sg1_maxhide = sg1_maxhide + 1;
                                    total_hide = total_hide + 1;
                                end
                            end
                        end
                    end
                end 
            end
            
            %this is record everyround's datahidding
            Stage1_max_hide(CountNumber) = Stage1_max_hide(CountNumber) + sg1_maxhide;
            
            
            %??????????????????? stageB %???????????????????
            %change block to 1 dimensions
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
            Ori_peakpoint_array2(CountNumber,blk) = mode(Ori_1Dimensions(:));   
            
            %the following program is the count and the pixel
            %correspond array
            X = Ori_1Dimensions(:);
            X = sort(X);                         %sort x array
            d = diff([X;max(X)+1]);
            count = diff(find([1;d])) ;

            Y = [X(find(d)) count];              %relative frequency
            Y_Translate = Y';  
            
            %find the peakpoint's count
            ref_peak_count = 0;
            for x=1:length(count)
                if count(x)>ref_peak_count
                    ref_peak_count = count(x);
                end
            end
            
            leftpeakpoint_array(CountNumber,blk) = Ori_peakpoint_array2(CountNumber,blk) - 1;
            rightpeakpoint_array(CountNumber,blk) = Ori_peakpoint_array2(CountNumber,blk) + 1;
            
                %shift the histogram
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
            
                %compute the stage2's maxhide
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
                
                %change to tmp_total_hide
                if Stage2_blk_hide < 9
                    
                    %total_hide = tmp_total_hide;
                    %fprintf('error blk=%d\n', blk);
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
                    %recover the peakpoint to last one point
                    for x=1:xy_block
                        for y=1:xy_block
                            if mod(x-1,2)~=0 || mod(y-1,2)~=0
                                if Stage1_pixel_shift(x,y)> Ori_peakpoint_array(CountNumber,blk) 
                                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) -1;
                                end
                            end
                        end
                    end
 
                    total_hide = total_hide - sg1_maxhide;
                    
                else
                    
                    effective_block = effective_block +1;
                    block_pass(CountNumber,blk)=1;
                    Stage2_max_hide(CountNumber) = Stage2_max_hide(CountNumber) + Stage2_blk_hide;
                    
                    for y=1:xy_block
                        for x=1:xy_block
                            if mod(x-1,2)~=0 || mod(y-1,2)~=0
                                                          
                                if Stage1_pixel_shift(x,y) == (leftpeakpoint_array(CountNumber,blk)-1)      
                                    % stage1's peakpoint don't finish and continue
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
                                                
                                            else
                                                total_hide = total_hide +1;
                                                
                                            end  
                                        end
                                    end
                                end
             
                                if Stage1_pixel_shift(x,y) == (rightpeakpoint_array(CountNumber,blk)+1)    
                                    %stage1's peakpoint don't finish?and continue
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
                                                
                                            else
                                                total_hide = total_hide +1;
                                                
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
           
                    
           %change the next block
           hideImage(xx:(xx+xy_block-1),yy:(yy+xy_block-1)) = Stage1_pixel_shift;
           test_total(CountNumber,blk) = total_hide;
           blk = blk+1;
        end
    end   
    
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
         ref = imread('barbara.bmp');
         [peaksnr, snr] = psnr(Stage1_test,ref);
         ORHD = total_hide-re_t-1;
         ORHP = effective_block*9;
         ORHT = ORHD + (effective_block*9);
         TH = TH + ORHT;
         
         fprintf('\n The count is %d', CountNumber);
         fprintf('\n The block is %d * %d', xy_block,xy_block);
         fprintf('\n The total block is %d', Area_Number);
         fprintf('\n The effective block is %d', effective_block);
         fprintf('\n One Round Hiding Data is %d', ORHD);
         fprintf('\n One Round Hiding Peskpoint is %d', ORHP);
         fprintf('\n One Round Hiding Total is %d', ORHT);
         fprintf('\n Total Hide is %d\n', TH);
         fprintf('\n One Round OverflowPoint is %d',OverFlow(CountNumber));
         fprintf('\n Total OverFlow point is %d',OF);
         fprintf('\n The disable block is %d\n', Area_Number-effective_block);
         fprintf('\n The Peak-SNR value is %0.4f', peaksnr);
         fprintf('\n -------------------------- \n');
         CountNumber = CountNumber + 1;
         re_t = total_hide;
 end
 
 imhist(Stage1_test);
 imshow(Stage1_test);
 end