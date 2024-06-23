import torch

# Check if CUDA is available
cuda_available = torch.cuda.is_available()
print(f"CUDA Available: {cuda_available}")

# Get the name of the CUDA device
if cuda_available:
    cuda_device_name = torch.cuda.get_device_name(0)
    print(f"CUDA Device Name: {cuda_device_name}")
else:
    print("No CUDA device detected.")