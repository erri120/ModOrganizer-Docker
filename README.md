# ModOrganizer 2 with Docker

## Requirements

- Docker Desktop for Windows
- Hyper-V features if on Windows 21H1/10.0.19043.X

## Additional Information for Windows 21H1/10.0.19043.X

See [this](https://github.com/microsoft/Windows-Containers/issues/117) issue for more information. The problem is that there are no containers for the 21H1 release of Windows at the time of writing this README which means we have to use the 20H2 container with Hyper-V isolation.

Make sure you have the Hyper-V features active and add `--isolation=hyperv` to the docker commands. If you get the error `Error response from daemon: Unsupported isolation: "hyperv"` you have to switch to Windows containers in Docker Desktop by selecting "Switch to Windows containers" from the taskbar menu.

## Errors and how to fix them

`Error response from daemon: hcsshim::CreateComputeSystem <some-id>: The request is not supported.`: Restart your system. This error occurred after enabling Windows containers and not restarting the system.

`re-exec error: exit status 1: output: hcsshim::ImportLayer - failed failed in Win32: The system cannot find the path specified. (0x3)`: Delete all Images in Docker Desktop and use [docker-ci-zap](https://github.com/moby/docker-ci-zap) in an elevated terminal: `.\docker-ci-zap.exe -folder C:\ProgramData\Docker\windowsfilter`.

## Sending SSH keys to the Container

### Using docker exec

You can use `docker exec` to execute any command inside the container. I have created a helper script [send-ssh-key.ps1](send-ssh-key.ps1) that will send your public SSH key of choice to the container using this method. The scripts requires the ID of the container, which you can obtain by using `docker ps`, and the name of the public key file in `~/.ssh/<name>`, eg: `id_rsa.pub`:

```powershell
.\send-ssh-key.ps1 -KeyFile id_rsa.pub -ContainerId 29a1f09cea0
```
