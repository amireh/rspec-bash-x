__rspec_bash_stub_body=""

let r_fd=${BASHIT_R_FD:-4}
let w_fd=${BASHIT_W_FD:-5}

function __rspec_bash_write() {
  builtin echo 1>&$w_fd $@
}

function __rspec_bash_read() {
  builtin read -u $r_fd $@
}

function __rspec_bash_retrieve_stub() {
  local name=$1

  builtin shift 1

  __rspec_bash_write $name $@
  __rspec_bash_write "</rspec_bash::stub>"
  __rspec_bash_read  __rspec_bash_stub_body
  __rspec_bash_write "</rspec_bash::stub-body>"

  builtin test -s "${__rspec_bash_stub_body}"
}

function __rspec_bash_run_stub() {
  __rspec_bash_retrieve_stub $@

  builtin . "${__rspec_bash_stub_body}" $@
}

function test() {
  if __rspec_bash_retrieve_stub "conditional_expr" $@; then
    builtin . "${__rspec_bash_stub_body}" $@
  else
    builtin test $@
  fi
}

function [()(
  local without_bracket="${@:1:$(($#-1))}"

  if __rspec_bash_retrieve_stub "conditional_expr" "${without_bracket[@]}"; then
    builtin . "${__rspec_bash_stub_body}" "${without_bracket[@]}"
  else
    builtin [ $@
  fi
)