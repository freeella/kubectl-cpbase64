#!/usr/bin/env bats

setup() {
    ### config
    # - calculate defaults based on current directory
    FULLNAME=$(realpath ${BATS_TEST_FILENAME})
    BASEDIR=$(dirname ${FULLNAME})
    # make executables in src/ visible to PATH
    PATH="${BASEDIR}/../main:$PATH"
}

@test "exec_kubectl_cpbase64_version" {
    kubectl-cpbase64 version
    [ "$?" -eq 0 ]
}

@test "exec_kubectl_cpbase64_help" {
    kubectl-cpbase64 help
    [ "$?" -eq 0 ]
}

@test "exec_kubectl_cpbase64_-h" {
    kubectl-cpbase64 -h
    [ "$?" -eq 0 ]
}

@test "exec_kubectl_cpbase64_--help" {
    kubectl-cpbase64 --help
    [ "$?" -eq 0 ]
}

@test "exec_kubectl_cpbase64_remote_basic" {
    kubectl-cpbase64 --test -d pod1:/tmp/foo /tmp/bar
    [ "$?" -eq 0 ]
}

@test "exec_kubectl_cpbase64_remote_pod1tmpfoo_tmpbar" {
    TESTRESULT=$( kubectl-cpbase64 --test pod1:/tmp/foo /tmp/bar; echo ";RETURN=$?;" )
    [[ "$TESTRESULT" =~ ";RETURN=0;" ]] &&
    [[ "$TESTRESULT" =~ ";LOCAL_FILE=/tmp/bar;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_NS=;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_POD=pod1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";CONTAINER_NAME=;" ]] &&
    [[ "$TESTRESULT" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_remote_ns1_pod1tmpfoo_tmpbar" {
    TESTRESULT=$( kubectl-cpbase64 --test ns1/pod1:/tmp/foo /tmp/bar; echo ";RETURN=$?;" )
    [[ "$TESTRESULT" =~ ";RETURN=0;" ]] &&
    [[ "$TESTRESULT" =~ ";LOCAL_FILE=/tmp/bar;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_NS=ns1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_POD=pod1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";CONTAINER_NAME=;" ]] &&
    [[ "$TESTRESULT" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_remote_ns1_pod1tmpfoo_tmpbar_container1" {
    TESTRESULT=$( kubectl-cpbase64 --test ns1/pod1:/tmp/foo /tmp/bar -c container1; echo ";RETURN=$?;" )
    [[ "$TESTRESULT" =~ ";RETURN=0;" ]] &&
    [[ "$TESTRESULT" =~ ";LOCAL_FILE=/tmp/bar;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_NS=ns1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_POD=pod1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";CONTAINER_NAME=container1;" ]] &&
    [[ "$TESTRESULT" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_remote_pod1tmpfoo_tmpbar_container1" {
    TESTRESULT=$( kubectl-cpbase64 --test pod1:/tmp/foo /tmp/bar -c container1; echo ";RETURN=$?;" )
    [[ "$TESTRESULT" =~ ";RETURN=0;" ]] &&
    [[ "$TESTRESULT" =~ ";LOCAL_FILE=/tmp/bar;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_NS=;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_POD=pod1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";CONTAINER_NAME=container1;" ]] &&
    [[ "$TESTRESULT" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_local_basic" {
    kubectl-cpbase64 --test -d /tmp/foo pod1:/tmp/bar
    [ "$?" -eq 0 ]
}

@test "exec_kubectl_cpbase64_local_tmpfoo_pod1tmpbar" {
    TESTRESULT=$( kubectl-cpbase64 --test /tmp/foo pod1:/tmp/bar; echo ";RETURN=$?;" )
    [[ "$TESTRESULT" =~ ";RETURN=0;" ]] &&
    [[ "$TESTRESULT" =~ ";LOCAL_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_NS=;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_POD=pod1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_FILE=/tmp/bar;" ]] &&
    [[ "$TESTRESULT" =~ ";CONTAINER_NAME=;" ]] &&
    [[ "$TESTRESULT" =~ ";COPY_FROM_LOCAL=1;" ]]
}

@test "exec_kubectl_cpbase64_local_tmpfoo_ns3_pod1tmpbar" {
    TESTRESULT=$( kubectl-cpbase64 --test /tmp/foo ns3/pod1:/tmp/bar; echo ";RETURN=$?;" )
    [[ "$TESTRESULT" =~ ";RETURN=0;" ]] &&
    [[ "$TESTRESULT" =~ ";LOCAL_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_NS=ns3;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_POD=pod1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_FILE=/tmp/bar;" ]] &&
    [[ "$TESTRESULT" =~ ";CONTAINER_NAME=;" ]] &&
    [[ "$TESTRESULT" =~ ";COPY_FROM_LOCAL=1;" ]]
}

@test "exec_kubectl_cpbase64_local_tmpfoo_ns3_pod1tmpbar_cont4" {
    TESTRESULT=$( kubectl-cpbase64 --test /tmp/foo ns3/pod1:/tmp/bar -c cont4; echo ";RETURN=$?;" )
    [[ "$TESTRESULT" =~ ";RETURN=0;" ]] &&
    [[ "$TESTRESULT" =~ ";LOCAL_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_NS=ns3;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_POD=pod1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_FILE=/tmp/bar;" ]] &&
    [[ "$TESTRESULT" =~ ";CONTAINER_NAME=cont4;" ]] &&
    [[ "$TESTRESULT" =~ ";COPY_FROM_LOCAL=1;" ]]
}

@test "exec_kubectl_cpbase64_local_tmpfoo_pod1tmpbar_cont4" {
    TESTRESULT=$( kubectl-cpbase64 --test /tmp/foo pod1:/tmp/bar -c cont4; echo ";RETURN=$?;" )
    [[ "$TESTRESULT" =~ ";RETURN=0;" ]] &&
    [[ "$TESTRESULT" =~ ";LOCAL_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_NS=;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_POD=pod1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_FILE=/tmp/bar;" ]] &&
    [[ "$TESTRESULT" =~ ";CONTAINER_NAME=cont4;" ]] &&
    [[ "$TESTRESULT" =~ ";COPY_FROM_LOCAL=1;" ]]
}

@test "exec_kubectl_cpbase64_remote_pod1tmpfoo_tmpdir1" {
    TESTRESULT=$( kubectl-cpbase64 --test pod1:/tmp/foo /tmp/; echo ";RETURN=$?;" )
    [[ "$TESTRESULT" =~ ";RETURN=0;" ]] &&
    [[ "$TESTRESULT" =~ ";LOCAL_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_NS=;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_POD=pod1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";CONTAINER_NAME=;" ]] &&
    [[ "$TESTRESULT" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_remote_pod1tmpfoo_tmpdir2" {
    TESTRESULT=$( kubectl-cpbase64 --test pod1:/tmp/foo /tmp; echo ";RETURN=$?;" )
    [[ "$TESTRESULT" =~ ";RETURN=0;" ]] &&
    [[ "$TESTRESULT" =~ ";LOCAL_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_NS=;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_POD=pod1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";CONTAINER_NAME=;" ]] &&
    [[ "$TESTRESULT" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_remote_pod1tmpfoo_pwd" {
    TESTRESULT=$( kubectl-cpbase64 --test pod1:/tmp/foo .; echo ";RETURN=$?;" )
    [[ "$TESTRESULT" =~ ";RETURN=0;" ]] &&
    [[ "$TESTRESULT" =~ ";LOCAL_FILE=./foo;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_NS=;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_POD=pod1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";CONTAINER_NAME=;" ]] &&
    [[ "$TESTRESULT" =~ ";COPY_FROM_LOCAL=0;" ]]
}

@test "exec_kubectl_cpbase64_local_tmpfoo_pod1tmpdir1" {
    TESTRESULT=$( kubectl-cpbase64 --test /tmp/foo pod1:/tmp/; echo ";RETURN=$?;" )
    [[ "$TESTRESULT" =~ ";RETURN=0;" ]] &&
    [[ "$TESTRESULT" =~ ";LOCAL_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_NS=;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_POD=pod1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";CONTAINER_NAME=;" ]] &&
    [[ "$TESTRESULT" =~ ";COPY_FROM_LOCAL=1;" ]]
}

@test "exec_kubectl_cpbase64_local_tmpfoo_pod1pwd" {
    TESTRESULT=$( kubectl-cpbase64 --test /tmp/foo pod1:.; echo ";RETURN=$?;" )
    [[ "$TESTRESULT" =~ ";RETURN=0;" ]] &&
    [[ "$TESTRESULT" =~ ";LOCAL_FILE=/tmp/foo;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_NS=;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_POD=pod1;" ]] &&
    [[ "$TESTRESULT" =~ ";KUBERNETES_FILE=foo;" ]] &&
    [[ "$TESTRESULT" =~ ";CONTAINER_NAME=;" ]] &&
    [[ "$TESTRESULT" =~ ";COPY_FROM_LOCAL=1;" ]]
}

{
    # TODO - missing unit tests
cat <<EOF
 # tests with -r / --remote
 # tests with -l / --local
 # tests with -r + -l
 # tests with -r / -l and : inside file names
 # tests with too many / duplicate options
 # - wrong parameters
 # - two remote locations
 # - two local locations
EOF

} >/dev/null