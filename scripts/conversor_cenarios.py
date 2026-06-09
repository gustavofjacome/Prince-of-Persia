from PIL import Image

# ==========================================
# CONFIGURAÇÕES
# ==========================================

INPUT_IMAGE = "pikachu.png" #colocar o nome do arquivo .png que sera convertido
OUTPUT_FILE = "pikachu.asm" #colocar o nome do arquivo .asm que sera gerado

BASE_LABEL = "pika" # configurar corretamenteo o valor do rotulo que estara configurado no asm gerado

TRANSPARENT_COLOR = "0xFFFFFFFF"

img = Image.open(INPUT_IMAGE).convert("RGBA")

width, height = img.size

with open(OUTPUT_FILE, "w") as f:

    f.write(".data\n\n") 

    f.write(f"{BASE_LABEL}_width: .word {width}\n")
    f.write(f"{BASE_LABEL}_height: .word {height}\n\n")

    f.write(f"{BASE_LABEL}:\n")

    for y in range(height):

        f.write(f"\n    # linha {y}\n")

        row_pixels = []

        for x in range(width):

            r, g, b, a = img.getpixel((x, y))

            if a == 0:
                row_pixels.append(TRANSPARENT_COLOR)

            else:
                hex_color = (r << 16) | (g << 8) | b
                row_pixels.append(f"0x{hex_color:06X}")

        # print compactado para economizar linhas, (antes tinha 50k)
        f.write("    .word ")
        f.write(", ".join(row_pixels))
        f.write("\n")


total_pixels = width * height

print("===================================")
print("ASM gerado com sucesso!")
print("===================================")
print(f"Imagem: {INPUT_IMAGE}")
print(f"Saída : {OUTPUT_FILE}")
print(f"Largura : {width}")
print(f"Altura  : {height}")
print(f"Pixels  : {total_pixels}")
print("===================================")