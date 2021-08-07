# escape=\

FROM mcr.microsoft.com/windows/servercore:20H2-amd64

# Install .NET Fx 3.5 (https://github.com/microsoft/dotnet-framework-docker/blob/171551180e2adefca869fe3804b3554da4e09a5c/src/runtime/3.5/windowsservercore-20H2/Dockerfile)
RUN curl -fSLo microsoft-windows-netfx3.zip https://dotnetbinaries.blob.core.windows.net/dockerassets/microsoft-windows-netfx3-20H2.zip \
    && tar -zxf microsoft-windows-netfx3.zip \
    && del /F /Q microsoft-windows-netfx3.zip \
    && dism /Online /Quiet /Add-Package /PackagePath:.\microsoft-windows-netfx3-ondemand-package~31bf3856ad364e35~amd64~~.cab \
    && del microsoft-windows-netfx3-ondemand-package~31bf3856ad364e35~amd64~~.cab \
    && powershell Remove-Item -Force -Recurse ${Env:TEMP}\*

# Install .NET Framework 4.6 Developer Pack (https://dotnet.microsoft.com/download/dotnet-framework/net46)
RUN curl -fSLo net4.6.exe https://go.microsoft.com/fwlink/?linkid=2099469 \
    && net4.6.exe /q /norestart \
    && del /F /Q net4.6.exe

# Install .NET Framework 4.8 Developer Pack (https://dotnet.microsoft.com/download/dotnet-framework/net48)
RUN curl -fSLo net4.8.exe https://go.microsoft.com/fwlink/?linkid=2088517 \
    && net4.8.exe /q /norestart \
    && del /F /Q net4.8.exe

# Install Chocolatey 0.10.15 (https://docs.chocolatey.org/en-us/choco/setup)
RUN powershell -Command "$env:chocolateyVersion = '0.10.15'; Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

# Install Visual Studio 2019 Build Tools (https://community.chocolatey.org/packages/visualstudio2019buildtools/16.10.4.0)
RUN choco install visualstudio2019buildtools -y --version=16.10.4.0 --params "--locale en-US --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041"

# Install Git 2.32.0.2 (https://community.chocolatey.org/packages/git/2.32.0.2)
RUN choco install git -y --version=2.32.0.2 --params "'/NoShellIntegration /NoGuiHereIntegration /NoShellHereIntegration'"

# Install CMake 3.21.0 (https://community.chocolatey.org/packages/cmake/3.21.0)
RUN choco install cmake -y --version=3.21.0 --ia "ADD_CMAKE_TO_PATH=System"

# Install Python 3.8.10 (https://community.chocolatey.org/packages/python3/3.8.10)
RUN choco install python3 --version=3.8.10 -y

# Install aqt 1.2.4 (https://pypi.org/project/aqtinstall/1.2.4/)
RUN pip install aqtinstall==1.2.4

# Install Qt 5.15.2 with aqt
RUN aqt install 5.15.2 windows desktop win64_msvc2019_64 -m qtwebengine --outputdir C:\Qt

# Install OpenSSH Server 8.6.0-beta1 (https://community.chocolatey.org/packages/openssh/8.6.0-beta1)
RUN choco install openssh --version=8.6.0-beta1 -y --params "'/SSHServerFeature /AlsoLogToFile /SSHLogLevel:DEBUG2'"

# Setup OpenSSH
RUN net user docker /add \
    && net localgroup administrators docker /add \
    && powershell -Command New-Item -Type File -Path C:\ProgramData\ssh\administrators_authorized_keys; \
    Set-Acl C:\ProgramData\ssh\administrators_authorized_keys -AclObject (Get-Acl C:\ProgramData\ssh\ssh_host_dsa_key)

# Download mob@f5c0b3e22320df2e31289c98efe23053f19b775c (https://github.com/ModOrganizer2/mob)
RUN mkdir C:\dev \
    && curl -fSLo mob.zip https://github.com/ModOrganizer2/mob/archive/f5c0b3e22320df2e31289c98efe23053f19b775c.zip \
    && tar -zxf mob.zip \
    && del /F /Q mob.zip \
    && move mob-f5c0b3e22320df2e31289c98efe23053f19b775c C:\dev\mob \
    && powershell Remove-Item -Force -Recurse ${Env:TEMP}\*

# Bootstrap
RUN powershell -Command C:\dev\mob\bootstrap.ps1

# Build
#RUN C:\dev\mob\mob.exe -l5 -d C:\dev\modorganizer build

# OpenSSH Server
EXPOSE 22/tcp