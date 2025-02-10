clc;
clear;
close all;

%% 参数设置
lambda = 632.8e-9;       % 波长（He - Ne激光）
w0 = 1e-3;               % 束腰半径（1mm）
f = 0.3;                 % 透镜焦距（300mm）
k = 2*pi/lambda;         % 波数

% 空间网格参数
N = 50;                % 采样点数
L = 5e-3;                % 物面尺寸（5mm）
[x, y] = meshgrid(linspace(-L/2, L/2, N));
[phi, r] = cart2pol(x, y); % 极坐标

% 定义不同的alpha值
alphas = [1.5, 1.8, 2.0, 2.2, 2.5, 2.8];

% 创建两个figure对象
fig_log = figure;
fig_resized = figure;

% 循环遍历不同的alpha值
for i = 1:length(alphas)
    alpha = alphas(i);
    
    %% 生成初始场（SLM平面）
    phase = exp(1i*alpha*phi); % 螺旋相位
    gauss = exp(-(x.^2 + y.^2)/w0^2); % 高斯分布
    E_input = gauss .* phase; % 初始场

    %% 计算焦平面场（傅里叶变换模拟2-f系统）
    E_focal = fftshift(fft2(fftshift(E_input))); % 二维傅里叶变换
    I_focal = abs(E_focal).^2;                   % 强度分布

    % 对对数刻度的图像数据进行放大，这里假设放大3倍
    magnify_factor = 3;
    magnified_log_I_focal = imresize(log(I_focal + 1e-6), magnify_factor);

    %% 绘制对数刻度的焦平面光斑
    figure(1); % 切换到第一个窗口
    subplot(2, 3, i); % 2行3列的子图布局
    imagesc(magnified_log_I_focal); % 显示放大后的对数刻度图像
    colormap hot; 
    axis equal; 
    axis off;
    title(['α = ', num2str(alpha), '时的焦平面光斑（对数刻度，放大', num2str(magnify_factor), '倍）']);

    %% 绘制放大10倍的焦平面光斑
    resized_img = imresize(I_focal, 10);
    figure(2); % 切换到第二个窗口
    subplot(2, 3, i); % 2行3列的子图布局
    imagesc(resized_img);
    axis equal; % 设置坐标轴纵横比相等
    axis off;
    title(['α = ', num2str(alpha), '时的焦平面光斑（放大10倍）']);
end
