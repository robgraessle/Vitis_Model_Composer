#!/usr/bin/env python3
"""
Post-processing script for README.html files to match the MATLAB process_examples.m functionality.

Usage: python3 post-process-html.py <html_file> <relative_path_to_root>
"""

import re
import sys
import os

def post_process_html(html_file, relative_path_to_root):
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
    
    # Write the processed content back
    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return True

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 post-process-html.py <html_file> <relative_path_to_root>")
        sys.exit(1)
    
    html_file = sys.argv[1]
    relative_path = sys.argv[2]
    
    success = post_process_html(html_file, relative_path)
    if success:
        print(f"Post-processing completed successfully for {html_file}")
    else:
        print(f"Post-processing failed for {html_file}")
        sys.exit(1)