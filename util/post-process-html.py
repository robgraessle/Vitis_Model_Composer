#!/usr/bin/env python3
"""
Post-processing script for README.html files to match the MATLAB process_examples.m functionality.

Usage: python3 post-process-html.py <html_file> <relative_path_to_root>
"""

import re
import sys
import os

def post_process_html(html_file, relative_path_to_root, directory_type=None, has_slx_files=False):
    """Post-process HTML file with MATLAB-compatible transformations."""
    
    if not os.path.exists(html_file):
        print(f"HTML file {html_file} not found")
        return False
    
    with open(html_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. Replace markdown emojis with image tags
    img_path = "Images/bulb.png" if relative_path_to_root == "." else "../" * relative_path_to_root.count('/') + "Images/bulb.png"
    content = content.replace(':bulb:', f'<img width="18" height="18" src="{img_path}">')
    
    # 2. Replace README.md links with MATLAB API calls
    # VMC Help links (needs function replacement)
    def replace_vmc_help(match):
        category, block_name = match.groups()
        return f'<a href="matlab:helpview(vmcHelp(name=\'{block_name}\',category=\'{category}\'))">'
    
    content = re.sub(r'<a\s+href="https://github\.com/Xilinx/VMC_Help/([^/]+)/([^/]+)/README\.md">', replace_vmc_help, content)
    
    # Other README.md links (using functions for proper quote handling)
    def replace_readme_link(match):
        folder_name = match.group(1)
        return f'<a href="matlab:XmcExampleApi.getExample(\'{folder_name}\')">'
    
    patterns = [
        # README.md links with optional ./ prefix
        r'<a\s+href="(?:\./)?(?:[^"]*\/)?([^\/]+)\/README\.md">',
        # GitHub Vitis_Model_Composer URLs
        r'<a\s+href="https?://[^"]*\/Vitis_Model_Composer\/[^"]*\/([^\/]+)\/README\.md">',
        # Directory links (avoiding image links)
        r'<a\s+href="[^"]*\/([^\/]+)\/?">(?![^<]*<img)'
    ]
    
    for pattern in patterns:
        content = re.sub(pattern, replace_readme_link, content)
    
    # 3. Normalize image paths (preserve simple "Images/" for root files)
    content = re.sub(r'src="(\.+/)+Images/', 'src="../Images/', content)
    
    # 4. Insert button HTML if applicable
    if os.path.basename(html_file) == 'README.html' and directory_type:
        content = insert_html_to_open_design(content, directory_type, has_slx_files)
    
    # Write processed content back
    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return True

def insert_html_to_open_design(content, directory_type, has_slx_files):
    """Insert HTML/JavaScript for Open Design or Lab Directory buttons."""
    
    # Determine template file
    template_name = None
    if directory_type == 'Examples' and has_slx_files:
        template_name = 'html_text.html'
    elif directory_type == 'Tutorials':
        template_name = 'html_text_labs.html'
    
    if not template_name:
        return content
    
    # Read template content
    script_dir = os.path.dirname(os.path.abspath(__file__))
    template_file = os.path.join(script_dir, template_name)
    
    try:
        with open(template_file, 'r', encoding='utf-8') as f:
            insert_html = f.read()
    except FileNotFoundError:
        print(f"Template file {template_file} not found")
        return content
    
    # Insert HTML after <div id='content'> using regex (more efficient than line-by-line)
    return re.sub(
        r"(<div id='content'>)(.*?\n)",
        r'\1\2' + insert_html + '\n',
        content,
        count=1
    )

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 post-process-html.py <html_file> <relative_path_to_root> [directory_type] [has_slx_files]")
        sys.exit(1)
    
    # Parse arguments
    html_file, relative_path = sys.argv[1:3]
    directory_type = sys.argv[3] if len(sys.argv) > 3 else None
    has_slx_files = len(sys.argv) > 4 and sys.argv[4].lower() == 'true'
    
    # Process file and exit with appropriate code
    success = post_process_html(html_file, relative_path, directory_type, has_slx_files)
    print(f"Post-processing {'completed successfully' if success else 'failed'} for {html_file}")
    sys.exit(0 if success else 1)