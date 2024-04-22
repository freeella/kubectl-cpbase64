#!/usr/bin/env bats

setup() {
    ### config
    # - calculate defaults based on current directory
    FULLNAME=$(realpath ${BATS_TEST_FILENAME})
    BASEDIR=$(dirname ${FULLNAME})
    # make executables in src/ visible to PATH
    PATH="${BASEDIR}/../main:$PATH"
    touch /tmp/foo
    touch '/tmp/foo:123:text.txt'
}

teardown() {
    rm -f /tmp/foo
    rm -f '/tmp/foo:123:text.txt'
}

#### successful tests
@test "exec_kubectl_cpbase64_version" {
    run kubectl-cpbase64 version
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ^Version:  ]]
}

@test "exec_kubectl_cpbase64_help" {
    run kubectl-cpbase64 help
    [ "$status" -eq 0 ]
    # By default run leaves out empty lines in ${lines[@]}. Use run --keep-empty-lines to retain them.
    [[ "${lines[1]}" =~ ^Usage:  ]]
}

@test "exec_kubectl_cpbase64_-h" {
    run kubectl-cpbase64 -h
    [ "$status" -eq 0 ]
    # By default run leaves out empty lines in ${lines[@]}. Use run --keep-empty-lines to retain them.
    [[ "${lines[1]}" =~ ^Usage:  ]]
}

@test "exec_kubectl_cpbase64_--help" {
    run kubectl-cpbase64 --help
    [ "$status" -eq 0 ]
    # By default run leaves out empty lines in ${lines[@]}. Use run --keep-empty-lines to retain them.
    [[ "${lines[1]}" =~ ^Usage:  ]]
}

@test "exec_kubectl_cpbase64_remote_basic" {
    run kubectl-cpbase64 --test -d pod1:/tmp/foo /tmp/bar
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ^"DEBUG: Found LOCAL_FILE:"  ]]
    [[ "${lines[1]}" =~ ^";LOCAL_FILE="  ]]
}

@test "exec_kubectl_cpbase64_remote_pod1tmpfoo_tmpbar" {
    run kubectl-cpbase64 --test pod1:/tmp/foo /tmp/bar
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/bar;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/foo;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_remote_ns1_pod1tmpfoo_tmpbar" {
    run kubectl-cpbase64 --test ns1/pod1:/tmp/foo /tmp/bar
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/bar;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=ns1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/foo;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_remote_ns1_pod1tmpfoo_tmpbar_container1" {
    run kubectl-cpbase64 --test ns1/pod1:/tmp/foo /tmp/bar -c container1
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/bar;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=ns1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/foo;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=container1;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_remote_pod1tmpfoo_tmpbar_container1" {
    run kubectl-cpbase64 --test pod1:/tmp/foo /tmp/bar -c container1
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/bar;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/foo;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=container1;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_local_basic" {
    run kubectl-cpbase64 --test -d /tmp/foo pod1:/tmp/bar
    [ "$status" -eq 0 ]
}

@test "exec_kubectl_cpbase64_local_tmpfoo_pod1tmpbar" {
    run kubectl-cpbase64 --test /tmp/foo pod1:/tmp/bar
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/foo;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/bar;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=1;" ]]
}

@test "exec_kubectl_cpbase64_local_tmpfoo_ns3_pod1tmpbar" {
    run kubectl-cpbase64 --test /tmp/foo ns3/pod1:/tmp/bar
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/foo;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=ns3;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/bar;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=1;" ]]
}

@test "exec_kubectl_cpbase64_local_tmpfoo_ns3_pod1tmpbar_cont4" {
    run kubectl-cpbase64 --test /tmp/foo ns3/pod1:/tmp/bar -c cont4
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/foo;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=ns3;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/bar;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=cont4;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=1;" ]]
}

@test "exec_kubectl_cpbase64_local_tmpfoo_pod1tmpbar_cont4" {
    run kubectl-cpbase64 --test /tmp/foo pod1:/tmp/bar -c cont4
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/foo;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/bar;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=cont4;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=1;" ]]
}

@test "exec_kubectl_cpbase64_remote_pod1tmpfoo1_tmpdir1" {
    run kubectl-cpbase64 --test pod1:/tmp/foo1 /tmp/
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/foo1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/foo1;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_remote_pod1tmpfoo1_tmpdir2" {
    run kubectl-cpbase64 --test pod1:/tmp/foo1 /tmp
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/foo1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/foo1;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_remote_pod1tmpfoo_pwd" {
    run kubectl-cpbase64 --test pod1:/tmp/foo .
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=./foo;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/foo;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_local_tmpfoo_pod1tmpdir1" {
    run kubectl-cpbase64 --test /tmp/foo pod1:/tmp/
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/foo;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/foo;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=1;" ]]
}

@test "exec_kubectl_cpbase64_local_tmpfoo_pod1pwd" {
    run kubectl-cpbase64 --test /tmp/foo pod1:.
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/foo;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=foo;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=1;" ]]
}

@test "exec_kubectl_cpbase64_local_tmpfoo_ns3_pod1tmpbar:123:text.txt" {
    run kubectl-cpbase64 --test /tmp/foo -r ns3/pod1:/tmp/bar:123:text.txt
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/foo;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=ns3;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/bar:123:text.txt;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=1;" ]]
}

@test "exec_kubectl_cpbase64_local_tmpfoo:123:text.txt_ns3_pod1tmpbar" {
    run kubectl-cpbase64 --test -l /tmp/foo:123:text.txt ns3/pod1:/tmp/bar
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/foo:123:text.txt;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=ns3;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/bar;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=1;" ]]
}

@test "exec_kubectl_cpbase64_local_tmpfoo:123:_ns3_pod1tmpbar:456:" {
    run kubectl-cpbase64 --test --local /tmp/foo:123:text.txt --remote ns3/pod1:/tmp/bar:456:something.zip
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ ";LOCAL_FILE=/tmp/foo:123:text.txt;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_NS=ns3;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_POD=pod1;" ]]
    [[ "${lines[0]}" =~ ";KUBERNETES_FILE=/tmp/bar:456:something.zip;" ]]
    [[ "${lines[0]}" =~ ";CONTAINER_NAME=;" ]]
    [[ "${lines[0]}" =~ ";COPY_FROM_LOCAL=1;" ]]
}

### negaive tests
@test "exec_kubectl_cpbase64_local_2times" {
    run kubectl-cpbase64 --test --local /tmp/foo:123:text.txt --remote ns3/pod1:/tmp/bar:456:something.zip /tmp/foo.txt
    [ "$status" -eq 26 ]
}

@test "exec_kubectl_cpbase64_remote_2times" {
    run kubectl-cpbase64 --test /tmp/foo --remote ns3/pod1:/tmp/bar:456:something.zip pod1:/tmp/bar
    [ "$status" -eq 26 ]
}

@test "exec_kubectl_cpbase64_unknown_option" {
    run kubectl-cpbase64 --test /tmp/foo pod1:/tmp/bar --no-known-option
    [ "$status" -eq 30 ]
    [[ "${lines[0]}" =~ ^"ERROR: Unexpected argument: --no-known-option" ]]
}

@test "exec_kubectl_cpbase64_local_file_not_existing" {
    run kubectl-cpbase64 --test -d /tmp/foo_not_exists pod1:/tmp/bar
    [ "$status" -eq 27 ]
}

@test "exec_kubectl_cpbase64_local_file_is_directory" {
    run kubectl-cpbase64 --test -d /tmp pod1:/tmp/bar
    [ "$status" -eq 29 ]
}

@test "exec_kubectl_cpbase64_remote_to_local_file_existing" {
    run kubectl-cpbase64 --test -d pod1:/tmp/foo /tmp/foo
    [ "$status" -eq 28 ]
}