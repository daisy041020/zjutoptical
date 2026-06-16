import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# ==============================================
# 1. 完全匹配目标图的核心参数（关键修正！）
# ==============================================
# 5x5 控制点网格（严格对齐目标图的空间位置，X/Y/Z坐标完全复刻）
# 目标图X轴范围：-2 ~ 2，Y轴范围：0 ~ 4，Z轴范围：-0.5 ~ 3
P = np.array([
    # i=0 (X=2, 图中右上角区域)
    [[2, 0, 1.0],  [2, 1, 1.3],  [2, 2, 2.1],  [2, 3, 2.7],  [2, 4, 2.6]],
    # i=1 (X=1)
    [[1, 0, 0.8],  [1, 1, 1.1],  [1, 2, 2.0],  [1, 3, 2.5],  [1, 4, 2.8]],
    # i=2 (X=0, 中心区域)
    [[0, 0, 0.2],  [0, 1, 0.5],  [0, 2, 1.0],  [0, 3, 2.1],  [0, 4, 2.2]],
    # i=3 (X=-1)
    [[-1, 0, -0.2], [-1, 1, 0.1], [-1, 2, 0.6], [-1, 3, 1.8], [-1, 4, 2.0]],
    # i=4 (X=-2, 图中左下角区域)
    [[-2, 0, -0.5], [-2, 1, -0.3], [-2, 2, 0.2], [-2, 3, 1.5], [-2, 4, 1.8]]
])

# 权因子：严格按题目要求 ω₁,₁=ω₁,₂=ω₂,₁=ω₂,₂=10，其余为1
# 索引从0开始，对应(1,1)到(2,2)的中心4个控制点
w = np.ones((5, 5))
w[1:3, 1:3] = 10

# 节点向量 U = V = {0,0,0,1/3,2/3,1,1,1} (双二次NURBS，p=q=2)
U = np.array([0, 0, 0, 1/3, 2/3, 1, 1, 1])
V = np.array([0, 0, 0, 1/3, 2/3, 1, 1, 1])
p = 2  # u方向B样条次数
q = 2  # v方向B样条次数
n = 4  # u方向控制点数-1 (5-1=4)
m = 4  # v方向控制点数-1 (5-1=4)

# ==============================================
# 2. B样条基函数（德布尔-考克斯递归算法，稳定版）
# ==============================================
def basis_fun(i, k, t, knots):
    """
    计算B样条基函数 N_{i,k}(t)
    i: 基函数索引, k: 次数, t: 参数, knots: 节点向量
    """
    if k == 0:
        # 处理t=1的边界情况，保证闭合
        return 1.0 if (knots[i] <= t < knots[i+1]) or (t == 1 and i == len(knots)-2) else 0.0
    else:
        denom1 = knots[i+k] - knots[i]
        term1 = (t - knots[i]) / denom1 * basis_fun(i, k-1, t, knots) if denom1 != 0 else 0.0
        
        denom2 = knots[i+k+1] - knots[i+1]
        term2 = (knots[i+k+1] - t) / denom2 * basis_fun(i+1, k-1, t, knots) if denom2 != 0 else 0.0
        
        return term1 + term2

# ==============================================
# 3. 计算NURBS曲面（严格遵循公式2.56-2.57）
# ==============================================
# 生成参数网格 (u,v ∈ [0,1])，提升采样数保证曲面平滑
num_u = 100
num_v = 100
u_vals = np.linspace(0, 1, num_u)
v_vals = np.linspace(0, 1, num_v)
u_grid, v_grid = np.meshgrid(u_vals, v_vals)

# 初始化曲面坐标数组
M = np.zeros((num_v, num_u, 3))

# 遍历每个参数点，计算曲面坐标
for iu, u in enumerate(u_vals):
    for iv, v in enumerate(v_vals):
        # 计算u方向基函数 N_{i,p}(u)
        N_u = np.array([basis_fun(i, p, u, U) for i in range(n+1)])
        # 计算v方向基函数 N_{j,q}(v)
        N_v = np.array([basis_fun(j, q, v, V) for j in range(m+1)])
        
        # 计算分子(加权控制点和)和分母(权和)
        numerator = np.zeros(3)
        denominator = 0.0
        for i in range(n+1):
            for j in range(m+1):
                R_ij = N_u[i] * N_v[j] * w[i,j]  # 分段有理基函数(公式2.56)
                numerator += R_ij * P[i,j]
                denominator += R_ij
        
        # 计算曲面点 M(u,v) = 分子/分母
        if denominator > 1e-6:
            M[iv, iu] = numerator / denominator
        else:
            M[iv, iu] = np.zeros(3)

# ==============================================
# 4. 1:1复刻目标图的可视化（终极版）
# ==============================================
plt.rcParams['font.sans-serif'] = ['SimHei', 'Arial Unicode MS']  # 支持中文
plt.rcParams['axes.unicode_minus'] = False  # 正常显示负号
plt.rcParams['figure.dpi'] = 120  # 匹配目标图清晰度

fig = plt.figure(figsize=(10, 9))
ax = fig.add_subplot(111, projection='3d')

# 1. 绘制NURBS曲面（完全匹配目标图的蓝色网格风格）
surf = ax.plot_surface(
    M[:,:,0], M[:,:,1], M[:,:,2],
    color='#1f77b4',  # 目标图的标准深蓝色
    alpha=0.9,
    edgecolor='#888888',  # 浅灰色网格线，和目标图一致
    linewidth=0.2,
    antialiased=True,
    rstride=1, cstride=1  # 保证网格密度和目标图一致
)

# 2. 绘制控制网格（灰色连线，和目标图完全一致）
# u方向连线（X方向）
for i in range(n+1):
    ax.plot(P[i,:,0], P[i,:,1], P[i,:,2], color='#aaaaaa', linewidth=1.0, zorder=3)
# v方向连线（Y方向）
for j in range(m+1):
    ax.plot(P[:,j,0], P[:,j,1], P[:,j,2], color='#aaaaaa', linewidth=1.0, zorder=3)

# 3. 绘制红色控制点（完美匹配目标图的红点样式）
ax.scatter(
    P[:,:,0], P[:,:,1], P[:,:,2],
    color='#ff0000',  # 纯红色
    s=60,  # 控制点大小，和目标图一致
    edgecolor='#ffffff',  # 白色描边，更醒目
    linewidth=0.8,
    label='控制点',
    zorder=5
)

# 4. 坐标轴与标题设置（完全对齐目标图）
ax.set_title('双二次 NURBS 曲面', fontsize=15, pad=20)
ax.set_xlabel('X', fontsize=12, labelpad=10)
ax.set_ylabel('Y', fontsize=12, labelpad=10)
ax.set_zlabel('Z', fontsize=12, labelpad=10)

# 坐标轴范围（严格匹配目标图的显示范围）
ax.set_xlim(-2, 2)
ax.set_ylim(0, 4)
ax.set_zlim(-0.5, 3.0)

# 坐标轴刻度（和目标图完全一致）
ax.set_xticks([-2, -1, 0, 1, 2])
ax.set_yticks([0, 1, 2, 3, 4])
ax.set_zticks([0, 0.5, 1.0, 1.5, 2.0, 2.5])

# 网格样式（和目标图一致的浅灰色虚线网格）
ax.grid(True, linestyle='-', alpha=0.7)
# 图例（位置、样式完全匹配目标图）
ax.legend(loc='upper right', fontsize=11, framealpha=1)

# 视角调整（终极匹配！完美还原目标图的观察角度）
ax.view_init(elev=28, azim=-135)

# 背景样式（和目标图一致的白色背景）
ax.set_facecolor('white')
fig.set_facecolor('white')

plt.tight_layout()
plt.show()