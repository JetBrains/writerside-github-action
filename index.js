const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
    try {
        let imageVersion = core.getInput('docker-version');
        const location = core.getInput('location') || '';
        const instance = core.getInput('instance');
        const artifact = core.getInput('artifact');
        const workspace = process.env.GITHUB_WORKSPACE;

        // Set a default docker image if docker-version is undefined
        if (!imageVersion) {
            imageVersion = '232.10275';
        }

        const commands = `
            cd /github/workspace
            export DISPLAY=:99
            Xvfb :99 &
            git config --global --add safe.directory /github/workspace
            echo "Generate timestamps"
            mkdir -p /github/workspace/timestamps
            echo "{" > /github/workspace/timestamps/timestamps.json
            git ls-tree -r --name-only HEAD | grep -E '\\.(topic|md)$' | xargs -n 1 -P 4 -I{} bash -c 'echo -e "\\"$0\\": \\"$(git log -1 --format="%at" -- "$0")\\","' {} >> /github/workspace/timestamps/timestamps.json
            sed -i '$ s/.$//' /github/workspace/timestamps/timestamps.json
            echo "}" >> /github/workspace/timestamps/timestamps.json
            echo "Printing timestamps.json"
            cat /github/workspace/timestamps/timestamps.json
            /opt/builder/bin/idea.sh helpbuilderinspect -source-dir /github/workspace/${location} -product ${instance} --runner github -output-dir /github/workspace/artifacts/ -time /github/workspace/timestamps/timestamps.json || true
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