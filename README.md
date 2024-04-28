# kubectl-cpbase64 - an alternative to kubectl cp

## install

### manual install

- Put script `kubectl-cpbase64` into environment variable PATH.

```bash
mkdir -p ~/.local/bin
cp src/kubectl-cpbase64 ~/.local/bin
chmod u+x ~/.local/bin/kubectl-cpbase64
export PATH=~/.local/bin:${PATH}

kubectl cpbase64 help
```

### install via krew plug-in manager

- Install via krew.

```bash
# install latest release
kubectl krew install cpbase64

# use it
kubectl cpbase64 help
```

- Install via krew using this repo URL.

```bash
kubectl krew index add cpbase64 https://github.com/freeella/kubectl-cpbase64.git
kubectl krew update
kubectl krew index list

# install latest release
kubectl krew install cpbase64/cpbase64
# install test version
kubectl krew install cpbase64/cpbase64-test

# use it
kubectl cpbase64 help
```

## purpose

Rootless and distroless containers are very popular these days. This means that as less as possible command line tools are installed inside containers and no additional tools can be installed later. Distributions that do not ship `busybox` often do not ship `tar` by default.

Without `tar` command `kubectl cp` can't be used to copy debug data such as memory dumps from the container.

Because the command line tool `base64` is still installed on many containers, `kubectl cpbase64` tries to be an alternative to `kubectl cp` by 
falling back to `base64` and trying to be in sync with command line syntax of `kubectl cp`.


```text
Usage:  kubectl cpbase64 [from_location] [to_location] [-c container_name]
        kubectl cpbase64 [-l|--local] /tmp/foo.txt [-r|--remote] [NS/]some-pod:[.|/tmp/[bar.txt]] [-c container_name]
        kubectl cpbase64 [-r|--remote] [namespace/]some-pod:/tmp/foo.txt  [-l|--local] [.|/tmp/[bar.txt]] [-c container_name]

        'kubectl cpbase64' tries to be an alternative to 'kubectl cp'
        when 'tar' is not available. Command 'base64' is used instead.

        Command line syntax of 'kubectl cpbase64' is similar to 'kubectl cp'!

Command line examples:

        kubectl cpbase64 version - returns the version of this plugin
        kubectl cpbase64 help - returns this help screen

        # Copy /tmp/foo from a remote pod to /tmp/bar locally
        kubectl cpbase64 <some-pod>:/tmp/foo /tmp/bar
        kubectl cpbase64 <some-namespace>/<some-pod>:/tmp/foo /tmp/bar
        kubectl cpbase64 <some-namespace>/<some-pod>:/tmp/foo /tmp/bar -c <specific-container>
        kubectl cpbase64 <some-pod>:/tmp/foo /tmp/bar -c <specific-container>

        # Copy local /tmp/foo to a remote pod file /tmp/bar
        kubectl cpbase64 /tmp/foo <some-pod>:/tmp/bar
        kubectl cpbase64 /tmp/foo <some-namespace>/<some-pod>:/tmp/bar
        kubectl cpbase64 /tmp/foo <some-namespace>/<some-pod>:/tmp/bar -c <specific-container>
        kubectl cpbase64 /tmp/foo <some-pod>:/tmp/bar -c <specific-container>

        # cpbase64 specific:
        # Copy /tmp/foo from a remote pod to /tmp/foo locally
        kubectl cpbase64 <some-pod>:/tmp/foo /tmp/
        kubectl cpbase64 <some-pod>:/tmp/foo /tmp
        cd ~/tmp; kubectl cpbase64 <some-pod>:/tmp/foo .

        # Copy local /tmp/foo to a remote pod file /tmp/foo
        kubectl cpbase64 /tmp/foo <some-pod>:/tmp/
        # Copy local /tmp/foo to a remote pod file ~/foo
        kubectl cpbase64 /tmp/foo <some-pod>:.

        # Copy local /tmp/foo_2024-04-01_20:33:44 to some remote pod file /tmp/bar_2024-04-01_20:33:44
        kubectl cpbase64 -l /tmp/foo_2024-04-01_20:33:44 -r <some-pod>:/tmp/bar_2024-04-01_20:33:44
        kubectl cpbase64 --local /tmp/foo_2024-04-01_20:33:44 --remote <some-pod>:/tmp/bar_2024-04-01_20:33:44

        # Copy from some remote pod file /tmp/foo_2024-04-01_20:33:44 to a local file /tmp/bar_2024-04-01_20:33:44
        kubectl cpbase64 -r <some-pod>:/tmp/foo_2024-04-01_20:33:44 -l /tmp/bar_2024-04-01_20:33:44
        kubectl cpbase64 --remote <some-pod>:/tmp/foo_2024-04-01_20:33:44 --local /tmp/bar_2024-04-01_20:33:44
```
