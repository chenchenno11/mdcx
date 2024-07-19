name: Build and Release

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: windows-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.8

      - name: Install dependencies
        run: |
          python -m venv venv
          .\venv\Scripts\activate
          pip install --upgrade pip
          pip install -r requirements.txt
          pip install pyinstaller

      - name: Build the project
        run: |
          .\venv\Scripts\activate
          $time = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
          $FileName = "MDCx-$time.exe"
          echo "Output File: $FileName"

          pyinstaller --onefile --name "$FileName" -i resources/Img/MDCx.ico -w main.py -p "./src" --add-data "resources;resources" --add-data "libs;." --hidden-import socks --hidden-import urllib3 --hidden-import _cffi_backend --collect-all curl_cffi --hidden-import numpy --hidden-import numpy.core._methods --hidden-import numpy.lib.format

          Remove-Item -Recurse -Force dist
          pyinstaller "$FileName.spec"

          Remove-Item -Recurse -Force build
          Remove-Item -Force "$FileName.spec"

          echo 'Done'

      - name: Upload build artifacts
        uses: actions/upload-artifact@v2
        with:
          name: build-artifacts
          path: dist/
