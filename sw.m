%% 抛物线绘图：V在负x轴，F在原点，匹配黑板示意
clear; clc; close all;

% -------------------- 1. 定义抛物线参数 --------------------
% 抛物线开口向右，顶点V在负x轴，焦点F在原点(0,0)
% 焦距 p = |VF|，即顶点到焦点的距离
p = 1;          % 焦距，控制开口宽窄，p=1时顶点V在(-1, 0)
vx = -p;        % 顶点V的x坐标：-p（在负横坐标上）
vy = 0;         % 顶点V的y坐标

% 抛物线标准方程（顶点在(vx,0)，焦点在(0,0)，开口向右）
% 方程形式：x = (1/(4p))*y^2 + vx
y = linspace(-3, 3, 500);   % y的取值范围
x = (1/(4*p)) * y.^2 + vx;  % 抛物线方程

% -------------------- 添加旋转矩阵 --------------------
theta = 30 * pi/180;  % 旋转角度30°转换为弧度
R = [cos(theta), -sin(theta); sin(theta), cos(theta)];  % 2D旋转矩阵

% 对抛物线上的所有点进行旋转变换
original_points = [x; y];  % 原始坐标点矩阵
rotated_points = R * original_points;  % 应用旋转矩阵
x_rotated = rotated_points(1, :);      % 旋转后的x坐标
y_rotated = rotated_points(2, :);      % 旋转后的y坐标

% 对顶点和焦点也进行旋转
V_original = [vx; vy];
F_original = [0; 0];
V = (R * V_original)';  % 旋转后的顶点坐标
F = (R * F_original)';  % 旋转后的焦点坐标（原点旋转后仍为原点）

% 顶点和焦点坐标
V = [vx, vy];   % 顶点V（负x轴上）
F = [0, 0];     % 焦点F（原点）

% -------------------- 2. 绘图基础设置 --------------------
figure('Color','w'); hold on; axis equal;
grid off; box off;
set(gca, 'XAxisLocation', 'origin', 'YAxisLocation', 'origin'); % 坐标轴交于原点

% 画坐标轴（带箭头）
quiver(0, 0, 4, 0, 0, 'k', 'LineWidth',1.5);       % x1轴
quiver(0, 0, 0, 3, 0, 'k', 'LineWidth',1.5);       % x2轴
text(4.1, -0.2, 'x_1', 'FontSize',16);
text(0.1, 3.1, 'x_2', 'FontSize',16);

% 画抛物线（使用旋转后的坐标）
plot(x_rotated, y_rotated, 'k', 'LineWidth',2);

% 标记顶点V和焦点F
plot(V(1), V(2), 'ko', 'MarkerFaceColor','k');
text(V(1)-0.3, V(2)-0.15, 'V', 'FontSize',16);

plot(F(1), F(2), 'ko', 'MarkerFaceColor','k');
text(F(1)+0.1, F(2)-0.15, 'F', 'FontSize',16);

% -------------------- 3. 取抛物线上一点P并标注所有量 --------------------
py_original = 1.5;                           % P点的原始y坐标（可调整）
px_original = (1/(4*p)) * py_original^2 + vx; % 由抛物线方程求P点x坐标
P_original = [px_original; py_original];

% 对P点进行旋转
P_rotated = R * P_original;
P = P_rotated';  % 旋转后的P点坐标

% 标记P点
plot(P(1), P(2), 'ko', 'MarkerFaceColor','k');
text(P(1)-0.3, P(2)+0.1, 'P', 'FontSize',16);

% 画线段FP（长度为t）
plot([F(1), P(1)], [F(2), P(2)], 'k--', 'LineWidth',1.2);
t = norm(P - F);                    % FP的长度
mid_t = (F + P)/2;
text(mid_t(1)-0.2, mid_t(2), 't', 'FontSize',14);

% 画水平线段d（F到P的水平投影，沿x1轴）
plot([F(1), P(1)], [F(2), F(2)], 'k:', 'LineWidth',1.2);
d = P(1) - F(1);
mid_d = (F + [P(1), F(2)])/2;
text(mid_d(1), mid_d(2)-0.2, 'd', 'FontSize',14);

% 画竖直线段s（P到水平投影的垂直距离，沿x2轴）
plot([P(1), P(1)], [F(2), P(2)], 'k:', 'LineWidth',1.2);
s = P(2) - F(2);
mid_s = ([P(1), F(2)] + P)/2;
text(mid_s(1)+0.1, mid_s(2), 's', 'FontSize',14);

% 标注角度φ（FP与x1轴正方向的夹角）
phi = atan2(P(2)-F(2), P(1)-F(1));  % 计算角度（弧度）
r = 0.3;                             % 圆弧半径
arc_theta = linspace(0, phi, 50);    % 角度范围
arc_x = F(1) + r*cos(arc_theta);
arc_y = F(2) + r*sin(arc_theta);
plot(arc_x, arc_y, 'k-', 'LineWidth',1);
text(F(1)+0.4, 0.3, '\phi', 'FontSize',16);

% -------------------- 添加旋转角度标注 --------------------
rotation_angle = 30;  % 旋转角度（度）
text(-2.5, -2.5, ['旋转角度: ' num2str(rotation_angle) '^\circ'], 'FontSize',14);

% -------------------- 4. 标注黑板上的公式 --------------------
text(2.5, 2.5, '$s = -t\cos\phi$', 'Interpreter','latex', 'FontSize',20);

% -------------------- 5. 调整坐标轴范围 --------------------
xlim([-4, 4]);   % 扩大范围以适应旋转后的图形
ylim([-4, 4]);

hold off;