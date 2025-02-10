clc;
clear;
close all;

%% 参数设置
lambda = 632.8e-9;       % 波长（He-Ne激光）
w0 = 1e-3;               % 束腰半径（1mm）
f = 0.3;                 % 透镜焦距（300mm）
k = 2*pi/lambda;         % 波数

% 空间网格参数
N = 200;                % 采样点数
L = 5e-3;                % 物面尺寸（5mm）
[x, y] = meshgrid(linspace(-L/2, L/2, N));
[phi, r] = cart2pol(x, y); % 极坐标

% 将数据移动到GPU上
x = gpuArray(x);
y = gpuArray(y);
phi = gpuArray(phi);
r = gpuArray(r);

%% 生成初始场（SLM平面）
alpha = 2;               % 拓扑电荷
phase = exp(1i*alpha*phi); % 螺旋相位
gauss = exp(-(x.^2 + y.^2)/w0^2); % 高斯分布
E_input = gauss .* phase; % 初始场

%% 计算焦平面场（傅里叶变换模拟2-f系统）
E_focal = fftshift(fft2(fftshift(E_input))); % 二维傅里叶变换
I_focal = abs(E_focal).^2;                   % 强度分布

% 将结果从GPU移回CPU
I_focal = gather(I_focal);

%% 绘制结果（对数刻度）
figure;
imagesc(log(I_focal + 1e-6)); % 对数缩放以显示暗区
colormap hot; 
axis equal; 
axis off;
title('α=2时的焦平面光斑（对数刻度）');

figure;
imagesc(I_focal);
axis equal; % 设置坐标轴纵横比相等
axis off;
title('α=2时的焦平面光斑');

resized_img = imresize(I_focal, 50);
figure;
imagesc(resized_img);
axis equal; % 设置坐标轴纵横比相等
axis off;
title('α=2时的焦平面光斑（放大10倍）');