import json
import sys

def convert_words():
    try:
        with open('assets/words/words.json', 'r') as f:
            # It's currently a text file despite .json extension
            content = f.read()
        
        # Split by lines
        words = content.splitlines()
        
        # Filter and process
        # 1. Length 3-8 chars
        # 2. Uppercase
        # 3. Only alpha
        filtered_words = []
        for w in words:
            w = w.strip()
            if 3 <= len(w) <= 9 and w.isalpha():
                filtered_words.append(w.upper())
        
        # Save as valid JSON array
        with open('assets/words/words.json', 'w') as f:
            json.dump(filtered_words, f)
            
        print(f"Mapped {len(filtered_words)} words to JSON")
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    convert_words()
