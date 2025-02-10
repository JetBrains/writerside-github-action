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
        const container = core.getInput('container') || '';
        const workingDirectory = core.getInput('workingDirectory') || '/github/workspace';

        // Set a default docker image if docker-version is undefined
        if (!imageVersion) {
            imageVersion = '232.10275';
        }

        // Set pdf flag if pdf is true
        let pdfFlag = '';
        if (pdf) {
            pdfFlag = `-pdf ${pdf}`;
        }

        const commands = `
            export DISPLAY=:99
            Xvfb :99 &
            git config --global --add safe.directory ${workingDirectory}
            /opt/builder/bin/idea.sh helpbuilderinspect -source-dir ${workingDirectory}/${location} -product ${instance} --runner github -output-dir ${workingDirectory}/artifacts/ || true
            echo "Test existing artifacts"
            test -e ${workingDirectory}/artifacts/${artifact} && echo ${artifact} exists
            if [ -z "$(ls -A ${workingDirectory}/artifacts/ 2>/dev/null)" ]; then
               echo "Artifacts not found" && false
            else
               chmod 777 ${workingDirectory}/artifacts/
               ls -la ${workingDirectory}/artifacts/
            fi
        `;

        const args = [
            'run',
            '--rm',
        ]
        if (container !== '') {
            args.push("--volumes-from", container);
        } else {
            args.push("-v", `${workspace}:${workingDirectory}`);
        }
        args.push(
            `registry.jetbrains.team/p/writerside/builder/writerside-builder:${imageVersion}`,
            '/bin/bash',
            '-c',
            commands
        )
        // Run your Docker container
        await exec.exec('docker', args);
    }
    catch (error) {
        core.setFailed(error.message);
    }
}

run();