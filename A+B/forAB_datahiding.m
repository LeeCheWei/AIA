function forAB_datahiding

    %��J�n�]�X���j��
    dataround = 10;
    %�s���ܼ�
    rand_hiding_data = rand(1,100000);
    bound_hiding_data = round(rand_hiding_data);

    ref2 = imread('lena.jpg'); 
    A = imnoise(ref2,'salt & pepper', 0.02);
    [peaksnr, snr] = psnr(A, ref2);
    fprintf('\n The Peak-SNR value is %0.4f', peaksnr);
    fprintf('\n The SNR value is %0.4f \n', snr);
    fprintf('\n ------------------ \n');
    
    Ori_imagePixel_array = imread('lena.jpg');                  %��v���g�J�}�C
    Ori_imagePixel_double = double(Ori_imagePixel_array)+1;     %uint8 �ন double���A
    
    CountNumber = 1;
    total_hide = 1;   %�`�öq
    
    %�ΰ}�C�����C�@�h�äJ�q
    EveryDataHide = [];
    %�ΰ}�C�O���C�@����peakpoint
    Ori_peakpoint_array = []; 
    %�ΰ}�C�O���C�@����zeropoint
    Ori_zeropoint = [];
    
    %stage2 �ΰ}�C�O���C�@����peakpoint
    Ori_peakpoint_array2 = []; 
    %stage2 �ΰ}�C�O���C�@����leftpeakpoint
    leftpeakpoint_array = [];
    %stage2 �ΰ}�C�O���C�@����rightpeakpoint
    rightpeakpoint_array = [];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    while(CountNumber<=dataround)
        
        %��Ori_imagePixel_double�ର1���}�C
        Ori_1Dimensions = reshape(Ori_imagePixel_double,1,numel(Ori_imagePixel_array)); 
        %��l�Ϫ��p��(double)   p.s �p�Ȭ��X�{�̦h����pixel
        Ori_peakpoint_array(CountNumber) = mode(Ori_1Dimensions(:));
        %��l�Ϫ��p��(Binary)
        Ori_peakpoint_binary = dec2bin(Ori_peakpoint_array(CountNumber),8);
        
        % writing Binary to char_array(prepare writing to stage2 peakpoint)
        for bin_i = 1:8
            Ori_peakpoint_char(1,bin_i) = bin2dec(Ori_peakpoint_binary(1,bin_i));    
        end
        
        %�H�U�{���X�����ͥXpixel�M�X�{���ƪ��۹����x�}
        X = Ori_1Dimensions(:);
        X = sort(X);                         %�ƧǢ�}�C
        d = diff([X;max(X)+1]);
        count = diff(find([1;d])) ;

        Y = [X(find(d)) count];              %�C�X�۹�������
        Y_Translate = Y';                    %��m��x�}
        
        %%%%%%%%%%%%%%%%%%%%%%%%
        %�Ҽ{�Y��pixel�ȥ��X�{�����p
        Ori_pixel_count(1:256) = 0;          %�ŧi�@�Ű}�C�A�s��pixel�۹�X�{������
        for i = 1:256
            for j = 1:size(Y_Translate,2)
                if i == Y_Translate(1,j)
                    Ori_pixel_count(1,i) = Y_Translate(2,j);
                end
            end
        end
        
        %��Xzeropoint�M�۹�����pixel��
        %Ori_zeropoint = 0;
        Ori_zero_pixel = 256;
        for i = Ori_peakpoint_array(CountNumber):length(Ori_pixel_count)
            if Ori_pixel_count(i)< Ori_zero_pixel
                Ori_zero_pixel = Ori_pixel_count(i);
                Ori_zeropoint(CountNumber) = i;
            end
        end
        
        %���ʪ���ϵM��}�l�ø��
        %�p�Gzeropoint���O0�h�]��0
        %�O���U�Ӥ���_��
        Stage1_renew(1:15) = 0;
        if Ori_zero_pixel > 0
            Ori_pixel_count(Ori_zeropoint(CountNumber))=Stage1_renew(1,CountNumber);    %�̧C�I���O0�����w���@�ܼ�
            Ori_pixel_count(Ori_zeropoint(CountNumber))=0;               %�]�w��0
        end
        
        %�⪽��ϦV�k���ʤ@�ӳ��(peak_point�Mzero_point����)
        Stage1_pixel_shift = Ori_imagePixel_double;
        for x=1:512
            for y=1:512
                if Stage1_pixel_shift(x,y) > Ori_peakpoint_array(CountNumber) && Stage1_pixel_shift(x,y) < Ori_zeropoint(CountNumber);
                    Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) + 1;
                end
            end
        end
        
        %hide data to hstogram
        max_hide = 1;     %stage1�̤j�öq
        for x=1:512
            for y=1:512
                if Stage1_pixel_shift(x,y) == Ori_peakpoint_array(CountNumber)
                    %�p�G�٦���ƨS�ç��A�ӥB��̤j�öqOri_pixel_count(Ori_peakpoint)�٭n�p�N�~����
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
    
        %��X�ø꧹���������
        Stage1_test = uint8(Stage1_pixel_shift)-1;
        imhist(Stage1_test);
        
        %---------------------------------stageB-----------------------------------
        
        %��Stage1�����G�ഫ���@���}�C
        Stage2_1Dimensions = reshape(Stage1_pixel_shift,1,numel(Ori_imagePixel_array));  
        %find out the peakpoint of stage1's hostogram
        Ori_peakpoint_array2(CountNumber) = mode(Stage2_1Dimensions(:));     
        
        %�H�U�{���X�����ͥXpixel�M�X�{���ƪ��۹����x�}
        X = Stage2_1Dimensions(:);
        X = sort(X);                         %�ƧǢ�}�C
        d = diff([X;max(X)+1]);
        count = diff(find([1;d])) ;

        Y = [X(find(d)) count];              %�C�X�۹�������
        Y_Translate = Y';                    %��m��x�}
        
        %�Ҽ{�Y��pixel�ȥ��X�{�����p
        Stage2_pixel_count(1:256) = 0;          %�ŧi�@�Ű}�C�A�s��pixel�۹�X�{������
        for i = 1:256
            for j = 1:size(Y_Translate,2)
                if i == Y_Translate(1,j)
                    Stage2_pixel_count(1,i) = Y_Translate(2,j);
                end
            end
        end
        
         %����peak_point��ǽçL�P�ɱN�|overflow���I�O���U��
        leftpeakpoint_array(CountNumber) = Ori_peakpoint_array2(CountNumber) - 1;
        rightpeakpoint_array(CountNumber) = Ori_peakpoint_array2(CountNumber) + 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Overflow_point = zeros(dataround,512,512);
        
        for x=1:512
            for y=1:512
                if (Stage1_pixel_shift(x,y) == 1)   %��^unit8�ɷ|overflow
                    Overflow_point(CountNumber,x,y)=1;
                end
                if (Stage1_pixel_shift(x,y) == 256) %��^unit8�ɷ|overflow
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
        
        %��X�����
        Stage1_test = uint8(Stage1_pixel_shift)-1;
        imhist(Stage1_test);
        
        %��ĤG���q���̤j�öq
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
        
        %���òĤ@���q���p��[0,1,1,0,0,0,1]
        %�A�~���ø��
        add_hide = 1;
        for x=1:512
            for y=1:512
                if Stage1_pixel_shift(x,y) == (leftpeakpoint_array(CountNumber)-1)      %24
                    %�Ĥ@���q��peakpoint�٨S�ç��A�~����
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
                    %�Ĥ@���q��peakpoint�٨S�ç��A�~����
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
       
        %��X�����
        Stage1_test = uint8(Stage1_pixel_shift)-1;
        imhist(Stage1_test);
        %imshow(Stage1_test);
        %�p��PSNR
        ref = Stage1_test;
        A = imnoise(ref,'salt & pepper', 0.02);
        [peaksnr, snr] = psnr(A, ref);
        fprintf('\n The count is %d', CountNumber);
        fprintf('\n The Peak-SNR value is %0.4f', peaksnr);
        fprintf('\n The SNR value is %0.4f \n', snr);
        
        Ori_imagePixel_double = Stage1_pixel_shift;
        
        %�p��C�@�h���öq
        EveryDataHide(CountNumber) = max_hide + Stage2_maxhide;
        
        CountNumber = CountNumber +1;
    end
    
    %--------------------------------�ѱK�_��{���X--------------------------------
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
        peakpoint = int2str(peak_array);               %�x�}��r��
        hidedata_peakpoint = bin2dec(peakpoint);       %2�i����10�i��(double���A��peakpoint,�Y�Ouint8���n��@)
        Stage1_decoding_data(length(Stage1_decoding_data)-7:length(Stage1_decoding_data)) = [];          %�R��peakpoint�}�C���   
        decode = decode-8;
        
        
         %stage2�_��{���X
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
        
        %�N��L���^�h
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
        
        %��X�����
        %Stage1_test = uint8(Stage1_pixel_shift)-1;
        %imhist(Stage1_test);
        
        %----------------------------stage1
        
        %���y�ñK�Ϥ��A�ѱK�P�ɴ_��
        for x = 512:-1:1
            for y = 512:-1:1
                %�p�Ȩ��X�Ӭ�0
                if decode_pixel_shift(x,y)== hidedata_peakpoint
                    Stage1_decoding_data(decode) = 0;
                    decode = decode + 1;
                end
                %�p��+1���X�Ӭ�1
                if decode_pixel_shift(x,y)== hidedata_peakpoint + 1
                    decode_pixel_shift(x,y)= decode_pixel_shift(x,y) - 1;
                    Stage1_decoding_data(decode) = 1;
                    decode = decode + 1;
                end
            end
        end
        
        %�⪽��ϦV�����ʤ@�ӳ��^��(peak_point�Mzero_point����)
        for x=1:512
            for y=1:512
                if decode_pixel_shift(x,y) > hidedata_peakpoint && decode_pixel_shift(x,y) < Ori_zeropoint(index);
                    decode_pixel_shift(x,y) = decode_pixel_shift(x,y) - 1;
                end
            end
        end
        
        %�Y�@�}�l�̧C�I��pixel�A�X�{���Ƥ��O0�A�h�⥦�_��
        for x=1:512
            for y=1:512
                if Stage1_pixel_shift(x,y) == Ori_zeropoint(index)
                    Stage1_pixel_shift(x,y)= Stage1_renew(index);
                end
            end
        end
        
         %%%%%%%%%%%%%%%%
        %��ѱK�x�}��m�^��
        
        final_decode = [];
        for x=1:length(Stage1_decoding_data)
            final_decode(x) = Stage1_decoding_data(length(Stage1_decoding_data)+1-x);
        end
    
        %����
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