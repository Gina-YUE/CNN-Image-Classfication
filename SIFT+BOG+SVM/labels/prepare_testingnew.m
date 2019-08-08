clc; clear;
% load image_names;
% load labels;
% load testset;
% load trainset;
clc; clear;
load image_names;
load labels;
load testset;
load trainset;
%֮ǰ��2236��  trian
 preimagelength = 2236;
 maindir = 'E:\CV��ҵ\MyWorkSpace\images\testing';
 subdir =  dir( maindir );   % ��ȷ�����ļ���
 disp(length(subdir))
for i = 1 : length( subdir )
    if( isequal( subdir( i ).name, '.' ) || ...
        isequal( subdir( i ).name, '..' ) || ...
        ~subdir( i ).isdir )   % �������Ŀ¼����
        continue;
    end
    %��i = 3��ʼ
    subdirpath = fullfile( maindir, subdir( i ).name, '*.jpg' );
    images = dir( subdirpath );   % ��������ļ������Һ�׺Ϊjpg���ļ�
    disp(i)
    disp(subdirpath)
    disp(length(images))
    % ����ÿ��ͼƬ
    for j = 1 : length( images )
        l = preimagelength + j;
        imagepath = fullfile( subdir( i ).name, images( j ).name );
        image_names{l}=['testing\',imagepath];
        labels(l,1)=i-2;
        trainset(l,1)=0;
        testset(l,1)=1;  
               
    end
    preimagelength = preimagelength +length(images)
end
 

%һ��4433��   ͼƬ    2236 train 2197 test

save('image_names','image_names');
save('labels','labels');
trainset=logical(trainset);
testset=logical(testset);
save('trainset','trainset');
save('testset','testset');







