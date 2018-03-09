let r_fd=${BASHIT_R_FD:-4}
let w_fd=${BASHIT_W_FD:-5}

function __bashit_write() {
  builtin echo 1>&$w_fd $@
}

function __bashit_read() {
  builtin read -u $r_fd $@
}

function __bashit_run_stub() {
  local body_file
  local name=$1

  shift 1

  __bashit_write $name $@
  __bashit_write "</bashit::stub>"
  __bashit_read  body_file
  __bashit_write "</bashit::stub-body>"

  . "${body_file}" $@
}
