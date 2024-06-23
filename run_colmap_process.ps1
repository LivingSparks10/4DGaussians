param (
    [string]$workdir,
    [string]$datatype # blender, hypernerf, llff
)

# Set CUDA_VISIBLE_DEVICES environment variable
$env:CUDA_VISIBLE_DEVICES = "0"

# Remove directories
Remove-Item -Recurse -Force "$workdir\sparse_"
Remove-Item -Recurse -Force "$workdir\image_colmap"

# Run Python script
python scripts/"$datatype"2colmap.py $workdir

# Remove more directories
Remove-Item -Recurse -Force "$workdir\colmap"
Remove-Item -Recurse -Force "$workdir\colmap\sparse\0"

# Create directories and copy files
New-Item -ItemType Directory -Path "$workdir\colmap"
Copy-Item -Recurse -Force "$workdir\image_colmap" "$workdir\colmap\images"
Copy-Item -Recurse -Force "$workdir\sparse_" "$workdir\colmap\sparse_custom"

# Run COLMAP commands
colmap feature_extractor --database_path "$workdir\colmap\database.db" --image_path "$workdir\colmap\images" --SiftExtraction.max_image_size 4096 --SiftExtraction.max_num_features 16384 --SiftExtraction.estimate_affine_shape 1 --SiftExtraction.domain_size_pooling 1

python database.py --database_path "$workdir\colmap\database.db" --txt_path "$workdir\colmap\sparse_custom\cameras.txt"

colmap exhaustive_matcher --database_path "$workdir\colmap\database.db"

New-Item -ItemType Directory -Path "$workdir\colmap\sparse\0"

colmap point_triangulator --database_path "$workdir\colmap\database.db" --image_path "$workdir\colmap\images" --input_path "$workdir\colmap\sparse_custom" --output_path "$workdir\colmap\sparse\0" --clear_points 1

New-Item -ItemType Directory -Force -Path "$workdir\colmap\dense\workspace"

colmap image_undistorter --image_path "$workdir\colmap\images" --input_path "$workdir\colmap\sparse\0" --output_path "$workdir\colmap\dense\workspace"

colmap patch_match_stereo --workspace_path "$workdir\colmap\dense\workspace"

colmap stereo_fusion --workspace_path "$workdir\colmap\dense\workspace" --output_path "$workdir\colmap\dense\workspace\fused.ply"
