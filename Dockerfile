# escape=`

FROM mcr.microsoft.com/dotnet/framework/aspnet:4.7.1-windowsservercore-ltsc2016

ARG DOTNETCOREHOSTING_EXE=c:\\install\\DotNetCore.1.1.0-WindowsHosting.exe
ARG PUBLISHING_SITE_NAME=sitecore.publishing
ARG SITE_WEB_ROOT="C:\\inetpub\\wwwroot\\publisher"
ARG ASSET_ROOT="C:\\assets"
ARG PUBLISHING_HOST="Sitecore.Framework.Publishing.Host.exe"
ARG PUBLISHING_PACKAGE
ARG CONN_STRING_CORE
ARG CONN_STRING_MASTER
ARG CONN_STRING_WEB

ADD https://aka.ms/dotnetcore_windowshosting_1_1_0 ${DOTNETCOREHOSTING_EXE}

# Install Prerequisites
RUN Start-Process $env:DOTNETCOREHOSTING_EXE -ArgumentList '/install', '/passive', '/norestart' -NoNewWindow -Wait; `	
	Import-Module ServerManager; Add-WindowsFeature Web-Scripting-Tools;

# Remove default IIS site
RUN Remove-Website -Name 'Default Web Site';

SHELL ["powershell", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop';"]

COPY ./assets ${ASSET_ROOT}

WORKDIR $SITE_WEB_ROOT

# Copy Publishing Service files
RUN $packagePath = Join-Path $env:ASSET_ROOT $env:PUBLISHING_PACKAGE; `
	Expand-Archive -Path $packagePath -DestinationPath $env:SITE_WEB_ROOT; 

# Set Conn strings
RUN	$coreArgs = 'configuration setconnectionstring core """' + $env:CONN_STRING_CORE + '"""'; `
	$masterArgs = 'configuration setconnectionstring master """' + $env:CONN_STRING_MASTER + '"""'; `
	$webArgs = 'configuration setconnectionstring web """' + $env:CONN_STRING_WEB + '"""'; `
	Start-Process $env:PUBLISHING_HOST -ArgumentList $coreArgs -NoNewWindow -Wait; ` 
    Start-Process $env:PUBLISHING_HOST -ArgumentList $masterArgs -NoNewWindow -Wait; ` 
	Start-Process $env:PUBLISHING_HOST -ArgumentList $webArgs -NoNewWindow -Wait; 
	
# Upgrade schema
RUN Start-Process $env:PUBLISHING_HOST -ArgumentList 'schema upgrade --force' -NoNewWindow -Wait; 
	
# Install IIS site	
RUN $args = 'iis install --sitename ' + $env:PUBLISHING_SITE_NAME + ' --apppool ' + $env:PUBLISHING_SITE_NAME; `
	Start-Process $env:PUBLISHING_HOST -ArgumentList $args -NoNewWindow -Wait; 
	
EXPOSE 80