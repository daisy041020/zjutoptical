clc
clear

d = 6;  %LED直径
D = 2000;   %目标面直径
H = 3000;   %LED光源与目标面之间的距离
F = [-d / 2, 0];    %抛物线焦点
P = [d / 2, 0];     %抛物线上一点
a = pi - atan(H / D * 2);   %抛物线开口朝向
%计算限制角度
phi_1 = atan(H / D * 2) + pi;
phi_2 = 2 * atan(H / D * 2) + pi;
N = 1000;   %线性插值点数量

y = myParabola(F, P, phi_1, phi_2, a, N);   %调用函数计算得到抛物线
%绘制抛物线
plot(y(:, 1), y(:, 2));
axis equal;
y = [y, zeros(length(y), 1)];	%对z轴参数进行补0处理
%保存抛物线数据到桌面
save('D:\HuaweiMoveData\Users\dyl123456\Desktop\CPC.txt', 'y', '-ascii');
disp('数据已保存到: D:\HuaweiMoveData\Users\dyl123456\Desktop\CPC.txt');

function p = myParabola(F, P, phi_1, phi_2, a, N)
    % 计算抛物流线函数
    phi = linspace(phi_1, phi_2, N)';   %对限制角度进行线性插值
    % 利用抛物流线参数化表达式进行计算
    p = (sqrt((P - F) * (P - F)') - (P - F) * [cos(a), sin(a)]') ./ (1 - cos(phi));
    p = p .* [cos(phi + a), sin(phi + a)] + F;
end
