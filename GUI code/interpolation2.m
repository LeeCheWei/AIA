%�b�ϥΫe�A�Х��ŧi�����ܼ�
%�����ܼ� �ǻ���GUI �M.m�ɤ���
%���{�������Ustart hide data���s��Ұ��檺�{��
%���{���X�����T���q
%�Ĥ@���q: ����S�w���Ѧ��I�A�ü����@�i�s�v��
%�ĤG���q: �ھڧڭ̼������v���A������Ϧ첾��k
%�ĤT���q: ���ۭȤ�Ϧ첾��k��A�A�����L�첾��k
% global user_input_data    GUI �ϥΪ̩ҭn�äJ���K�X
% global user_input_image   GUI �ϥΪ̩ҭn�ø�ƪ��Ϥ�
% global user_hide_data     GUI �ϥΪ̸ѱK�X�Ӫ����
% global user_input_round    GUI �ϥΪ̩һݭn���h��
% global user_input_block   GUI �ϥΪ̩һݭn���϶��j�p
% global block_pass         interpolation���A�i�ϥΪ�block�ơA���B�~��T
% global hideImage          interpolation���A�ç���ƪ��Ϥ�
% global Overflow_point     interpolation���AOverFlow�ơA���B�~��T
% global image_PSNR         �L�X�Ӥ���PSNR��

function interpolation2

 global user_input_round 
 global user_input_data
 global user_input_image
 global hideImage
 global block_pass
 global user_input_block
 global Overflow_point
 global image_PSNR
 
 %GUI���ϥΪ̿�J���h��
 dataround = user_input_round;
 %GUI���ϥΪ̿�J���϶��j�p
 xy_block = user_input_block;
 
 %�ŧi�@�Ű}�C�A��mbinary���A�����
 hiding_data_i = [];
 %�N�ϥΪ̩ҭn�äJ����Ʊqchar�নdouble���A�A���x�s
 msg_double = double(user_input_data);

 %�Ndouble���A������নbinary�A�å�����ܨ�hiding_data_i��
 for x=1:length(user_input_data)
     msg_bin = dec2bin(msg_double(x),8);
     hiding_data_i = [hiding_data_i,msg_bin(1:8)];
 end
 
 %�A�Nbinary������Ƥ@�@�s���double_data���A���A��double
 %�]���q�ϥΪ̭�ӿ�J���A�Ochar�A�ҥH�নdouble�ɡA0�|��ܦ�48�A1�|��ܦ�49
 %�ҥH�ڭ̱N��X�Ӫ��Ȥ@�@����48�æs�J�ܼƤ��A�ϱo�D�{���i�H���`����
 for y=1:length(hiding_data_i)
     double_data(y) = double(hiding_data_i(y))-48;
 end
 %�N�ҭn�äJ������ഫ������A�s�Jbound_hiding_data
 bound_hiding_data = double_data;
 
 %������n�૬�A?
 %GUI���ϥΪ̿�J���Ochar���A
 %�ڭ̦b�{�����ҭn�äJ���Odouble���A��100101010101�x�}
 %�ҥH�qchar�নdouble�A�নbinary(���ɩҦ�����Ʒ|�A�P�@��index���A�ҥH�ڭ̥����@�@����)
 %ex: '101101'
 %�̫�A�Nbinary�নdouble�A�ñN�Ҧ���1010101001����
 %ex: '1','0','1','1','0','1'
 
 %------------------------------------------------------------------------
 
 %GUI���A�ϥΪ̩ҿ�ܪ��Ϥ��AŪ�iOri_imagePixel_array��
 %�`�N�Ϥ����A��uint8
 Ori_imagePixel_array = user_input_image;
 %�N�Ϥ����A���double
 %���double��n�O�o+1(�]���নdouble��|�����|����0~255��)
 %�ڭ̹�ڰ���{���һݭn���d��O1~256�A�ҥH�n�[1
 Ori_imagePixel_double = double(Ori_imagePixel_array)+1;
 
 %�۰ʧ���ۤ��j�p�A���{���S���Ψ�A�Y���ݭn�i�ۦ�ϥ�
 %[imgy, imgx] = size(Ori_imagePixel_array);
 

 
 %�]�p�ڭ�interpolation�һݭn��X,Y(�ھڧڭ̰϶��j�p�M�w)
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

 %�p��ڭ̨쩳�����h�ֶ�
 cut_side = (length(Ori_imagePixel_array)/xy_block);
 Area_Number = cut_side*cut_side;
    
 
 %�H�U���ڭ̰���{���һݭn���ܼ�
    

 total_hide = 1;                                                    %�`�öq(�����x�}��indexd�ҥH�@�}�l�]��1)
 total_hide_stage1 = 0;                                             %�Ĥ@���q�`�öq
 total_hide_stage2 = 0;                                             %�ĤG���q�`�öq
  
 EveryDataHide = [];                                                %�C�@�h���öq
 OverFlow = [];                                                     %�C�@�h��OverFlow
 
 Ori_peakpoint_array = zeros(dataround,Area_Number);                %�O���C�@���Ĥ@���q��peakpoint(deBUG��)
 Ori_peakpoint_array2 = zeros(dataround,Area_Number);               %�O���C�@���ĤG���q��peakpoint(deBUG��)
 
 leftpeakpoint_array = zeros(dataround,Area_Number);                %�O���C�@���ĤG���q��leftpeakpoint(deBUG��)
 rightpeakpoint_array = zeros(dataround,Area_Number);               %�O���C�@���ĤG���q��rightpeakpoint(deBUG��)

 small_blk = zeros(dataround+1,Area_Number);                        %�϶��Ӥp�ɭP�L�k�ø�ơA�O���U��

 Overflow_point = ones(dataround,512,512);                          %OverFlow���h�ơB�϶��A���B�~��T�A���B�~�O�� 
 block_pass = zeros(dataround,Area_Number);                         %�i�H�ϥΪ��϶��A���B�~��T�A���B�~�O��
        
 test_total = [];                                                   %���ե��ܼ�
  
 
 %�H�U���L�X�̲׵��G���ܼ�  
 OF = 0;
 TH = 0;
 re_t = 0;
 re_t_st1 = 0;
 re_t_st2 = 0;
 
 %------------------------------------------------------------------------
 CountNumber=1;                                                     %�Ĥ@���}�l����A�ƭȳ]�w��1
 hideImage = Ori_imagePixel_double;                                 %�ŧi�@�s�ܼơA�s��ڭ̪��v���A�O�@��v�������l
 Stage1_max_hide = zeros(dataround);                                %�Ĥ@���q�C�h���`�öq
 Stage2_max_hide = zeros(dataround);                                %�ĤG���q�C�h���`�öq
 
 while(CountNumber<=dataround)
     
     blk=1;                                                         %�϶��q�Ĥ@���}�l����
     effective_block = 0;                                           %�C�h���İ϶�����l�Ƭ�0
     overflow = 0;                                                  %�C�hOverFlow�ƥ���l�Ƭ�0
     
    for yy = 1:xy_block:512
        for xx = 1:xy_block:512
            add_hide = 1;
            
            if small_blk(CountNumber,blk) ~= 1                              %�p�G�϶��Ӥp�A�h������A��l�ȳ]�w�����i�H����
                                                                            %�Y�᭱�o�{�϶��Ӥp�A�h�|���ܤU�@�Ӱ϶��ô_��   
            block = hideImage(xx:xx+xy_block-1,yy:yy+xy_block-1);           %�@���@���϶������U�h�èϥΪ̪����
            
 %---------------------------stage interpolation---------------------------
 
            %��X�C�Ӱ϶����Ѧ��I(�Ѧ��I������n�����s�v�����I�A���వ���󪺭ק�)
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
            
            %'interp2'�O�@��interpolatio�����
            %���w�Ѧ��I�A�|�۰����ڭ̼����P�򪺹�����
            iter_len = length(ref_block)-1;
            output_toal = interp2([0:iter_len], [0:iter_len], ref_block, X1, Y1); 
            ouput = round(output_toal);
            
            %�N�ڭ̼����X�Ӫ������s�Jinter_block��
            %���ͤ@�ӷs�������϶�
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
            
            %�N��Ӫ��϶� ��h �ڭ̼������s�϶� �|�o��@�t�ȯx�}
            %sub_block���t�ȯx�}
            sub_block = block-inter_block;
            
            
 %---------------------------------stage A---------------------------------
            %�����ڭ̥��N�t�ȯx�}�A�ഫ���@���}�C
            %��K�ڭ̧�Xpeakpoint
            Ori_1Dimensions = reshape(sub_block,1,numel(block));
            
            %�ĤG�B�A�ڭ̧R���Ѧ��I(�]�����i�H��Ѧ��I�����󪺭ק�)
            %���U�ӱƧǦ��@���}�C
            del = 0;
            for x=1:length(Ori_1Dimensions)
                ref_Num = mod(x,xy_block);
                ref_Num2 = mod(x,(xy_block*2));
                 if mod(ref_Num,2)~=0 && ref_Num2<=xy_block
                     Ori_1Dimensions(x-del)=[];
                     del = del+1;
                 end
            end
            
            %��Xpeakpoint
            Ori_peakpoint_array(CountNumber,blk) = mode(Ori_1Dimensions(:));
            
            %�p�G��X�Ӫ�peakpoint�O�t�ơA�ڭ̧�Ĥ@�Ӭ����令1
            if Ori_peakpoint_array(CountNumber,blk) <0
                peakpoint = Ori_peakpoint_array(CountNumber,blk)*(-1);
                %�⫬�A�নBinary
                Ori_peakpoint_binary = dec2bin(peakpoint,8);
                
                %��Binary���A��peakpoint�g�J��char_array��(�ǳ��äJ��ĤG���q��)
                for bin_i = 1:8
                    Ori_peakpoint_char(1,bin_i) = bin2dec(Ori_peakpoint_binary(1,bin_i));    
                end
                Ori_peakpoint_char = [1,Ori_peakpoint_char(1:8)];
            else
                %�⫬�A�নBinary
                Ori_peakpoint_binary = dec2bin(Ori_peakpoint_array(CountNumber,blk),8);
                
                %��Binary���A��peakpoint�g�J��char_array��(�ǳ��äJ��ĤG���q��)
                for bin_i = 1:8
                    Ori_peakpoint_char(1,bin_i) = bin2dec(Ori_peakpoint_binary(1,bin_i));    
                end
                Ori_peakpoint_char = [0,Ori_peakpoint_char(1:8)];
            end
            
            
            %���U�ӧڭ̭n��Xpeakppoint����(�H�K�p���öq)
            %correspond array
            X = Ori_1Dimensions(:);
            X = sort(X);                         %�Ƨ�X�x�}
            d = diff([X;max(X)+1]);
            count = diff(find([1;d])) ;

            Y = [X(find(d)) count];              %relative frequency
            Y_Translate = Y';  
            
            %%��X�����ȻP��������ֿn�q
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
            %�����ڭ̥��N�Ĥ@���q�����G�A�ഫ���@���}�C
            %��K�ڭ̧�Xpeakpoint
            Ori_1Dimensions = reshape(Stage1_pixel_shift,1,numel(Stage1_pixel_shift)); 
            
            %�ĤG�B�A�ڭ̧R���Ѧ��I(�]�����i�H��Ѧ��I�����󪺭ק�)
            %���U�ӱƧǦ��@���}�C
            del = 0;
            for x=1:length(Ori_1Dimensions)
                ref_Num = mod(x,xy_block);
                ref_Num2 = mod(x,(xy_block*2));
                 if mod(ref_Num,2)~=0 && ref_Num2<=xy_block
                     Ori_1Dimensions(x-del)=[];
                     del = del+1;
                 end
            end   
                
            %��Xpeakpoint
            Ori_peakpoint_array2(CountNumber,blk) = mode(Ori_1Dimensions(:));   
            
            %���U�ӧڭ̭n��Xpeakppoint����(�H�K�p���öq)
            %correspond array
            X = Ori_1Dimensions(:);
            X = sort(X);                         %sort x array
            d = diff([X;max(X)+1]);
            count = diff(find([1;d])) ;

            Y = [X(find(d)) count];              %relative frequency
            Y_Translate = Y';  
            
            %��X�����ȻP��������ֿn�q
            ref_peak_count = 0;
            for x=1:length(count)
                if count(x)>ref_peak_count
                    ref_peak_count = count(x);
                end
            end
            
            leftpeakpoint_array(CountNumber,blk) = Ori_peakpoint_array2(CountNumber,blk) - 1;
            rightpeakpoint_array(CountNumber,blk) = Ori_peakpoint_array2(CountNumber,blk) + 1;
            
                %���ʭȤ��(��L�첾)
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
            
                %�p��ĤG�h���öq
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
                
                %�p�G�ĤG�h�äJ�q�p��9�A�h���ϥΦ��϶�
                %�P�ɱN���᪺�϶����аO�A���K�����n������
                %�H��N�ڭ̦bstage1�Mstage2�Ҳ��ʪ������Ȱ��_��
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
                    
                    %�_��ڭ�stage1�A�Ҳ��ʪ������
                    %�]���ڭ̨S��k�Astage2���äJ��T
                    %�ҥH�����_��ڭ̦bstage1�Ҳ��ʪ������
                    for x=1:xy_block
                        for y=1:xy_block
                            if mod(x-1,2)~=0 || mod(y-1,2)~=0
                                if Stage1_pixel_shift(x,y)> Ori_peakpoint_array(CountNumber,blk) 
                                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) -1;
                                end
                            end
                        end
                    end
                    
                    %�]���_��ڭ̩��äJ�����
                    %�ҥH���e�O�J���öq��T��������
                    total_hide = total_hide - sg1_maxhide;
                    total_hide_stage1 = total_hide_stage1 - sg1_maxhide;
                    
                else
                    %�p�Gstage2���öq���j��9����
                    %�}�lstage2�A��L�첾
                    effective_block = effective_block +1;
                    block_pass(CountNumber,blk)=1;
                    Stage2_max_hide(CountNumber) = Stage2_max_hide(CountNumber) + Stage2_blk_hide;
                    
                    %�}�l�ø��
                    for y=1:xy_block
                        for x=1:xy_block
                            if mod(x-1,2)~=0 || mod(y-1,2)~=0
                                                          
                                if Stage1_pixel_shift(x,y) == (leftpeakpoint_array(CountNumber,blk)-1)      
                                    %�p�G�Ĥ@���q��peakpoint�٨S�ç�
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
                                    %%�p�G�Ĥ@���q��peakpoint�٨S�ç�
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
           
                    
           %���U�@�Ӱ϶�
           hideImage(xx:(xx+xy_block-1),yy:(yy+xy_block-1)) = Stage1_pixel_shift;
           test_total(CountNumber,blk) = total_hide;
           blk = blk+1;
        end
    end   
    
        %�B�zoverflow�����D�A�p�G��overflow�h�O���U��
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
 %����ç���ƪ������
 %imhist(Stage1_test);
 %����ç���ƪ��v��
 imshow(Stage1_test);
 end