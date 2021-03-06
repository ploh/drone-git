$ErrorActionPreference = 'Stop';

# HACK: no clue how to set the PATH inside the Dockerfile,
# so am setting it here instead. This is not idea.
$Env:PATH += ';C:\git\cmd;C:\git\mingw64\bin;C:\git\usr\bin'

# if the workspace is set we should make sure
# it is the current working directory.

if ($Env:DRONE_WORKSPACE) {
    cd $Env:DRONE_WORKSPACE
}

# if the netrc enviornment variables exist, write
# the netrc file.

if ($Env:DRONE_NETRC_MACHINE) {

$netrc=[string]::Format("{0}\_netrc",$Env:HOME);
"machine $Env:CI_NETRC_MACHINE" >> $netrc;
"login $Env:CI_NETRC_USERNAME" >> $netrc;
"password $Env:CI_NETRC_PASSWORD" >> $netrc;
}

# configure git global behavior and parameters via the
# following environment variables:

if ($Env:PLUGIN_SKIP_VERIFY) {
    $Env:GIT_SSL_NO_VERIFY = "true"
}

if ($Env:DRONE_COMMIT_AUTHOR_NAME) {
    $Env:GIT_AUTHOR_NAME = $Env:DRONE_COMMIT_AUTHOR_NAME
} else {
    $Env:GIT_AUTHOR_NAME = "drone"
}

if ($Env:DRONE_COMMIT_AUTHOR_NAME) {
    $Env:GIT_AUTHOR_NAME = $Env:DRONE_COMMIT_AUTHOR_NAME
} else {
    $Env:GIT_AUTHOR_NAME = 'drone@localhost'
}

$Env:GIT_COMMITTER_NAME  = $Env:GIT_AUTHOR_NAME
$Env:GIT_COMMITTER_EMAIL = $Env:GIT_AUTHOR_EMAIL

# invoke the sub-script based on the drone event type.
# TODO we should ultimately look at the ref, since
# we need something compatible with deployment events.

switch ($Env:DRONE_BUILD_EVENT) {
    "pull_request" {
        Invoke-Expression "${PSScriptRoot}\clone-pull-reqest.ps1"
        break
    }
    "tag" {
        Invoke-Expression "${PSScriptRoot}\clone-tag.ps1"
        break
    }
    default {
        Invoke-Expression "${PSScriptRoot}\clone-commit.ps1"
        break
    }
}