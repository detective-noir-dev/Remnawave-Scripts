#!/usr/bin/env bats
# iso_to_flag: код страны ISO → эмодзи-флаг

load helpers

setup() { use_module ids; }

@test "iso_to_flag: RU → 🇷🇺" {
    run iso_to_flag RU
    [ "$status" -eq 0 ]
    [ "$output" = "🇷🇺" ]
}

@test "iso_to_flag: регистр не важен" {
    run iso_to_flag us
    [ "$output" = "🇺🇸" ]
    [ "$output" = "$(iso_to_flag US)" ]
}

@test "iso_to_flag: флаг состоит из двух символов" {
    run iso_to_flag DE
    [ "${#output}" -eq 2 ]
}
