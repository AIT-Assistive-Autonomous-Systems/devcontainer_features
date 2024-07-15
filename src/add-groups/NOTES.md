# OS support
Should support any POSIX OS supportin typical user tools (e.g., useradd, ...), bash and with sed installed, but only tested against Ubuntu currently.
# Permissions
Relies on `onCreateCommand` currently due to lack up devcontainer feature support. Thus, requires sudo permissions or permission to update groups and user databases as well as any path written or being read.
# Automatic discovery
Is planned in the future if the `devcontainer-features` API will allow it. Currently you must resort to an `initializeCommand` or another approach to run commands on the host to provide the required entries/file.

In the future if auto-discovery is supported that will be default (map all user groups found for that user).

```sh
# Example call to provide groups of the host without the user group (mapped by common-utils already)
id | cut -d = -f 4 | sed -E "s/$(id -g)\($(id -gn)\),?//" > .devcontainer/host_groups
#Example output_
4(adm),24(cdrom),27(sudo),46(plugdev),116(lpadmin),999(docker)
```

After the container is created you will need to restart the container for all new groups to become active currently.
In `vscode` this means either closing the last instance on your current (remote) host or force killing the vscode instance via the command palette.

# Options
Currently the `addGroups` option supports that above output format or a recusrive resolve `file://path-to-file` with the above format. This is necessary as currently we don't have access to such a file until the container hooks run and have access to the workspace. If a referenced file is not found no-groups will be added or modified.

# Extended Example

```json
{
	"name": "Ubuntu",
	"image": "mcr.microsoft.com/devcontainers/base:jammy",
	"features": {
		"ghcr.io/devcontainers/features/common-utils:2": {},
		"ghcr.io/AIT-Assistive-Autonomous-Systems/devcontainer_features/add-groups": {
			"addGroups": "file://.devcontainer/host_groups"
		}
	},
    "initializeCommand": "id | cut -d = -f 4 | sed -E \"s/$(id -g)\\($(id -gn)\\),?//\" > .devcontainer/host_groups",
    "remoteUser": "vscode"
}
```
