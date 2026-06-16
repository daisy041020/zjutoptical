%% 初始化
clc
clear

%% 参数设定
H = 3000;   % 目标面距离
RN = 500;  % 目标光斑半径
N = 10000;  % 曲面细分
d = 20;     % 初始定点距离

%% 坐标运算
y = RS_site(H, d, RN, N);
y = real(y);    % 略去虚部

%% 绘制图像
plot(y(:, 1), y(:, 2));
axis equal;
grid on;
y = [y, zeros(length(y), 1)];

%% 保存抛物线数据
save('d:\HuaweiMoveData\Users\dyl123456\Desktop\裁剪法反射面数据.txt', 'y', '-ascii');
