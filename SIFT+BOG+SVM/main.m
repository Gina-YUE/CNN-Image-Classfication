%% Script to perform BOW-based image classification demo
% ========================================================================
% Image Classification using Bag of Words and Spatial Pyramid BoW
% Created by Piji Li (pagelee.sd@gmail.com)  
% Blog: ا�� http://www.zhizhihu.com
% QQ: 379115886
% IRLab. : http://ir.sdu.edu.cn     
% Shandong University,Jinan,China
% 10/24/2011
%% initialize the settings
disp('*********** start *********')
clc;
ini;
detect_opts=[];descriptor_opts=[];dictionary_opts=[];assignment_opts=[];ada_opts=[];

%% Descriptors
descriptor_opts.type='sift';                                                     % name descripto
descriptor_opts.name=['des',descriptor_opts.type]; % output name (combines detector and descrtiptor name)
descriptor_opts.patchSize=16;                                                   % normalized patch size
descriptor_opts.gridSpacing=8;   % ÿ������Ĳ���
descriptor_opts.maxImageSize=1000;
GenerateSiftDescriptors(pg_opts,descriptor_opts);  % ����ÿ��ͼƬ��576*128ά��sift����������300��ͼƬ

%% Create the texton dictionary
dictionary_opts.dictionarySize = 500;
dictionary_opts.name='sift_features';
dictionary_opts.type='sift_dictionary';
CalculateDictionary(pg_opts, dictionary_opts);  % K-Means��240��ѵ������Ƭ���ܹ�240*576*128�н��о��࣬�õ�300*128����������

%% assignment
assignment_opts.type='1nn';                                 % name of assignment method  % 1NN�㷨
assignment_opts.descriptor_name=descriptor_opts.name;       % name of descriptor (input)
assignment_opts.dictionary_name=dictionary_opts.name;       % name of dictionary
assignment_opts.name=['BOW_',descriptor_opts.type];         % name of assignment output
assignment_opts.dictionary_type=dictionary_opts.type;
assignment_opts.featuretype=dictionary_opts.name;
assignment_opts.texton_name='texton_ind';
do_assignment(pg_opts,assignment_opts);  % ����BOW��300*360����ÿһ�д���һ��ͼ���Ƶ�ʷֲ�ֱ��ͼ����һ����ÿһ�к�Ϊ1��
% �ôʰ�ģ��BOW�洢��BOW_sift.mat�ļ��£���Ҫ��load����BOW_sift.mat���ſ�����Workspace��ʾ�ʴ�ģ��BOW

%% CompilePyramid
% �������������һ��ͳ�ƴ�Ƶ�ķ�������������ʴ�ģ�ͣ���Ϊ3�㣬�ֱ����Σ�ÿ�ν�ͼƬ��Ϊ4*4,2*2,1*1������21��
% ��ÿһ�����300���������ĵľ��࣬�ʵõ��Ĵʴ�pyramid_all��СΪ��21*300��* 360 �飬�ܼ�6300��*360
% �ôʴ�ģ�ʹ洢��spatial_pyramid.mat�ļ��£���Ҫ��load����spatial_pyramid.mat���ſ�����Workspace��ʾpyramid_all
pyramid_opts.name='spatial_pyramid';
pyramid_opts.dictionarySize=dictionary_opts.dictionarySize;
pyramid_opts.pyramidLevels=3;  % ����������
pyramid_opts.texton_name=assignment_opts.texton_name;
CompilePyramid(pg_opts,pyramid_opts); % ��������һ���ʴ�ģ�ͣ�6300*360����ÿһ�д���һ��ͼ���Ƶ�ʷֲ�ֱ��ͼ����һ����ÿһ�к�Ϊ1��

%% Classification
do_classification_rbf_svm  % ����BOW+������˺���rbf��SVM���з���

%% histogram intersection kernel
do_classification_inter_svm  % ����BOW+ֱ��ͼ����ˣ����߶���ģ�SVM���з���

%% pyramid bow rbf
do_p_classification__rbf_svm  % ����pyramid_all+������˺���rbf��SVM���з���

%% pyramid bow histogram intersection kernel
do_p_classification__inter_svm  % ����pyramid_all+ֱ��ͼ����ˣ����߶���ģ�SVM���з��� % ��߾��� ��90.83%

%%
do_classification_liner_svm   % ����BOW+���Ժ˺�����SVM���з���

%%
do_p_classification__liner_svm   % ����pyramid_all+���Ժ˺�����SVM���з���

%
show_results_script  % ����߾��Ȼ�ͼ���������󣩣����ſ���

%% AdaBoost  
% ����AdaBoost���з���
ada_opts.T = 100;
ada_opts.weaklearner  = 0;
ada_opts.epsi = 0.2;
ada_opts.lambda = 1e-3;
ada_opts.max_ite = 3000;
ada_opts.bow = assignment_opts.name;
ada_opts.pbow = pyramid_opts.name;
% do_classification_adaboost_bow(pg_opts,ada_opts);
% do_classification_adaboost_pyramid_bow(pg_opts,ada_opts);

