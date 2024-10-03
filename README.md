name: Patch Recovery Image

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  patch:
    runs-on: ubuntu-latest

    steps:
      # 1. Check out the repository to access scripts
      - name: Check out repository
        uses: actions/checkout@v4

      # 2. Fetch necessary packages
      - name: Install required packages
        run: |
          sudo apt update
          sudo apt install git wget lz4 tar openssl python3 -y

      # 3. Download recovery image from the provided URL
      - name: Download recovery image
        run: |
          wget https://we.tl/t-MKbgvT5uQT -O recovery.img

      # 4. Make patching scripts executable
      - name: Make scripts executable
        run: |
          chmod +x magiskboot
          chmod +x patcher-minimal

      # 5. Run the patching script
      - name: Patch the recovery image
        run: ./patcher-minimal

      # 6. Upload the patched image as an artifact
      - name: Upload patched image
        uses: actions/upload-artifact@v4
        with:
          path: ./patched-recovery.img
          name: Patched Recovery Image
          retention-days: 15
