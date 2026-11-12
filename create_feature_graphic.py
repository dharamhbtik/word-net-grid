from PIL import Image, ImageDraw, ImageFont, ImageFilter
import random
import os

def create_feature_graphic():
    width = 1024
    height = 500
    
    # Brand Colors
    color_start = (44, 62, 80)   # #2C3E50 (Dark Blue)
    color_end = (52, 152, 219)   # #3498DB (Light Blue)
    
    # Create Gradient Background
    base = Image.new('RGB', (width, height), color_start)
    top = Image.new('RGB', (width, height), color_end)
    mask = Image.new('L', (width, height))
    mask_data = []
    for y in range(height):
        for x in range(width):
            mask_data.append(int(255 * (x / width + y / height) / 2))
    mask.putdata(mask_data)
    base.paste(top, (0, 0), mask)
    
    draw = ImageDraw.Draw(base)
    
    # Draw Scattered Letters Background
    letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    try:
        # Try to load a font, otherwise default
        font_path = "/System/Library/Fonts/Helvetica.ttc" # iOS/Mac standard
        if not os.path.exists(font_path):
             font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" # Linux fallback
             
        bg_font = ImageFont.truetype(font_path, 80)
    except:
        bg_font = ImageFont.load_default()

    for _ in range(20):
        char = random.choice(letters)
        x = random.randint(0, width)
        y = random.randint(0, height)
        # Random opacity white
        opacity = random.randint(10, 40)
        
        # Create a temporary transparent image for the text
        txt_img = Image.new('RGBA', (100, 100), (255, 255, 255, 0))
        d = ImageDraw.Draw(txt_img)
        d.text((0, 0), char, font=bg_font, fill=(255, 255, 255, opacity))
        
        # Rotate randomly
        txt_img = txt_img.rotate(random.randint(-30, 30), expand=1)
        
        # Paste
        base.paste(txt_img, (x, y), txt_img)

    # Draw "Glossy" Overlay (simple white gradient at top left)
    gloss = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(gloss)
    gdraw.ellipse((-200, -200, 600, 400), fill=(255, 255, 255, 20))
    base.paste(gloss, (0, 0), gloss)

    # Draw Title
    title_text = "WORDNET"
    subtitle_text = "GRID"
    
    try:
         title_font = ImageFont.truetype(font_path, 120)
         subtitle_font = ImageFont.truetype(font_path, 80)
    except:
         title_font = ImageFont.load_default()
         subtitle_font = ImageFont.load_default()

    # Center Text
    # getbbox returns (left, top, right, bottom)
    bbox_title = draw.textbbox((0, 0), title_text, font=title_font)
    w_title = bbox_title[2] - bbox_title[0]
    h_title = bbox_title[3] - bbox_title[1]
    
    bbox_sub = draw.textbbox((0, 0), subtitle_text, font=subtitle_font)
    w_sub = bbox_sub[2] - bbox_sub[0]
    
    cx, cy = width // 2, height // 2
    
    # Shadow
    draw.text((cx - w_title // 2 + 4, cy - h_title + 4), title_text, font=title_font, fill=(0, 0, 0, 100))
    draw.text((cx - w_sub // 2 + 4, cy + 20 + 4), subtitle_text, font=subtitle_font, fill=(0, 0, 0, 100))

    # Main Text
    draw.text((cx - w_title // 2, cy - h_title), title_text, font=title_font, fill=(255, 255, 255))
    draw.text((cx - w_sub // 2, cy + 20), subtitle_text, font=subtitle_font, fill=(200, 230, 255)) # Light Blue
    
    # Save
    output_path = "assets/feature_graphic.png"
    base.save(output_path)
    print(f"Feature graphic saved to {output_path}")

if __name__ == "__main__":
    create_feature_graphic()
