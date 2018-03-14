function test() {
  if __rspec_bash_load_stub 'conditional_expr' "${@}"; then
    builtin . "${__rspec_bash_stub_body}" "${@}"
  else
    builtin test "${@}"
  fi
}

function [() {
  local without_bracket="${@:1:$(($#-1))}"

  if __rspec_bash_load_stub 'conditional_expr' "${without_bracket[@]}"; then
    builtin . "${__rspec_bash_stub_body}" "${without_bracket[@]}"
  else
    builtin [ "${@}"
  fi
}
