function y = mycpc_lighting(d, alpha_max, num, filename)
% CPC配光系统 - 输出抛物线坐标（保留光源半径）
% 输入参数：
%   d         - 光源直径（mm）
%   alpha_max - 最大出射角度（弧度）
%   num       - 离散点数量
%   filename  - 输出文件名

if nargin < 4
    filename = 'cpc_lighting.txt';
end

% 生成CPC曲线（右半部分）
f = [-d/2, 0];                 
p = [d/2, 0];                  
alpha = alpha_max + pi/2;      
phi1 = 2*pi - alpha;           
phi2 = phi1 + pi/2 - alpha_max; 
y = zeros(num, 2);             
phi = linspace(phi1, phi2, num);

for i = 1:num
    y(i,:) = (sqrt(dot((p-f),(p-f))) - dot((p-f),[cos(alpha),sin(alpha)])) / ...
             (1 - cos(phi(i))) * [cos(alpha+phi(i)), sin(alpha+phi(i))] + f;
end

% 平移到合适位置，保留光源半径
y(:,2) = y(:,2) - min(y(:,2));  % Z方向底部归零
% X方向：保持光源边缘在 x = d/2 处
y(:,1) = y(:,1) + d/2;

% 只保留 x >= d/2 的点（反射面从光源边缘开始）
y = y(y(:,1) >= d/2, :);
y = unique(y, 'rows', 'stable');

% 添加Z坐标（Z=0）
points_3d = [y, zeros(size(y,1), 1)];

% 保存文件
save(filename, 'points_3d', '-ascii');

fprintf('已保存 %d 个点至：%s\n', size(points_3d,1), filename);
fprintf('光源半径: %.2f mm (x = 0 ~ %.2f mm 为空腔)\n', d/2, d/2);
fprintf('反射面起始点 x = %.2f mm (光源边缘)\n', min(y(:,1)));
fprintf('反射面开口半径: %.2f mm\n', max(y(:,1)));
fprintf('反射面高度: %.2f mm\n', max(y(:,2)));
fprintf('\n数据预览（前5行，X Y Z）：\n');
disp(points_3d(1:min(5, size(points_3d,1)), :));
end