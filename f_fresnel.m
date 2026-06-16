%% 初始化
clear
clc

%% 参数设定
r = 20;                     % 透镜半径
f = 200 .* [5; 4; 3; 2; 1]; % 确定焦距
N = length(f);              % 确定透镜环数
n = 1.4935;                 % 透镜材料折射率,材料PMMA
num = 100;                  % 每环内点的总数

%% 计算光学母线
y = split_section(r, f, N, n, num);
y(:, 2) = y(:, 2) + 1;      % 将母线上移
plot(y(:, 1), y(:, 2));
y = [y, zeros(N * num, 1)]; % 补上z轴
axis equal;
grid on;

% 将所有母线数据保存到一个txt文件
output_file = 'D:\HuaweiMoveData\Users\dyl123456\Desktop\my_Fresnel.txt';
save(output_file, 'y', '-ascii');
fprintf('母线数据已保存到: %s\n', output_file);

function site = split_section(r, f, N, n, num)
    % 计算菲涅尔环带坐标
    R = f .* (n - 1);   % 计算曲率半径
    % 计算圆心坐标
    ce_site = zeros(2, N);
    ce_site(2, :) = -sqrt(R .^ 2 - r ^ 2) .* (abs(R) ./ R);    % y轴值
    site = zeros(2, N * num);   % 为坐标分配内存
    for i = 1 : N
        theta1 = asin(r * sqrt((i - 1) / N) / R(i));
        theta2 = asin(r * sqrt(i / N) / R(i));
        if (theta1 >= 0)
            t = ce_site(2, i) + R(i) .* cos(theta2);
        else
            t = ce_site(2, i) + R(i) .* cos(theta1);
        end
        range_t = linspace(theta1, theta2, num);
        site(1, 1 + (i - 1) * num : i * num) = ce_site(1, i) + R(i) * sin(range_t);         % 计算x轴坐标
        site(2, 1 + (i - 1) * num : i * num) = ce_site(2, i) + R(i) * cos(range_t) - t;     % 计算y轴坐标
    end
    site = site';
end
