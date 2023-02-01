# A GitHub action for building a Writerside docs artifacts in a Docker container

This action creates a zip-archive with HTMLs from markdown or semantic markup topics.

## Environment variables

You need to change these variables values to the ones from your help project.

### `ARTIFACT`

The name of the archive is webHelpXX2-all.zip where XX gets replaced by the instance id in caps.

### `PRODUCT`

The $PRODUCT should be name_of_module / instance_id, for example sample_module/sd. No default value.

## Example usage with the build HTMLs only

```yml
name: Build docs

on:
  push:
    branches: ["main"]

  workflow_dispatch:

env:
  PRODUCT: name_of_module/instance_id
  ARTIFACT: webHelpXX2-all.zip

jobs:
  build-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Build Writerside docs using Docker
        uses: JetBrains/writerside-github-action@v2
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: artifact
          path: artifacts/${{ env.ARTIFACT }}
          retention-days: 7
```


## Example usage with build and publish to GitHub pages

```yml
name: Build docs

on:
  push:
    branches: ["main"]

  workflow_dispatch:

permissions:
  id-token: write
  pages: write

env:
  PRODUCT: name_of_module/instance_id
  ARTIFACT: webHelpXX2-all.zip

jobs:
  build-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3
      - name: Build Writerside docs using Docker
        uses: JetBrains/writerside-github-action@v2
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: artifact
          path: artifacts/${{ env.ARTIFACT }}
          retention-days: 7

 deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    needs: build-job
    runs-on: ubuntu-latest
    steps:
      - name: Download artifact
        uses: actions/download-artifact@v3
        with:
          name: artifact
      - name: Unzip artifact
        uses: montudor/action-zip@v1
        with:
          args: unzip -qq ${{ env.ARTIFACT }} -d dir
      - name: Setup Pages
        uses: actions/configure-pages@v2
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v1
        with:
          path: dir
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v1
```
