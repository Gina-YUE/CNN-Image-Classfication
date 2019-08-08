function sift_arr = sp_find_sift_grid(I, grid_x, grid_y, patch_size, sigma_edge)

% sigma_edge ����̬�ֲ��ı�׼�ֵԽ��ͼ��Խģ����ƽ����

% parameters
num_angles = 8;  % �ܹ�8����
num_bins = 4; 
num_samples = num_bins * num_bins;   % 1�����黮��Ϊ4*4����
alpha = 9;  % �Ƕ�˥������(����������)

if nargin < 5  % nargin�������ж���������ĸ�������matlab�ı�����
    sigma_edge = 1;
end

angle_step = 2 * pi / num_angles;   % ÿ45��һ����
angles = 0:angle_step:2*pi;
angles(num_angles+1) = []; % bin centers  % �������һ��Ԫ��360�㣬ʹangles�Ĵ�СΪ1*8��������1*9

[hgt wid] = size(I);
num_patches = numel(grid_x);  % number of   %576��patch

sift_arr = zeros(num_patches, num_samples * num_angles); %4*4*8=128  % 576*128άsift������������ʼ��Ϊ0

[G_X,G_Y]=gen_dgauss(sigma_edge);  % ����һ��5*5�ĸ�˹ģ�壨ȡֵ[-1,1]���������GX,GY���ݶ�G_X��G_Y

I_X = filter2(G_X, I, 'same'); % vertical edges   % �������G_X��ͼ��I�����˲����ӣ�ע��ͼ��I�����������ֵ���ǹ�һ������ֵ[0,1]��
I_Y = filter2(G_Y, I, 'same'); % horizontal edges  % ͬ�ϣ���Ϊ�������˲����ӣ����ʱͼ���п���ȡֵΪ[-1,1]
I_mag = sqrt(I_X.^2 + I_Y.^2); % gradient magnitude  % 200*200��ͼ�񣬼���ͼ���ݶȵķ�ֵ

I_theta = atan2(I_Y,I_X);   % 200*200��ͼ��ͼ���ݶȵķ���

I_theta(find(isnan(I_theta))) = 0; % necessary???  % ��0����Ƿ��Ľ������Ϊ��Щ�ݶȷ���Ϊinf

% make default grid of samples (centered at zero, width 2)  % ȷ��ͼ��������Ĭ�ϣ���ʼ����λ��
interval = 2/num_bins:2/num_bins:2;
interval = interval - (1/num_bins + 1);  % [-0.75,-0.25,0.25,0.75]
[sample_x sample_y] = meshgrid(interval, interval);
sample_x = reshape(sample_x, [1 num_samples]); % change to array 1:16
sample_y = reshape(sample_y, [1 num_samples]);

% make orientation images   % ȷ��ͼ��(200*200)��ÿһ�����ص��ݶȵ�8������
I_orientation = zeros(hgt, wid, num_angles);  % z��Ϊ8������
% for each histogram angle
for a=1:num_angles    
    % compute each orientation channel
    cos(I_theta - angles(a));
    tmp = cos(I_theta - angles(a)).^alpha;
    tmp = tmp .* (tmp > 0);
    
    % weight by magnitude
    I_orientation(:,:,a) = tmp .* I_mag;
end

% for all patches
for i=1:num_patches
    % ȡ��i��patch������
    r = patch_size/2;  % r=8
    cx = grid_x(i) + r - 0.5;  
    cy = grid_y(i) + r - 0.5;

    % find coordinates of sample points (bin centers) % ����16�������㣨16��bin���ģ�����
    sample_x_t = sample_x * r + cx;
    sample_y_t = sample_y * r + cy;
    sample_res = sample_y_t(2) - sample_y_t(1);  % ��������
    
    % find window of pixels that contributes to this descriptor  % ��������½���
    x_lo = grid_x(i);
    x_hi = grid_x(i) + patch_size - 1;
    y_lo = grid_y(i);
    y_hi = grid_y(i) + patch_size - 1;
    
    % find coordinates of pixels    % ������������
    [sample_px, sample_py] = meshgrid(x_lo:x_hi,y_lo:y_hi);
    num_pix = numel(sample_px);  % 256���أ���Ϊ�����С��16*16��
    sample_px = reshape(sample_px, [num_pix 1]);  % �ع�һ��256��1�е�����
    sample_py = reshape(sample_py, [num_pix 1]);  % �ع�һ��256��1�е�����
        
    % find (horiz, vert) distance between each pixel and each grid sample
    % һ������256�����ص�16�������㣨16��bin���ģ��ľ���
    dist_px = abs(repmat(sample_px, [1 num_samples]) - repmat(sample_x_t, [num_pix 1]));  % 256*16
    dist_py = abs(repmat(sample_py, [1 num_samples]) - repmat(sample_y_t, [num_pix 1]));  % 256*16
    
    % find weight of contribution of each pixel to each bin  % ÿ�����ض�16�������㣨16��bin���ģ����׵�Ȩ��
    weights_x = dist_px/sample_res;  
    weights_x = (1 - weights_x) .* (weights_x <= 1);
    weights_y = dist_py/sample_res;
    weights_y = (1 - weights_y) .* (weights_y <= 1);
    weights = weights_x .* weights_y;  % ��Ȩ��Ϊx��y����Ȩ�صĳ˻�
%     % make sure that the weights for each pixel sum to one?
%     tmp = sum(weights,2);
%     tmp = tmp + (tmp == 0);
%     weights = weights ./ repmat(tmp, [1 num_samples]);
        
    % make sift descriptor  % ����sift����
    curr_sift = zeros(num_angles, num_samples);  % һ��patch��С��8*16��8������16�������㣨16��bin���ģ�
    for a = 1:num_angles 
        tmp = reshape(I_orientation(y_lo:y_hi,x_lo:x_hi,a),[num_pix 1]);  % һ������16*16����256�����ص�ĵ�a������      
        tmp = repmat(tmp, [1 num_samples]); % ��չ��16��bin����
        curr_sift(a,:) = sum(tmp .* weights); % ��a������Ҫ���Ը÷����Ȩ��weights
    end
    sift_arr(i,:) = reshape(curr_sift, [1 num_samples * num_angles]);  % 1*128��ѭ��576�Σ�
        
%     % visualization
%     if sigma_edge >= 3
%         subplot(1,2,1);
%         rescale_and_imshow(I(y_lo:y_hi,x_lo:x_hi) .* reshape(sum(weights,2), [y_hi-y_lo+1,x_hi-x_lo+1]));
%         subplot(1,2,2);
%         rescale_and_imshow(curr_sift);
%         pause;
%     end
end

function G=gen_gauss(sigma)  % ����һ��5*5�Ķ�ά��˹�˲�������˹ģ�������ĶԳƵģ�

if all(size(sigma)==[1, 1])
    % isotropic gaussian   % ����ͬ�Ը�˹
	f_wid = 4 * ceil(sigma) + 1;  % 5
    G = fspecial('gaussian', f_wid, sigma);  % ����һ��5*5���� ��=0.8
%	G = normpdf(-f_wid:f_wid,0,sigma);
%	G = G' * G;
else
    % anisotropic gaussian  % �������Ը�˹���ᡢ������Ħ�ȡֵ��ͬ��
    f_wid_x = 2 * ceil(sigma(1)) + 1;  
    f_wid_y = 2 * ceil(sigma(2)) + 1;
    G_x = normpdf(-f_wid_x:f_wid_x,0,sigma(1));
    G_y = normpdf(-f_wid_y:f_wid_y,0,sigma(2));
    G = G_y' * G_x;
end

function [GX,GY]=gen_dgauss(sigma)  % �õ�delta��˹����

% laplacian of size sigma
%f_wid = 4 * floor(sigma);
%G = normpdf(-f_wid:f_wid,0,sigma);
%G = G' * G;
G = gen_gauss(sigma);   % ����һ����ά��˹�˲�����5*5�ĸ�˹ģ�壩

[GX,GY] = gradient(G);  % ����G��X��Y������ݶ�GX��GY���õ�delta��˹����

GX = GX * 2 ./ sum(sum(abs(GX))); % colum sum and all sum
GY = GY * 2 ./ sum(sum(abs(GY)));

