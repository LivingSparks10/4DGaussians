import os
import cv2

import time

def extract_frames(input_folder, output_folder):
    # List all video files in the input folder
    video_files = [f for f in os.listdir(input_folder) if f.endswith(('.mp4', '.avi', '.mov', '.mkv'))]
    total_videos = len(video_files)
    video_index = 0
    
    for video_file in video_files:
        print(f"Processing video {video_index+1}/{total_videos}: {video_file}")
        video_index += 1
        video_name, _ = os.path.splitext(video_file)  # Remove file extension to get the base name
        
        # Create the corresponding camera directory
        cam_folder = os.path.join(output_folder, video_name, 'images')
        os.makedirs(cam_folder, exist_ok=True)
        
        cap = cv2.VideoCapture(os.path.join(input_folder, video_file))
        frame_index = 0
        start_time = time.time()
        
        if not cap.isOpened():
            print(f"Error opening video file {video_file}")
            continue
        
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            
            frame_filename = f"{frame_index:04d}.png"
            frame_path = os.path.join(cam_folder, frame_filename)
            cv2.imwrite(frame_path, frame)
            frame_index += 1
            
            elapsed_time = time.time() - start_time
            remaining_time = (total_videos - video_index) * elapsed_time / video_index
            print(f"Progress: {video_index}/{total_videos} - Elapsed time: {elapsed_time:.2f}s - Remaining time: {remaining_time:.2f}s")
        
        cap.release()
        print(f"Completed video {video_file}")
    
    print("Frame extraction completed.")


def main():
    input_folder = 'data/dynerf/cut_roasted_beef'
    output_folder = 'output/dnerf/cut_roasted_beef_001'
    extract_frames(input_folder, output_folder)


if __name__ == "__main__":
    main()


