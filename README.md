[![JetBrains team project](https://jb.gg/badges/team.svg)](https://confluence.jetbrains.com/display/ALL/JetBrains+on+GitHub)


# Writerside GitHub action

This action runs the Writerside builder Docker image,
which creates a ZIP archive with your documentation website from a Writerside project.

For more information,
see [Writerside documentation](https://www.jetbrains.com/help/writerside/deploy-docs-to-github-pages.html).

## Environment variables

The following environment variables are mandatory:

`INSTANCE`
: Specify the module name and instance ID or build-group-ID, separated by a slash.
: When you create a new Writerside project or add an instance in an existing project, the default module name is `Writerside` and the default instance ID is `hi`.
: So, in this case, you would set `INSTANCE: 'Writerside/hi'`.

`DOCKER_VERSION`
: Specify the version tag of the Writerside Docker builder image.
  For the latest version, see [What's new](https://www.jetbrains.com/help/writerside/whats-new-last-update.html).

The following environment variables are optional:

`PDF`
: Produce a PDF file as a build artifact instead of the documentation website.
  Specify an XML file with PDF generation options.

`IS_GROUP`
: Build documentation for a group of instances.

> **Note**  
> Building a PDF file is **not supported** when using `IS_GROUP`. If you set both `IS_GROUP` and `PDF`, the builder will ignore the `IS_GROUP` option and produce a PDF for a single instance only.

## Example: Build your documentation website

```yml
name: Build documentation

on:
  push:
    branches: ["main"]
  workflow_dispatch:

env:
  INSTANCE: 'Writerside/hi'
  DOCKER_VERSION: '243.22562'
  # IS_GROUP: 'true'  # Uncomment to build a group

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Define instance id and artifacts
        id: define-ids
        run: |
          INSTANCE=${INSTANCE#*/}
          INSTANCE_ID_UPPER=$(echo "$INSTANCE" | tr '[:lower:]' '[:upper:]')
          ARTIFACT="webHelp${INSTANCE_ID_UPPER}2-all.zip"
          ALGOLIA_ARTIFACT="algolia-indexes-${INSTANCE_ID_UPPER}.zip"

          # Print the values
          echo "INSTANCE_ID_UPPER: $INSTANCE_ID_UPPER"
          echo "ARTIFACT: $ARTIFACT"
          echo "ALGOLIA_ARTIFACT: $ALGOLIA_ARTIFACT"

          # Set the environment variables and outputs
          echo "INSTANCE_ID_UPPER=$INSTANCE_ID_UPPER" >> $GITHUB_ENV
          echo "ARTIFACT=$ARTIFACT" >> $GITHUB_ENV
          echo "ALGOLIA_ARTIFACT=$ALGOLIA_ARTIFACT" >> $GITHUB_ENV

      - name: Build docs using Writerside Docker builder
        uses: JetBrains/writerside-github-action@v4
        with:
          instance: ${{ env.INSTANCE }}
          docker-version: ${{ env.DOCKER_VERSION }}
          is-group: ${{ env.IS_GROUP }}
          artifact: ${{ env.ARTIFACT }}

      - name: Save artifact with build results
        uses: actions/upload-artifact@v4
        with:
          name: docs
          path: artifacts/*
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
  DOCKER_VERSION: '243.22562'
# IS_GROUP: 'true'  # Uncomment to build a group

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      algolia_artifact: ${{ steps.define-ids.outputs.algolia_artifact }}
      artifact: ${{ steps.define-ids.outputs.artifact }}
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Define instance id and artifacts
        id: define-ids
        run: |
          INSTANCE=${INSTANCE#*/}
          INSTANCE_ID_UPPER=$(echo "$INSTANCE" | tr '[:lower:]' '[:upper:]')
          ARTIFACT="webHelp${INSTANCE_ID_UPPER}2-all.zip"
          ALGOLIA_ARTIFACT="algolia-indexes-${INSTANCE_ID_UPPER}.zip"

          # Print the values
          echo "INSTANCE_ID_UPPER: $INSTANCE_ID_UPPER"
          echo "ARTIFACT: $ARTIFACT"
          echo "ALGOLIA_ARTIFACT: $ALGOLIA_ARTIFACT"

          # Set the environment variables and outputs
          echo "INSTANCE_ID_UPPER=$INSTANCE_ID_UPPER" >> $GITHUB_ENV
          echo "ARTIFACT=$ARTIFACT" >> $GITHUB_ENV
          echo "ALGOLIA_ARTIFACT=$ALGOLIA_ARTIFACT" >> $GITHUB_ENV
          echo "artifact=$ARTIFACT" >> $GITHUB_OUTPUT
          echo "algolia_artifact=$ALGOLIA_ARTIFACT" >> $GITHUB_OUTPUT

      - name: Build docs using Writerside Docker builder
        uses: JetBrains/writerside-github-action@v4
        with:
          instance: ${{ env.INSTANCE }}
          docker-version: ${{ env.DOCKER_VERSION }}
          is-group: ${{ env.IS_GROUP }}
          artifact: ${{ steps.define-ids.outputs.artifact }}

      - name: Save artifact with build results
        uses: actions/upload-artifact@v4
        with:
          name: docs
          path: artifacts/*
          retention-days: 7
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: docs
          path: artifacts

      - name: Unzip artifact
        run: unzip -O UTF-8 -qq "artifacts/${{ needs.build.outputs.artifact }}" -d dir

      - name: Setup Pages
        uses: actions/configure-pages@v4

      - name: Package and upload Pages artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: dir

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
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
  DOCKER_VERSION: '243.22562'
  PDF: 'PDF.xml'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Define instance id
        run: |
          INSTANCE_ID="${INSTANCE#*/}"
          INSTANCE_ID_UPPER=$(echo "$INSTANCE_ID" | tr '[:lower:]' '[:upper:]')
          echo "INSTANCE_ID_UPPER=$INSTANCE_ID_UPPER" >> $GITHUB_ENV
          echo "Extracted ID: $INSTANCE_ID_UPPER"
      
      - name: Build Writerside docs using Docker
        uses: JetBrains/writerside-github-action@v4
        with:
          instance: ${{ env.INSTANCE }}
          docker-version: ${{ env.DOCKER_VERSION }}
          pdf: ${{ env.PDF }}
          artifact: pdfSource${{ env.INSTANCE_ID_UPPER }}.pdf

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: artifact
          path: |
            artifacts/pdfSource${{ env.INSTANCE_ID_UPPER }}.pdf
            artifacts/pdfSource${{ env.INSTANCE_ID_UPPER }}.html
          retention-days: 7
```
