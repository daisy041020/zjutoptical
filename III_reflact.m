%% 完全匹配光学仿真参数版本
% 匹配：LED直径1mm朗伯 + 屏距500mm + 屏边长250mm + 绕Z轴旋转
clear; clc; close all;

% ========== 严格匹配你仿真的固定参数 ==========
L        = 500;        % 接收屏距离原点 500mm
R_spot   = 125;        % 屏幕半边长 250/2=125mm
theta_max= pi/3;       % LED最大出射角 60° 适配朗伯
N        = 300;

% 反光碗结构约束（工程正常尺寸，不细长）
Max_Rho  = 30;         % 反光碗最大口径半径(mm)
Max_Depth= 25;         % 反光碗Z向深度(mm)
Z0       = 1.5;        % 母线起点靠近LED原点，适配1mm发光面
% ==============================================

theta = linspace(0, theta_max, N);
% 适配远场匀光映射
r = R_spot * sin(theta);

rho = zeros(1,N);
z   = zeros(1,N);
rho(1) = 0;
z(1)   = Z0;

for i = 2:N
    d_theta = theta(i) - theta(i-1);
    alpha = atan2(r(i-1), L - z(i-1));
    beta  = theta(i-1);
    if abs(beta) < 1e-6
        beta = 1e-6;
    end
    gamma = (alpha + beta)/2;
    
    ds = 0.25;
    drho = ds * sin(gamma);
    dz   = ds * cos(gamma);
    
    rho(i) = rho(i-1) + drho;
    z(i)   = z(i-1) + dz;
    
    % 截断，防止无限拉长
    if rho(i)>=Max_Rho || (z(i)-Z0)>=Max_Depth
        rho = rho(1:i);
        z   = z(1:i);
        break;
    end
end

% 标准直角坐标：XZ平面母线 Y=0  绕Z轴旋转
X = rho;
Y = zeros(size(X));
Z = z;
xyz = [X', Y', Z'];

% 保存到指定路径
save_path = "D:\HuaweiMoveData\Users\dyl123456\Desktop\reflector_profile.txt";
writematrix(xyz, save_path, 'Delimiter',' ');

fprintf('已完全匹配光学仿真参数\n');
fprintf('屏距500mm, 屏幕半边长125mm\n');
fprintf('反光碗最大口径: %.2f mm\n',max(X));
fprintf('碗深度: %.2f mm\n',max(Z)-Z0);
fprintf('输出格式：X Y=0 Z  XZ平面母线 绕Z轴旋转\n');

% 绘图
figure;
plot(X,Z,'LineWidth',2);
xlabel('X 径向(mm)');
ylabel('Z 光轴/出光方向(mm)');
title('适配光学仿真 XZ母线 → 绕Z轴旋转');
grid on; axis equal;

saveas(gcf,"D:\HuaweiMoveData\Users\dyl123456\Desktop\reflector_profile.png");