import sys, numpy as np
from PIL import Image, ImageFilter

def riempi_da_bordo(libero):
    seme = np.zeros_like(libero)
    seme[0,:]=libero[0,:]; seme[-1,:]=libero[-1,:]; seme[:,0]=libero[:,0]; seme[:,-1]=libero[:,-1]
    r = seme.copy()
    while True:
        n = r.copy()
        n[1:,:] |= r[:-1,:]; n[:-1,:] |= r[1:,:]; n[:,1:] |= r[:,:-1]; n[:,:-1] |= r[:,1:]
        n &= libero
        if (n == r).all(): return r
        r = n

def filtro(mask, f):
    return np.asarray(Image.fromarray((mask*255).astype(np.uint8)).filter(f)) > 127

src, dst = sys.argv[1], sys.argv[2]
im = Image.open(src).convert('RGB')
a = np.asarray(im)
dark = a.astype(np.int16).max(axis=2) < 38
fg = ~riempi_da_bordo(dark)
fg = filtro(filtro(fg, ImageFilter.MaxFilter(3)), ImageFilter.MinFilter(3))
def morbido(mask, r, soglia):
    b = Image.fromarray((mask*255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(r))
    return np.asarray(b) > soglia*255
chiuso = morbido(fg, 9, 0.16) | fg
chiuso = ~riempi_da_bordo(~chiuso)
bordo = morbido(chiuso, 3, 0.2)
out = np.zeros(a.shape[:2] + (4,), np.uint8)
out[bordo] = [236, 226, 204, 255]
out[chiuso, :3] = a[chiuso]
out[chiuso, 3] = 255
Image.fromarray(out, 'RGBA').save(dst)
