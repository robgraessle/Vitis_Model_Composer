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
    # Calculate path to bulb image based on directory depth
    if relative_path_to_root == ".":
        img_path = "Images/bulb.png"
    else:
        # Count directory depth
        depth = relative_path_to_root.count('/')
        img_path = "../" * depth + "Images/bulb.png"
    
    content = content.replace(':bulb:', f'<img width="18" height="18" src="{img_path}">')
    
    # 2. Replace various README.md link formats with MATLAB API calls
    
    # Format 1: <a href="path/to/folder/README.md">
    pattern1 = r'<a\s+href="[^"]*\/([^\/]+)\/README\.md">'
    content = re.sub(pattern1, r'<a href="matlab:XmcExampleApi.getExample(\'\1\')">', content)
    
    # Format 2: <a href="folder/README.md">
    pattern2 = r'<a\s+href="([^\/]+)\/README\.md">'
    content = re.sub(pattern2, r'<a href="matlab:XmcExampleApi.getExample(\'\1\')">', content)
    
    # Format 3: GitHub URLs to Vitis_Model_Composer
    pattern3 = r'<a\s+href="https?://[^"]*\/Vitis_Model_Composer\/[^"]*\/([^\/]+)\/README\.md">'
    content = re.sub(pattern3, r'<a href="matlab:XmcExampleApi.getExample(\'\1\')">', content)
    
    # Format 4: Directory links (with or without trailing slash)
    pattern4 = r'<a\s+href="[^"]*\/([^\/]+)\/?">(?![^<]*<img)'  # Negative lookahead to avoid image links
    content = re.sub(pattern4, r'<a href="matlab:XmcExampleApi.getExample(\'\1\')">', content)
    
    # 3. Replace VMC Help links with vmcHelp API calls
    pattern_vmc = r'<a\s+href="https://github\.com/Xilinx/VMC_Help/([^/]+)/([^/]+)/README\.md">'
    def replace_vmc_help(match):
        category = match.group(1)
        block_name = match.group(2)
        return f'<a href="matlab:helpview(vmcHelp(name=\'{block_name}\',category=\'{category}\'))">'
    
    content = re.sub(pattern_vmc, replace_vmc_help, content)
    
    # 4. Fix image paths for product display (normalize to ../Images)
    pattern_img = r'src="((?:\.\./)+)Images'
    content = re.sub(pattern_img, 'src="../Images', content)
    
    # 5. Insert HTML for "Open Design" or "Open Lab Directory" button (README.html only)
    if os.path.basename(html_file) == 'README.html' and directory_type:
        content = insert_html_to_open_design(content, directory_type, has_slx_files)
    
    # Write the processed content back
    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return True

def insert_html_to_open_design(content, directory_type, has_slx_files):
    """Insert HTML/JavaScript for Open Design or Lab Directory buttons."""
    
    # Determine which template to use
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    if directory_type == 'Examples' and has_slx_files:
        template_file = os.path.join(script_dir, 'html_text.html')
    elif directory_type == 'Tutorials':
        template_file = os.path.join(script_dir, 'html_text_labs.html')
    else:
        return content  # No button to insert
    
    # Read the template content
    if not os.path.exists(template_file):
        print(f"Template file {template_file} not found")
        return content
        
    with open(template_file, 'r', encoding='utf-8') as f:
        insert_html = f.read()
    
    # Find the <div id='content'> line and insert the HTML after it
    lines = content.split('\n')
    result_lines = []
    
    for i, line in enumerate(lines):
        result_lines.append(line)
        
        # Look for the content div
        if "<div id='content'>" in line:
            # Add the next line (typically empty or start of content)
            if i + 1 < len(lines):
                result_lines.append(lines[i + 1])
                i += 1
            # Insert the button HTML
            result_lines.append(insert_html)
            # Add remaining lines
            result_lines.extend(lines[i + 1:])
            break
    
    return '\n'.join(result_lines)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 post-process-html.py <html_file> <relative_path_to_root> [directory_type] [has_slx_files]")
        sys.exit(1)
    
    html_file = sys.argv[1]
    relative_path = sys.argv[2]
    directory_type = sys.argv[3] if len(sys.argv) > 3 else None
    has_slx_files = sys.argv[4].lower() == 'true' if len(sys.argv) > 4 else False
    
    success = post_process_html(html_file, relative_path, directory_type, has_slx_files)
    if success:
        print(f"Post-processing completed successfully for {html_file}")
    else:
        print(f"Post-processing failed for {html_file}")
        sys.exit(1)