#!/bin/bash

# Lucid Dream Sequencer
# A Prototype

## Version 0.1 ###############
## Last Updated: [4-7-2025] ##
##############################

# READ DISCLAIMER ABOUT LISTENING RESPONSIBILITY & SAFETY FIRST!! (Find below)

# ⚠️ Experimental Tool Disclaimer ⚠️

# This is an experimental prototype. The Lucid Dream Sequencer was created with good intentions but
# has not undergone rigorous testing or validation for safety, efficacy, or reliability. 
# It may contain flaws, inaccuracies, or unintended effects.

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
  [1]="N1 🌑  | Brown noise + 7.83Hz (Schumann)"
  [2]="N2 🌒  | Pink noise + 4.854Hz (Theta/PHI*3)"
  [3]="N3 🌑  | Brown noise + 1.618Hz (Delta/PHI)"
  [4]="N3 🌑  | Brown noise + 0.618Hz (Delta/phi)"
  [5]="N3 🌑  | Brown noise + 0.618Hz (Delta/phi)"
  [6]="N2 🌒  | Pink noise + 6.18Hz (Theta/PHI*10)"
  [7]="REM 🌕 | White noise + 16.18Hz (Beta/PHI*10)"
  [8]="REM 🌕 | White noise + 16.18Hz 5sec spindle pulses"
  [9]="N2 🌒  | Pink noise + 6.18Hz (Theta/PHI*3.81)"
  [10]="N2 🌒 | Brown noise + 1.618Hz (Delta/PHI)"
  [11]="N3 🌑 | Pink noise + 6.18Hz (Theta/PHI*10)"
  [12]="N2 🌒 | Pink noise + 6.18Hz (Theta/PHI*10)"
)

# Loop through all segments
for i in {1..12}; do
  # Calculate time range
  START=$(( (i-1)*10 ))
  END=$(( i*10 ))
  
  # Set phaser level & frequency
  PHASER_LEVEL=0.1 # DEFAULT: 0.4; MAX:0.5; MIN:0.0 (OFF)
  PHASER_FREQ=0.1  # DEFAULT: 0.1 (10 sec); MAX:2; MIN:0.1
  
  # Print stage info
  echo -e "\n Segment $i ($START–$END min): ${STAGES[$i]}"

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

##########################################################
## ⚠️ DISCLAIMER: LISTENING RESPONSIBILITY & SAFETY!! ⚠️ ##
##########################################################

# Purpose of This Tool
# This Lucid Dream Sequencer is designed to provide ambient sounds aligned with sleep and lucid dreaming cycles 
# for general wellness purposes. 
# It is not a medical device, treatment, or diagnostic tool. 

# Critical Volume Warning
# Hearing Safety First:

# Never use this script at high volumes, even if you feel you "need" loud sounds to fall asleep. 
# Prolonged exposure to sounds above 85 dB (decibels) can cause permanent hearing damage, 
# especially during sleep when your ears remain sensitive.
# Start at low volumes and adjust only as needed. 

# Avoid using headphones/earbuds at max volume. For reference:
# Normal conversation ≈ 60 dB
# Busy traffic ≈ 80 dB
# Headphone max volume ≈ 100+ dB
# Special Warning for Headphone Users:

# Over-ear headphones or earbuds can deliver sound directly into the ear canal, increasing risk. 
# Consider using noise-canceling headphones at low volumes instead of cranking up the sound to block external noise.
# Do not fall asleep with in-ear devices (e.g., earbuds). They can cause discomfort, ear infections, or increased 
# hearing risk if volume spikes occur.

# Listening Responsibility

# Volume & Duration: Users assume full responsibility for setting safe volume levels and usage durations. 
# Prolonged exposure to loud sounds (even during sleep) may risk hearing damage.

# Personal Health Awareness: If you have tinnitus, hearing loss, sleep disorders, or other medical conditions, 
# consult a healthcare professional before use.
# Environmental Safety: Ensure the sequencer does not interfere with alarms, emergency alerts, or other critical 
# auditory cues in your environment.

# Medical Disclaimer

# This tool is not a substitute for professional medical advice, diagnosis, or treatment. 
# Always seek the guidance of a licensed healthcare provider for sleep-related concerns or health questions.
# Do not delay or disregard medical advice based on content or features within this sequencer.

# No Liability for Outcomes

# The creator(s) of this sequencer assume no responsibility for:
# Individual health outcomes, including unintended effects of sound exposure.
# Technical malfunctions (e.g., app crashes, incorrect timing of sounds).
# Any reliance on the sequencer’s ability to improve sleep quality.

# Final Disclaimer Note

# Use this tool thoughtfully and adjust settings to suit your comfort. If discomfort, irritation, 
# or adverse effects occur, discontinue use immediately.

# Volume Safety Reminder:

# Keep volume below 60% of maximum if unsure.
# For children or sensitive users, supervise use and prioritize extra-low volumes.
# By using this sequencer, you acknowledge and agree to the terms above.

# Proceed only if you understand and accept the risks of using an untested tool.
# Monitor your body’s response and prioritize safety over "experimentation."
# By using this sequencer, you acknowledge and agree to the terms above.

# Experimental Prototype – Not for Medical Use.

#################################################

## END
