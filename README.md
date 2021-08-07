# ModOrganizer 2 with Docker

- [`erri120/modorganizer-base:latest`](Dockerfile.Base): Contains all Build Requirements as well as [mob](https://github.com/modorganizer2/mob) already configured
- [`erri120/modorganizer-build:latest`](Dockerfile.Build): Build-Container
- [`erri120/modorganizer-dev:latest`](Dockerfile.Dev): Dev-Container for remote development

## Remote Development using the Dev-Container

If you are like me then you absolutely hate dealing with C++ build systems and trying to get a development environment working on your local machine. The pain and stress associated with creating this environment can be omitted by simply using a development container.

### Requirements

- [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
- [SSH Client](https://docs.microsoft.com/en-gb/windows-server/administration/openssh/openssh_install_firstuse)
- Hyper-V features depending on your Windows Version (required for Windows 21H1/10.0.19043.X), see [Hyper-V vs Process Isolation](#hyper-v-vs-process-isolation) for more information

### Starting the Dev-Container

You can use the Docker Desktop UI, the `docker run` command or you can create a `docker-compose.yml` file and use `docker-compose` / `docker compose`. Whatever you choose there are some imporant things you need to know and use:

1) Use Hyper-V isolation if required, see [Hyper-V vs Process Isolation](#hyper-v-vs-process-isolation) for more information:
   - Docker Desktop: will automatically use if required
   - `docker`: append `--isolation=hyperv` to your command ([Docs](https://docs.docker.com/engine/reference/commandline/run/#specify-isolation-technology-for-container---isolation))
   - Docker-Compose: use `isolation: "hyperv"` ([Docs](https://docs.docker.com/compose/compose-file/compose-file-v3/#isolation))
2) Allocate a pseudo-TTY or the container will exit immediately after startup:
   - Docker Desktop: will automatically do this
   - `docker`: append `-it` to your command ([Docs](https://docs.docker.com/engine/reference/commandline/run/#assign-name-and-allocate-pseudo-tty---name--it))
   - Docker-Compose: use `tty: true` ([Docs](https://docs.docker.com/compose/compose-file/compose-file-v3/#domainname-hostname-ipc-mac_address-privileged-read_only-shm_size-stdin_open-tty-user-working_dir))
3) Map the SSH Container Port to a Local Host Port
   - Docker Desktop: open the Optional Settings before running and assing a port
   - `docker`: append `-p 9999:22` to your command ([Docs](https://docs.docker.com/engine/reference/commandline/run/#publish-or-expose-port--p---expose))
   - Docker-Compose: use `ports:\n-"9999:22"` ([Docs](https://docs.docker.com/compose/compose-file/compose-file-v3/#ports))

TODO: mounting with volumes or bindings don't work because either git or patch.exe (GnuWin32 patch utility) fail. This is apparently some problem with mounted directories. Here is a compilation of issues: [git-for-windows/git#2278](https://github.com/git-for-windows/git/issues/2778), [git-for-windows/git#1737](https://github.com/git-for-windows/git/issues/1737), [git-for-windows/git#1007](https://github.com/git-for-windows/git/issues/1007), [moby/moby#31089](https://github.com/moby/moby/issues/31089).

### Sending SSH keys to the Container

You can use `docker exec` to execute any command inside the container. I have created a helper script [send-ssh-key.ps1](send-ssh-key.ps1) that will send your public SSH key of choice to the container using this method. The scripts requires the ID of the container, which you can obtain by using `docker ps`, and the name of the public key file in `~/.ssh/<name>`, eg: `id_rsa.pub`:

```powershell
.\send-ssh-key.ps1 -KeyFile id_rsa.pub -ContainerId 29a1f09cea0
```

On the topic of SSH keys: you might get an SSH error when you rebuild the container or use a different version. This is caused by a different public key of the OpenSSH server and you can fix this by removing the server entry from the `known_hosts` file in `~/.ssh/`.

### Development with VS Code

VS Code has very good support for [Remote Development](https://code.visualstudio.com/docs/remote/remote-overview) offering different extensions depending on the remote server: [SSH](https://code.visualstudio.com/docs/remote/ssh), [Containers](https://code.visualstudio.com/docs/remote/containers) and [WSL](https://code.visualstudio.com/docs/remote/wsl). We are using a Container so you'd think that we can utilize the VS Code Remote Containers extension with the only problem being that Windows Containers are not yet supported. See [this](https://github.com/microsoft/vscode-remote-release/issues/445) issue for more information and updates. This means we have to use the SSH extension which works just fine so make sure you have the container running, [send your SSH key to the container](#sending-ssh-keys-to-the-container) and [installed the required extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh).

Start VS Code, open the Command Palette (_View_ -> _Command Palette..._) and select **Remote-SSH: Connect to Host...**. On the first run you have to configure the host so make sure to use `docker@localhost` or `docker@127.0.0.1` with the correct port. Once VS Code establishes the connection it will download the VS Code Server and you should see information about the SSH connection in the Status bar.

You can now select **Open Folder** and navigate to `C:\dev` where you will find [mob](https://github.com/modorganizer2/mob) that has already been build.

### Development with Visual Studio

**TODO**:

### Development with  CLion

**TODO**:

## Using the Build-Container

This container was designed to simply call `mob.exe build` when you run the container.

## Hyper-V vs Process Isolation

Containers are amazing and we love them. They are faster than a VM because they can share the same kernel as the host which leads to reduced image sizes and faster speeds. This is no different with Windows Containers and is called **Process Isolation**. The specific problem that Windows Containers have are version mismatches. This means that you can only run a Windows Server 20H2 Container in process isolation with a Windows 10 version 20H2. If you instead use a Windows 10 that is older or newer than 20H2 (21H1, 2004, 1909, 1903 or 1809) you will get error messages like "File not found" or "Version unsupported".

To solve this problem Microsoft introduced **Hyper-V isolation** for Windows Containers. With Hyper-V you have better security, better version compatability but less speed.

The Dockerfiles in this repository use Windows Server Core 20H2 base-images because there are no 21H1 images. See [this](https://github.com/microsoft/Windows-Containers/issues/117) issue for more information. If you want to use these Dockerfiles and you do not have a Windows 10 version 20H2 then you have to use Hyper-V isolation by adding `--isolation=hyperv` to your docker commands.

If you get the error `Error response from daemon: Unsupported isolation: "hyperv"` you have to switch to Windows containers in Docker Desktop by selecting "Switch to Windows containers" from the taskbar menu.

For more information on this topic see the official docs on [Isolation modes](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/hyperv-container) and [Version compatibility](https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility).

## Common Errors and how to fix them

`Error response from daemon: hcsshim::CreateComputeSystem <some-id>: The request is not supported.`: Restart your system. This error occurred after enabling Windows containers and not restarting the system.

`re-exec error: exit status 1: output: hcsshim::ImportLayer - failed failed in Win32: The system cannot find the path specified. (0x3)`: Delete all Images in Docker Desktop and use [docker-ci-zap](https://github.com/moby/docker-ci-zap) in an elevated terminal: `.\docker-ci-zap.exe -folder C:\ProgramData\Docker\windowsfilter`.
