export __rspec_bash_stub_body=""

function __rspec_bash_read() {
  local fd=${BASHIT_R_FD:-4}

  builtin read -u $fd "${@}"
}

function __rspec_bash_write() {
  local fd=${BASHIT_W_FD:-5}

  builtin echo 1>&$fd "${@}"
}

function __rspec_bash_load_stub() {
  local name="${1}"

  builtin shift 1

  __rspec_bash_write "${name}" "${@}"
  __rspec_bash_write "</rspec_bash::stub>"
  __rspec_bash_read  __rspec_bash_stub_body
  __rspec_bash_write "</rspec_bash::stub-body>"

  builtin test -s "${__rspec_bash_stub_body}"
}

function __rspec_bash_call_stubbed() {
  __rspec_bash_load_stub "${@}"

  builtin . "${__rspec_bash_stub_body}" "${@}"
}
