# escape=\

#FROM mcr.microsoft.com/windows/servercore:20H2-amd64
#FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-20H2

FROM abrarov/msvc-2019:2.12.1

# Install Chocolatey (https://docs.chocolatey.org/en-us/choco/setup)
#RUN powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

# Install Visual Studio 2019 Build Tools (https://community.chocolatey.org/packages/visualstudio2019buildtools/16.10.4.0)
#RUN choco install visualstudio2019buildtools --version=16.10.4.0 -y --params "--quiet --norestart --wait --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset --add Microsoft.VisualStudio.Component.VC.Llvm.Clang --add Microsoft.VisualStudio.Component.VC.CLI.Support --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.Net.Component.3.5.DeveloperTools --add Microsoft.Net.Component.4.6.TargetingPack --add Microsoft.Net.Component.4.6.1.TargetingPack --add Microsoft.Net.ComponentGroup.4.6.1.DeveloperTools"
#RUN choco install visualstudio2019buildtools --version=16.10.4.0 -y --params "--quiet --norestart --wait --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.VC.CLI.Support --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.Net.Component.3.5.DeveloperTools --add Microsoft.Net.Component.4.6.TargetingPack --add Microsoft.Net.Component.4.6.1.TargetingPack --add Microsoft.Net.ComponentGroup.4.6.1.DeveloperTools"

# Install .NET Framework 4.6 Developer Pack (https://docs.microsoft.com/en-gb/dotnet/framework/deployment/guide-for-administrators#create-a-package-and-program-for-the-net-framework-redistributable-package)
RUN curl -fSLo net4.6.exe https://go.microsoft.com/fwlink/?linkid=2099469 \
    && net4.6.exe /q /norestart \
    && del /F /Q net4.6.exe

# Install .NET Fx 3.5 (https://github.com/microsoft/dotnet-framework-docker/blob/171551180e2adefca869fe3804b3554da4e09a5c/src/runtime/3.5/windowsservercore-ltsc2019/Dockerfile)
RUN curl -fSLo microsoft-windows-netfx3.zip https://dotnetbinaries.blob.core.windows.net/dockerassets/microsoft-windows-netfx3-ltsc2019.zip \
    && tar -zxf microsoft-windows-netfx3.zip \
    && del /F /Q microsoft-windows-netfx3.zip \
    && dism /Online /Quiet /Add-Package /PackagePath:.\microsoft-windows-netfx3-ondemand-package~31bf3856ad364e35~amd64~~.cab \
    && del microsoft-windows-netfx3-ondemand-package~31bf3856ad364e35~amd64~~.cab \
    && powershell Remove-Item -Force -Recurse ${Env:TEMP}\*

# Install Python (https://community.chocolatey.org/packages/python3/3.8.10)
RUN choco install python3 --version=3.8.10 -y

# Install aqt (https://github.com/miurahr/aqtinstall)
RUN pip install aqtinstall

# Install Qt 5.15.2 with aqt
RUN aqt install 5.15.2 windows desktop win64_msvc2019_64 -m qtwebengine --outputdir C:\Qt

# Install Git (https://community.chocolatey.org/packages/git)
#RUN choco install git -y --params "/GitOnlyOnPath /NoShellIntegration /NoGuiHereIntegration /NoShellHereIntegration"

# Install OpenSSH Server (https://docs.microsoft.com/en-gb/windows-server/administration/openssh/openssh_install_firstuse)
#RUN powershell.exe -Command \
#    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0; \
#    Start-Service sshd; \
#    Set-Service -Name sshd -StartupType 'Automatic'; \
#    Get-NetFirewallRule -Name *ssh*; \
#    New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

# Download mob
RUN mkdir C:\dev && git clone https://github.com/ModOrganizer2/mob C:\dev\mob

# Bootstrap
RUN powershell.exe -Command C:\dev\mob\bootstrap.ps1

# Build
RUN C:\dev\mob\mob.exe -l5 -d C:\dev\modorganizer build