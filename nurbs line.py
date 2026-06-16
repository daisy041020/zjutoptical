import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import PathPatch
from matplotlib.path import Path

# 高清设置
plt.rcParams['figure.dpi'] = 150
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['font.family'] = ['SimHei', 'DejaVu Sans']  # 支持中文标签和数学公式
plt.rcParams['axes.unicode_minus'] = False

# -------------------------- 1. 核心参数（完全匹配图2.4）--------------------------
p = 3  # 三次NURBS
n_ctrl = 7  # 7个控制点 P0-P6
ctrlpts = np.array([
    (0.0, 0.0),  # P0
    (1.0, 2.0),  # P1
    (2.0, 1.0),  # P2
    (3.0, 3.0),  # P3 (凸起点)
    (4.0, 0.0),  # P4
    (5.0, 2.0),  # P5
    (6.0, 0.0)   # P6
])
weights = np.array([1, 1, 1, 3, 1, 1, 1])  # ω3=3，其余=1
# 钳位型节点矢量
knot = np.array([0, 0, 0, 0, 1/4, 1/2, 3/4, 1, 1, 1, 1])
u_sampling = np.linspace(0, 1, 500)

# -------------------------- 2. 基础计算函数 --------------------------
def bspline_basis(i, p, u, knot):
    """计算B样条基函数N_{i,p}(u)"""
    if p == 0:
        return 1.0 if (knot[i] <= u < knot[i+1]) or (abs(u-1) < 1e-10 and abs(knot[i+1]-1) < 1e-10) else 0.0
    
    denom1 = knot[i+p] - knot[i]
    term1 = 0.0
    if denom1 > 1e-10:
        term1 = ((u - knot[i]) / denom1) * bspline_basis(i, p-1, u, knot)
        
    denom2 = knot[i+p+1] - knot[i+1]
    term2 = 0.0
    if denom2 > 1e-10:
        term2 = ((knot[i+p+1] - u) / denom2) * bspline_basis(i+1, p-1, u, knot)
        
    return term1 + term2

def nurbs_curve(ctrlpts, weights, degree, knot, u_range):
    """计算NURBS曲线"""
    n = len(ctrlpts)
    curve = np.zeros((len(u_range), 2))
    for idx, u in enumerate(u_range):
        num_x, num_y, den = 0.0, 0.0, 0.0
        for i in range(n):
            b = bspline_basis(i, degree, u, knot)
            wb = weights[i] * b
            num_x += wb * ctrlpts[i, 0]
            num_y += wb * ctrlpts[i, 1]
            den += wb
        curve[idx] = (num_x/den, num_y/den) if den > 1e-10 else (0, 0)
    return curve.T  # 返回 (x_array, y_array)

# 计算曲线点
curve_x, curve_y = nurbs_curve(ctrlpts, weights, p, knot, u_sampling)

# -------------------------- 3. 绘制图形（分两栏：曲线+基函数）--------------------------
fig, (ax_curve, ax_basis) = plt.subplots(2, 1, figsize=(10, 10))
fig.suptitle('图2.4 由7个控制点生成的三次NURBS曲线', fontsize=16, fontweight='bold')

# --- 子图1：NURBS曲线 (a) ---
ax_curve.plot(curve_x, curve_y, 'k-', linewidth=2, label='NURBS曲线')
ax_curve.scatter(ctrlpts[:, 0], ctrlpts[:, 1], c='black', s=50, zorder=5)

# 绘制虚线辅助线（连接控制点）
dashed_vertices = [
    (0,0), (1,2), (2,1), (3,3), (4,0), (5,2), (6,0), # 轮廓
    (3,3), (4,0), # P3-P4
    (1,2), (0,0), # P1-P0
    (2,1), (3,3)  # P2-P3
]
dashed_codes = [Path.MOVETO] + [Path.LINETO]*(len(dashed_vertices)-1)
dashed_path = Path(dashed_vertices, dashed_codes)
dashed_patch = PathPatch(dashed_path, fill=False, edgecolor='gray', linestyle='--', linewidth=1)
ax_curve.add_patch(dashed_patch)

# 标注控制点 P0-P6
for i, (x, y) in enumerate(ctrlpts):
    ax_curve.text(x+0.1, y+0.1, f'$P_{i}$', fontsize=12, fontweight='bold')

ax_curve.set_xlabel('X')
ax_curve.set_ylabel('Y')
ax_curve.set_title('(a) 一条三次NURBS曲线')
ax_curve.axis('equal')
ax_curve.grid(True, alpha=0.3)
ax_curve.set_xlim(-0.5, 6.5)
ax_curve.set_ylim(-0.5, 3.5)

# --- 子图2：有理基函数 (b) ---
# 计算所有有理基函数 R_{i,3}(u)
N_all = np.zeros((n_ctrl, len(u_sampling)))
for i in range(n_ctrl):
    for idx, u in enumerate(u_sampling):
        N_all[i, idx] = bspline_basis(i, p, u, knot)

W = np.dot(weights, N_all)
R_all = (weights.reshape(-1, 1) * N_all) / W

# 定义配色与标签
colors = ['blue', 'orange', 'green', 'red', 'purple', 'brown', 'pink']
labels = [f'$R_{{{i},3}}(u)$' for i in range(n_ctrl)]

# 绘制7条基函数曲线
for i in range(n_ctrl):
    linestyle = '--' if i == 3 else '-' # R3用虚线突出
    ax_basis.plot(u_sampling, R_all[i], color=colors[i], linestyle=linestyle, 
                  linewidth=2, label=labels[i])

# 图表美化
ax_basis.set_xlabel('$u$')
ax_basis.set_ylabel('$R_{i,3}(u)$')
ax_basis.set_title('(b) 相联系的基函数')
ax_basis.set_xlim(0, 1)
ax_basis.set_ylim(0, 1.05)
ax_basis.grid(True, alpha=0.3)
# 图例：两列显示，适配平板
ax_basis.legend(loc='upper right', fontsize=10, ncol=2)

plt.tight_layout(rect=[0, 0, 1, 0.96]) # 给总标题留空间
# 保存图片

plt.show()

# -------------------------- 4. 验证信息 --------------------------
print("=== 计算验证 ===")
print(f"控制点数量: {len(ctrlpts)}")
print(f"节点矢量: {list(knot)}")
print(f"权因子: {list(weights)}")
print(f"曲线起点 C(0): ({curve_x[0]:.2f}, {curve_y[0]:.2f}) (应=P0)")
print(f"曲线终点 C(1): ({curve_x[-1]:.2f}, {curve_y[-1]:.2f}) (应=P6)")
