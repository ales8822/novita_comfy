#!/bin/bash

##############################################
# Step 1: Prepare system and install packages
##############################################

apt-get update && apt-get install -y wget git python3 python3-pip
git pull origin master
echo "wget, git, python3, python3-pip installed successfully!"

##############################################
# Step 2: Download & Install ComfyUI
##############################################

WORKSPACE_DIR="workspace"
COMFYUI_REPO="https://github.com/comfyanonymous/ComfyUI.git"

# Verify we are in the parent directory of WORKSPACE_DIR
if [[ ! -d "$WORKSPACE_DIR" ]]; then
    echo "Error: '$WORKSPACE_DIR' does not exist. Please run this script from the directory containing '$WORKSPACE_DIR'." >&2
    exit 1
fi

cd "$WORKSPACE_DIR"

if [[ ! -d "ComfyUI" ]]; then
    echo "Cloning ComfyUI repository..."
    if ! git clone "$COMFYUI_REPO"; then
        echo "Failed to clone ComfyUI. Please ensure Git is installed and try again." >&2
        exit 1
    fi
else
    echo "ComfyUI directory already exists, skipping clone."
fi

cd ComfyUI

echo "Installing Python dependencies for ComfyUI..."
if ! pip install -r requirements.txt; then
    echo "pip install failed. Check for errors above." >&2
    exit 1
fi

echo "ComfyUI installation complete."

##############################################
# Step 3: Download & Install ComfyUI Manager
##############################################

CUSTOM_NODES_DIR="custom_nodes"
COMFYUI_MANAGER_REPO="https://github.com/ltdrdata/ComfyUI-Manager.git"

# Ensure custom_nodes directory is present
if [[ ! -d "$CUSTOM_NODES_DIR" ]]; then
    echo "Error: $CUSTOM_NODES_DIR directory does not exist in ComfyUI. Please create it or check your setup." >&2
    exit 1
fi

cd "$CUSTOM_NODES_DIR"

if [[ ! -d "ComfyUI-Manager" ]]; then
    echo "Cloning ComfyUI-Manager repository..."
    if ! git clone "$COMFYUI_MANAGER_REPO"; then
        echo "Failed to clone ComfyUI-Manager. Please ensure Git is installed and try again." >&2
        exit 1
    fi
else
    echo "ComfyUI-Manager directory already exists, skipping clone."
fi

cd ComfyUI-Manager

echo "Installing ComfyUI Manager dependencies..."
if ! pip install -r requirements.txt; then
    echo "ComfyUI Manager pip install failed. Check for errors above." >&2
    exit 1
fi

echo "ComfyUI Manager installation complete."

# Return to ComfyUI root
cd ../..

##############################################
# Step 4: Download AE VAE Model
##############################################

AE_URL="https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/ae.safetensors"
AE_FILE="models/vae/ae.safetensors"

# Ensure models/vae directory is present
if [[ ! -d "models/vae" ]]; then
    echo "Error: models/vae directory does not exist in ComfyUI. Please create it or check your setup." >&2
    exit 1
fi

if [[ ! -f "$AE_FILE" ]]; then
    echo "Downloading ae.safetensors into $AE_FILE..."
    wget -O "$AE_FILE" "$AE_URL"

    if [[ -f "$AE_FILE" ]]; then
        echo "ae.safetensors successfully downloaded to $AE_FILE."
    else
        echo "Download failed for ae.safetensors. Please check the URL and try again." >&2
        exit 1
    fi
else
    echo "ae.safetensors already exists in $AE_FILE. Skipping download."
fi

##############################################
# Step 5: Download T5XXL Text Encoder
##############################################

TEXT_ENCODER_URL="https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors"
TEXT_ENCODER_FILE="models/clip/t5xxl_fp8_e4m3fn.safetensors"

if [[ ! -d "models/clip" ]]; then
    echo "Error: models/clip directory does not exist in ComfyUI. Please create it or check your setup." >&2
    exit 1
fi

if [[ ! -f "$TEXT_ENCODER_FILE" ]]; then
    echo "Downloading t5xxl_fp8_e4m3fn.safetensors into $TEXT_ENCODER_FILE..."
    wget -O "$TEXT_ENCODER_FILE" "$TEXT_ENCODER_URL"

    if [[ -f "$TEXT_ENCODER_FILE" ]]; then
        echo "t5xxl_fp8_e4m3fn.safetensors successfully downloaded to $TEXT_ENCODER_FILE."
    else
        echo "Download failed for t5xxl_fp8_e4m3fn.safetensors. Please check the URL and try again." >&2
        exit 1
    fi
else
    echo "t5xxl_fp8_e4m3fn.safetensors already exists in $TEXT_ENCODER_FILE. Skipping download."
fi

##############################################
# Step 6: Download CLIP Text Encoder
##############################################

CLIP_URL="https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
CLIP_FILE="models/clip/clip_l.safetensors"

if [[ ! -d "models/clip" ]]; then
    echo "Error: models/clip directory does not exist in ComfyUI. Please create it or check your setup." >&2
    exit 1
fi

if [[ ! -f "$CLIP_FILE" ]]; then
    echo "Downloading clip_l.safetensors into $CLIP_FILE..."
    wget -O "$CLIP_FILE" "$CLIP_URL"

    if [[ -f "$CLIP_FILE" ]]; then
        echo "clip_l.safetensors successfully downloaded to $CLIP_FILE."
    else
        echo "Download failed for clip_l.safetensors. Please check the URL and try again." >&2
        exit 1
    fi
else
    echo "clip_l.safetensors already exists in $CLIP_FILE. Skipping download."
fi

##############################################
# Step 7: Download Lora Models from Google Drive
##############################################

# Install gdown if not already installed
if ! command -v gdown &> /dev/null; then
  echo "gdown not found. Installing gdown..."
  pip install gdown
fi

LORAS_DIR="models/loras"

if [[ ! -d "$LORAS_DIR" ]]; then
    echo "Error: $LORAS_DIR directory does not exist in ComfyUI. Please create it or check your setup." >&2
    exit 1
fi

LORAS_FILE_IDS=(
  "1R8xTsUpYkhkKzPTQP2np-lZ3jWRYax17" # Oiled Skin ( OiledSkin )
  "1nVU8QX7aWyKkcR0nBC1M8fNhAzJ2yhdc" # Cinematic Photography Style XL + F1D
  "1pMqIDXYhSL0qkKeyE7I9RTtDjJokkKCi" # Dynamic Poses FLUX + SDXL 2.0
  "1d40-6De13Pso-apOX1ItUBRl7slEVDUX" # Hyper Realism Lora by aidma 0.3
  "1dR3qUCQZPcm3dw2ApI_buOLsh5qp-zrq" # Vixon's Pony Styles - gothic neon
  "1Blkg72iJDINiKxifERQcDiuq8u_3uOCz" # FluxSideboob
  "1MP36YoGsvfjILtq33JZjyX6OckejNcZF" # Hand v2
  "17bGEBIGiFBGe9vzybGONaxipf6wg4Dnb" # bustyFC-2.1
  "1VudJ-wgW2IyjKNUVtg7iqUNdrx2IB1ql" # roundassv16_Flux
  "19SNMZjLRNHPwpfOBztHDaQPrkHOPJs6z" # NSWF_master
  "1Lh3qqm6Ga7jWSElO04fP5IBQsFUDuHQd" # hourglassv2_flux
  "1au4LXdJCp6a0aFVjEcO4yJHGYaqtIKKH" # All_in_one_nipples
  "1xwHR7j5Ir6cEVxzrFp2-91g84X8Nopjs" # aidmaMJ6.1-v0.4
  "1u56I0SkYZJFGOjho6OqUbsP4KOTWae3A" # Movie Poster - CE (mvpstrCE style)
  "1VmsjptWMLPhgd3RkS_4KlYBIyU5_UUW2" # Famous Tits | Inspired breasts | Flux + Pony
  "1QCpZfVKMM2bpHwxN0DZ0SqeAQqq5_Vkl" # MicroSkirt FLUX & SDXL
  "17f6VZKevKQYT47qfFoga7f7ShB5g-h9C" # BreastShaper_splendid_droplets (Flux) v3.0
)

download_failed=0

for FILE_ID in "${LORAS_FILE_IDS[@]}"; do
  GDRIVE_URL="https://drive.google.com/uc?id=$FILE_ID"
  echo "Downloading Lora model from Google Drive (ID: $FILE_ID) into $LORAS_DIR..."

  if ! gdown "$GDRIVE_URL" -O "$LORAS_DIR/"; then
    echo "Download failed for Lora model with ID: $FILE_ID. Please check the link and try again." >&2
    download_failed=1
  else
    echo "Lora model with ID: $FILE_ID successfully downloaded to $LORAS_DIR."
  fi
done

if [[ $download_failed -eq 1 ]]; then
    echo "Some downloads failed, check the log." >&2
else
    echo "All Lora downloads completed (or no downloads were attempted)."
fi

##############################################
# Step 8: Download flux1-dev checkpoint
##############################################

FLUX1_DEV_URL="https://huggingface.co/Comfy-Org/flux1-dev/resolve/main/flux1-dev-fp8.safetensors"
FLUX1_DEV_FILE="models/diffusion_models/flux1-dev-fp8.safetensors"

if [[ ! -d "models/checkpoints" ]]; then
   echo "Error: models/checkpoints directory does not exist in ComfyUI. Please create it or check your setup." >&2
   exit 1
fi

if [[ ! -f "$FLUX1_DEV_FILE" ]]; then
   echo "Downloading flux1-dev-fp8.safetensors into $FLUX1_DEV_FILE..."
   wget -O "$FLUX1_DEV_FILE" "$FLUX1_DEV_URL"

   if [[ -f "$FLUX1_DEV_FILE" ]]; then
       echo "flux1-dev-fp8.safetensors successfully downloaded to $FLUX1_DEV_FILE."
   else
       echo "Download failed for flux1-dev-fp8.safetensors. Please check the URL and try again." >&2
       exit 1
   fi
else
   echo "flux1-dev-fp8.safetensors already exists in $FLUX1_DEV_FILE. Skipping download."
fi



##############################################
# Step 9: Download flux1-dev checkpoint
##############################################
#!/bin/bash

LORAS_DIR="models/checkpoints/"

# Check if the checkpoint directory exists
if [[ ! -d "$LORAS_DIR" ]]; then
    echo "Error: $LORAS_DIR directory does not exist in ComfyUI. Please create it or check your setup." >&2
fi

# Check if gdown is installed
if ! command -v gdown &> /dev/null; then
    echo "Error: gdown is not installed. Please install it and try again." >&2
fi

LORAS_FILE_IDS=(
    "15JMhbBLjTL9KS3fhnBMpNWbElfAokk71" # juggernautXL_versionXInpaint
)

download_failed=0

for FILE_ID in "${LORAS_FILE_IDS[@]}"; do
    GDRIVE_URL="https://drive.google.com/uc?id=$FILE_ID"
    # Define an output file name. Adjust the filename or extension as needed.
    OUTPUT_FILE="$LORAS_DIR/${FILE_ID}.safetensors"
    
    echo "Downloading checkpoint from Google Drive (ID: $FILE_ID) into $OUTPUT_FILE..."
    
    if ! gdown "$GDRIVE_URL" -O "$OUTPUT_FILE"; then
        echo "Download failed for checkpoint with ID: $FILE_ID. Please check the link and try again." >&2
        download_failed=1
    else
        echo "Checkpoint with ID: $FILE_ID successfully downloaded to $OUTPUT_FILE."
    fi
done

if [[ $download_failed -eq 1 ]]; then
    echo "Some downloads failed, check the log." >&2
else
    echo "All Lora downloads completed successfully."
fi

