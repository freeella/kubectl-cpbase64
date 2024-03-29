# kubectl-cpbase64 - an alternative to kubectl cp

## install

### manual install

Put script `kubectl-cpbase64` into environment variable PATH.

## purpose

Rootless and distroless containers are very poulare these days. Rootless means that additional tools can't be installed. Distroless or minimal install menan that in many cases `tar` is not available on the container.

`kubectl cp` can't be used to export debug data such as memory dumps from the container, if `tar` is not installed.

Because the command line tool `base64` is still installed on many containers, `kubectl cpbase64` tries to be an alternative to `kubectl cp` by 
falling back to `base64` and trying to be in sync with command line syntax of `kubectl cp`.


```text
Usage:  kubectl cpbase64 [from_location] [to_location] [-c container_name]

        Command line syntax of 'kubectl cpbase64' is similar to 'kubectl cp'!

Command line examples:

        kubectl cpbase64 version - returns the version of this plugin
        kubectl cpbase64 help    - returns this help screen


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
```
