#!/bin/bash

## Version 0.1 ###############
## Last Updated: [8-7-2025] ##
##############################

# Function to generate N2 spindle pulses with voice prompt
function n2_spindles() {
  local BURST_DURATION=5
  local MIN_INTERVAL=60
  local MAX_INTERVAL=90
  local TOTAL_TIME=0
  local VOICE_DURATION=5
  local SPINDLE_COUNT=0
  local VOICE_DIR="audio"
  local MIN_RANDOM_DELAY=3
  local MAX_RANDOM_DELAY=5

  echo "Generating N2 spindles with randomized voice delays"
  echo "Voice directory: $VOICE_DIR"

  while (( TOTAL_TIME < 600 )); do
    # Play spindle burst
    play -q -r 44100 -n synth $BURST_DURATION whitenoise \
      tremolo 16.18 70 \
      phaser 0.8 0.7 0.2 0.4 0.1 -s \
      remix - \
      gain -12 \
      fade t 0.2 $BURST_DURATION 0.2
    
    ((TOTAL_TIME += BURST_DURATION))
    ((SPINDLE_COUNT++))
    echo "⏱️ Spindle $SPINDLE_COUNT at $TOTAL_TIME"

    # Skip voice on final spindle
    if (( TOTAL_TIME + VOICE_DURATION >= 600 )); then
      echo "Final spindle reached - skipping voice"
      break
    fi

    # Add random delay (3–5s) before voice
    local DELAY=$((MIN_RANDOM_DELAY + RANDOM % (MAX_RANDOM_DELAY - MIN_RANDOM_DELAY + 1)))
    echo "⏳ Adding $DELAYs delay before voice"
    sleep $DELAY
    ((TOTAL_TIME += DELAY))

    # Random voice selection
    local VOICE_NUM=$((RANDOM % 9 + 1))  # 1–9
    local VOICE_FILE="$VOICE_DIR/${VOICE_NUM}_Voice.mp3"

    # Insert voice after every spindle
    if [[ -f "$VOICE_FILE" ]]; then
      echo "🔊 Inserting voice $VOICE_NUM: 'Do you dreaming?'"
      play -q -t mp3 "$VOICE_FILE" remix - gain -3
      ((TOTAL_TIME += VOICE_DURATION))
    else
      echo "❌ Voice file missing: $VOICE_FILE"
    fi

    # Add randomized silence
    if (( TOTAL_TIME < 600 )); then
      INTERVAL=$((MIN_INTERVAL + RANDOM % (MAX_INTERVAL - MIN_INTERVAL + 1)))
      echo "⏳ Adding $INTERVALs silence"
      sleep $INTERVAL
      ((TOTAL_TIME += INTERVAL))
    fi
  done
}

# Sleep stage labels
declare -A STAGES=(
  [1]="N1  🌑 | Brown noise + 7.83Hz (Schumann)"
  [2]="N2  🌒 | Pink noise + 4.854Hz (Theta/PHI*3)"
  [3]="N3  🌑 | Brown noise + 1.618Hz (Delta/PHI)"
  [4]="N3  🌑 | Brown noise + 0.618Hz (Delta/phi)"
  [5]="N3  🌑 | Brown noise + 0.618Hz (Delta/phi)"
  [6]="N2  🌒 | Pink noise + 6.18Hz (Theta/PHI*10)"
  [7]="REM 🌕 | White noise + 16.18Hz (Beta/PHI*10)"
  [8]="REM 🌕 | White noise + 16.18Hz 5sec spindle pulses"
  [9]="N2  🌒 | Pink noise + 6.18Hz (Theta/PHI*3.81)"
  [10]="N2 🌒 | Brown noise + 1.618Hz (Delta/PHI)"
  [11]="N3 🌑 | Pink noise + 6.18Hz (Theta/PHI*10)"
  [12]="N2 🌒 | Pink noise + 6.18Hz (Theta/PHI*10)"
)

# Loop through all segments
for i in {1..12}; do
  # Calculate time range
  START=$(( (i-1)*10 ))
  END=$(( i*10 ))
  
  # Phaser level & frequency
  PHASER_LEVEL=0.1 # DEFAULT: 0.4; MAX:0.5 (clip); MIN:0.0 (OFF)
  PHASER_FREQ=0.1  # DEFAULT: 0.1 (10 sec); MAX:2 (Hz); MIN:0.1
  
  # Date and time
  TIMESTAMP=$(date +%F_%T)
  
  # Print stage info
  echo -e "\n Segment $i ($START–$END min): ${STAGES[$i]} | $TIMESTAMP"
  
  # Play segment
  case $i in
    1) play -r 44100 -n synth 600 brownnoise fade p 10 0 10 gain -6 tremolo 7.83 50 phaser 0.8 0.8 0.2 $PHASER_LEVEL $PHASER_FREQ -s remix - ;;
    2) play -r 44100 -n synth 600 pinknoise fade p 10 0 10 gain -8 tremolo 4.854 50 phaser 0.8 0.8 0.2 $PHASER_LEVEL $PHASER_FREQ -s remix - ;;
    3) play -r 44100 -n synth 600 brownnoise fade p 10 0 10 gain -6 tremolo 1.618 70 phaser 0.8 0.8 0.2 $PHASER_LEVEL $PHASER_FREQ -s remix - ;;
    4) play -r 44100 -n synth 600 brownnoise fade p 10 0 10 gain -6 tremolo 0.618 70 phaser 0.8 0.8 0.2 $PHASER_LEVEL $PHASER_FREQ -s remix - ;;
    5) play -r 44100 -n synth 600 brownnoise fade p 10 0 10 gain -6 tremolo 0.618 70 phaser 0.8 0.8 0.2 $PHASER_LEVEL $PHASER_FREQ -s remix - ;;
    6) play -r 44100 -n synth 600 pinknoise fade p 10 0 10 gain -8 tremolo 6.18 50 phaser 0.8 0.8 0.2 $PHASER_LEVEL $PHASER_FREQ -s remix - ;;
    7) play -r 44100 -n synth 600 whitenoise fade p 10 0 0 gain -12 tremolo 16.18 50 phaser 0.8 0.8 0.2 $PHASER_LEVEL $PHASER_FREQ -s remix - ;;
    8) n2_spindles ;;  # With voice prompt "Do you dreaming?"
    9) play -r 44100 -n synth 600 pinknoise fade p 0 0 10 gain -8 tremolo 6.18 50 phaser 0.8 0.8 0.2 $PHASER_LEVEL $PHASER_FREQ -s remix - ;;
    10) play -r 44100 -n synth 600 brownnoise fade p 10 0 10 gain -6 tremolo 1.618 70 phaser 0.8 0.8 0.2 $PHASER_LEVEL $PHASER_FREQ -s remix - ;;
    11) play -r 44100 -n synth 600 pinknoise fade p 10 0 10 gain -8 tremolo 6.18 50 phaser 0.8 0.8 0.2 $PHASER_LEVEL $PHASER_FREQ -s remix - ;;
    12) play -r 44100 -n synth 600 pinknoise fade p 10 0 10 gain -8 tremolo 6.18 50 phaser 0.8 0.8 0.2 $PHASER_LEVEL $PHASER_FREQ -s remix - ;;
  esac
done

## END
