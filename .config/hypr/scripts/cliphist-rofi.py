#!/usr/bin/env python3

import sys
import os
import subprocess
import re
import html
import shutil

# --- Configuration ---
CACHE_DIR = os.path.expanduser("~/.cache/cliphist/thumbnails")
RASI_FILE = os.path.expanduser("~/.config/rofi/clipboard.rasi")
TEXT_ICON = "text-x-generic"
MAX_TEXT_LEN = 60

os.makedirs(CACHE_DIR, exist_ok=True)

def get_cliphist_items():
    result = subprocess.run(['cliphist', 'list'], capture_output=True, text=True)
    return result.stdout.strip().splitlines()

def send_notification(title, message):
    subprocess.run(['notify-send','-t' ,'1600','-u','normal',title,message])

def clean_cache(current_ids):
    try:
        for filename in os.listdir(CACHE_DIR):
            file_id = filename.split('.')[0]
            if file_id not in current_ids and file_id.isdigit():
                path = os.path.join(CACHE_DIR, filename)
                os.remove(path)
    except Exception as e:
        print(f"Cache clean error: {e}")

def main():
    raw_lines = get_cliphist_items()
    parsed_items = []
    current_ids = set()
    
    rofi_input = ""

    for line in raw_lines:
        # Check for image
        match_img = re.search(r'^(\d+)\s+\[\[\s+binary.*(jpg|jpeg|png|bmp)', line)
        
        if match_img:
            clip_id = match_img.group(1)
            ext = match_img.group(2)
            current_ids.add(clip_id)
            
            filename = f"{clip_id}.{ext}"
            path = os.path.join(CACHE_DIR, filename)
            
            if not os.path.exists(path):
                with open(path, 'wb') as f:
                    subprocess.run(['cliphist', 'decode', clip_id], stdout=f)
            
            display_text = "<b>Image</b>"
            # STORE THE RAW LINE for deletion later
            parsed_items.append({'id': clip_id, 'type': 'image', 'raw': line})
            rofi_input += f"{display_text}\0icon\x1f{path}\n"
            
        else:
            # Text Item
            match_text = re.search(r'^(\d+)\s+(.*)', line)
            if match_text:
                clip_id = match_text.group(1)
                content = match_text.group(2)
                current_ids.add(clip_id)
                
                display_content = (content[:MAX_TEXT_LEN] + '...') if len(content) > MAX_TEXT_LEN else content
                safe_content = html.escape(display_content).replace("\n", " ")
                
                # STORE THE RAW LINE for deletion later
                parsed_items.append({'id': clip_id, 'type': 'text', 'raw': line})
                rofi_input += f"{safe_content}\0icon\x1f{TEXT_ICON}\n"

    clean_cache(current_ids)

    # 2. Run Rofi
    rofi_cmd = [
        'rofi', 
        '-dmenu', 
        '-config', RASI_FILE, 
        '-i', 
        '-show-icons', 
        '-markup-rows',
        '-format', 'i',
        '-kb-custom-1', 'Alt+1',   # Wipe All
        '-kb-custom-2', 'Alt+d',   # Delete Specific
        '-mesg', 'Alt+d: Delete Item | Alt+1: Wipe All'
    ]

    proc = subprocess.run(rofi_cmd, input=rofi_input, text=True, capture_output=True)
    
    exit_code = proc.returncode
    selection_index = proc.stdout.strip()

    # 3. Handle Copy
    if exit_code == 0 and selection_index.isdigit():
        idx = int(selection_index)
        if 0 <= idx < len(parsed_items):
            item = parsed_items[idx]
            subprocess.run(f"cliphist decode {item['id']} | wl-copy", shell=True)
            
            msg = "Image Copied 🖼️" if item['type'] == 'image' else "Text Copied 📝"
            send_notification("Clipboard", msg)

    # 4. Handle Single Delete (Alt+d)
    elif exit_code == 11 and selection_index.isdigit():
        idx = int(selection_index)
        if 0 <= idx < len(parsed_items):
            item = parsed_items[idx]
            
            # FIXED: Pass the FULL RAW LINE to cliphist delete
            subprocess.run(['cliphist', 'delete'], input=item['raw'], text=True)
            
            send_notification("Clipboard", "Item Deleted 🗑️")
            
            # Optional: Refresh the UI immediately so the item disappears
            os.execv(sys.executable, ['python3'] + sys.argv)

    # 5. Handle Wipe All (Alt+1)
    elif exit_code == 10:
        confirm_rofi = ['rofi', '-dmenu', '-config', RASI_FILE, '-p', '⚠️ WIPE ALL?', '-mesg', 'Irreversible action.']
        res = subprocess.run(confirm_rofi, input="Yes, Wipe\nNo, Cancel", text=True, capture_output=True)
        
        if "Yes" in res.stdout:
            subprocess.run(['cliphist', 'wipe'])
            if os.path.exists(CACHE_DIR):
                shutil.rmtree(CACHE_DIR)
                os.makedirs(CACHE_DIR)
            send_notification("Clipboard", "History Wiped 🗑️")

if __name__ == "__main__":
    main()