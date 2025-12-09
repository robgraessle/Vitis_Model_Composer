#!/usr/bin/env python3
"""
Simulink Model (.slx) Analysis Script

This script analyzes Simulink .slx files to extract:
1. MATLAB release version
2. Presence of DUT subsystem
3. Hub block platform configuration

Usage: python3 analyze_slx.py <path_to_slx_file>
"""

import sys
import os
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path
import tempfile
import shutil
import json

class SlxAnalyzer:
    def __init__(self, slx_path):
        """Initialize analyzer with path to .slx file."""
        self.slx_path = Path(slx_path)
        self.results = {
            'file_path': str(self.slx_path),
            'matlab_release': None,
            'has_dut_subsystem': False,
            'hub_platform_configured': False,
            'hub_platform_info': {},
            'error': None
        }
        
    def analyze(self):
        """Main analysis function."""
        try:
            if not self.slx_path.exists():
                raise FileNotFoundError(f"File not found: {self.slx_path}")
            
            if not self.slx_path.suffix.lower() == '.slx':
                raise ValueError(f"Not a .slx file: {self.slx_path}")
            
            # Extract .slx file (it's a ZIP archive)
            with tempfile.TemporaryDirectory() as temp_dir:
                with zipfile.ZipFile(self.slx_path, 'r') as zip_ref:
                    zip_ref.extractall(temp_dir)
                
                temp_path = Path(temp_dir)
                
                # 1. Get MATLAB release version
                self._get_matlab_release(temp_path)
                
                # 2. Check for DUT subsystem
                self._check_dut_subsystem(temp_path)
                
                # 3. Check Hub block platform configuration
                self._check_hub_platform(temp_path)
                
        except Exception as e:
            self.results['error'] = str(e)
        
        return self.results
    
    def _get_matlab_release(self, temp_path):
        """Extract MATLAB release version from metadata."""
        try:
            # Check mwcoreProperties.xml first (most reliable)
            mw_props_file = temp_path / 'metadata' / 'mwcoreProperties.xml'
            if mw_props_file.exists():
                tree = ET.parse(mw_props_file)
                root = tree.getroot()
                
                # Handle namespace
                ns = {'mw': 'http://schemas.mathworks.com/package/2012/coreProperties'}
                release_elem = root.find('mw:matlabRelease', ns)
                if release_elem is not None:
                    self.results['matlab_release'] = release_elem.text
                    return
            
            # Fallback to coreProperties.xml
            core_props_file = temp_path / 'metadata' / 'coreProperties.xml'
            if core_props_file.exists():
                tree = ET.parse(core_props_file)
                root = tree.getroot()
                
                # Handle namespace for core properties
                ns = {'cp': 'http://schemas.openxmlformats.org/package/2006/metadata/core-properties'}
                version_elem = root.find('cp:version', ns)
                if version_elem is not None:
                    self.results['matlab_release'] = version_elem.text
                    return
                    
        except Exception as e:
            print(f"Warning: Could not parse MATLAB release info: {e}")
    
    def _check_dut_subsystem(self, temp_path):
        """Check if model has a DUT subsystem."""
        try:
            system_root_file = temp_path / 'simulink' / 'systems' / 'system_root.xml'
            if not system_root_file.exists():
                return
                
            tree = ET.parse(system_root_file)
            root = tree.getroot()
            
            # Look for SubSystem blocks named 'DUT'
            for block in root.findall('.//Block'):
                block_type = block.get('BlockType')
                name_attr = block.get('Name')
                
                if block_type == 'SubSystem' and name_attr == 'DUT':
                    self.results['has_dut_subsystem'] = True
                    return
                    
        except Exception as e:
            print(f"Warning: Could not check for DUT subsystem: {e}")
    
    def _check_hub_platform(self, temp_path):
        """Check Hub block platform configuration."""
        try:
            system_root_file = temp_path / 'simulink' / 'systems' / 'system_root.xml'
            if not system_root_file.exists():
                return
                
            tree = ET.parse(system_root_file)
            root = tree.getroot()
            
            # Look for Vitis Model Composer Hub block
            hub_blocks = []
            for block in root.findall('.//Block[@BlockType="Reference"]'):
                source_block = block.find('P[@Name="SourceBlock"]')
                if (source_block is not None and 
                    'Hub' in source_block.text and 
                    ('vmcUtilities' in source_block.text or 'Vitis Model Composer' in source_block.text)):
                    hub_blocks.append(block)
            
            # Analyze Hub block configuration
            for hub_block in hub_blocks:
                instance_data = hub_block.find('InstanceData')
                if instance_data is not None:
                    platform_info = self._extract_platform_info(instance_data)
                    if platform_info:
                        self.results['hub_platform_configured'] = True
                        self.results['hub_platform_info'] = platform_info
                        break
                        
        except Exception as e:
            print(f"Warning: Could not check Hub block configuration: {e}")
    
    def _extract_platform_info(self, instance_data):
        """Extract platform configuration from Hub block InstanceData."""
        platform_info = {}
        
        try:
            # Key parameters to look for
            key_params = {
                'PlatformType': 'platform_type',
                'Platform': 'platform_path', 
                'ProjDevice': 'device',
                'ProjDevicePart': 'device_part',
                'ExportType': 'export_type',
                'AIEType': 'aie_type'
            }
            
            for param in instance_data.findall('P'):
                name_attr = param.get('Name')
                if name_attr in key_params:
                    platform_info[key_params[name_attr]] = param.text
            
            # Determine if platform is configured
            platform_type = platform_info.get('platform_type', '')
            platform_path = platform_info.get('platform_path', '')
            
            # Check if it's platform-based configuration
            is_platform = (
                platform_type == 'Specify Platform' or
                (platform_path and platform_path.endswith('.xpfm'))
            )
            
            if is_platform:
                platform_info['is_platform_based'] = True
                # Extract platform name from path
                if platform_path:
                    platform_name = Path(platform_path).stem
                    platform_info['platform_name'] = platform_name
            else:
                platform_info['is_platform_based'] = False
                
            return platform_info
            
        except Exception as e:
            print(f"Warning: Could not extract platform info: {e}")
            return {}

def format_results(results):
    """Format results for display."""
    print("=" * 60)
    print("SIMULINK MODEL ANALYSIS RESULTS")
    print("=" * 60)
    
    print(f"File: {results['file_path']}")
    
    if results['error']:
        print(f"[ERROR] {results['error']}")
        return
    
    # MATLAB Release
    print(f"\n1. MATLAB Release: {results['matlab_release'] or 'Unknown'}")
    
    # DUT Subsystem  
    dut_status = "[YES]" if results['has_dut_subsystem'] else "[NO]"
    print(f"2. Has DUT Subsystem: {dut_status}")
    
    # Hub Platform Configuration
    hub_status = "[YES]" if results['hub_platform_configured'] else "[NO]" 
    print(f"3. Hub Platform Configured: {hub_status}")
    
    # Platform Details
    if results['hub_platform_info']:
        platform_info = results['hub_platform_info']
        print(f"\n   Platform Details:")
        
        if platform_info.get('platform_name'):
            print(f"   - Platform Name: {platform_info['platform_name']}")
        
        if platform_info.get('device'):
            print(f"   - Target Device: {platform_info['device']}")
            
        if platform_info.get('device_part'):
            print(f"   - Device Part: {platform_info['device_part']}")
            
        if platform_info.get('export_type'):
            print(f"   - Export Type: {platform_info['export_type']}")
            
        if platform_info.get('aie_type'):
            print(f"   - AIE Type: {platform_info['aie_type']}")
            
        if platform_info.get('platform_path'):
            print(f"   - Platform Path: {platform_info['platform_path']}")
    
    print("=" * 60)

def main():
    """Main entry point."""
    if len(sys.argv) != 2:
        print("Simulink Model (.slx) Analysis Tool")
        print("=" * 40)
        print("Usage: python3 analyze_slx.py <path_to_slx_file>")
        print("\nExamples:")
        print("  python3 analyze_slx.py Examples/AIENGINE/DSPlib/fft/fft_dsp_lib.slx")
        print("  python3 analyze_slx.py Examples/HDL/AXI_IP/Complex_Multiplier/ComplexMultiplier.slx")
        print("\nThis script extracts:")
        print("  1. MATLAB release version")
        print("  2. Presence of DUT subsystem")  
        print("  3. Hub block platform configuration")
        sys.exit(1)
    
    slx_file = sys.argv[1]
    
    # Analyze the .slx file
    analyzer = SlxAnalyzer(slx_file)
    results = analyzer.analyze()
    
    # Display results
    format_results(results)
    
    # Return appropriate exit code
    if results['error']:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == "__main__":
    main()