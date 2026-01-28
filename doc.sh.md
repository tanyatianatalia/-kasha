```bash
#!/bin/bash
set -e

# Ensure dependencies
for cmd in python3 pdflatex convert; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "ERROR: $cmd not found. Run: pkg install python texlive imagemagick"
    exit 1
  fi
done

# Install minimal Python deps if missing
python3 -c "import numpy, matplotlib" 2>/dev/null || {
  pkg install python-numpy python-matplotlib -y
}

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Helper: render matplotlib plot via python
plot_py() {
  local name="$1"
  local code="$2"
  echo "$code" > "$TMPDIR/${name}.py"
  python3 "$TMPDIR/${name}.py" "$TMPDIR/${name}.png" 2>/dev/null
  if [[ -f "$TMPDIR/${name}.png" ]]; then
    convert "$TMPDIR/${name}.png" "./${name}.pdf" 2>/dev/null
    cp "$TMPDIR/${name}.png" "./${name}.png"
    echo "Generated: ${name}.{png,pdf}"
  else
    echo "FAILED: ${name}"
  fi
}

# 1. Φ FIELD: QUATERNIONIC AETHER FLOW (E + iB)
plot_py "01_phi_field" '
import numpy as np, matplotlib.pyplot as plt, sys
N=30; x=np.linspace(-2,2,N); y=np.linspace(-2,2,N); X,Y=np.meshgrid(x,y)
E_x = -Y; E_y = X          # rotational E
B_x = X; B_y = Y           # radial B
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

# 2. HOPF FIBRATION: S³ → S² (STEREOGRAPHIC PROJECTION OF ζ(s))
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

# 3. RIEMANN ZETA ON CRITICAL LINE: ζ(1/2 + it)
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

# 4. LEECH LATTICE RADIAL SHELLS → PERIODIC TABLE (2, 8, 18, 32)
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

# 5. STEREOGRAPHIC PROJECTION OF ζ(s) ZEROS → HOPF FIBERS
plot_py "05_zeta_zeros_hopf" '
import numpy as np, matplotlib.pyplot as plt, mpmath as mp, sys
mp.mp.dps = 30
# First 20 non-trivial zeta zeros on critical line
zeros = [mp.zeta_zero(n) for n in range(1, 21)]
x = [float(mp.re(z)) for z in zeros]
y = [float(mp.im(z)) for z in zeros]
# Stereographic projection to S2
X = 2*np.array(x) / (1 + np.array(x)**2 + np.array(y)**2)
Y = 2*np.array(y) / (1 + np.array(x)**2 + np.array(y)**2)
Z = (-1 + np.array(x)**2 + np.array(y)**2) / (1 + np.array(x)**2 + np.array(y)**2)
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
ax.scatter(X, Y, Z, c="magenta", s=20)
# Draw unit sphere
u = np.linspace(0, 2*np.pi, 30)
v = np.linspace(0, np.pi, 15)
xs = np.outer(np.cos(u), np.sin(v))
ys = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones(np.size(u)), np.cos(v))
ax.plot_wireframe(xs, ys, zs, color="gray", linewidth=0.3, alpha=0.3)
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 6. VON NEUMANN ORDINALS AS VORTEX SHELLS (∅, {∅}, {{∅},∅}, ...)
plot_py "06_von_neumann_vortices" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
# Shell 0: ∅
ax.text(0, 0, r"$\varnothing$", fontsize=12, ha="center", va="center")
# Shell 1: {∅}
circle1 = plt.Circle((0,0), 0.8, fill=False, color="blue", linewidth=0.8)
ax.add_patch(circle1)
ax.text(0, 0.8, r"$\{\varnothing\}$", fontsize=10, ha="center", va="center")
# Shell 2: {∅, {∅}}
circle2 = plt.Circle((0,0), 1.6, fill=False, color="green", linewidth=0.8)
ax.add_patch(circle2)
ax.text(0, 1.6, r"$\{\varnothing,\{\varnothing\}\}$", fontsize=8, ha="center", va="center")
# Shell 3
circle3 = plt.Circle((0,0), 2.4, fill=False, color="red", linewidth=0.8)
ax.add_patch(circle3)
ax.text(0, 2.4, r"$\{\varnothing,\{\varnothing\},\{\varnothing,\{\varnothing\}\}\}$", fontsize=6, ha="center", va="center")
ax.set_xlim(-3,3); ax.set_ylim(-3,3)
ax.set_aspect("equal"); ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 7. QUATERNIONIC VORTICITY FIELD: ∇ × Φ = ω (Aetheric Spin Density)
plot_py "07_quaternionic_vorticity" '
import numpy as np, matplotlib.pyplot as plt, sys
N=25; x=np.linspace(-1.5,1.5,N); y=np.linspace(-1.5,1.5,N); X,Y=np.meshgrid(x,y)
# Φ = E + iB; E = (-y, x, 0), B = (x, y, 0) → Φ = (-y + i x, x + i y, 0)
# Vorticity ω = ∇ × Re(Φ) = ∇ × E = (0,0,2)
# But visualize streamlines of Im(Φ) = B
U = X  # B_x
V = Y  # B_y
speed = np.sqrt(U**2 + V**2)
plt.figure(figsize=(4,4))
plt.streamplot(X, Y, U, V, color=speed, cmap="plasma", density=1.5, linewidth=0.8)
plt.colorbar(shrink=0.6).set_label(r"$\|\Im(\Phi)\|$", fontsize=8)
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 8. HYPERSPHERE PACKING IN Λ₂₄: KISSING NUMBER 196560 (Projected)
plot_py "08_leech_kissing" '
import numpy as np, matplotlib.pyplot as plt, sys
# Simulate 2D projection of Leech kissing configuration
np.random.seed(0)
N=200
theta = np.random.uniform(0, 2*np.pi, N)
r = np.ones(N)  # unit sphere
x = r * np.cos(theta)
y = r * np.sin(theta)
plt.figure(figsize=(4,4))
plt.scatter(x, y, s=5, c="black", alpha=0.7)
# Central sphere
plt.scatter([0], [0], s=80, c="red", edgecolors="k", linewidth=0.5)
plt.text(0, 0, "196560", ha="center", va="center", fontsize=7, color="white")
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 9. SELF-REFERENTIAL ENCODING: C = F(C) = 1 + C + C×C + C^C
plot_py "09_logos_codex_fixed_point" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
# Draw recursive structure
ax.text(0, 0, r"$\mathcal{C} = 1 + \mathcal{C} + \mathcal{C}\times\mathcal{C} + \mathcal{C}^\mathcal{C}$", fontsize=12, ha="center", va="center", wrap=True)
# Add fractal-like self-similarity via nested boxes
for i in range(4):
    s = 0.8 - 0.2*i
    rect = plt.Rectangle((-s,-s), 2*s, 2*s, fill=False, linewidth=0.5, alpha=0.5)
    ax.add_patch(rect)
ax.set_xlim(-1,1); ax.set_ylim(-1,1)
ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'
# 10. STEREOGRAPHIC PROJECTION OF ζ(s) ZEROS ONTO S² VIA HOPF FIBRATION (FULL)
plot_py "10_zeta_hopf_stereographic" '
import numpy as np, matplotlib.pyplot as plt, mpmath as mp, sys
mp.mp.dps = 35
# Compute first 30 non-trivial zeta zeros
zeros = [mp.zeta_zero(n) for n in range(1, 31)]
x = np.array([float(mp.re(z)) for z in zeros])
y = np.array([float(mp.im(z)) for z in zeros])
# Stereographic projection from C to S²
denom = 1 + x**2 + y**2
X = 2*x / denom
Y = 2*y / denom
Z = (-1 + x**2 + y**2) / denom
# Plot 3D sphere with projected zeros
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
# Draw sphere wireframe
u = np.linspace(0, 2*np.pi, 40)
v = np.linspace(0, np.pi, 20)
xs = np.outer(np.cos(u), np.sin(v))
ys = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones_like(u), np.cos(v))
ax.plot_wireframe(xs, ys, zs, color="lightgray", linewidth=0.3, alpha=0.4)
# Plot projected zeros
ax.scatter(X, Y, Z, c="purple", s=15, depthshade=True)
# Add critical line projection (Re(s)=1/2)
t_line = np.linspace(0, 50, 200)
x_line = np.full_like(t_line, 0.5)
y_line = t_line
denom_line = 1 + x_line**2 + y_line**2
X_line = 2*x_line / denom_line
Y_line = 2*y_line / denom_line
Z_line = (-1 + x_line**2 + y_line**2) / denom_line
ax.plot(X_line, Y_line, Z_line, color="red", linewidth=1, alpha=0.7)
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 11. PRIME–LEECH DUALITY: π(x) vs π_Λ(R) with RH ERROR BOUND
plot_py "11_prime_leech_duality" '
import numpy as np, matplotlib.pyplot as plt, mpmath as mp, sys
mp.mp.dps = 20
# Generate primes up to 100
def primes_upto(n):
    sieve = np.ones(n+1, dtype=bool)
    sieve[:2] = False
    for i in range(2, int(n**0.5)+1):
        if sieve[i]: sieve[i*i::i] = False
    return np.where(sieve)[0]
primes = primes_upto(100)
x_vals = np.arange(2, 101)
pi_x = np.array([np.sum(primes <= x) for x in x_vals])
# Leech lattice radial count: π_Λ(R) ≈ π(R²)
R_vals = np.sqrt(x_vals)
pi_L = pi_x  # by duality π_Λ(√x) ≈ π(x)
# Li(x) and error bound
Li = np.array([mp.li(x) for x in x_vals])
error = np.abs(pi_x - Li)
bound = np.sqrt(x_vals) * np.log(x_vals)
plt.figure(figsize=(5,3))
plt.plot(x_vals, pi_x, "bo", markersize=2, label=r"$\pi(x)$")
plt.plot(x_vals, Li, "r-", linewidth=1, label=r"$\mathrm{Li}(x)$")
plt.fill_between(x_vals, Li - bound, Li + bound, color="orange", alpha=0.2, label=r"$\mathcal{O}(\sqrt{x}\log x)$")
plt.xlim(0,100); plt.ylim(0,30)
plt.gca().set_xticks([]); plt.gca().set_yticks([])
plt.legend(fontsize=7)
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 12. HOPF FIBRATION AS PERCEPTION OPERATOR: S³ → S² → C
plot_py "12_hopf_perception" '
import numpy as np, matplotlib.pyplot as plt, sys
# Parameterize S3 via (z1, z2) in C^2, |z1|^2 + |z2|^2 = 1
t = np.linspace(0, 2*np.pi, 100)
phi = np.linspace(0, np.pi/2, 50)
T, PHI = np.meshgrid(t, phi)
# Hopf map: (z1, z2) -> (2 Re(z1 z2*), 2 Im(z1 z2*), |z1|^2 - |z2|^2)
z1 = np.cos(PHI) * np.exp(1j * T)
z2 = np.sin(PHI) * np.exp(1j * T)
X = 2 * np.real(z1 * np.conj(z2))
Y = 2 * np.imag(z1 * np.conj(z2))
Z = np.abs(z1)**2 - np.abs(z2)**2
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
# Plot fibers as linked circles
for i in range(0, len(t), 10):
    ax.plot(X[:,i], Y[:,i], Z[:,i], "b-", linewidth=0.8, alpha=0.7)
# Draw target S2
u = np.linspace(0, 2*np.pi, 30)
v = np.linspace(0, np.pi, 15)
xs = np.outer(np.cos(u), np.sin(v))
ys = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones_like(u), np.cos(v))
ax.plot_wireframe(xs, ys, zs, color="gray", linewidth=0.3, alpha=0.3)
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 13. QUATERNIONIC STREAMLINES OF Φ = E + iB (AETHER FLOW)
plot_py "13_quaternionic_streamlines" '
import numpy as np, matplotlib.pyplot as plt, sys
N=20; x=np.linspace(-2,2,N); y=np.linspace(-2,2,N); X,Y=np.meshgrid(x,y)
# Define Φ = E + iB with E = (-y, x), B = (x, y)
E_x, E_y = -Y, X
B_x, B_y = X, Y
# Total field for streamline: Re(Φ) + Im(Φ)
U = E_x + B_x
V = E_y + B_y
plt.figure(figsize=(4,4))
plt.streamplot(X, Y, U, V, density=1.8, linewidth=0.7, color="navy", arrowsize=0.5)
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 14. ZETA FUNCTION ENCODED IN QUATERNIONS VIA HOPF FIBRATION
plot_py "14_zeta_quaternionic_hopf" '
import numpy as np, matplotlib.pyplot as plt, mpmath as mp, sys
mp.mp.dps = 30
# Define s = 1/2 + i t
t_vals = np.linspace(0.1, 50, 200)
s_vals = 0.5 + 1j * t_vals
zeta_vals = np.array([complex(mp.zeta(s)) for s in s_vals])
# Map zeta(s) to S3 via normalization
norm = np.abs(zeta_vals)
z1 = np.where(norm > 0, zeta_vals / norm, 1+0j)
z2 = np.sqrt(1 - np.abs(z1)**2 + 0j)
# Ensure |z1|^2 + |z2|^2 = 1
z2 = np.where(np.abs(z1) <= 1, np.sqrt(1 - np.abs(z1)**2), 0+0j)
# Hopf projection to S2
X = 2 * np.real(z1 * np.conj(z2))
Y = 2 * np.imag(z1 * np.conj(z2))
Z = np.abs(z1)**2 - np.abs(z2)**2
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
ax.plot(X, Y, Z, "m-", linewidth=1.2, alpha=0.9)
# Draw unit sphere
u = np.linspace(0, 2*np.pi, 40)
v = np.linspace(0, np.pi, 20)
xs = np.outer(np.cos(u), np.sin(v))
ys = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones_like(u), np.cos(v))
ax.plot_wireframe(xs, ys, zs, color="lightgray", linewidth=0.2, alpha=0.3)
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 15. STEREOGRAPHIC PROJECTION OF S^n → R^n FOR n=1,2,3 (PERCEPTION MODEL)
plot_py "15_stereographic_perception" '
import numpy as np, matplotlib.pyplot as plt, sys
fig, axs = plt.subplots(1, 3, figsize=(12,4))
# S1 -> R1
theta = np.linspace(0, 2*np.pi, 100)
x1 = np.cos(theta); y1 = np.sin(theta)
axs[0].plot(x1, y1, "k-", linewidth=1)
axs[0].scatter([0], [1], c="red", s=20) # north pole
t_line = np.linspace(-3, 3, 50)
axs[0].plot(t_line, np.zeros_like(t_line), "b--", linewidth=0.8)
# Projection lines
for t in [-2, -1, 0, 1, 2]:
    x_proj = 2*t/(1+t**2)
    y_proj = (t**2-1)/(1+t**2)
    axs[0].plot([0, x_proj], [1, y_proj], "g-", linewidth=0.5, alpha=0.6)
axs[0].set_aspect("equal"); axs[0].axis("off")
# S2 -> R2
u = np.linspace(0, 2*np.pi, 30)
v = np.linspace(0, np.pi, 15)
U, V = np.meshgrid(u, v)
xs = np.cos(U)*np.sin(V); ys = np.sin(U)*np.sin(V); zs = np.cos(V)
axs[1].contour(xs, ys, levels=8, colors="k", linewidths=0.5)
axs[1].scatter([0], [0], c="red", s=20)
axs[1].set_aspect("equal"); axs[1].axis("off")
# S3 fiber projection (Hopf)
t = np.linspace(0, 2*np.pi, 50)
phi = np.pi/4
z1 = np.cos(phi) * np.exp(1j*t)
z2 = np.sin(phi) * np.exp(1j*t)
X = 2*np.real(z1*np.conj(z2))
Y = 2*np.imag(z1*np.conj(z2))
axs[2].plot(X, Y, "m-", linewidth=1)
axs[2].set_aspect("equal"); axs[2].axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 16. QUATERNIONIC AETHER VORTICITY: ∇ × Φ = ω (SPIN DENSITY FIELD)
plot_py "16_aether_vorticity" '
import numpy as np, matplotlib.pyplot as plt, sys
N=25; x=np.linspace(-2,2,N); y=np.linspace(-2,2,N); X,Y=np.meshgrid(x,y)
# Φ = E + iB; E = (-y, x, 0), B = (0, 0, x²+y²)
E_x, E_y = -Y, X
B_z = X**2 + Y**2
# Vorticity ω = ∇ × Re(Φ) = ∇ × E = (0,0,2)
# But visualize full quaternionic curl
omega_z = np.gradient(E_y, axis=1) - np.gradient(E_x, axis=0)
plt.figure(figsize=(4,4))
plt.contourf(X, Y, omega_z, levels=20, cmap="RdBu", alpha=0.8)
plt.colorbar(shrink=0.6).set_label(r"$\omega_z = (\nabla \times \Re(\Phi))_z$", fontsize=7)
plt.streamplot(X, Y, E_x, E_y, color="k", linewidth=0.5, density=1.0, alpha=0.7)
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 17. LEECH LATTICE KISSING CONFIGURATION (24D → 3D PROJECTION)
plot_py "17_leech_24d_projection" '
import numpy as np, matplotlib.pyplot as plt, sys
# Simulate projection of Leech minimal vectors (norm^2=4)
np.random.seed(42)
N=500
# Generate points on S^23 and project to R^3 via first 3 coords
vec = np.random.normal(size=(N,24))
norms = np.linalg.norm(vec, axis=1, keepdims=True)
vec = vec / norms * 2  # norm=2 → norm^2=4
proj = vec[:, :3]
x, y, z = proj[:,0], proj[:,1], proj[:,2]
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
ax.scatter(x, y, z, s=8, c="darkgreen", alpha=0.6)
# Draw origin
ax.scatter([0],[0],[0], s=50, c="red")
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# Final execution of all plots
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
plot_py "03_zeta_critical_line" '
import numpy as np, matplotlib.pyplot as plt, mpmath as mp, sys
mp.mp.dps = 25
t_vals = np.linspace(0, 50, 1000)
zeta_vals = [mp.zeta(0.5 + 1j*t) for t in t_vals]
real_part = [float(mp.re(z)) for z in zeta_vals]
imag_part = [float(mp.im(z)) for z in zeta_vals]
plt.figure(figsize=(5,3))
plt.plot(t_vals, real_part, "b", linewidth=1)
plt.plot(t_vals, imag_part, "r", linewidth=1)
plt.axhline(0, color="k", linewidth=0.5)
plt.xlim(0,50); plt.ylim(-3,3)
plt.gca().set_xticks([]); plt.gca().set_yticks([])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
  '
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
plot_py "06_von_neumann_vortices" '
import matplotlib.pyplot as plt, sys
fig, ax = plt.subplots(figsize=(4,4))
ax.text(0, 0, r"$\varnothing$", fontsize=12, ha="center", va="center")
circle1 = plt.Circle((0,0), 0.8, fill=False, color="blue", linewidth=0.8)
ax.add_patch(circle1)
ax.text(0, 0.8, r"$\{\varnothing\}$", fontsize=10, ha="center", va="center")
circle2 = plt.Circle((0,0), 1.6, fill=False, color="green", linewidth=0.8)
ax.add_patch(circle2)
ax.text(0, 1.6, r"$\{\varnothing,\{\varnothing\}\}$", fontsize=8, ha="center", va="center")
circle3 = plt.Circle((0,0), 2.4, fill=False, color="red", linewidth=0.8)
ax.add_patch(circle3)
ax.text(0, 2.4, r"$\{\varnothing,\{\varnothing\},\{\varnothing,\{\varnothing\}\}\}$", fontsize=6, ha="center", va="center")
ax.set_xlim(-3,3); ax.set_ylim(-3,3)
ax.set_aspect("equal"); ax.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
  '
plot_py "07_quaternionic_vorticity" '
import numpy as np, matplotlib.pyplot as plt, sys
N=25; x=np.linspace(-1.5,1.5,N); y=np.linspace(-1.5,1.5,N); X,Y=np.meshgrid(x,y)
U = X; V = Y
speed = np.sqrt(U**2 + V**2)
plt.figure(figsize=(4,4))
plt.streamplot(X, Y, U, V, color=speed, cmap="plasma", density=1.5, linewidth=0.8)
plt.colorbar(shrink=0.6).set_label(r"$\|\Im(\Phi)\|$", fontsize=8)
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
  '
plot_py "08_leech_kissing" '
import numpy as np, matplotlib.pyplot as plt, sys
np.random.seed(0)
N=200
theta = np.random.uniform(0, 2*np.pi, N)
r = np.ones(N)
x = r * np.cos(theta)
y = r * np.sin(theta)
plt.figure(figsize=(4,4))
plt.scatter(x, y, s=5, c="black", alpha=0.7)
plt.scatter([0], [0], s=80, c="red", edgecolors="k", linewidth=0.5)
plt.text(0, 0, "196560", ha="center", va="center", fontsize=7, color="white")
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
  '
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
plot_py "10_zeta_hopf_stereographic" '
import numpy as np, matplotlib.pyplot as plt, mpmath as mp, sys
mp.mp.dps = 35
zeros = [mp.zeta_zero(n) for n in range(1, 31)]
x = np.array([float(mp.re(z)) for z in zeros])
y = np.array([float(mp.im(z)) for z in zeros])
denom = 1 + x**2 + y**2
X = 2*x / denom
Y = 2*y / denom
Z = (-1 + x**2 + y**2) / denom
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
u = np.linspace(0, 2*np.pi, 40)
v = np.linspace(0, np.pi, 20)
xs = np.outer(np.cos(u), np.sin(v))
ys = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones_like(u), np.cos(v))
ax.plot_wireframe(xs, ys, zs, color="lightgray", linewidth=0.3, alpha=0.4)
ax.scatter(X, Y, Z, c="purple", s=15, depthshade=True)
t_line = np.linspace(0, 50, 200)
x_line = np.full_like(t_line, 0.5)
y_line = t_line
denom_line = 1 + x_line**2 + y_line**2
X_line = 2*x_line / denom_line
Y_line = 2*y_line / denom_line
Z_line = (-1 + x_line**2 + y_line**2) / denom_line
ax.plot(X_line, Y_line, Z_line, color="red", linewidth=1, alpha=0.7)
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
  '
plot_py "11_prime_leech_duality" '
import numpy as np, matplotlib.pyplot as plt, mpmath as mp, sys
mp.mp.dps = 20
def primes_upto(n):
    sieve = np.ones(n+1, dtype=bool)
    sieve[:2] = False
    for i in range(2, int(n**0.5)+1):
        if sieve[i]: sieve[i*i::i] = False
    return np.where(sieve)[0]
primes = primes_upto(100)
x_vals = np.arange(2, 101)
pi_x = np.array([np.sum(primes <= x) for x in x_vals])
Li = np.array([mp.li(x) for x in x_vals])
bound = np.sqrt(x_vals) * np.log(x_vals)
plt.figure(figsize=(5,3))
plt.plot(x_vals, pi_x, "bo", markersize=2)
plt.plot(x_vals, Li, "r-", linewidth=1)
plt.fill_between(x_vals, Li - bound, Li + bound, color="orange", alpha=0.2)
plt.xlim(0,100); plt.ylim(0,30)
plt.gca().set_xticks([]); plt.gca().set_yticks([])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
  '
plot_py "12_hopf_perception" '
import numpy as np, matplotlib.pyplot as plt, sys
t = np.linspace(0, 2*np.pi, 100)
phi = np.linspace(0, np.pi/2, 50)
T, PHI = np.meshgrid(t, phi)
z1 = np.cos(PHI) * np.exp(1j * T)
z2 = np.sin(PHI) * np.exp(1j * T)
X = 2 * np.real(z1 * np.conj(z2))
Y = 2 * np.imag(z1 * np.conj(z2))
Z = np.abs(z1)**2 - np.abs(z2)**2
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
for i in range(0, len(t), 10):
    ax.plot(X[:,i], Y[:,i], Z[:,i], "b-", linewidth=0.8, alpha=0.7)
u = np.linspace(0, 2*np.pi, 30)
v = np.linspace(0, np.pi, 15)
xs = np.outer(np.cos(u), np.sin(v))
ys = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones_like(u), np.cos(v))
ax.plot_wireframe(xs, ys, zs, color="gray", linewidth=0.3, alpha=0.3)
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
  '
plot_py "13_quaternionic_streamlines" '
import numpy as np, matplotlib.pyplot as plt, sys
N=20; x=np.linspace(-2,2,N); y=np.linspace(-2,2,N); X,Y=np.meshgrid(x,y)
E_x, E_y = -Y, X
B_x, B_y = X, Y
U = E_x + B_x
V = E_y + B_y
plt.figure(figsize=(4,4))
plt.streamplot(X, Y, U, V, density=1.8, linewidth=0.7, color="navy", arrowsize=0.5)
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
  '
plot_py "14_zeta_quaternionic_hopf" '
import numpy as np, matplotlib.pyplot as plt, mpmath as mp, sys
mp.mp.dps = 30
t_vals = np.linspace(0.1, 50, 200)
s_vals = 0.5 + 1j * t_vals
zeta_vals = np.array([complex(mp.zeta(s)) for s in s_vals])
norm = np.abs(zeta_vals)
z1 = np.where(norm > 0, zeta_vals / norm, 1+0j)
z2 = np.where(np.abs(z1) <= 1, np.sqrt(1 - np.abs(z1)**2), 0+0j)
X = 2 * np.real(z1 * np.conj(z2))
Y = 2 * np.imag(z1 * np.conj(z2))
Z = np.abs(z1)**2 - np.abs(z2)**2
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
ax.plot(X, Y, Z, "m-", linewidth=1.2, alpha=0.9)
u = np.linspace(0, 2*np.pi, 40)
v = np.linspace(0, np.pi, 20)
xs = np.outer(np.cos(u), np.sin(v))
ys = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones_like(u), np.cos(v))
ax.plot_wireframe(xs, ys, zs, color="lightgray", linewidth=0.2, alpha=0.3)
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
  '
plot_py "15_stereographic_perception" '
import numpy as np, matplotlib.pyplot as plt, sys
fig, axs = plt.subplots(1, 3, figsize=(12,4))
theta = np.linspace(0, 2*np.pi, 100)
x1 = np.cos(theta); y1 = np.sin(theta)
axs[0].plot(x1, y1, "k-", linewidth=1)
axs[0].scatter([0], [1], c="red", s=20)
t_line = np.linspace(-3, 3, 50)
axs[0].plot(t_line, np.zeros_like(t_line), "b--", linewidth=0.8)
for t in [-2, -1, 0, 1, 2]:
    x_proj = 2*t/(1+t**2)
    y_proj = (t**2-1)/(1+t**2)
    axs[0].plot([0, x_proj], [1, y_proj], "g-", linewidth=0.5, alpha=0.6)
axs[0].set_aspect("equal"); axs[0].axis("off")
u = np.linspace(0, 2*np.pi, 30)
v = np.linspace(0, np.pi, 15)
U, V = np.meshgrid(u, v)
xs = np.cos(U)*np.sin(V); ys = np.sin(U)*np.sin(V); zs = np.cos(V)
axs[1].contour(xs, ys, levels=8, colors="k", linewidths=0.5)
axs[1].scatter([0], [0], c="red", s=20)
axs[1].set_aspect("equal"); axs[1].axis("off")
t = np.linspace(0, 2*np.pi, 50)
phi = np.pi/4
z1 = np.cos(phi) * np.exp(1j*t)
z2 = np.sin(phi) * np.exp(1j*t)
X = 2*np.real(z1*np.conj(z2))
Y = 2*np.imag(z1*np.conj(z2))
axs[2].plot(X, Y, "m-", linewidth=1)
axs[2].set_aspect("equal"); axs[2].axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
  '
plot_py "16_aether_vorticity" '
import numpy as np, matplotlib.pyplot as plt, sys
N=25; x=np.linspace(-2,2,N); y=np.linspace(-2,2,N); X,Y=np.meshgrid(x,y)
E_x, E_y = -Y, X
B_z = X**2 + Y**2
omega_z = np.gradient(E_y, axis=1) - np.gradient(E_x, axis=0)
plt.figure(figsize=(4,4))
plt.contourf(X, Y, omega_z, levels=20, cmap="RdBu", alpha=0.8)
plt.colorbar(shrink=0.6).set_label(r"$\omega_z$", fontsize=7)
plt.streamplot(X, Y, E_x, E_y, color="k", linewidth=0.5, density=1.0, alpha=0.7)
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
  '
  plot_py "17_leech_24d_projection" '
import numpy as np, matplotlib.pyplot as plt, sys
np.random.seed(42)
N=500
vec = np.random.normal(size=(N,24))
norms = np.linalg.norm(vec, axis=1, keepdims=True)
vec = vec / norms * 2
proj = vec[:, :3]
x, y, z = proj[:,0], proj[:,1], proj[:,2]
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
ax.scatter(x, y, z, s=8, c="darkgreen", alpha=0.6)
ax.scatter([0],[0],[0], s=50, c="red")
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
  '
}

# 18. QUATERNIONIC AETHER FIELD Φ = E + iB (FULL 4D PROJECTION)
plot_py "18_quaternionic_phi_field" '
import numpy as np, matplotlib.pyplot as plt, sys
N=20; x=np.linspace(-2,2,N); y=np.linspace(-2,2,N); X,Y=np.meshgrid(x,y)
# E = (-y, x, 0) rotational
# B = (x, y, 0) radial
E_x, E_y = -Y, X
B_x, B_y = X, Y
# Total Φ = E + iB
U = E_x + 1j*B_x
V = E_y + 1j*B_y
mag = np.abs(U + 1j*V)
phase = np.angle(U + 1j*V)
plt.figure(figsize=(4,4))
plt.streamplot(X, Y, E_x, E_y, color="blue", linewidth=0.7, density=1.3, alpha=0.8)
plt.streamplot(X, Y, B_x, B_y, color="red", linewidth=0.7, density=1.3, alpha=0.8)
plt.contour(X, Y, mag, levels=10, cmap="viridis", alpha=0.4)
plt.contourf(X, Y, phase, levels=20, cmap="twilight", alpha=0.3)
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 19. HOPF FIBRATION AS STEREOGRAPHIC MODEL OF PERCEPTION
plot_py "19_hopf_perception_model" '
import numpy as np, matplotlib.pyplot as plt, sys
# S3 parameterization
t = np.linspace(0, 2*np.pi, 120)
phi = np.linspace(0, np.pi/2, 60)
T, PHI = np.meshgrid(t, phi)
z1 = np.cos(PHI) * np.exp(1j * T)
z2 = np.sin(PHI) * np.exp(1j * T)
# Hopf map to S2
X = 2 * np.real(z1 * np.conj(z2))
Y = 2 * np.imag(z1 * np.conj(z2))
Z = np.abs(z1)**2 - np.abs(z2)**2
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
# Plot linked circles (fibers)
for i in range(0, len(t), 12):
    ax.plot(X[:,i], Y[:,i], Z[:,i], "b-", linewidth=0.9, alpha=0.8)
# Draw perception axis
ax.quiver(0,0,-1,0,0,2, color="magenta", arrow_length_ratio=0.1, linewidth=1.5)
# Unit sphere
u = np.linspace(0, 2*np.pi, 40)
v = np.linspace(0, np.pi, 20)
xs = np.outer(np.cos(u), np.sin(v))
ys = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones_like(u), np.cos(v))
ax.plot_wireframe(xs, ys, zs, color="gray", linewidth=0.25, alpha=0.3)
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 20. RIEMANN ZETA FUNCTION AS QUATERNIONIC FIELD EXCITATION
plot_py "20_zeta_quaternionic_excitation" '
import numpy as np, matplotlib.pyplot as plt, mpmath as mp, sys
mp.mp.dps = 30
# Grid in critical strip
re_vals = np.linspace(0.1, 0.9, 50)
im_vals = np.linspace(0.1, 50, 200)
RE, IM = np.meshgrid(re_vals, im_vals)
ZETA = np.zeros_like(RE, dtype=complex)
for i in range(RE.shape[0]):
    for j in range(RE.shape[1]):
        s = RE[i,j] + 1j*IM[i,j]
        ZETA[i,j] = complex(mp.zeta(s))
mag = np.abs(ZETA)
phase = np.angle(ZETA)
plt.figure(figsize=(5,4))
plt.contourf(IM, RE, mag, levels=30, cmap="plasma", alpha=0.9)
plt.contour(IM, RE, phase, levels=20, colors="white", linewidths=0.3, alpha=0.5)
plt.axvline(x=0.5, color="cyan", linestyle="--", linewidth=1.2, alpha=0.8)
plt.xlabel(r"$\Im(s)$", fontsize=8); plt.ylabel(r"$\Re(s)$", fontsize=8)
plt.gca().set_xticks([]); plt.gca().set_yticks([])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 21. STEREOGRAPHIC PROJECTION OF S^n → R^n FOR ALL n (PERCEPTION OPERATOR)
plot_py "21_stereographic_perception_operator" '
import numpy as np, matplotlib.pyplot as plt, sys
fig = plt.figure(figsize=(12,4))
# S1 -> R1
ax1 = fig.add_subplot(131)
theta = np.linspace(0, 2*np.pi, 200)
x1 = np.cos(theta); y1 = np.sin(theta)
ax1.plot(x1, y1, "k-", linewidth=1)
ax1.scatter([0], [1], c="red", s=30)
t_line = np.linspace(-4, 4, 100)
ax1.plot(t_line, np.zeros_like(t_line), "b--", linewidth=0.8)
for t in np.linspace(-3, 3, 7):
    denom = 1 + t**2
    x_proj = 2*t / denom
    y_proj = (t**2 - 1) / denom
    ax1.plot([0, x_proj], [1, y_proj], "g-", linewidth=0.5, alpha=0.6)
ax1.set_aspect("equal"); ax1.axis("off")
# S2 -> R2
ax2 = fig.add_subplot(132)
u = np.linspace(0, 2*np.pi, 50)
v = np.linspace(0, np.pi, 30)
U, V = np.meshgrid(u, v)
xs = np.cos(U)*np.sin(V); ys = np.sin(U)*np.sin(V)
ax2.contour(xs, ys, levels=12, colors="k", linewidths=0.4)
ax2.scatter([0], [0], c="red", s=30)
ax2.set_aspect("equal"); ax2.axis("off")
# S3 -> R3 (Hopf fibers)
ax3 = fig.add_subplot(133, projection="3d")
t = np.linspace(0, 2*np.pi, 80)
phi = np.pi/4
z1 = np.cos(phi) * np.exp(1j*t)
z2 = np.sin(phi) * np.exp(1j*t)
X = 2*np.real(z1*np.conj(z2))
Y = 2*np.imag(z1*np.conj(z2))
Z = np.abs(z1)**2 - np.abs(z2)**2
ax3.plot(X, Y, Z, "m-", linewidth=1.2)
u = np.linspace(0, 2*np.pi, 30)
v = np.linspace(0, np.pi, 15)
xs = np.outer(np.cos(u), np.sin(v))
ys = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones_like(u), np.cos(v))
ax3.plot_wireframe(xs, ys, zs, color="gray", linewidth=0.2, alpha=0.3)
ax3.set_axis_off(); ax3.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 22. QUATERNIONIC VORTICITY FIELD: ∇ × Φ = ω (SPIN DENSITY)
plot_py "22_quaternionic_vorticity_spin" '
import numpy as np, matplotlib.pyplot as plt, sys
N=30; x=np.linspace(-2,2,N); y=np.linspace(-2,2,N); X,Y=np.meshgrid(x,y)
# Φ = E + iB; E = (-y, x, 0), B = (x, y, 0)
E_x, E_y = -Y, X
# Vorticity ω = ∇ × E = (0,0,2)
omega_z = np.full_like(X, 2.0)
plt.figure(figsize=(4,4))
plt.contourf(X, Y, omega_z, levels=1, cmap="RdBu", alpha=0.6)
plt.streamplot(X, Y, E_x, E_y, color="k", linewidth=0.7, density=1.5, alpha=0.8)
plt.colorbar(shrink=0.6).set_label(r"$\omega_z = (\nabla \times \Re(\Phi))_z$", fontsize=7)
plt.axis("equal"); plt.axis("off")
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

# 23. LEECH LATTICE KISSING CONFIGURATION (196560 VECTORS)
plot_py "23_leech_kissing_196560" '
import numpy as np, matplotlib.pyplot as plt, sys
# Simulate projection of minimal Leech vectors (norm^2=4)
np.random.seed(123)
N=1000
vec = np.random.normal(size=(N,24))
norms = np.linalg.norm(vec, axis=1, keepdims=True)
vec = vec / norms * 2  # norm=2
proj = vec[:, :3]
x, y, z = proj[:,0], proj[:,1], proj[:,2]
fig = plt.figure(figsize=(4,4))
ax = fig.add_subplot(111, projection="3d")
ax.scatter(x, y, z, s=4, c="purple", alpha=0.5)
ax.scatter([0],[0],[0], s=60, c="gold", edgecolors="k")
ax.text(0,0,0, "196560", color="white", fontsize=6, ha="center", va="center")
ax.set_axis_off(); ax.set_box_aspect([1,1,1])
plt.savefig(sys.argv[1], bbox_inches="tight", dpi=200)
'

echo
echo "✅ Logos Codex visual encyclopedia complete."
```
Then run with...
```bash
cd /data/data/com.termux/files/home/storage/shared/Intelligence/
chmod +x ./doc.sh
bash -x ./doc.sh
```
