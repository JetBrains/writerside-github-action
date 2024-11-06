const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
    try {
        let imageVersion = core.getInput('docker-version');
        const location = core.getInput('location') || '';
        const instance = core.getInput('instance');
        const artifact = core.getInput('artifact');
        const pdf = core.getInput('pdf');
        const workspace = process.env.GITHUB_WORKSPACE;

        // Set a default docker image if docker-version is undefined
        if (!imageVersion) {
            imageVersion = '232.10275';
        }

        // Set pdf flag if pdf is true
        let pdfFlag = '';
        if (pdf) {
            pdfFlag = '-pdf=${pdf}';
        }

        const commands = `
            export DISPLAY=:99
            Xvfb :99 &
            git config --global --add safe.directory /github/workspace
            /opt/builder/bin/idea.sh helpbuilderinspect -source-dir /github/workspace/${location} -product ${instance} --runner github -output-dir /github/workspace/artifacts/ ${pdfFlag} || true
            echo "Test existing artifacts"
            test -e /github/workspace/artifacts/${artifact} && echo ${artifact} exists
            if [ -z "$(ls -A /github/workspace/artifacts/ 2>/dev/null)" ]; then
               echo "Artifacts not found" && false
            else
               chmod 777 /github/workspace/artifacts/
               ls -la /github/workspace/artifacts/
            fi
        `;

        // Run your Docker container
        await exec.exec('docker', [
            'run',
            '--rm',
            '-v',
            `${workspace}:/github/workspace`,
            `registry.jetbrains.team/p/writerside/builder/writerside-builder:${imageVersion}`,
            '/bin/bash',
            '-c',
            commands
        ]);
    }
    catch (error) {
        core.setFailed(error.message);
    }
}

run();