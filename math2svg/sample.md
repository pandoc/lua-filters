Only plane waves in the far field exhibit the [characteristic impedance of free space](https://en.wikipedia.org/wiki/Impedance_of_free_space), which is exactly:

$$Z_0 = \frac{\left|\vec{E}\right|}{\left|\vec{H}\right|} = \sqrt{\frac{\mu_0}{\epsilon_0}} = \mu_0\cdot c_0 \approx 376.73\,\Omega$$

| where:
| $c_0 = 299\,792\,458\,\frac{\text{m}}{\text{s}}$: the speed of light in free space
| $\mu_0 = 4\pi\cdot10^{-7}\frac{\text{H}}{\text{m}}$: the free space permeability
| $\epsilon_0 = \frac{1}{\mu_0 c_0^2}$: the absolute permittivity of free space
| $Z_0$: the characteristic impedance of free space

---

Euler's formula:

$$\e{\j\omega t} = \cos{\omega t} + \j \sin{\omega t}$$

---

The input impedance $Z_\text{in,$\,$short}$ of a transmission line stub terminated in a short circuit is given by:

$$Z_\text{in,$\,$short} = Z_\text{c} \tanh{(\gamma\ell)} \approx \j\tan{(\beta\ell)}\,Z_\text{c}$$

| where:
| $\gamma = \alpha + \j\beta$ is the [propagation constant $\gamma$](https://en.wikipedia.org/wiki/Propagation_constant#Definition),
| $\alpha$ is the attenuation constant, and
| $\beta$ is the [phase constant](https://en.wikipedia.org/wiki/Propagation_constant#Phase_constant).
