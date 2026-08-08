#!/bin/bash
# Script to run all experiments sequentially and record the generated run in run_info.md

# Ensure we are in the sar_logic_diff directory
cd "$(dirname "$0")/.."

# Create runs directory if it doesn't exist
mkdir -p runs

for EXP_DIR in experiments/*; do
  if [ -d "$EXP_DIR" ]; then
    echo "========================================"
    echo "Running experiment: $EXP_DIR"
    echo "========================================"
    
    # 1. Update symlinks to point to the current experiment
    rm -f config.yaml base.sdc
    
    # We only symlink base.sdc if it exists in the experiment directory
    if [ -f "$EXP_DIR/base.sdc" ]; then
        ln -s "$EXP_DIR/base.sdc" base.sdc
    fi
    
    if [ -f "$EXP_DIR/config.yaml" ]; then
        ln -s "$EXP_DIR/config.yaml" config.yaml
    else
        echo "Skipping $EXP_DIR - No config.yaml found."
        continue
    fi
    
    # 2. Run librelane
    # Using the correct syntax based on the LibreLane help output
    librelane config.yaml
    
    # 3. Find the newest run generated
    LATEST_RUN=$(ls -td runs/* 2>/dev/null | head -1)
    
    if [ -n "$LATEST_RUN" ]; then
      LATEST_RUN_NAME=$(basename "$LATEST_RUN")
      
      echo "Experiment $EXP_DIR generated run: $LATEST_RUN_NAME"
      
      # 4. Update run_info.md with the run name
      if [ -f "$EXP_DIR/run_info.md" ]; then
        # Replace the placeholder if it exists
        sed -i "s/\*(Update this when LibreLane finishes running)\*/$LATEST_RUN_NAME/g" "$EXP_DIR/run_info.md"
        
        # Also ensure we append it clearly at the end just in case the placeholder was missing
        if ! grep -q "$LATEST_RUN_NAME" "$EXP_DIR/run_info.md"; then
          echo "" >> "$EXP_DIR/run_info.md"
          echo "**Latest Run**: $LATEST_RUN_NAME" >> "$EXP_DIR/run_info.md"
        fi
      else
        # If no run_info.md exists, create one
        echo "# Run Info for $(basename "$EXP_DIR")" > "$EXP_DIR/run_info.md"
        echo "**Associated Run**: $LATEST_RUN_NAME" >> "$EXP_DIR/run_info.md"
      fi
    else
      echo "Warning: No run directory found in runs/ after execution for $EXP_DIR."
    fi
    
    echo "========================================"
    echo "Finished $EXP_DIR"
    echo "========================================"
    echo ""
  fi
done

echo "All experiments finished!"
