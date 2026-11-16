#!/usr/bin/env bats
# _clean_human: килобайты → человекочитаемый размер (границы: > 1024 KB → MB, > 1048576 KB → GB)

load helpers

setup() { use_module cleaner; }

@test "_clean_human: малые значения остаются в KB" {
    run _clean_human 0
    [ "$output" = "0 KB" ]
    run _clean_human 512
    [ "$output" = "512 KB" ]
}

@test "_clean_human: ровно 1024 KB ещё KB" {
    run _clean_human 1024
    [ "$output" = "1024 KB" ]
}

@test "_clean_human: мегабайты" {
    run _clean_human 2048
    [ "$output" = "2.0 MB" ]
    run _clean_human 1536
    [ "$output" = "1.5 MB" ]
}

@test "_clean_human: гигабайты" {
    run _clean_human 2097152
    [ "$output" = "2.0 GB" ]
}
