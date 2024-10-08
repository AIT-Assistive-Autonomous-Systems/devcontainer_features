## OS support
Should support any POSIX OS supporting typical user tools (e.g., useradd, ...), bash and with sed installed, but only tested against Ubuntu currently.
## Permissions
Relies on `onCreateCommand` currently due to lack up devcontainer feature support. Thus, requires sudo permissions or permission to update groups and user databases as well as any path written or being read.
## Automatic discovery
Is planned in the future if the `devcontainer-features` API will allow it. Currently you must resort to an `initializeCommand` or another approach to run commands on the host to provide the required entries/file.

In the future if auto-discovery is supported that will be default (map all user groups found for that user).

```sh
# Example call to provide groups of the host without the user group (mapped by common-utils already)
id | cut -d = -f 4 | sed -E "s/$(id -g)\($(id -gn)\),?//" | sed -E "s/,+$//" > .devcontainer/host_groups
#Example output
4(adm),24(cdrom),27(sudo),46(plugdev),116(lpadmin),999(docker)
```

After the container is created you will need to restart the container for all new groups to become active currently.
In `vscode` this means either closing the last instance on your current (remote) host or force killing the vscode instance via the command palette.

## Option notes

### addGroups

Currently the `addGroups` option supports that above output format or a recusrive resolve `file://path-to-file` with the above format. This is necessary as currently we don't have access to such a file until the container hooks run and have access to the workspace. If a referenced file is not found no-groups will be added or modified.

### excludeGroups

Ideally in the future we can default it to remove the user group, right now you must either pre-filter it or add it to an exclude file as with host_groups. On most systems id will return the host group as the first group. Setting `excludeGroups` to `()` will remove the first entry resp. next group of the provided groups. `(),()` would remove the the first two entries from the provided string.

### runAt

If you are able to set your groups at image build time (as file in your image or as direct values), you can select `build` instead of `create` for running the script at image build time.

## Extended example


### Add supplemental groups

Adds or modifies all groups inside the container to match the outside user, except the user group:

```json
{
    "name": "Ubuntu",
    "image": "mcr.microsoft.com/devcontainers/base:jammy",
    "features": {
        "ghcr.io/devcontainers/features/common-utils:2": {},
        "ghcr.io/AIT-Assistive-Autonomous-Systems/devcontainer_features/add-groups:0": {
            "addGroups": "file://.devcontainer/host_groups"
        }
    },
    "initializeCommand": "id | cut -d = -f 4 | sed -E \"s/$(id -g)\\($(id -gn)\\),?//\" | sed -E \"s/,+$//\" > .devcontainer/host_groups",
    "remoteUser": "vscode"
}
```

Or by remove the first group, which is usually the user group:

```json
{
    "name": "Ubuntu",
    "image": "mcr.microsoft.com/devcontainers/base:jammy",
    "features": {
        "ghcr.io/devcontainers/features/common-utils:2": {},
        "ghcr.io/AIT-Assistive-Autonomous-Systems/devcontainer_features/add-groups:0": {
            "addGroups": "file://.devcontainer/host_groups",
            "excludeGroups": "()"
        }
    },
    "initializeCommand": "id | cut -d = -f 4 > .devcontainer/host_groups",
    "remoteUser": "vscode"
}
```
