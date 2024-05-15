#!/usr/bin/env bats

# - setup_file() only runs once
# - setup() before each test
setup_file() {
    ### config
    # - calculate defaults based on current directory
    FULLNAME=$(realpath ${BATS_TEST_FILENAME})
    BASEDIR=$(dirname ${FULLNAME})
    # make executables in src/ visible to PATH
    PATH="${BASEDIR}/../main:$PATH"
    head --bytes=10240 /dev/urandom >/tmp/foo
    ls -lah /tmp/foo                 | sed 's|^|# SETUP_FILE: ls -la  : |' >&3
    sha1sum /tmp/foo                 | sed 's|^|# SETUP_FILE: sha1sum : |' >&3
    cp /tmp/foo '/tmp/foo:123:text.txt'
    ls -lah '/tmp/foo:123:text.txt'  | sed 's|^|# SETUP_FILE: ls -la  : |' >&3
    sha1sum '/tmp/foo:123:text.txt'  | sed 's|^|# SETUP_FILE: sha1sum : |' >&3
}

# - teardown_file() only runs once
# - teardown() after each test
teardown_file() {
    rm -f /tmp/foo
    rm -f '/tmp/foo:123:text.txt'
    rm -f /tmp/bar*
}

#### successful tests
# 1
@test "exec_kubectl_cpbase64_version" {
    run kubectl-cpbase64 version
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ^Version:  ]]
    for i in `seq 0 "${#lines[@]}"`; do echo "# DEBUG: ${lines[$i]}" >&3; done
}

# 2
@test "exec_kubectl_cpbase64_help" {
    run kubectl-cpbase64 help
    [ "$status" -eq 0 ]
    # By default run leaves out empty lines in ${lines[@]}. Use run --keep-empty-lines to retain them.
    [[ "${lines[1]}" =~ ^Usage:  ]]
    echo "# DEBUG: ${lines[1]}" >&3
}

# 3
@test "exec_kubectl_cpbase64_local_basic" {
    run kubectl-cpbase64 -d /tmp/foo cpbase64/cpbase64-pod:/tmp/bar1
    [ "$status" -eq 0 ]
    for i in `seq 0 "${#lines[@]}"`; do echo "# DEBUG: ${lines[$i]}" >&3; done
    sha1sum /tmp/foo | sed 's|^|# DEBUG: LOCAL - |g' >&3
    kubectl exec -i cpbase64-pod -n cpbase64 -- sha1sum /tmp/bar1 | sed 's|^|# DEBUG: REMOTE - |g' >&3
    [ "$( kubectl exec -i cpbase64-pod -n cpbase64 -- sha1sum /tmp/bar1 | awk '{print $1}')" == "$( sha1sum /tmp/foo | awk '{print $1}')" ]
}

# 4
@test "exec_kubectl_cpbase64_local_basic_with_container" {
    run kubectl-cpbase64 -d /tmp/foo cpbase64/cpbase64-pod:/tmp/bar2 -c cpb64
    [ "$status" -eq 0 ]
    for i in `seq 0 "${#lines[@]}"`; do echo "# DEBUG: ${lines[$i]}" >&3; done
    sha1sum /tmp/foo | sed 's|^|# DEBUG: LOCAL - |g' >&3
    kubectl exec -i cpbase64-pod -n cpbase64 -- sha1sum /tmp/bar2 | sed 's|^|# DEBUG: REMOTE - |g' >&3
    [ "$( kubectl exec -i cpbase64-pod -c cpb64 -n cpbase64 -- sha1sum /tmp/bar2 | awk '{print $1}')" == "$( sha1sum /tmp/foo | awk '{print $1}')" ]
}

# 5
@test "exec_kubectl_cpbase64_remote_basic" {
    run kubectl-cpbase64 -d cpbase64/cpbase64-pod:/usr/bin/env /tmp/bar1
    [ "$status" -eq 0 ]
    for i in `seq 0 "${#lines[@]}"`; do echo "# DEBUG: ${lines[$i]}" >&3; done
    kubectl exec -i cpbase64-pod -n cpbase64 -- sha1sum /usr/bin/env | sed 's|^|# DEBUG: REMOTE - |g' >&3
    sha1sum /tmp/bar1 | sed 's|^|# DEBUG: LOCAL - |g' >&3
    [ "$( kubectl exec -i cpbase64-pod -n cpbase64 -- sha1sum /usr/bin/env | awk '{print $1}')" == "$( sha1sum /tmp/bar1 | awk '{print $1}')" ]
}

# 6
@test "exec_kubectl_cpbase64_remote_basic_with_container" {
    run kubectl-cpbase64 -d cpbase64/cpbase64-pod:/usr/bin/env /tmp/bar2 -c cpb64
    [ "$status" -eq 0 ]
    for i in `seq 0 "${#lines[@]}"`; do echo "# DEBUG: ${lines[$i]}" >&3; done
    kubectl exec -i cpbase64-pod -c cpb64 -n cpbase64 -- sha1sum /usr/bin/env | sed 's|^|# DEBUG: REMOTE - |g' >&3
    sha1sum /tmp/bar2 | sed 's|^|# DEBUG: LOCAL - |g' >&3
    [ "$( kubectl exec -i cpbase64-pod -c cpb64 -n cpbase64 -- sha1sum /usr/bin/env | awk '{print $1}')" == "$( sha1sum /tmp/bar2 | awk '{print $1}')" ]
}

#### local -> remote - : in file name
# 7
@test "exec_kubectl_cpbase64_local_dot_to_remote_folder" {
    run kubectl-cpbase64 -d -l '/tmp/foo:123:text.txt' -r cpbase64/cpbase64-pod:/tmp/ -c cpb64
    [ "$status" -eq 0 ]
    for i in `seq 0 "${#lines[@]}"`; do echo "# DEBUG: ${lines[$i]}" >&3; done
    sha1sum '/tmp/foo:123:text.txt' | sed 's|^|# DEBUG: LOCAL - |g' >&3
    kubectl exec -i cpbase64-pod -n cpbase64 -- sha1sum '/tmp/foo:123:text.txt' | sed 's|^|# DEBUG: REMOTE - |g' >&3
    [ "$( kubectl exec -i cpbase64-pod -c cpb64 -n cpbase64 -- sha1sum '/tmp/foo:123:text.txt' | awk '{print $1}')" == "$( sha1sum '/tmp/foo:123:text.txt' | awk '{print $1}')" ]
}

# 8
@test "exec_kubectl_cpbase64_local_dot_to_remote_dot" {
    run kubectl-cpbase64 -d -l '/tmp/foo:123:text.txt' -r 'cpbase64/cpbase64-pod:/tmp/foo:456:text.txt' -c cpb64
    [ "$status" -eq 0 ]
    for i in `seq 0 "${#lines[@]}"`; do echo "# DEBUG: ${lines[$i]}" >&3; done
    sha1sum '/tmp/foo:123:text.txt' | sed 's|^|# DEBUG: LOCAL - |g' >&3
    kubectl exec -i cpbase64-pod -n cpbase64 -- sha1sum '/tmp/foo:456:text.txt' | sed 's|^|# DEBUG: REMOTE - |g' >&3
    [ "$( kubectl exec -i cpbase64-pod -c cpb64 -n cpbase64 -- sha1sum '/tmp/foo:456:text.txt' | awk '{print $1}')" == "$( sha1sum '/tmp/foo:123:text.txt' | awk '{print $1}')" ]
}

#### remote -> local - : in file name
# 9
@test "exec_kubectl_cpbase64_remote_dot_to_local_folder" {
    # - file -r 'cpbase64/cpbase64-pod:/tmp/foo:456:text.txt' exists from test 8
    run kubectl-cpbase64 -d -r 'cpbase64/cpbase64-pod:/tmp/foo:456:text.txt' -l /tmp/ -c cpb64
    [ "$status" -eq 0 ]
    for i in `seq 0 "${#lines[@]}"`; do echo "# DEBUG: ${lines[$i]}" >&3; done
    kubectl exec -i cpbase64-pod -n cpbase64 -- sha1sum '/tmp/foo:456:text.txt' | sed 's|^|# DEBUG: REMOTE - |g' >&3
    sha1sum '/tmp/foo:456:text.txt' | sed 's|^|# DEBUG: LOCAL - |g' >&3
    [ "$( kubectl exec -i cpbase64-pod -c cpb64 -n cpbase64 -- sha1sum '/tmp/foo:456:text.txt' | awk '{print $1}')" == "$( sha1sum '/tmp/foo:456:text.txt' | awk '{print $1}')" ]
}

# 10
@test "exec_kubectl_cpbase64_remote_dot_to_local_dot" {
    # - file -r 'cpbase64/cpbase64-pod:/tmp/foo:456:text.txt' exists from test 8
    run kubectl-cpbase64 -d -r 'cpbase64/cpbase64-pod:/tmp/foo:456:text.txt' -l '/tmp/foo:789:text.txt' -c cpb64
    [ "$status" -eq 0 ]
    for i in `seq 0 "${#lines[@]}"`; do echo "# DEBUG: ${lines[$i]}" >&3; done
    kubectl exec -i cpbase64-pod -n cpbase64 -- sha1sum '/tmp/foo:456:text.txt' | sed 's|^|# DEBUG: REMOTE - |g' >&3
    sha1sum '/tmp/foo:789:text.txt' | sed 's|^|# DEBUG: LOCAL - |g' >&3
    [ "$( kubectl exec -i cpbase64-pod -c cpb64 -n cpbase64 -- sha1sum '/tmp/foo:456:text.txt' | awk '{print $1}')" == "$( sha1sum '/tmp/foo:789:text.txt' | awk '{print $1}')" ]
}
