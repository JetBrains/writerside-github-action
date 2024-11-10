[![JetBrains team project](https://jb.gg/badges/team.svg)](https://confluence.jetbrains.com/display/ALL/JetBrains+on+GitHub)


# Writerside GitHub action

This action runs the Writerside builder Docker image,
which creates a ZIP archive with your documentation website from a Writerside project.

For more information,
see [Writerside documentation](https://www.jetbrains.com/help/writerside/deploy-docs-to-github-pages.html).

## Environment variables

The following environment variables are mandatory:

`INSTANCE`
: Specify the module name and instance ID, separated by a slash.
: When you create a new Writerside project or add an instance in an existing project, the default module name is `Writerside` and the default instance ID is `hi`.
: So, in this case, you would set `INSTANCE: 'Writerside/hi'`.

`ARTIFACT`
: The name of the produced archive is `webHelpXX2-all.zip`
  where `XX` is the capitalized instance ID.
: For example, if the module (directory with documentation) is `Writerside`,
  and the instance ID is `hi`, then set to `ARTIFACT: webHelpHI2-all.zip`.

`DOCKER_VERSION`
: Specify the version tag of the Writerside Docker builder image.
  For the latest version, see [What's new](https://www.jetbrains.com/help/writerside/whats-new-last-update.html).

The following environment variables are optional:

`PDF`
: Produce a PDF file as a build artifact instead of the documentation website.
  Specify an XML file with PDF generation options.

## Example: Build your documentation website

```yml
name: Build documentation

on:
  push:
    branches: ["main"]
  workflow_dispatch:

env:
  INSTANCE: 'Writerside/hi'
  ARTIFACT: 'webHelpHI2-all.zip'
  DOCKER_VERSION: '242.21870'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Build docs using Writerside Docker builder
        uses: JetBrains/writerside-github-action@v4
        with:
          instance: ${{ env.INSTANCE }}
          artifact: ${{ env.ARTIFACT }}
          docker-version: ${{ env.DOCKER_VERSION }}
      
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: artifact
          path: artifacts/${{ env.ARTIFACT }}
          retention-days: 7
```


## Example: Build and publish to GitHub Pages

```yml
name: Build documentation

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  id-token: write
  pages: write

env:
  INSTANCE: 'Writerside/hi'
  ARTIFACT: 'webHelpHI2-all.zip'
  DOCKER_VERSION: '242.21870'

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Build Writerside docs using Docker
        uses: JetBrains/writerside-github-action@v4
        with:
          instance: ${{ env.INSTANCE }}
          artifact: ${{ env.ARTIFACT }}
          docker-version: ${{ env.DOCKER_VERSION }}
        
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: docs
          path: |
            artifacts/${{ env.ARTIFACT }}
          retention-days: 7

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    needs: build
    runs-on: ubuntu-latest

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: docs

      - name: Unzip artifact
        run: unzip -O UTF-8 -qq ${{ env.ARTIFACT }} -d dir

      - name: Setup Pages
        uses: actions/configure-pages@v4.0.0
      
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3.0.1
        with:
          path: dir
      
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4.0.4
```

## Example: Build PDF

```yml
name: Build documentation

on:
  push:
    branches: ["main"]
  workflow_dispatch:

env:
  INSTANCE: 'Writerside/hi'
  ARTIFACT: 'webHelpHI2-all.zip'
  DOCKER_VERSION: '242.21870'
  PDF: 'PDF.xml'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Build Writerside docs using Docker
        uses: JetBrains/writerside-github-action@v4
        with:
          instance: ${{ env.INSTANCE }}
          artifact: ${{ env.ARTIFACT }}
          docker-version: ${{ env.DOCKER_VERSION }}
          pdf: ${{ env.PDF }}
      
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: artifact
          path: artifacts/${{ env.ARTIFACT }}
          retention-days: 7
```
