function site = RS_site(H, d, l, N)
    % 计算剪裁法反射面母线坐标
    % H为LED到目标面的距离
    % d为LED到首个反射点之间的距离
    % l为目标光斑半径
    % N为分割点数
    theta = zeros(N, 1);    
    theta(1) = asin(sqrt(1 / N));   % 初始角度
    L1 = d / cos(theta(1));  % LED到首点之间距离
    site = zeros(N, 2);      % 为反射面坐标分配内存
    site(1, :) = [d * tan(theta(1)), d];   % 反射面上首个坐标
    r = zeros(N, 1);
    r(1) = sqrt(l ^ 2 / N);  % 按照能量分配计算得到中心圆的半径
    for i = 2 : N
        theta(i)=asin(sqrt(1 / N + (sin(theta(i - 1))) ^ 2));   % 计算每一反射点对应角度
        r(i) = sqrt(l ^ 2 / N + r(i - 1) ^ 2);                  % 计算当前接收面环带外半径
        t = [r(i - 1), -H];
        a = norm(t);    % 求解LED到目标面落点之间的距离
        c = norm(site(i - 1, :) - t);   % 求解反射点到目标面落点之间的距离
        alpha = acos((L1 ^ 2 + c ^ 2 - a ^ 2) / (2 * L1 * c)) / 2;  % 求解入射光线与反射光线之间的夹角
        L2 = L1 * sin(theta(i) - theta(i - 1)) / sin(pi / 2 - alpha + theta(i - 1) - theta(i)); % 求解该段反射面长度
        % 计算反射点坐标
        t = -site(i - 1, :) / norm(site(i - 1, :)) * L2;
        tsite = site(i - 1, :)' + ...
            [cos(alpha + pi / 2), -sin(alpha + pi / 2); sin(alpha + pi / 2), cos(alpha + pi / 2)]...
            * t';
        site(i, :) = tsite';
        % 初始化下一段斜边长
        L1 = norm(site(i, :));
    end
    site = [0, d; site];
end
