#!/usr/bin/env python3
"""
Generate index.csv mapping unique directory names to their paths.
Replicates the functionality of process_examples.m for directory indexing.
"""

import os
import sys
from pathlib import Path
import csv

def get_directory_name(path):
    """Extract the directory name from a path, similar to MATLAB regexp logic."""
    return Path(path).name

def should_include_directory(dir_path):
    """
    Determine if a directory should be included in the index.
    Include directories that have:
    - .md files, OR
    - .slx files AND path contains 'Block_Help'
    """
    has_md = any(f.suffix == '.md' for f in dir_path.iterdir() if f.is_file())
    has_slx = any(f.suffix == '.slx' for f in dir_path.iterdir() if f.is_file())
    is_block_help = 'Block_Help' in str(dir_path)
    
    return has_md or (has_slx and is_block_help)

def recurse_through_directories(base_path, current_path, index_dict, depth=0, max_depth=5):
    """
    Recursively traverse directories up to max_depth levels.
    Replicates the MATLAB recurseThroughDir function logic.
    MATLAB code stops at cnt == 5, which means it goes 5 levels deep.
    """
    if depth >= max_depth:
        return
    
    try:
        # Get all subdirectories
        subdirs = [d for d in current_path.iterdir() 
                  if d.is_dir() and d.name not in {'.git', '.', '..'}]
        
        # Check if current directory should be included
        if should_include_directory(current_path):
            dir_name = get_directory_name(current_path)
            relative_path = current_path.relative_to(base_path)
            
            # Handle duplicate names by adding suffix
            original_name = dir_name
            counter = 1
            while dir_name in index_dict:
                dir_name = f"{original_name}_{counter}"
                counter += 1
            
            # Special case for root directory
            if current_path == base_path:
                index_dict["Vitis_Model_Composer"] = ""
            else:
                index_dict[dir_name] = str(relative_path)
        
        # Recursively process subdirectories
        for subdir in subdirs:
            recurse_through_directories(base_path, subdir, index_dict, depth + 1, max_depth)
            
    except PermissionError:
        print(f"Permission denied: {current_path}")
    except Exception as e:
        print(f"Error processing {current_path}: {e}")

def generate_index_csv(repo_path="."):
    """
    Generate index.csv file mapping directory names to paths.
    """
    base_path = Path(repo_path).resolve()
    index_dict = {}
    
    # Remove existing index.csv if it exists
    index_file = base_path / "index.csv"
    if index_file.exists():
        index_file.unlink()
    
    print(f"Processing directories starting from: {base_path}")
    
    # Build the index dictionary
    recurse_through_directories(base_path, base_path, index_dict)
    
    # Write CSV file with keys in first row, values in second row
    if index_dict:
        with open(index_file, 'w', newline='', encoding='utf-8') as csvfile:
            # Sort keys for consistent output
            sorted_keys = sorted(index_dict.keys())
            sorted_values = [index_dict[key] for key in sorted_keys]
            
            writer = csv.writer(csvfile)
            writer.writerow(sorted_keys)   # First row: directory names
            writer.writerow(sorted_values) # Second row: corresponding paths
            
        print(f"Generated index.csv with {len(index_dict)} entries")
        print(f"Index file written to: {index_file}")
    else:
        print("No directories found matching criteria")

def main():
    """Main entry point."""
    repo_path = sys.argv[1] if len(sys.argv) > 1 else "."
    
    try:
        generate_index_csv(repo_path)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()