#!/usr/bin/env bash

# Note: This is an example file, do not edit `launch-open-docker.sh`. Instead, duplicate the file and edit your duplicate.
# `custom-launch-docker.sh` is reserved in gitignore for if you want to use that.

# Run script automatically in Swarm's dir regardless of how it was triggered
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR/.."

docker build --build-arg UID=1000 -f launchtools/OpenDockerfile.docker -t av-swarmui .

# add "--network=host" if you want to access other services on the host network (eg a separated comfy instance)

#ANIMVS: How to update pip:
# cd /mnt/AVHOM/AI/DockerData/AVSwarmUI/swarmbackend/ComfyUI/
# ./venv/bin/python -s -m pip install -r /mnt/AVHOM/AI/projects/AVSwarmUI/launchtools/av-comfyui-extra-requirements.txt

docker run -it \
    --rm \
    --user 1000:1000 --cap-drop=ALL \
    --name av-swarmui \
    -v "$PWD:/SwarmUI" \
    -v ./launchtools/av-comfyui-extra-requirements.txt:/AV-EXTRA/av-comfyui-extra-requirements.txt \
    -v /mnt/AVHOM/AI/Models/:/SwarmUI/Models/ \
    -v /mnt/AVHOM/AI/DockerData/AVSwarmUI/swarmdata/:/SwarmUI/Data/ \
    -v /mnt/AVHOM/AI/DockerData/AVSwarmUI/swarmbackend/:/SwarmUI/dlbackend/ \
    -v /mnt/AVHOM/AI/DockerData/AVSwarmUI/swarmdlnodes/:/SwarmUI/src/BuiltinExtensions/ComfyUIBackend/DLNodes/ \
    -v /mnt/AVHOM/AI/DockerData/AVSwarmUI/Output/:/SwarmUI/Output/ \
    -v /mnt/AVHOM/AI/DockerData/AVSwarmUI/BuiltinExtensions/CustomWorkflows/:/SwarmUI/src/BuiltinExtensions/ComfyUIBackend/CustomWorkflows/ \
    -v /mnt/AVHOM/AI/DockerData/AVSwarmUI/swarmbackend/linuxhome/:/SwarmUI/dlbackend/linuxhome/ \
    --gpus=all -p 7801:7801 av-swarmui --forward_restart $@

if [ $? == 42 ]; then
    exec "$SCRIPT_DIR/av-launch-open-docker.sh" $@
fi
