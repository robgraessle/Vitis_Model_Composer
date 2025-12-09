#!/bin/bash
# Test script to analyze multiple .slx files

echo "Testing analyze_slx.py with multiple model files..."
echo "======================================================"

# Find a few different types of models
test_files=(
    "Examples/AIENGINE/DSPlib/fft/fft_dsp_lib.slx"
    "Examples/AIENGINE/DSPlib/fir/fir.slx" 
    "Examples/HDL/AXI_IP/Complex_Multiplier/ComplexMultiplier.slx"
)

for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        echo ""
        echo "Testing: $file"
        echo "----------------------------------------"
        python3 util/analyze_slx.py "$file"
        echo ""
    else
        echo "Skipping $file (not found)"
    fi
done

echo "Test completed."