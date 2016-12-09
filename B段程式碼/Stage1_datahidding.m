function Stage1_datahidding

     %�s���ܼ�
    rand_hiding_data = rand(1,10000);
    bound_hiding_data = round(rand_hiding_data);


    %-------------------------------------�Ĥ@���q-------------------------------------
    Ori_imagePixel_array = imread('lena.jpg');                  %��v���g�J�}�C
    Ori_imagePixel_double = double(Ori_imagePixel_array)+1;     %uint8 �ন double���A
    %imhist(Ori_imagePixel_array);                               %���ͪ����
    
    %��Ori_imagePixel_double�ର1���}�C
    Ori_1Dimensions = reshape(Ori_imagePixel_double,1,numel(Ori_imagePixel_array)); 
    
    % ��l�Ϫ��p��(double)   p.s �p�Ȭ��X�{�̦h����pixel
    Ori_peakpoint = mode(Ori_1Dimensions(:));
    %��l�Ϫ��p��(Binary)
    Ori_peakpoint_binary = dec2bin(Ori_peakpoint,8);
    
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
    Ori_zeropoint = 0;
    Ori_zero_pixel = 256;
    for i = Ori_peakpoint:length(Ori_pixel_count)
        if Ori_pixel_count(i)< Ori_zero_pixel
            Ori_zero_pixel = Ori_pixel_count(i);
            Ori_zeropoint = i;
        end
    end
    
    
    %------���ʪ���ϵM��}�l�ø��-----
    %�p�Gzeropoint���O0�h�]��0
    %�O���U�Ӥ���_��
    Stage1_renew = 0;
    if Ori_zero_pixel > 0
        Ori_pixel_count(Ori_zeropoint)=Stage1_renew;    %�̧C�I���O0�����w���@�ܼ�
        Ori_pixel_count(Ori_zeropoint)=0;               %�]�w��0
    end
    
    
    %�⪽��ϦV�k���ʤ@�ӳ��(peak_point�Mzero_point����)
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
                %�p�G�٦���ƨS�ç��A�ӥB��̤j�öqOri_pixel_count(Ori_peakpoint)�٭n�p�N�~����
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
    %��X�ø�Ƹ�Ƨ����������
    Stage1_test = uint8(Stage1_pixel_shift)-1;
    imhist(Stage1_test);
        
    %--------------------------------�Ĥ@���q�ѱK�_��{���X--------------------------------
    Stage1_decoding_data = [];
    decode = 1;
    %���y�ñK�Ϥ��A�ѱK�P�ɴ_��
    for x = 1:512
        for y = 1:512
            %�p�Ȩ��X�Ӭ�0
            if Stage1_pixel_shift(x,y)== Ori_peakpoint
                Stage1_decoding_data(decode) = 0;
                decode = decode + 1;
            end
            %�p��+1���X�Ӭ�1
            if Stage1_pixel_shift(x,y)== Ori_peakpoint + 1
                Stage1_pixel_shift(x,y)= Stage1_pixel_shift(x,y) - 1;
                Stage1_decoding_data(decode) = 1;
                decode = decode + 1;
            end
        end
    end
    
    %�⪽��ϦV�����ʤ@�ӳ��^��(peak_point�Mzero_point����)
    for x=1:512
        for y=1:512
            if Stage1_pixel_shift(x,y) > Ori_peakpoint && Stage1_pixel_shift(x,y) < Ori_zeropoint;
                Stage1_pixel_shift(x,y) = Stage1_pixel_shift(x,y) - 1;
            end
        end
    end
    
    %�Y�@�}�l�̧C�I��pixel�A�X�{���Ƥ��O0�A�h�⥦�_��
    for x=1:512
        for y=1:512
            if Stage1_pixel_shift(x,y) == Ori_zeropoint
                Stage1_pixel_shift(x,y)= Stage1_renew;
            end
        end
    end
    
    %��X�ѱK�᪽���
    Stage1_test = uint8(Stage1_pixel_shift)-1;
    imhist(Stage1_test);
        
end
    