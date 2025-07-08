import os
import sys
import time
import random
import threading
import subprocess
from datetime import datetime

# Global flag for skipping
skip_flag = False
skip_lock = threading.Lock()

def key_listener():
    """Thread to detect Enter + 's' key press and set skip flag"""
    global skip_flag
    while True:
        # Wait for user input followed by Enter
        user_input = sys.stdin.readline().strip()
        if user_input.lower() == 's':
            with skip_lock:
                skip_flag = True

# Start the key listener thread
listener_thread = threading.Thread(target=key_listener, daemon=True)
listener_thread.start()

print("Type 's' to skip to next stage.")

def wait_with_skip(duration):
    """Non-blocking sleep that checks for skip flag"""
    start = time.time()
    while time.time() - start < duration:
        with skip_lock:
            if skip_flag:
                return True
        time.sleep(0.1)
    return False

def play_with_skip(command):
    """Run a play command and allow skipping"""
    process = subprocess.Popen(command)
    while True:
        with skip_lock:
            if skip_flag:
                process.terminate()
                process.wait()
                return True  # Skip requested
        if process.poll() is not None:
            return False  # Finished normally
        time.sleep(0.1)

def n2_spindles():
    burst_duration = 5
    min_interval = 60
    max_interval = 90
    total_time = 0
    voice_duration = 5
    spindle_count = 0
    voice_dir = "audio"
    min_random_delay = 3
    max_random_delay = 5

    print("Generating N2 spindles with randomized voice delays")
    print(f"Voice directory: {voice_dir}")

    while total_time < 600:
        print(f"⏱️ Spindle {spindle_count + 1} at {total_time}s")
        command = [
            'play', '-q', '-r', '44100', '-n', 'synth', str(burst_duration), 'whitenoise',
            'tremolo', '16.18', '70',
            'phaser', '0.8', '0.7', '0.2', '0.4', '0.1', '-s',
            'remix', '-',
            'gain', '-12',
            'fade', 't', '0.2', str(burst_duration), '0.2'
        ]
        if play_with_skip(command):
            return  # Skip requested

        total_time += burst_duration
        spindle_count += 1

        if total_time + voice_duration >= 600:
            print("Final spindle reached - skipping voice")
            break

        delay = random.randint(min_random_delay, max_random_delay)
        print(f"⏳ Adding {delay}s delay before voice")
        if wait_with_skip(delay):
            return

        total_time += delay
        voice_num = random.randint(1, 9)
        voice_file = os.path.join(voice_dir, f"{voice_num}_Voice.mp3")

        if os.path.isfile(voice_file):
            print(f"🔊 Inserting voice {voice_num}: 'Do you dreaming?'")
            if play_with_skip(['play', '-q', '-t', 'mp3', voice_file, 'remix', '-', 'gain', '-3']):
                return
            total_time += voice_duration
        else:
            print(f"❌ Voice file missing: {voice_file}")

        if total_time < 600:
            interval = random.randint(min_interval, max_interval)
            print(f"⏳ Adding {interval}s silence")
            if wait_with_skip(interval):
                return
            total_time += interval

# Sleep stage labels
stages = {
    1: "N1  🌑 | Brown noise + 7.83Hz (Schumann)",
    2: "N2  🌒 | Pink noise + 4.854Hz (Theta/PHI*3)",
    3: "N3  🌑 | Brown noise + 1.618Hz (Delta/PHI)",
    4: "N3  🌑 | Brown noise + 0.618Hz (Delta/phi)",
    5: "N3  🌑 | Brown noise + 0.618Hz (Delta/phi)",
    6: "N2  🌒 | Pink noise + 6.18Hz (Theta/PHI*10)",
    7: "REM 🌕 | White noise + 16.18Hz (Beta/PHI*10)",
    8: "REM 🌕 | White noise + 16.18Hz 5sec spindle pulses",
    9: "N2  🌒 | Pink noise + 6.18Hz (Theta/PHI*3.81)",
    10: "N2 🌒 | Brown noise + 1.618Hz (Delta/PHI)",
    11: "N3 🌑 | Pink noise + 6.18Hz (Theta/PHI*10)",
    12: "N2 🌒 | Pink noise + 6.18Hz (Theta/PHI*10)",
}

# Loop through all segments
for i in range(1, 13):
    start = (i - 1) * 10
    end = i * 10
    phaser_level = 0.1
    phaser_freq = 0.1
    timestamp = datetime.now().strftime("%Y-%m-%d_%H:%M:%S")

    print(f"\n Segment {i} ({start}–{end} min): {stages[i]} | {timestamp}")

    # Build command based on segment index
    if i == 1:
        command = ['play', '-r', '44100', '-n', 'synth', '600', 'brownnoise',
                   'fade', 'p', '10', '0', '10', 'gain', '-6', 'tremolo', '7.83', '50',
                   'phaser', '0.8', '0.8', '0.2', str(phaser_level), str(phaser_freq), '-s', 'remix', '-']
    elif i == 2:
        command = ['play', '-r', '44100', '-n', 'synth', '600', 'pinknoise',
                   'fade', 'p', '10', '0', '10', 'gain', '-8', 'tremolo', '4.854', '50',
                   'phaser', '0.8', '0.8', '0.2', str(phaser_level), str(phaser_freq), '-s', 'remix', '-']
    elif i == 3:
        command = ['play', '-r', '44100', '-n', 'synth', '600', 'brownnoise',
                   'fade', 'p', '10', '0', '10', 'gain', '-6', 'tremolo', '1.618', '70',
                   'phaser', '0.8', '0.8', '0.2', str(phaser_level), str(phaser_freq), '-s', 'remix', '-']
    elif i == 4 or i == 5:
        command = ['play', '-r', '44100', '-n', 'synth', '600', 'brownnoise',
                   'fade', 'p', '10', '0', '10', 'gain', '-6', 'tremolo', '0.618', '70',
                   'phaser', '0.8', '0.8', '0.2', str(phaser_level), str(phaser_freq), '-s', 'remix', '-']
    elif i == 6 or i == 11 or i == 12:
        command = ['play', '-r', '44100', '-n', 'synth', '600', 'pinknoise',
                   'fade', 'p', '10', '0', '10', 'gain', '-8', 'tremolo', '6.18', '50',
                   'phaser', '0.8', '0.8', '0.2', str(phaser_level), str(phaser_freq), '-s', 'remix', '-']
    elif i == 7:
        command = ['play', '-r', '44100', '-n', 'synth', '600', 'whitenoise',
                   'fade', 'p', '10', '0', '0', 'gain', '-12', 'tremolo', '16.18', '50',
                   'phaser', '0.8', '0.8', '0.2', str(phaser_level), str(phaser_freq), '-s', 'remix', '-']
    elif i == 9:
        command = ['play', '-r', '44100', '-n', 'synth', '600', 'pinknoise',
                   'fade', 'p', '0', '0', '10', 'gain', '-8', 'tremolo', '6.18', '50',
                   'phaser', '0.8', '0.8', '0.2', str(phaser_level), str(phaser_freq), '-s', 'remix', '-']
    elif i == 10:
        command = ['play', '-r', '44100', '-n', 'synth', '600', 'brownnoise',
                   'fade', 'p', '10', '0', '10', 'gain', '-6', 'tremolo', '1.618', '70',
                   'phaser', '0.8', '0.8', '0.2', str(phaser_level), str(phaser_freq), '-s', 'remix', '-']
    elif i == 8:
        n2_spindles()
        continue

    # Run the audio command with skip capability
    print("Starting audio playback...")
    play_with_skip(command)
    with skip_lock:
        skip_flag = False
