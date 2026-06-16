%% 菲涅尔透镜母线数据生成（调用 my_fresnel_fun 函数）
clear; clc; close all;

%% 1. 参数设置
n = 1.5; f = 50; rho_M = 5; N = 5;
num = 10; % 每个环带的采样点数
save_path = 'D:\HuaweiMoveData\Users\dyl123456\Desktop\my_Fresnel.txt';

%% 2. 调用 my_fresnel_fun 函数生成母线数据
% 函数说明: y = my_fresnel_fun(n, N, r, f, num)
% n: 折射率
% N: 环带数量
% r: 最大半径 (rho_M)
% f: 焦距
% num: 每个环带的采样点数
y = my_fresnel_fun(n, N, rho_M, f, num);

%% 3. 转换为 XYZ 坐标格式
% y(:,1) 是半径 r, y(:,2) 是矢高 z
xyz_data = zeros(size(y, 1), 3);
xyz_data(:, 1) = 0;      % X 坐标（母线在 YZ 平面）
xyz_data(:, 2) = y(:, 1); % Y 坐标（半径）
xyz_data(:, 3) = y(:, 2); % Z 坐标（矢高）

%% 4. 去除重复点
unique_data = [];
for i = 1:size(xyz_data, 1)
    if i == 1
        unique_data = [unique_data; xyz_data(i, :)];
    else
        % 检查是否与上一个点相同
        if ~(unique_data(end, 2) == xyz_data(i, 2) && unique_data(end, 3) == xyz_data(i, 3))
            unique_data = [unique_data; xyz_data(i, :)];
        end
    end
end
xyz_data = unique_data;

%% 5. 检查所有相邻点间距
fprintf('========================================\n');
fprintf('点间距检查:\n');
fprintf('========================================\n');

min_dist = inf;
bad_pairs = [];

for i = 2:size(xyz_data, 1)
    dr = xyz_data(i,2) - xyz_data(i-1,2);
    dz = xyz_data(i,3) - xyz_data(i-1,3);
    dist = sqrt(dr^2 + dz^2);
    
    fprintf('点%d → 点%d: 间距 = %.5f mm\n', i-1, i, dist);
    
    if dist < min_dist
        min_dist = dist;
    end
    if dist < 0.001
        bad_pairs = [bad_pairs; i-1, i];
    end
end

fprintf('========================================\n');
fprintf('最小点间距: %.6f mm\n', min_dist);

if min_dist < 0.01
    fprintf('⚠ 警告: 存在过近的点！\n');
else
    fprintf('✓ 所有点间距正常\n');
end
fprintf('========================================\n');

%% 6. 保存数据到文件
fid = fopen(save_path, 'w');
for i = 1:size(xyz_data, 1)
    fprintf(fid, '%.6f\t%.6f\t%.6f\n', xyz_data(i, 1), xyz_data(i, 2), xyz_data(i, 3));
end
fclose(fid);

%% 7. 可视化
figure('Position', [100, 100, 1200, 500]);

% 整体图
subplot(1,2,1);
plot(xyz_data(:,2), xyz_data(:,3), 'b.-', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('半径 (mm)');
ylabel('矢高 (mm)');
title('菲涅尔透镜母线');
grid on;
xlim([0, rho_M]);

% 局部放大
subplot(1,2,2);
plot(xyz_data(:,2), xyz_data(:,3), 'b.-', 'LineWidth', 1.5, 'MarkerSize', 6);
xlabel('半径 (mm)');
ylabel('矢高 (mm)');
title('局部放大（半径0-2mm）');
grid on;
xlim([0, 2]);
ylim([-0.005, max(xyz_data(:,3))*1.1]);

fprintf('\n✓ 文件已保存: %s\n', save_path);
fprintf('✓ 总数据点数: %d\n', size(xyz_data, 1));