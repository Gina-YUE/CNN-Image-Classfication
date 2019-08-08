% ========================================================================
% Image Classification using Bag of Words and Spatial Pyramid BoW
% Created by Piji Li (peegeelee@gmail.com)  
% Blog: http://www.zhizhihu.com
% QQ: 379115886
% IRLab. : http://ir.sdu.edu.cn     
% Shandong University,Jinan,China
% 10/24/2011
function draw_cm(mat,tick,num_class)
%%
%  ���ߣ� ا��  zhizhihu.com
%  ������mat-����tick-Ҫ������������ʾ��label����������{'label_1','label_2'...}
%
%%
imagesc(1:num_class,1:num_class,mat);            %# ���ɫͼ
colormap(flipud(gray));  %# ת�ɻҶ�ͼ����˸�value�ǽ���ɫ�ģ���value�ǽ��׵�

textStrings = num2str(mat(:),'%0.2f');  
textStrings = strtrim(cellstr(textStrings)); 
[x,y] = meshgrid(1:num_class); 
hStrings = text(x(:),y(:),textStrings(:), 'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim')); 
textColors = repmat(mat(:) > midValue,1,3); 
%�ı�test����ɫ���ں�cell����ʾ��ɫ
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors

set(gca,'xticklabel',tick,'XAxisLocation','top');
set(gca, 'XTick', 1:num_class, 'YTick', 1:num_class); % to handle a bug
set(gca,'yticklabel',tick);

%% rotate x label
rotateXLabels(gca, 315 ); % ����ǰ�����ᣨ��gca�����õ�����ת315��
% NARGINCHK(gca, 315)



