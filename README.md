[![JetBrains team project](https://jb.gg/badges/team.svg)](https://confluence.jetbrains.com/display/ALL/JetBrains+on+GitHub)


# A GitHub action for building a Writerside docs artifacts in a Docker container

This action creates a zip-archive with HTMLs converted from markdown or semantic markup files.

## Environment variables

Change these variables with the values from your project.

### `INSTANCE`

Represents the module name and instance ID, separated by a slash.

When you create a new Writerside project or add an instance in an existing project, the default module name is `Writerside` and the default instance id is `hi`.
So, in this case, set `INSTANCE: Writerside/hi`.

### `ARTIFACT`

The name of the archive is `webHelpXX2-all.zip` where `XX` gets replaced by the capitalized instance id.

For example, if the module (folder with documentation) is *Writerside*, and its ID is `hi`, then should be set to `ARTIFACT: webHelpHI2-all.zip`.

### `DOCKER_VERSION`

The Writerside docker tag. Change the DOCKER_VERSION to the corresponding version published with the plugin update. To check the corresponding version, read the [What's new section](https://www.jetbrains.com/help/writerside/whats-new-last-update.html) in our documentation.

### `PDF`
TODO: 

## Example usage: Building HTMLs Only

```yml
name: Build documentation

on:
  push:
  # To trigger the workflow once you push to the `main` branch
  # Replace `main` with your branch’s name
    branches: ["main"]
  # Specify to run a workflow manually from the Actions tab on GitHub
  workflow_dispatch:

env:
  # Name of module and id separated by a slash
  INSTANCE: Writerside/hi
  # Replace HI with the ID of the instance in capital letters
  ARTIFACT: webHelpHI2-all.zip
  # Docker image version
  DOCKER_VERSION: 242.21870

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
          name: artifact
          path: artifacts/${{ env.ARTIFACT }}
          retention-days: 7
```


## Example Usage: Building and Publishing to GitHub Pages

```yml
name: Build documentation

on:
  push:
    # To trigger the workflow once you push to the `main` branch
    # Replace `main` with your branch’s name
    branches: ["main"]
  # Specify to run a workflow manually from the Actions tab on GitHub
  workflow_dispatch:

permissions:
  id-token: write
  pages: write

env:
  # Name of module and id separated by a slash
  INSTANCE: Writerside/xx
  # Replace XX with the ID of the instance in capital letters
  ARTIFACT: webHelpXX2-all.zip
  # Docker image version
  DOCKER_VERSION: 242.21870

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
    # Requires build job results
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

## Example usage: Building PDF Only

```yml
name: Build documentation

on:
  push:
  # To trigger the workflow once you push to the `main` branch
  # Replace `main` with your branch’s name
    branches: ["main"]
  # Specify to run a workflow manually from the Actions tab on GitHub
  workflow_dispatch:

env:
  # Name of module and id separated by a slash
  INSTANCE: Writerside/hi
  # Replace HI with the ID of the instance in capital letters
  ARTIFACT: webHelpHI2-all.zip
  # Docker image version
  DOCKER_VERSION: 242.21870
  # PDF
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

For more information, please read the deployment guide — [Build and publish on GitHub](https://www.jetbrains.com/help/writerside/deploy-docs-to-github-pages.html).


