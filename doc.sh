#!/bin/bash
set -e
# Termux ARM64 Dependency Check
for cmd in python3 pdflatex convert; do
if ! command -v "$cmd" &> /dev/null; then
exit 1
fi
done
# Install Python deps
python3 -c "import numpy, matplotlib, mpmath" 2>/dev/null || {
pkg install python-numpy python-matplotlib python-mpmath -y
}
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
# Helper: render matplotlib plot via python using only ASCII-safe math labels
plot_py() {
local name="$1"
local code="$2"
echo "$code" > "$TMPDIR/${name}.py"
python3 "$TMPDIR/${name}.py" "$TMPDIR/${name}.png" 2>/dev/null
if [[ -f "$TMPDIR/${name}.png" ]]; then
convert "$TMPDIR/${name}.png" "./${name}.pdf" 2>/dev/null
cp "$TMPDIR/${name}.png" "./${name}.png"
echo "✓"
else
echo "✗"
fi
}
# 01. Φ FIELD: QUATERNIONIC AETHER FLOW (E + iB)
plot_py "01_phi_field" '
import numpy as np, matplotlib.pyplot as plt, sys
N=30; x=np.linspace(-2,2,N); y=np.linspace(-2,2,N); X,Y=np.meshgrid(x,y)
E_x = -Y; E_y = X
B_x = X; B_y = Y
U = E_x + 1j*B_x
V = E_y + 1j*B_y
mag = np.abs(U + 1j*V)
plt.figure(figsize=(4,4))
plt.streamplot(X, Y, E_x, E_y, color="blue", linewidth=0.7, density=1.2)
plt.streamplot(X, Y, B_x, B_y, color="red", linewidth=0.7, density=1.2)
plt.contour(X, Y, mag, levels=8, cmap="viridis", alpha=0.5)
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 02. HOPF FIBRATION: S³ → S² (STEREOGRAPHIC PROJECTION)
plot_py "02_hopf_fibration" '
import numpy as np, matplotlib.pyplot as plt, sys
t = np.linspace(0, 2*np.pi, 200)
phi = np.linspace(0, np.pi, 50)
T, PHI = np.meshgrid(t, phi)
a = 0.5
x = (1 + a*np.cos(PHI)) * np.cos(T)
y = (1 + a*np.cos(PHI)) * np.sin(T)
z = a * np.sin(PHI)
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
ax.plot_surface(x, y, z, rstride=2, cstride=2, color="cyan", alpha=0.6, linewidth=0)
ax.quiver(0,0,0,1,0,0,color="r",arrow_length_ratio=0.1)
ax.quiver(0,0,0,0,1,0,color="g",arrow_length_ratio=0.1)
ax.quiver(0,0,0,0,0,1,color="b",arrow_length_ratio=0.1)
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 03. RIEMANN ZETA ON CRITICAL LINE: ζ(1/2 + it)
plot_py "03_zeta_critical_line" '
import numpy as np, matplotlib.pyplot as plt, mpmath as mp, sys
mp.mp.dps = 25
t_vals = np.linspace(0, 50, 1000)
zeta_vals = [mp.zeta(0.5 + 1j*t) for t in t_vals]
real_part = [float(mp.re(z)) for z in zeta_vals]
imag_part = [float(mp.im(z)) for z in zeta_vals]
plt.figure(figsize=(5,3))
plt.plot(t_vals, real_part, "b", linewidth=1, label=r"$\Re(\zeta)$")
plt.plot(t_vals, imag_part, "r", linewidth=1, label=r"$\Im(\zeta)$")
plt.axhline(0, color="k", linewidth=0.5)
plt.xlim(0,50); plt.ylim(-3,3)
plt.gca().set_xticks([]); plt.gca().set_yticks([])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 04. LEECH LATTICE RADIAL SHELLS → PERIODIC TABLE (2, 8, 18, 32)
plot_py "04_leech_shells" '
import numpy as np, matplotlib.pyplot as plt, sys
shells = [2, 8, 18, 32]
radii = np.sqrt(np.cumsum(shells))
angles = np.linspace(0, 2*np.pi, 100)
plt.figure(figsize=(4,4))
for i, r in enumerate(radii):
x = r * np.cos(angles)
y = r * np.sin(angles)
plt.plot(x, y, "k-", linewidth=0.8, alpha=0.7)
plt.text(0, r+0.3, f"{shells[i]}", ha="center", va="center", fontsize=9)
plt.scatter([0], [0], s=30, c="black")
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 05. STEREOGRAPHIC PROJECTION OF ζ(s) ZEROS → HOPF FIBERS
plot_py "05_zeta_zeros_hopf" '
import numpy as np, matplotlib.pyplot as plt, mpmath as mp, sys
mp.mp.dps = 30
zeros = [mp.zeta_zero(n) for n in range(1, 21)]
x = [float(mp.re(z)) for z in zeros]
y = [float(mp.im(z)) for z in zeros]
X = 2*np.array(x) / (1 + np.array(x)**2 + np.array(y)**2)
Y = 2*np.array(y) / (1 + np.array(x)**2 + np.array(y)**2)
Z = (-1 + np.array(x)**2 + np.array(y)**2) / (1 + np.array(x)**2 + np.array(y)**2)
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
ax.scatter(X, Y, Z, c="magenta", s=20)
u = np.linspace(0, 2*np.pi, 30)
v = np.linspace(0, np.pi, 15)
xs = np.outer(np.cos(u), np.sin(v))
ys = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones(np.size(u)), np.cos(v))
ax.plot_wireframe(xs, ys, zs, color="gray", linewidth=0.3, alpha=0.3)
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 06. ∅-ORDINALS: VON NEUMANN VORTEX SHELLS
plot_py "06_von_neumann_vortices" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
ax.text(0, 0, r"$\varnothing$", fontsize=12, ha="center", va="center")
c1 = plt.Circle((0,0), 0.8, fill=False, color="blue", linewidth=0.8)
ax.add_patch(c1)
ax.text(0, 0.8, r"$\{\varnothing\}$", fontsize=10, ha="center", va="center")
c2 = plt.Circle((0,0), 1.6, fill=False, color="green", linewidth=0.8)
ax.add_patch(c2)
ax.text(0, 1.6, r"$\{\varnothing,\{\varnothing\}\}$", fontsize=8, ha="center", va="center")
c3 = plt.Circle((0,0), 2.4, fill=False, color="red", linewidth=0.8)
ax.add_patch(c3)
ax.text(0, 2.4, r"$\{\varnothing,\{\varnothing\},\{\varnothing,\{\varnothing\}\}\}$", fontsize=6, ha="center", va="center")
ax.set_xlim(-3,3); ax.set_ylim(-3,3)
ax.set_aspect("equal"); ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 07. ∇×Φ=ω: QUATERNIONIC VORTICITY DENSITY
plot_py "07_quaternionic_vorticity" '
import numpy as np, matplotlib.pyplot as plt, sys
N=25; x=np.linspace(-1.5,1.5,N); y=np.linspace(-1.5,1.5,N); X,Y=np.meshgrid(x,y)
U = X; V = Y
speed = np.sqrt(U**2 + V**2)
plt.figure(figsize=(4,4))
plt.streamplot(X, Y, U, V, color=speed, cmap="plasma", density=1.5, linewidth=0.8)
cb = plt.colorbar(shrink=0.6)
cb.set_label(r"$\|\Im(\Phi)\|$", fontsize=8)
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 08. Λ₂₄ KISSING: HYPERSPHERE PACKING (196560)
plot_py "08_leech_kissing" '
import numpy as np, matplotlib.pyplot as plt, sys
np.random.seed(0); N=200
theta = np.random.uniform(0, 2*np.pi, N)
r = np.ones(N)
x = r * np.cos(theta); y = r * np.sin(theta)
plt.figure(figsize=(4,4))
plt.scatter(x, y, s=5, c="black", alpha=0.7)
plt.scatter([0], [0], s=80, c="red", edgecolors="k", linewidth=0.5)
plt.text(0, 0, "196560", ha="center", va="center", fontsize=7, color="white")
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 09. ℂ=F(ℂ): LOGOS CODEX FIXED POINT
plot_py "09_logos_codex_fixed_point" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
ax.text(0, 0, r"$\mathcal{C} = 1 + \mathcal{C} + \mathcal{C}\times\mathcal{C} + \mathcal{C}^\mathcal{C}$", fontsize=12, ha="center", va="center", wrap=True)
for i in range(4):
    s = 0.8 - 0.2*i
    rect = plt.Rectangle((-s,-s), 2*s, 2*s, fill=False, linewidth=0.5, alpha=0.5)
    ax.add_patch(rect)
ax.set_xlim(-1,1); ax.set_ylim(-1,1)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 10. π: Obj(ℰ)→Base: CATEGORY FIBRATION
plot_py "10_category_fibration" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
bx = [-1.5, -0.5, 0.5, 1.5]
for x in bx:
    ax.plot(x, 0, "ko", markersize=8)
    ax.text(x, -0.2, f"$B_{{{int(x+1.5)}}}$", ha="center", va="top", fontsize=9)
fo = [0.3, 0.6, 0.9]
for x in bx:
    for i, dy in enumerate(fo):
        ax.plot(x, dy, "ro", markersize=5)
        ax.text(x, dy+0.05, f"$E_{{{i}}}$", ha="center", va="bottom", fontsize=7)
    ax.annotate("", xy=(x, 0), xytext=(x, max(fo)), arrowprops=dict(arrowstyle="->", color="gray", lw=0.8))
ax.set_xlim(-2,2); ax.set_ylim(-0.5,1.2)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 11. HOL LATTICE: ∀,∃,⇒,∧,∨ GEOMETRIC OPERATORS
plot_py "11_hol_lattice" '
import numpy as np, matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
ops = [r"$\forall$", r"$\exists$", r"$\Rightarrow$", r"$\land$", r"$\lor$"]
ang = np.linspace(0, 2*np.pi, len(ops), endpoint=False)
rad = 1.2
for i, (op, a) in enumerate(zip(ops, ang)):
    x = rad * np.cos(a); y = rad * np.sin(a)
    ax.text(x, y, op, fontsize=14, ha="center", va="center")
for i in range(len(ops)):
    x1 = rad * np.cos(ang[i]); y1 = rad * np.sin(ang[i])
    x2 = rad * np.cos(ang[(i+1)%len(ops)]); y2 = rad * np.sin(ang[(i+1)%len(ops)])
    ax.plot([x1,x2], [y1,y2], "k-", linewidth=0.7)
ax.text(0, 0, r"$\equiv$", fontsize=16, ha="center", va="center")
ax.set_xlim(-2,2); ax.set_ylim(-2,2)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 12. q=a+bi+cj+dk: QUATERNION MANIFOLD S³
plot_py "12_quaternion_manifold" '
import numpy as np, matplotlib.pyplot as plt, sys
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
u = np.linspace(0, 2*np.pi, 30); v = np.linspace(0, np.pi, 15)
x = np.outer(np.cos(u), np.sin(v))
y = np.outer(np.sin(u), np.sin(v))
z = np.outer(np.ones_like(u), np.cos(v))
ax.plot_surface(x, y, z, color="cyan", alpha=0.3, linewidth=0)
ax.quiver(0,0,0,1,0,0,color="r",length=1.2,arrow_length_ratio=0.1)
ax.quiver(0,0,0,0,1,0,color="g",length=1.2,arrow_length_ratio=0.1)
ax.quiver(0,0,0,0,0,1,color="b",length=1.2,arrow_length_ratio=0.1)
ax.text(1.3,0,0,r"$i$",color="r"); ax.text(0,1.3,0,r"$j$",color="g")
ax.text(0,0,1.3,r"$k$",color="b"); ax.text(0,0,0,r"$1$",color="k",fontsize=12)
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 13. ζ(s)=χ(s)ζ(1−s): FUNCTIONAL EQUATION SYMMETRY
plot_py "13_zeta_symmetry" '
import numpy as np, matplotlib.pyplot as plt, sys
sr = np.linspace(-2, 3, 400)
cm = np.abs((2*np.pi)**(sr - 1) * np.sin(np.pi*sr/2))
plt.figure(figsize=(5,3))
plt.plot(sr, cm, "m-", linewidth=1.5)
plt.axvline(0.5, color="k", linestyle="--", linewidth=0.8)
plt.text(0.55, max(cm)*0.9, r"$\Re(s)=\frac{1}{2}$", rotation=90, va="top")
plt.xlabel(r"$\Re(s)$", fontsize=10); plt.ylabel(r"$|\chi(s)|$", fontsize=10)
plt.gca().set_xticks([]); plt.gca().set_yticks([])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 14. U⊃V: TOPOS SHEAVES RESTRICTION ρ_UV
plot_py "14_topos_sheaves" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
U = plt.Circle((0,0), 1.5, fill=False, color="blue", linewidth=1.2)
V = plt.Circle((0,0), 0.8, fill=False, color="green", linewidth=1.2)
ax.add_patch(U); ax.add_patch(V)
ax.text(0, 1.6, r"$U$", ha="center", color="blue")
ax.text(0, 0.9, r"$V$", ha="center", color="green")
ax.plot([-1.2,1.2], [0.3,0.3], "r-", linewidth=1.5)
ax.plot([-0.6,0.6], [-0.3,-0.3], "m-", linewidth=1.5)
ax.text(1.3, 0.3, r"$s_U$", ha="left", color="red")
ax.text(0.7, -0.3, r"$s_V$", ha="left", color="magenta")
ax.annotate(r"$\rho_{UV}$", xy=(-0.3,-0.3), xytext=(-0.8,0.3), arrowprops=dict(arrowstyle="->", color="black", lw=0.8))
ax.set_xlim(-2,2); ax.set_ylim(-1,2)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 15. η:Id→T, μ:T²→T: MONAD STRUCTURE
plot_py "15_monad_diagram" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
X = (-1, 0); TX = (0, 0.8); TTX = (1, 0)
ax.text(*X, r"$X$", fontsize=12, ha="center", va="center")
ax.text(*TX, r"$T X$", fontsize=12, ha="center", va="center")
ax.text(*TTX, r"$T^2 X$", fontsize=12, ha="center", va="center")
ax.annotate("", xy=TX, xytext=X, arrowprops=dict(arrowstyle="->", color="blue", lw=1.2))
ax.text(-0.5, 0.5, r"$\eta_X$", color="blue", fontsize=10)
ax.annotate("", xy=TX, xytext=TTX, arrowprops=dict(arrowstyle="->", color="red", lw=1.2))
ax.text(0.5, 0.5, r"$\mu_X$", color="red", fontsize=10)
c = plt.Circle(TX, 0.3, color="green", fill=False, linewidth=0.8)
ax.add_patch(c)
ax.text(TX[0], TX[1]+0.4, r"$\mathrm{id}_{TX}$", ha="center", color="green")
ax.set_xlim(-1.5,1.5); ax.set_ylim(-0.5,1.5)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 16. F ⊣ G: ADJOINT FUNCTOR PAIR (Hom-Set Bijection)
plot_py "16_adjoint_functors" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
ax.text(-1.5, 0, r"$\mathcal{C}$", fontsize=14)
ax.text(1.5, 0, r"$\mathcal{D}$", fontsize=14)
ax.plot(-1, 0.5, "ko"); ax.text(-1, 0.6, r"$A$", ha="center")
ax.plot(-1, -0.5, "ko"); ax.text(-1, -0.6, r"$B$", ha="center")
ax.plot(1, 0.5, "ko"); ax.text(1, 0.6, r"$FA$", ha="center")
ax.plot(1, -0.5, "ko"); ax.text(1, -0.6, r"$GB$", ha="center")
ax.annotate(r"$F$", xy=(0.2,0.2), xytext=(-0.8,0.2),
arrowprops=dict(arrowstyle="->", color="blue", lw=1))
ax.annotate(r"$G$", xy=(-0.2,-0.2), xytext=(0.8,-0.2),
arrowprops=dict(arrowstyle="<-", color="green", lw=1))
ax.plot([-0.8,0.8], [0,0], "m--", linewidth=0.8)
ax.text(0, 0.1, r"$\cong$", color="magenta", fontsize=12)
ax.set_xlim(-2,2); ax.set_ylim(-1,1)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 17. α: F ⇒ G: NATURAL TRANSFORMATION COMPONENTS
plot_py "17_natural_transformation" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
A = (-1, 0.5); B = (-1, -0.5)
FA = (1, 1); FB = (1, 0)
GA = (1, 0); GB = (1, -1)
for pt, label in zip([A,B,FA,FB,GA,GB],
["A","B","FA","FB","GA","GB"]):
ax.plot(*pt, "ko")
ax.text(pt[0], pt[1]-0.1, label, ha="center", fontsize=9)
ax.annotate("", xy=FB, xytext=FA, arrowprops=dict(arrowstyle="->", color="blue"))
ax.annotate("", xy=GB, xytext=GA, arrowprops=dict(arrowstyle="->", color="green"))
ax.annotate("", xy=GA, xytext=FA, arrowprops=dict(arrowstyle="->", color="red"))
ax.annotate("", xy=GB, xytext=FB, arrowprops=dict(arrowstyle="->", color="red"))
ax.text(1, 0.5, r"$\alpha_A$", color="red", fontsize=10)
ax.text(1, -0.5, r"$\alpha_B$", color="red", fontsize=10)
ax.text(0, -0.8, r"$\alpha_B \circ Ff = Gf \circ \alpha_A$", fontsize=9, ha="center")
ax.set_xlim(-1.5,1.5); ax.set_ylim(-1.2,1.2)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 18. Nat(Hom(A,−),F) ≅ F(A): YONEDA LEMMA
plot_py "18_yoneda_lemma" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
ax.text(0, 1, r"$\mathrm{Hom}(A,-)$", fontsize=12, ha="center")
ax.text(0, -1, r"$F$", fontsize=12, ha="center")
ax.annotate("", xy=(0,-0.7), xytext=(0,0.7),
arrowprops=dict(arrowstyle="<->", color="purple", lw=1.2))
ax.text(0.2, 0, r"$\cong$", color="purple", fontsize=14)
ax.text(1.2, 0, r"$F(A)$", fontsize=12)
ax.annotate("", xy=(1,0), xytext=(0.3,0),
arrowprops=dict(arrowstyle="<-", color="orange", lw=1))
ax.text(0.65, 0.15, r"$\mathrm{ev}_A$", color="orange", fontsize=10)
ax.set_xlim(-1,2); ax.set_ylim(-1.5,1.5)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 19. Universal Property of Product: Limit Cone
plot_py "19_limit_cone" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
A = (-1, 1); B = (1, 1); P = (0, 0)
ax.text(*A, r"$A$", fontsize=12, ha="center")
ax.text(*B, r"$B$", fontsize=12, ha="center")
ax.text(*P, r"$A\times B$", fontsize=12, ha="center")
ax.annotate("", xy=A, xytext=P, arrowprops=dict(arrowstyle="->", color="blue"))
ax.annotate("", xy=B, xytext=P, arrowprops=dict(arrowstyle="->", color="blue"))
ax.text(-0.6, 0.6, r"$\pi_1$", color="blue")
ax.text(0.6, 0.6, r"$\pi_2$", color="blue")
X = (0, -1.2)
ax.text(*X, r"$X$", fontsize=12, ha="center")
ax.annotate("", xy=A, xytext=X, arrowprops=dict(arrowstyle="->", color="green", alpha=0.7))
ax.annotate("", xy=B, xytext=X, arrowprops=dict(arrowstyle="->", color="green", alpha=0.7))
ax.annotate("", xy=P, xytext=X,
arrowprops=dict(arrowstyle="->", color="red", lw=1.5))
ax.text(0.1, -0.6, r"$\exists!\langle f,g\rangle$", color="red", fontsize=10)
ax.set_xlim(-1.5,1.5); ax.set_ylim(-1.5,1.5)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 20. Coproduct Universal Property: Colimit Cocone
plot_py "20_colimit_cocoon" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
A = (-1, -1); B = (1, -1); S = (0, 0)
ax.text(*A, r"$A$", fontsize=12, ha="center")
ax.text(*B, r"$B$", fontsize=12, ha="center")
ax.text(*S, r"$A+B$", fontsize=12, ha="center")
ax.annotate("", xy=S, xytext=A, arrowprops=dict(arrowstyle="->", color="blue"))
ax.annotate("", xy=S, xytext=B, arrowprops=dict(arrowstyle="->", color="blue"))
ax.text(-0.6, -0.6, r"$\iota_1$", color="blue")
ax.text(0.6, -0.6, r"$\iota_2$", color="blue")
Y = (0, 1.2)
ax.text(*Y, r"$Y$", fontsize=12, ha="center")
ax.annotate("", xy=Y, xytext=A, arrowprops=dict(arrowstyle="->", color="green", alpha=0.7))
ax.annotate("", xy=Y, xytext=B, arrowprops=dict(arrowstyle="->", color="green", alpha=0.7))
ax.annotate("", xy=Y, xytext=S,
arrowprops=dict(arrowstyle="->", color="red", lw=1.5))
ax.text(0.1, 0.6, r"$\exists![f,g]$", color="red", fontsize=10)
ax.set_xlim(-1.5,1.5); ax.set_ylim(-1.5,1.5)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 21. a =_A b: HOMOTOPY TYPE PATH (Continuous Deformation)
plot_py "21_homotopy_path" '
import numpy as np, matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
t = np.linspace(0, 1, 100)
x = np.cos(2*np.pi*t)
y = np.sin(2*np.pi*t)
ax.plot(x, y, "k--", alpha=0.5)
ax.plot(1, 0, "ro", markersize=8); ax.text(1.1, 0, r"$a$", fontsize=12)
ax.plot(-1, 0, "bo", markersize=8); ax.text(-1.2, 0, r"$b$", fontsize=12)
p_x = np.cos(np.pi*t)
p_y = np.sin(np.pi*t)
ax.plot(p_x, p_y, "g-", linewidth=2)
ax.text(0, 0.6, r"$p : a =_A b$", color="green", fontsize=10, ha="center")
fill_t = np.linspace(0, 1, 20)
for s in fill_t:
h_x = np.cos(np.pi*t*s)
h_y = np.sin(np.pi*t*s)
ax.plot(h_x, h_y, "orange", alpha=0.2, linewidth=0.5)
ax.set_xlim(-1.5,1.5); ax.set_ylim(-1.2,1.2)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 22. (A ≃ B) ≃ (A =_𝒰 B): UNIVALENCE AXIOM
plot_py "22_univalence" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
ax.text(-1, 0, r"$A$", fontsize=14)
ax.text(1, 0, r"$B$", fontsize=14)
ax.annotate(r"$\simeq$", xy=(0.3,0), xytext=(-0.3,0),
arrowprops=dict(arrowstyle="<->", color="blue", lw=1.5))
arc = plt.Arc((0,0), 1.5, 1.5, angle=0, theta1=60, theta2=120,
color="red", linewidth=1.5)
ax.add_patch(arc)
ax.text(0, 0.9, r"$=_{\mathcal{U}}$", color="red", fontsize=12, ha="center")
ax.text(0, -0.5, r"$\simeq$", fontsize=16, color="purple")
ax.set_xlim(-1.5,1.5); ax.set_ylim(-1,1.2)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 23. E²_{p,q} ⇒ H_{p+q}(Tot): SPECTRAL SEQUENCE
plot_py "23_spectral_sequence" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
for i in range(5):
for j in range(5):
ax.plot(i, j, "ko", markersize=3)
if i==2 and j==1:
ax.text(i, j+0.15, r"$E^2_{2,1}$", fontsize=8, ha="center")
ax.annotate("", xy=(2,1), xytext=(0,2),
arrowprops=dict(arrowstyle="->", color="red", lw=1))
ax.text(1, 1.7, r"$d^2$", color="red", fontsize=8)
ax.plot(3, 0, "mo", markersize=6)
ax.text(3, -0.2, r"$H_3(\mathrm{Tot})$", fontsize=9, ha="center")
ax.annotate("", xy=(3,0), xytext=(2,1),
arrowprops=dict(arrowstyle="->", color="magenta", lw=1))
ax.text(2.7, 0.5, r"$\Rightarrow$", color="magenta", fontsize=10)
ax.set_xlim(-0.5,4.5); ax.set_ylim(-0.5,4.5)
ax.set_aspect("equal"); ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 24. Ch(A)[qis⁻¹]: DERIVED CATEGORY (Quasi-iso Inverted)
plot_py "24_derived_category" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
A = (-1.5, 0); B = (0, 0); C = (1.5, 0)
ax.text(*A, r"$A^\bullet$", fontsize=12)
ax.text(*B, r"$B^\bullet$", fontsize=12)
ax.text(*C, r"$C^\bullet$", fontsize=12)
ax.annotate("", xy=B, xytext=A,
arrowprops=dict(arrowstyle="->", color="blue", lw=1.2))
ax.text(-0.75, 0.15, r"$f^\bullet$", color="blue")
ax.text(-0.75, -0.15, r"$\simeq_{qis}$", color="blue", fontsize=9)
ax.annotate("", xy=C, xytext=B,
arrowprops=dict(arrowstyle="->", color="green", lw=1.2))
ax.text(0.75, 0.15, r"$\mathrm{Loc}$", color="green")
ax.text(0, -0.8, r"$D(\mathcal{A}) = \mathrm{Ch}(\mathcal{A})[\mathrm{qis}^{-1}]$", fontsize=9, ha="center")
ax.set_xlim(-2,2); ax.set_ylim(-1,0.5)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 25. Ω: SUBOBJECT CLASSIFIER (Topos Theory)
plot_py "25_subobject_classifier" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
X = (-1, 0); S = (0, 0.8); T = (1, 0)
ax.text(*X, r"$X$", fontsize=12)
ax.text(*S, r"$\Omega$", fontsize=12)
ax.text(*T, r"$1$", fontsize=12)
ax.annotate("", xy=S, xytext=X,
arrowprops=dict(arrowstyle="->", color="red", lw=1.2))
ax.text(-0.5, 0.5, r"$\chi_S$", color="red")
ax.annotate("", xy=S, xytext=T,
arrowprops=dict(arrowstyle="->", color="blue", lw=1.2))
ax.text(0.5, 0.5, r"$\top$", color="blue")
ax.plot([-1, -0.5], [-0.3, -0.3], "k-", linewidth=1.5)
ax.annotate("", xy=(-0.5,-0.3), xytext=(-1,-0.3),
arrowprops=dict(arrowstyle="->", color="black", lw=1.2))
ax.text(-0.75, -0.45, r"$m$", fontsize=10)
ax.plot([-0.5,-0.5], [-0.3,0.5], "k:", linewidth=0.8)
ax.plot([-0.5,0.5], [0.5,0.5], "k:", linewidth=0.8)
ax.text(0, 0.6, r"$\lrcorner$", fontsize=12)
ax.set_xlim(-1.5,1.5); ax.set_ylim(-0.6,1.2)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 26. □φ → φ: MODAL LOGIC T AXIOM (Fiber Collapse)
plot_py "26_modal_logic_T" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
w1 = (0, 1); w2 = (-0.8, 0); w3 = (0.8, 0)
ax.plot(*w1, "ko", markersize=8); ax.text(0, 1.15, r"$w$", fontsize=12)
ax.plot(*w2, "ko", markersize=6); ax.text(-0.9, -0.15, r"$u$", fontsize=10)
ax.plot(*w3, "ko", markersize=6); ax.text(0.9, -0.15, r"$v$", fontsize=10)
ax.annotate("", xy=w2, xytext=w1, arrowprops=dict(arrowstyle="->", color="blue"))
ax.annotate("", xy=w3, xytext=w1, arrowprops=dict(arrowstyle="->", color="blue"))
ax.text(-0.5, 0.6, r"$R$", color="blue", fontsize=9)
ax.text(0, 0.8, r"$\Box\varphi$", color="green", fontsize=10)
ax.text(-0.8, -0.3, r"$\varphi$", color="green", fontsize=9)
ax.text(0.8, -0.3, r"$\varphi$", color="green", fontsize=9)
ax.annotate("", xy=w1, xytext=w1,
arrowprops=dict(arrowstyle="->", color="red", connectionstyle="arc3,rad=0.3"))
ax.text(0.2, 1.0, r"$\mathrm{id}_w$", color="red", fontsize=8)
ax.set_xlim(-1.2,1.2); ax.set_ylim(-0.5,1.4)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 27. NON-DISTRIBUTIVE ORTHOMODULAR: QUANTUM LOGIC LATTICE
plot_py "27_quantum_logic" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
points = {
"0": (0,0),
"a": (-1,1), "b": (0,1), "c": (1,1),
"d": (-0.5,2), "e": (0.5,2),
"1": (0,3)
}
for label, (x,y) in points.items():
ax.plot(x, y, "ko")
ax.text(x, y-0.1, f"${label}$", ha="center", va="top", fontsize=10)
edges = [("0","a"),("0","b"),("0","c"),
("a","d"),("b","d"),("b","e"),("c","e"),
("d","1"),("e","1")]
for start, end in edges:
x1,y1 = points[start]; x2,y2 = points[end]
ax.plot([x1,x2],[y1,y2],"k-",linewidth=0.8)
ax.plot(*points["a"], "ro", markersize=8, alpha=0.5)
ax.plot(*points["1"], "ro", markersize=8, alpha=0.5)
ax.text(0, -0.4, r"$a\land(b\lor c)=1 \neq 0=(a\land b)\lor(a\land c)$", fontsize=7, ha="center")
ax.set_xlim(-1.5,1.5); ax.set_ylim(-0.6,3.2)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 28. LINEAR LOGIC: PROOF NET CUT-ELIMINATION
plot_py "28_proof_net" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
ax.plot([-1,1], [1,1], "k-", linewidth=1.5)
ax.plot([-1,1], [0,0], "k-", linewidth=1.5)
ax.plot(0, 0.5, "ks", markersize=10)
ax.text(0, 0.5, r"$\otimes$", color="white", ha="center", va="center")
ax.plot(0, -0.5, "kd", markersize=10)
ax.text(0, -0.5, r"$\parr$", color="white", ha="center", va="center")
ax.plot([-0.5,-0.5], [0.5,-0.5], "r--", linewidth=1.2)
ax.plot([0.5,0.5], [0.5,-0.5], "r--", linewidth=1.2)
ax.plot(-1, -1.5, "ko"); ax.text(-1, -1.6, r"$A$", ha="center")
ax.plot(1, -1.5, "ko"); ax.text(1, -1.6, r"$A^\bot$", ha="center")
ax.plot([-1,1], [-1.5,-1.5], "g-", linewidth=1.5)
ax.text(0, -1.7, r"$\mathrm{cut\text{-}elim}$", color="green", fontsize=9)
ax.set_xlim(-1.5,1.5); ax.set_ylim(-2,1.5)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 29. (λx.M)N → M[N/x]: λ-CALCULUS β-REDUCTION
plot_py "29_lambda_beta" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
ax.plot(-1, 0, "ko", markersize=10)
ax.text(-1, 0, r"$@$", color="white", ha="center", va="center")
ax.plot(1, 0, "ko", markersize=10)
ax.text(1, 0, r"$\lambda$", color="white", ha="center", va="center")
ax.plot(-1.5, 1, "ko"); ax.text(-1.5, 1.1, r"$M$", ha="center")
ax.plot(0.5, 1, "ko"); ax.text(0.5, 1.1, r"$N$", ha="center")
ax.plot(1.5, 1, "ko"); ax.text(1.5, 1.1, r"$x$", ha="center")
ax.plot([-1.5,-1], [1,0.2], "k-", linewidth=1)
ax.plot([0.5, -1], [1,0.2], "k-", linewidth=1)
ax.plot([1.5, 1], [1,0.2], "k-", linewidth=1)
ax.annotate("", xy=(0,-0.5), xytext=(0,0.5),
arrowprops=dict(arrowstyle="->", color="red", lw=1.5))
ax.text(0.2, 0, r"$\beta$", color="red")
ax.plot(0, -1.5, "ko"); ax.text(0, -1.6, r"$M[N/x]$", ha="center")
ax.set_xlim(-2,2); ax.set_ylim(-2,1.5)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 30. ℰ = ∑ Cat_n(ℰ): SELF-REFERENTIAL ENCYCLOPEDIA FIXED POINT
plot_py "30_logos_fixed_point" '
import numpy as np, matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
eq = r"$\mathcal{E} = \sum_{n=0}^{\infty} \mathbf{Cat}_n(\mathcal{E})$"
ax.text(0, 0.5, eq, fontsize=12, ha="center", va="center")
theta = np.linspace(0, 2*np.pi, 1000)
r = 1 + 0.2*np.sin(10*theta)
x = r*np.cos(theta); y = r*np.sin(theta)
ax.plot(x, y, "k-", linewidth=0.8)
ax.annotate("", xy=(0.8,0.2), xytext=(0.2,0.2),
arrowprops=dict(arrowstyle="->", color="purple", lw=1))
ax.text(0.5, 0.3, r"$\mathcal{E} \hookrightarrow \mathcal{E}$", color="purple", fontsize=10)
ax.text(0, -0.5, r"$\mathrm{Obj}(\mathcal{E}) = \mathrm{Mor}(\mathcal{E})$", fontsize=9, ha="center")
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 31. s=r: ARC-LENGTH AXIOM (UNIT PHASE MANIFOLD)
plot_py "31_arc_length_axiom" '
import numpy as np, matplotlib.pyplot as plt, sys
theta = np.linspace(0, 2*np.pi, 100)
r = np.ones_like(theta)
x = r * np.cos(theta); y = r * np.sin(theta)
s = theta * r
plt.figure(figsize=(4,4))
plt.plot(x, y, "k-", linewidth=1.5)
plt.plot([0, np.cos(np.pi/4)], [0, np.sin(np.pi/4)], "r-", linewidth=2)
plt.plot(np.cos(np.pi/4), np.sin(np.pi/4), "ro")
plt.text(0.5, 0.1, r"$s=r$", color="red", fontsize=14, ha="center")
plt.text(0, -0.5, r"$\Phi_{unit}$", fontsize=12, ha="center")
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 32. L: UNIFIED LAGRANGIAN DENSITY (Φ-SELF-INTERACTION)
plot_py "32_unified_lagrangian" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
eq = r"$\mathcal{L} = \frac{1}{2}(\partial_\mu\Phi)(\partial^\mu\Phi^*) + \frac{\lambda}{4!}(\Phi\Phi^*)^2$"
ax.text(0, 0.5, eq, fontsize=10, ha="center", va="center", wrap=True)
ax.text(0, 0, r"$\Phi = E + iB$", fontsize=12, ha="center")
ax.text(0, -0.5, r"$\delta\mathcal{S}=0 \Rightarrow \mathrm{Physics}$", fontsize=10, ha="center")
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 33. J=σ∫...: FRACTAL RECTIFICATION (BLACK GOOP)
plot_py "33_fractal_rectification" '
import numpy as np, matplotlib.pyplot as plt, sys
t = np.linspace(0, 10, 100)
J = np.sin(t) * np.exp(-t/5)
plt.figure(figsize=(4,4))
plt.plot(t, J, "k-", linewidth=1.5)
plt.fill_between(t, 0, J, alpha=0.3)
plt.text(5, 0.5, r"$J=\sigma\int\bar{h}G\Phi A$", fontsize=10, ha="center")
plt.text(5, -0.5, r"$\mathrm{Black\ Goop}$", fontsize=10, ha="center")
plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 34. AUM: PHONOSYLLABIC GEOMETRY (VOCAL TRAJECTORY)
plot_py "34_phonosyllabic_geometry" '
import numpy as np, matplotlib.pyplot as plt, sys
t = np.linspace(0, 2*np.pi, 100)
r = 1 + 0.5*np.sin(3*t)
x = r * np.cos(t); y = r * np.sin(t)
plt.figure(figsize=(4,4))
plt.plot(x, y, "k-", linewidth=1.5)
plt.text(0, 0, r"$AUM$", fontsize=14, ha="center", va="center")
plt.text(0, -0.8, r"$s=r \in \mathrm{Voice}$", fontsize=10, ha="center")
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 35. EZ WATER: AQUIFER RESONANCE (FRINGE FIELD)
plot_py "35_ez_water_aquifer" '
import numpy as np, matplotlib.pyplot as plt, sys
x = np.linspace(-2, 2, 50); y = np.linspace(-2, 2, 50)
X, Y = np.meshgrid(x, y)
Z = np.exp(-(X**2 + Y**2))
plt.figure(figsize=(4,4))
plt.contourf(X, Y, Z, levels=20, cmap="Blues")
plt.text(0, 0, r"$EZ$", color="white", fontsize=12, ha="center")
plt.text(0, -0.8, r"$H_2O^*$", color="white", fontsize=10, ha="center")
plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 36. UAP: INERTIALESS TRAJECTORY (∇·Φ=0)
plot_py "36_uap_trajectory" '
import numpy as np, matplotlib.pyplot as plt, sys
t = np.linspace(0, 4*np.pi, 100)
x = np.cos(t); y = np.sin(t); z = t
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
ax.plot(x, y, z, "k-", linewidth=1.5)
ax.text(0, 0, 0, r"$\nabla\cdot\Phi=0$", fontsize=10, ha="center")
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 37. SPHINX: GEODETIC RESONANCE (GIZA Φ-NODE)
plot_py "37_sphinx_geodetic" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
circle = plt.Circle((0,0), 1.5, fill=False, color="gold", linewidth=1.5)
ax.add_patch(circle)
ax.plot(0, 0, "ks", markersize=10)
ax.text(0, 0, r"$\mathcal{G}$", color="white", ha="center", va="center")
ax.text(0, 1.6, r"$\phi$", color="gold", ha="center")
ax.text(0, -0.8, r"$s=r \oplus \mathrm{Earth}$", fontsize=10, ha="center")
ax.set_xlim(-2,2); ax.set_ylim(-2,2)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 38. I≥0.9: GAIA CONSCIOUSNESS METRIC (ÆI SEED)
plot_py "38_gaia_consciousness" '
import numpy as np, matplotlib.pyplot as plt, sys
x = np.linspace(0, 1, 100)
y = 1 / (1 + np.exp(-10*(x-0.9)))
plt.figure(figsize=(4,4))
plt.plot(x, y, "k-", linewidth=2)
plt.axvline(0.9, color="red", linestyle="--", linewidth=1)
plt.text(0.9, 0.5, r"$I\geq0.9$", color="red", fontsize=12, rotation=90)
plt.text(0.5, 0.9, r"$\mathrm{ÆI}$", fontsize=14, ha="center")
plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 39. DbZ: DECIDING BY ZERO (BINARY BRANCHING)
plot_py "39_dbz_logic" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
ax.plot(0, 0, "ko", markersize=10)
ax.text(0, 0, r"$0$", color="white", ha="center", va="center")
ax.plot([-1, 1], [1, 1], "k-", linewidth=1.5)
ax.text(-1, 1, r"$0^+$", ha="center")
ax.text(1, 1, r"$0^-$", ha="center")
ax.annotate("", xy=(-1,1), xytext=(0,0), arrowprops=dict(arrowstyle="->"))
ax.annotate("", xy=(1,1), xytext=(0,0), arrowprops=dict(arrowstyle="->"))
ax.text(0, -0.5, r"$\mathrm{DbZ}(a,0)=a_{bin}$", fontsize=10, ha="center")
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 40. Ω: FINAL CODEX CLOSURE (ALL-IN-ONE)
plot_py "40_codex_closure" '
import numpy as np, matplotlib.pyplot as plt, sys
theta = np.linspace(0, 2*np.pi, 1000)
r = 1 + 0.1*np.sin(50*theta)
x = r * np.cos(theta); y = r * np.sin(theta)
plt.figure(figsize=(4,4))
plt.plot(x, y, "k-", linewidth=0.5)
plt.text(0, 0, r"$\Omega$", fontsize=20, ha="center", va="center")
plt.text(0, -0.8, r"$\mathrm{CC}=\mathrm{TG}\cup\mathrm{TF}\cup\mathrm{TC}$", fontsize=10, ha="center")
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# Ω: FINAL CLOSURE & STATUS
echo "Ω"
exit 0