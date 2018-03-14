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
  local arg
  local message
  local fragments=(
    "1 ${name}"
    "3 $(caller 1)"
    "3 $(caller 2)"
    "3 $(caller 3)"
  )

  builtin shift 1

  for arg in "${@}"; do
    fragments+=("2 ${arg}")
  done

  message="${#fragments[@]};"

  for fragment in "${fragments[@]}"; do
    message="${message}${#fragment};${fragment}"
  done

  __rspec_bash_write "${message}"
  __rspec_bash_write "<rspec-bash::req>"

  __rspec_bash_read  __rspec_bash_stub_body
  __rspec_bash_write "<rspec-bash::ack>"

  builtin test -s "${__rspec_bash_stub_body}"
}

function __rspec_bash_call_stubbed() {
  __rspec_bash_load_stub "${@}"

  builtin shift 1

  builtin . "${__rspec_bash_stub_body}" "${@}"
}
