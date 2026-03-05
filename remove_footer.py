import os
import re

directory = 'lovista-frontend/src/views'

footer_tag_pattern = re.compile(r'<TheFooter.*?\/>')
footer_import_pattern = re.compile(r'import TheFooter from.*?;?\n')

def clean_footers():
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.vue'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = footer_tag_pattern.sub('', content)
                new_content = footer_import_pattern.sub('', new_content)
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Cleaned footer from: {filepath}")

if __name__ == "__main__":
    clean_footers()
