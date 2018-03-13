__bashit_stub_body=""

let r_fd=${BASHIT_R_FD:-4}
let w_fd=${BASHIT_W_FD:-5}

function __bashit_write() {
  builtin echo 1>&$w_fd $@
}

function __bashit_read() {
  builtin read -u $r_fd $@
}

function __bashit_retrieve_stub() {
  local name=$1

  shift 1

  __bashit_write $name $@
  __bashit_write "</bashit::stub>"
  __bashit_read  __bashit_stub_body
  __bashit_write "</bashit::stub-body>"

  builtin test -z "${__bashit_stub_body}"
}

function __bashit_run_stub() {
  __bashit_retrieve_stub $@

  . "${__bashit_stub_body}" $@
}

function test() {
  __bashit_retrieve_stub "conditional_expr" $@

  if builtin [ -z "${__bashit_stub_body}" ]
  then
    builtin test $@
  else
    . "${__bashit_stub_body}" $@
  fi
}

function [()(
  local without_bracket="${@:1:$(($#-1))}"

  __bashit_retrieve_stub "conditional_expr" "${without_bracket[@]}"

  if builtin [ -z "${__bashit_stub_body}" ]
  then
    builtin [ $@
  else

    . "${__bashit_stub_body}" "${without_bracket[@]}"
  fi
)
