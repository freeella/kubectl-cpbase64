# kubectl-cpbase64 - an alternative to kubectl cp

'kubectl cpbase64' tries to be an alternative to 'kubectl cp' 
when 'tar' is not available. Command 'base64' is used instead.

```text
Usage:  kubectl cpbase64 [from_location] [to_location] [-c container_name]

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
```
