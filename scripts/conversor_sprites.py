from PIL import Image

INPUT = "gordo-defendendo.png"
OUTPUT = "gordo-defendendo.asm"
LABEL = "gordo_defendendo"
TILE_SIZE = None  # usa imagem inteira 

def rgb_to_hex(r, g, b):
    return (r << 16) | (g << 8) | b

img = Image.open(INPUT).convert("RGBA")
w, h = img.size

pixels = []

for y in range(h):
    row = []
    for x in range(w):
        r, g, b, a = img.getpixel((x, y))

        
        if a < 10:
            hex_color = 0x00000000
        else:
            hex_color = rgb_to_hex(r, g, b)

        row.append(f"0x{hex_color:08X}")
    pixels.append(row)

with open(OUTPUT, "w") as f:
    f.write(".data\n\n")
    f.write(f"{LABEL}:\n")

    for row in pixels:
        f.write(".word " + ", ".join(row) + "\n")

print(f"Sprite gerado com sucesso em {OUTPUT}")