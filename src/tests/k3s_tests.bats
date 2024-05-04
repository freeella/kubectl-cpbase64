#!/usr/bin/env bats

setup() {
    ### config
    # - calculate defaults based on current directory
    FULLNAME=$(realpath ${BATS_TEST_FILENAME})
    BASEDIR=$(dirname ${FULLNAME})
    # make executables in src/ visible to PATH
    PATH="${BASEDIR}/../main:$PATH"
    cp $( which kubectl ) /tmp/foo
    sha1sum /tmp/foo                | sed 's|^ |#|' >&3
    cp $( which kubectl ) '/tmp/foo:123:text.txt'
    sha1sum '/tmp/foo:123:text.txt' | sed 's|^ |#|' >&3
}

teardown() {
    rm -f /tmp/foo
    rm -f '/tmp/foo:123:text.txt'
    rm -f /tmp/bar*
}

#### successful tests
@test "exec_kubectl_cpbase64_version" {
    run kubectl-cpbase64 version
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ^Version:  ]]
    for i in ${lines[@]}; do echo '# DEBUG: $i' >&3; done
}

@test "exec_kubectl_cpbase64_help" {
    run kubectl-cpbase64 help
    [ "$status" -eq 0 ]
    # By default run leaves out empty lines in ${lines[@]}. Use run --keep-empty-lines to retain them.
    [[ "${lines[1]}" =~ ^Usage:  ]]
    do echo '# DEBUG: ${lines[1]}' >&3
}

@test "exec_kubectl_cpbase64_local_basic" {
    run kubectl-cpbase64 -d /tmp/foo cpbase64/cpbase64-pod:/tmp/bar
    [ "$status" -eq 0 ]
    # TODO - check remote file and local file are binary the same
    for i in ${lines[@]}; do echo '# DEBUG: $i' >&3; done
}

@test "exec_kubectl_cpbase64_local_basic_with_container" {
    run kubectl-cpbase64 -d /tmp/foo cpbase64/cpbase64-pod:/tmp/bar -c cpb64
    [ "$status" -eq 0 ]
    # TODO - check remote file and local file are binary the same
    for i in ${lines[@]}; do echo '# DEBUG: $i' >&3; done
}

@test "exec_kubectl_cpbase64_remote_basic" {
    run kubectl-cpbase64 -d cpbase64/cpbase64-pod:/usr/bin/env /tmp/bar1
    [ "$status" -eq 0 ]
    for i in ${lines[@]}; do echo '# DEBUG: $i' >&3; done
    # TODO - create test file on pod; check remote file and local file are binary the same
}

@test "exec_kubectl_cpbase64_remote_basic_with_container" {
    run kubectl-cpbase64 -d cpbase64/cpbase64-pod:/usr/bin/env /tmp/bar2 -c cpb64
    [ "$status" -eq 0 ]
    for i in ${lines[@]}; do echo '# DEBUG: $i' >&3; done
    # TODO - create test file on pod; check remote file and local file are binary the same
}



