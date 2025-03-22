#!/usr/bin/env bats

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  PROMPT_COMMAND=''
  PS1=''
  set -o nounset
}

# Example of how to use the script command to run a bash shell with a custom prompt and see the full transcript
# bash-5.1# printf "" | script -q -E never -c "PROMPT_COMMAND='echo PROMPT' PS1='PLAYSTATIONONE' bash -i" /dev/null
# PROMPT
# >>>$
# exit

scripted_bash_run() {
  echo "$1" | script -q -E never -c "PS1='PLAYSTATIONONE' bash -i" /dev/null | sed -r 's/\x1b\[\?2004[hl]//g' | tr -d '\r\n'
}

# Santity checking for our setup
@test "simple PROMPT_COMMAND" {
  # output=$(echo ". /suite/definitions/pc_simple; exit 2> /dev/null" | script -q -E never -c "PS1='PLAYSTATIONONE' bash -i" /dev/null | sed -r 's/\x1b\[\?2004[hl]//g' | tr -d '\r\n')
  run scripted_bash_run ". /suite/definitions/pc_simple; exit 2> /dev/null"
  assert_output "PLAYSTATIONONE"
}

# Santity checking for our setup
@test "array PROMPT_COMMAND" {
  run scripted_bash_run ". /suite/definitions/pc_array; exit 2> /dev/null"
  assert_output "PLAYSTATIONONE"
}

# When hook command doesn't support an array, it still works with a scalar PROMPT_COMMAND
@test "supports scalar PROMPT_COMMAND" {
  run scripted_bash_run ". /suite/definitions/pc_simple; . /suite/definitions/hook_no_array_support; echo ''; (exit 2> /dev/null)"
  assert_success
}

# Reproduce issue when shell hook does not consider PROMPT_COMMAND as an array
@test "without array support produces a failure" {
  run scripted_bash_run ". /suite/definitions/pc_array; . /suite/definitions/hook_no_array_support; echo ''; (exit 2> /dev/null)"
  assert_output --partial "printf: usage: printf [-v var] format [arguments]"
  assert_output --partial "command not found"
}

@test "casing on whether HOOK_PROMPT is an array handles a simple prompt correctly" {
  run scripted_bash_run ". /suite/definitions/pc_simple; . /suite/definitions/hook; echo ''; (exit 2> /dev/null)"
  assert_output --partial "SIMPLEPROMPT"
  assert_output --partial "shpool:yehaw"
  assert_output --partial "PLAYSTATIONONE"
  assert_output --partial "exit"
}

@test "casing on whether HOOK_PROMPT is an array handles an array prompt correctly" {
  run scripted_bash_run ". /suite/definitions/pc_array; . /suite/definitions/hook; echo ''; (exit 2> /dev/null)"
  assert_output --partial "PROMPT A"
  assert_output --partial "PROMPT B"
  assert_output --partial "shpool:yehaw"
  assert_output --partial "PLAYSTATIONONE"
  assert_output --partial "exit"
}